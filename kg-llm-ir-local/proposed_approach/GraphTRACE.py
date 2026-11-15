"""GraphTRACE: entity extraction, subquery generation, KG path retrieval and
path-based answering.

Originally this script only worked against OpenAI's cloud API (model
"gpt-4o-mini"). It is adapted to run against a **local Strata model server**
(OpenAI-compatible endpoint, default http://127.0.0.1:<port>/v1), and the cloud
model is still available through `--cloud`.

What changed for the local model:
- base_url + api_key are auto-discovered from the running Strata instance
  (~/.strata/data/native-instances/*.json), overridable through .env
  (STRATA_BASE_URL / STRATA_API_KEY / STRATA_MODEL)
- the model name is read from /v1/models instead of being hard-coded
- entity extraction and subquery generation request JSON first, then fall back
  to a plain reply plus loose-JSON repair; results are validated as non-empty
  string lists and retried (local servers emit reasoning before the JSON, so
  the token budget must be larger than for gpt-4o-mini)
- Neo4j credentials come from .env / CLI flags instead of being hard-coded
- results are appended row by row to ../evaluation/results/<output>.csv, so an
  interrupted run resumes where it stopped (local generation is ~13 tokens/s,
  a full dataset takes hours)

Usage:
    python GraphTRACE.py --dataset Converging --limit 2      # local model smoke test
    python GraphTRACE.py --cloud --dataset Linear            # original cloud path
"""

import os
import re
import sys
import csv
import json
import glob
import time
import argparse

import pandas as pd
from openai import OpenAI
from sentence_transformers import CrossEncoder
from neo4j import GraphDatabase

try:
    from dotenv import load_dotenv
    load_dotenv()
except ModuleNotFoundError:
    # python-dotenv is optional: read KEY=VALUE pairs from .env manually
    def load_dotenv(path=".env"):
        for candidate in (path, os.path.join("..", path)):
            if not os.path.exists(candidate):
                continue
            for line in open(candidate, encoding="utf-8"):
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    load_dotenv()

RESULT_COLUMNS = ["query", "paths", "subqueries", "entities",
                  "missing_entities", "answer"]

# ---------------------------------------------------------------------------
# Local model (Strata) client
# ---------------------------------------------------------------------------


def discover_strata_instance():
    """Return (base_url, api_key, model) from the running Strata instance config."""
    cfg_dir = os.path.expanduser("~/.strata/data/native-instances")
    for path in sorted(glob.glob(os.path.join(cfg_dir, "*.json"))):
        try:
            with open(path, encoding="utf-8") as f:
                cfg = json.load(f)
        except Exception:
            continue
        port = cfg.get("port")
        api_key = cfg.get("api_key")
        if not port:
            continue
        host = cfg.get("host") or "127.0.0.1"
        base_url = f"http://{host}:{port}/v1"
        yield base_url, api_key, cfg.get("model_name")


def build_client(use_cloud=False, base_url=None, api_key=None, model=None):
    """Build an OpenAI client for the local Strata server (default) or the cloud."""
    if use_cloud:
        client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        return client, model or os.getenv("LLM_MODEL", "gpt-4o-mini")

    base_url = base_url or os.getenv("STRATA_BASE_URL")
    api_key = api_key or os.getenv("STRATA_API_KEY")
    model = model or os.getenv("STRATA_MODEL")

    if not base_url:
        for url, key, cfg_model in discover_strata_instance():
            base_url, api_key = url, key
            model = model or cfg_model
            break

    if not base_url:
        raise RuntimeError(
            "No local Strata server found. Start Strata, set STRATA_BASE_URL and "
            "STRATA_API_KEY in .env, or run with --cloud."
        )

    client = OpenAI(base_url=base_url, api_key=api_key or "local", timeout=1200.0)

    if not model:
        try:
            models = client.models.list()
            ids = [m.id for m in models.data]
            model = ids[0] if ids else None
        except Exception as e:
            print(f"Could not list models from {base_url}: {e}")
            model = None

    if not model:
        raise RuntimeError(
            "No model available at the local endpoint. Start/serve a model in "
            "Strata and pass --model <name>."
        )
    print(f"Local model: {model} @ {base_url}")
    return client, model


# ---------------------------------------------------------------------------
# Robust replies for local models
# ---------------------------------------------------------------------------

RAW_DEBUG_LOG = os.getenv("RAW_DEBUG_LOG")


def debug_dump(tag, text):
    if RAW_DEBUG_LOG:
        with open(RAW_DEBUG_LOG, "a", encoding="utf-8") as f:
            f.write(f"\n===== {tag} =====\n{str(text)}\n")


def strip_think(text):
    """Remove chain-of-thought fences some local models emit inside content."""
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.S)
    return text.strip()


def extract_json(text):
    """Best-effort extraction of a JSON object from a chat completion."""
    if not text:
        return None
    t = strip_think(text)
    fence = re.search(r"```(?:json)?\s*(.*?)```", t, re.S)
    if fence:
        t = fence.group(1).strip()
    try:
        obj = json.loads(t)
        return obj if isinstance(obj, dict) else {"value": obj}
    except Exception:
        pass

    start = t.find("{")
    if start == -1:
        return None
    depth = 0
    end = None
    for i in range(start, len(t)):
        c = t[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = i
                break
    cand = t[start:end + 1] if end is not None else t[start:] + "}" * depth
    cand = re.sub(r",\s*([}\]])", r"\1", cand)
    try:
        obj = json.loads(cand)
        return obj if isinstance(obj, dict) else {"value": obj}
    except Exception:
        return None


def clean_list(data, key):
    """Return a clean list of strings from a parsed reply; None if unusable."""
    if not isinstance(data, dict):
        return None
    raw = data.get(key)
    if raw is None and key == "entities":
        raw = data.get("entity")
    if isinstance(raw, str):
        raw = [raw]
    if not isinstance(raw, list):
        return None
    items = [str(x).strip() for x in raw if str(x).strip()]
    return items or None


def chat_text(client, model, system_prompt, prompt, max_tokens, temperature):
    """Plain completion; content is preferred, reasoning as the fallback."""
    response = client.chat.completions.create(
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        model=model,
        temperature=temperature,
        max_tokens=max_tokens,
    )
    msg = response.choices[0].message
    content = msg.content
    if not content:
        content = getattr(msg, "reasoning_content", None)
    debug_dump(f"plain call {model}", {
        "content": content,
        "reasoning": getattr(msg, "reasoning_content", None),
        "finish_reason": response.choices[0].finish_reason,
    })
    if content:
        return strip_think(content)
    return None


def json_chat(client, model, system_prompt, prompt, key, max_tokens,
             temperature, max_attempts=3):
    """Ask for a JSON object with one `key` list. Structured mode first,
    plain text plus loose-JSON repair second, retried up to max_attempts."""
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt},
    ]

    last_error = None
    for attempt in range(1, max_attempts + 1):
        # 1) Structured JSON output (honoured by the Strata server, as by OpenAI)
        try:
            response = client.chat.completions.create(
                messages=messages,
                model=model,
                response_format={"type": "json_object"},
                temperature=temperature,
                max_tokens=max_tokens,
            )
            msg = response.choices[0].message
            data = extract_json(msg.content)
            items = clean_list(data, key)
            if items:
                return items
            last_error = f"reply had no usable '{key}' list: {str(msg.content)[:120]}"
        except Exception as e:
            last_error = f"structured call failed: {type(e).__name__}: {e}"

        # 2) Plain completion + loose JSON extraction
        try:
            content = chat_text(client, model, system_prompt,
                                "\n".join([m["content"] for m in messages[1:]]),
                                max_tokens, temperature)
            data = extract_json(content)
            items = clean_list(data, key)
            if items:
                return items
            last_error = f"reply had no usable '{key}' list: {str(content)[:120]}"
        except Exception as e:
            last_error = f"plain call failed: {type(e).__name__}: {e}"

        # Ask the model to self-correct on the next attempt
        messages.append({"role": "user", "content":
            f"That was not usable ({last_error}). Reply with ONLY one JSON object "
            f'{{"{key}": [...]}} of {key}, no prose, no markdown fences.'})

    print(f"\n  No usable '{key}' reply after {max_attempts} attempts: {last_error}")
    return []


# ---------------------------------------------------------------------------
# Knowledge graph helpers (unchanged)
# ---------------------------------------------------------------------------

def test_connection(driver):
    try:
        with driver.session() as session:
            result = session.run("RETURN 'Neo4j connection successful!' AS message")
            message = result.single()["message"]
            print(f"{message}")
        return True
    except Exception as e:
        print(f"Connection failed: {e}")
        return False


def check_entities_in_kg(entities, driver):
    found_entities = []
    missing_entities = []

    with driver.session() as session:
        for entity in entities:
            query = "MATCH (n) WHERE n.name = $name RETURN n.name"
            result = session.run(query, name=entity)
            records = [record["n.name"] for record in result]

            if records:
                found_entities.append(entity)
            else:
                missing_entities.append(entity)

    return found_entities, missing_entities


def reverse_path(path):
    """Erstellt die gespiegelte Version eines Pfades mit umgekehrten Relationen."""
    reversed_path = []
    for i in range(len(path) - 1, 0, -2):  # Gehe rückwärts durch den Pfad
        reversed_path.append(path[i])  # Knoten hinzufügen
        relation = path[i - 1]

        # Drehe die Richtung um
        if "->" in relation:
            reversed_relation = relation.replace("->", "<-")
        elif "<-" in relation:
            reversed_relation = relation.replace("<-", "->")
        else:
            reversed_relation = relation  # Falls keine Richtung vorhanden ist

        reversed_path.append(reversed_relation)

    reversed_path.append(path[0])  # Letzten Knoten hinzufügen
    return tuple(reversed_path)


def find_paths_between_entities(entities, driver):
    paths = set()

    with driver.session() as session:
        query = """
        MATCH path = allShortestPaths((e1)-[*]-(e2))
        WHERE e1.name IN $entities AND e2.name IN $entities AND e1 <> e2
        RETURN
            [node IN nodes(path) | node.name] AS nodes,
            [rel IN relationships(path) | {
                type: rel.type,
                start: startNode(rel).name,
                end: endNode(rel).name
            }] AS relations
        """
        result = session.run(query, entities=entities)

        for record in result:
            nodes = record["nodes"]
            relations = record["relations"]

            full_path = []
            for i in range(len(relations)):
                full_path.append(nodes[i])

                relation = relations[i]
                relation_type = relation["type"]

                if relation["start"] == nodes[i]:
                    relation_string = f"{relation_type} ->"
                else:
                    relation_string = f"{relation_type} <-"

                full_path.append(relation_string)

            full_path.append(nodes[-1])

            reversed_path = reverse_path(full_path)

            canonical_path = min(tuple(full_path), reversed_path)

            paths.add(canonical_path)

    return [list(p) for p in paths]


def format_path_for_scoring(path):
    formatted_parts = []

    for i in range(0, len(path), 2):
        entity = path[i]  # Aktuelle Entität

        if i + 1 < len(path):  # Falls eine Beziehung existiert
            relation = path[i + 1]
            next_entity = path[i + 2]  # Zielentität

            # Beziehung mit richtiger Richtung formatieren
            if "->" in relation:
                formatted_parts.append(f"{entity} {relation.replace(' ->', '')} {next_entity}")
            elif "<-" in relation:
                formatted_parts.append(f"{next_entity} {relation.replace(' <-', '')} {entity}")

    return ". ".join(formatted_parts)


def rank_paths_by_relevance(subquery, paths, cross_encoder, top_k=3):
    # Formatiere Pfade für das Scoring-Modell
    formatted_paths = [format_path_for_scoring(path) for path in paths]

    # Erstelle Query-Pfad-Paare für das Modell
    query_path_pairs = [(subquery, path) for path in formatted_paths]

    if not query_path_pairs:
        print(f"!!! No Query-Path-Pairs for subquery: {subquery}")
        return []

    # Scoring durch den Cross-Encoder
    scores = cross_encoder.predict(query_path_pairs)

    # Sortiere die Pfade nach ihrem Score
    ranked_paths = sorted(zip(scores, paths), key=lambda x: x[0], reverse=True)

    # Extrahiere die top-k relevantesten Pfade
    top_paths = [path for _, path in ranked_paths[:top_k]]

    return top_paths


# ---------------------------------------------------------------------------
# GraphTRACE pipeline
# ---------------------------------------------------------------------------

def GraphTRACE(QA_df, output_name, client, model, driver, cross_encoder,
              max_entities_tokens=700, max_subquery_tokens=900,
              max_answer_tokens=1000, temperature=0.0, max_attempts=3,
              top_k=3, save=True):
    print("START GraphTRACE()")

    file_path_name = f"../evaluation/results/{output_name}.csv"
    done_queries = set()
    if save:
        if os.path.exists(file_path_name):
            try:
                prev = pd.read_csv(file_path_name)
                done_queries = set(prev["query"].astype(str))
                print(f"Resuming: {len(done_queries)} rows already in {file_path_name}")
            except Exception:
                print(f"Existing {file_path_name} is unreadable; starting fresh")
                os.remove(file_path_name)
        if not os.path.exists(file_path_name):
            os.makedirs(os.path.dirname(file_path_name), exist_ok=True)
            with open(file_path_name, "w", newline="", encoding="utf-8") as f:
                csv.writer(f).writerow(RESULT_COLUMNS)

    system_prompt = """You are an AI that extracts entities relevant for a Knowledge Graph.
    Identify only the main entities from the given user query.
    Respond with a JSON object containing the extracted entities. Example:
    {
        "entities": ["inflation", "monetary policy", "Governing Council"]
    }
    Do not add explanations. Only return valid JSON."""

    subquery_system_prompt = """You are an AI that generates subqueries from a given user query.
    Break the input query into multiple relevant subqueries that each focus on a specific aspect.
    The subqueries should be self-contained, informative, and avoid redundancy.
    Return the subqueries as a JSON object. Example:
    {
        "subqueries": [
            "What are the main factors influencing inflation?",
            "How does monetary policy respond to inflation?",
            "What is the relationship between the euro area and inflation?"
        ]
    }
    Do not add explanations. Only return valid JSON."""

    answer_system_prompt = ("You are a helpful assistant specialized in answering questions "
                            "based strictly on the given context. Do not use any external knowledge.")
    prompt_template = """
            ### Query
            {query}

            ### Context
            The following information has been retrieved to help answer the query. It may consist of triples, paths, or subgraphs extracted from a knowledge graph.

            {context}

            ### Instructions
            Based solely on the context above, provide a concise and accurate answer to the query.
            Do **not** use any external knowledge or make assumptions beyond what is explicitly stated in the context.
    """

    t_start = time.time()
    written = 0
    for i in range(QA_df.shape[0]):
        query = QA_df['Question'].iloc[i]

        if save and str(query) in done_queries:
            print(f"\rSkipped (done): {i + 1}/{QA_df.shape[0]}", end="", flush=True)
            continue

        extracted_entities = json_chat(client, model, system_prompt, query, "entities",
                                       max_entities_tokens, temperature, max_attempts)
        subqueries = json_chat(client, model, subquery_system_prompt, query, "subqueries",
                               max_subquery_tokens, temperature, max_attempts)

        found_entities, missing = check_entities_in_kg(extracted_entities, driver)
        paths = find_paths_between_entities(found_entities, driver)

        if not subqueries:
            print(f"\nNO SUBQUERIES for Query: {query}")
        if not paths:
            print(f"\nNO PATHS for these found entities: {found_entities}")

        final_paths = []
        seen = set()

        for subquery in subqueries:
            top_paths = rank_paths_by_relevance(subquery, paths, cross_encoder, top_k=top_k)
            for path in top_paths:
                path_tuple = tuple(path)
                if path_tuple not in seen:
                    seen.add(path_tuple)
                    final_paths.append(path)

        prompt = prompt_template.format(context=final_paths, query=query)
        answer = chat_text(client, model, answer_system_prompt, prompt,
                           max_answer_tokens, temperature)
        if answer is None:
            print(f"\nNo answer for query {i + 1}: {query}")
            answer = ""

        row = {"query": query, "paths": json.dumps(final_paths),
              "subqueries": json.dumps(subqueries),
              "entities": json.dumps(found_entities),
              "missing_entities": json.dumps(missing),
              "answer": answer}

        if save:
            with open(file_path_name, "a", newline="", encoding="utf-8") as f:
                csv.writer(f).writerow([row[c] for c in RESULT_COLUMNS])
            done_queries.add(str(query))

        written += 1
        elapsed = time.time() - t_start
        remaining = QA_df.shape[0] - (i + 1)
        eta = elapsed / (i + 1) * remaining
        print(f"\rProgress: {i + 1}/{QA_df.shape[0]}  "
              f"elapsed={int(elapsed // 60)}m{int(elapsed % 60):02d}s  "
              f"eta={int(eta // 60)}m{int(eta % 60):02d}s   ", end="", flush=True)

    if save:
        print(f"\nSaved: {file_path_name} ({written} rows)")
    print("END GraphTRACE()")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

DATASETS = ["Converging", "Divergent", "Linear", "descriptive",
            "singleEntity", "yesNo", "NULL"]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="GraphTRACE with a local Strata model")
    parser.add_argument("--dataset", choices=DATASETS, nargs="*",
                        help="Datasets to run (default: Converging Divergent Linear)")
    parser.add_argument("--limit", type=int, default=None,
                        help="Only run the first N rows (smoke test)")
    parser.add_argument("--cloud", action="store_true", help="Use OpenAI cloud (gpt-4o-mini)")
    parser.add_argument("--model", default=None, help="Model name (default: auto-detect)")
    parser.add_argument("--base-url", default=None,
                        help="Override endpoint, e.g. http://localhost:8080/v1")
    parser.add_argument("--api-key", default=None, help="Override endpoint API key")
    parser.add_argument("--uri", default=os.getenv("NEO4J_URI", "bolt://localhost:7687"))
    parser.add_argument("--user", default=os.getenv("NEO4J_USER", "neo4j"))
    parser.add_argument("--password",
                        default=os.getenv("NEO4J_PASSWORD", "875421963"))
    parser.add_argument("--cross-encoder",
                        default=os.getenv("CROSS_ENCODER", "cross-encoder/ms-marco-MiniLM-L-6-v2"))
    parser.add_argument("--top-k", type=int, default=3)
    parser.add_argument("--temperature", type=float, default=0.0)
    parser.add_argument("--max-attempts", type=int, default=3)
    parser.add_argument("--entities-max-tokens", type=int, default=700)
    parser.add_argument("--subquery-max-tokens", type=int, default=900)
    parser.add_argument("--answer-max-tokens", type=int, default=1000)
    parser.add_argument("--output-name", default=None,
                        help="Result file name (default: GraphTRACE_<dataset>)")
    parser.add_argument("--no-save", action="store_true",
                        help="Do not write the result CSV (original behaviour)")
    args = parser.parse_args()

    datasets = args.dataset or ["Converging", "Divergent", "Linear"]

    client, model = build_client(use_cloud=args.cloud, base_url=args.base_url,
                                 api_key=args.api_key, model=args.model)

    driver = GraphDatabase.driver(args.uri, auth=(args.user, args.password))
    if not test_connection(driver):
        print("Neo4j is not reachable. Start Neo4j (or pass --uri/--user/--password) "
              "and run again.")
        sys.exit(1)

    cross_encoder = CrossEncoder(args.cross_encoder)

    for dataset in datasets:
        print(f"\n### Dataset: {dataset} ###")
        QA_df = pd.read_csv(f"./data/QA_{dataset}.csv")
        if args.limit:
            QA_df = QA_df.head(args.limit).reset_index(drop=True)
        output_name = args.output_name or f"GraphTRACE_{dataset}"
        if args.output_name and len(datasets) > 1:
            output_name = f"{args.output_name}_{dataset}"
        GraphTRACE(QA_df, output_name, client, model, driver, cross_encoder,
                   max_entities_tokens=args.entities_max_tokens,
                   max_subquery_tokens=args.subquery_max_tokens,
                   max_answer_tokens=args.answer_max_tokens,
                   temperature=args.temperature,
                   max_attempts=args.max_attempts,
                   top_k=args.top_k,
                   save=not args.no_save)

    driver.close()
