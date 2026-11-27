"""Generation evaluation (LLM-as-a-judge) for the 7 RAG approaches.

Originally this script only worked against OpenAI's cloud API
(client.beta.chat.completions.parse, model="gpt-4o-mini").

It is adapted to run against a **local Strata model server** (OpenAI-compatible
endpoint, default http://127.0.0.1:<port>/v1), and it still supports the cloud
model via `--cloud`.

What changed for the local model:
- base_url + api_key are auto-discovered from the running Strata instance
  (~/.strata/data/native-instances/*.json), overridable through .env
- the model name is read from /v1/models instead of being hard-coded
- structured output is requested first, with a plain-text + loose-JSON fallback
  (local servers do not always honour response_format)
- winners are validated (ints in 1..7) and the call is retried on failure
- results are written incrementally, so an interrupted run can be resumed
  (important: local generation is ~10 tokens/s, a full run takes hours)
"""

import os
import re
import sys
import csv
import json
import glob
import time
import argparse

from openai import OpenAI
from pydantic import BaseModel
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

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

# ---------------------------------------------------------------------------
# Local model (Strata) client
# ---------------------------------------------------------------------------

APPROACHES = [
    "NaiveRAG",
    "NaiveRAG + Subquery",
    "HybridRAG",
    "RerankRAG",
    "Naive GraphRAG",
    "KG RAG",
    "GraphTRACE",
]


class answerEval(BaseModel):
    comprehensiveness_winner: int
    comprehensiveness_explanation: str
    diversity_winner: int
    diversity_explanation: str
    empowerment_winner: int
    empowerment_explanation: str
    directness_winner: int
    directness_explanation: str
    overall_winner: int
    overall_winner_explanation: str


RESULT_COLUMNS = [
    "query",
    "comprehensiveness_winner",
    "comprehensiveness_explanation",
    "diversity_winner",
    "diversity_explanation",
    "empowerment_winner",
    "empowerment_explanation",
    "directness_winner",
    "directness_explanation",
    "overall_winner",
    "overall_winner_explanation",
]


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


def build_client(use_local=False, base_url=None, api_key=None, model=None):
    """Use the ACCloud (default) or build an OpenAI client for the local Strata server."""
    if not use_local:
        client = OpenAI(api_key=os.getenv("ACCLOUD_API_KEY"), base_url = base_url)
        return client, model or os.getenv("LLM_MODEL", "qwen3.8-27b")


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
            "No local Strata server found. Start Strata, or set STRATA_BASE_URL "
            "and STRATA_API_KEY in .env, or run with --cloud."
        )

    client = OpenAI(base_url=base_url, api_key=api_key or "local", timeout=600.0)

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
# Robust JSON parsing for local models
# ---------------------------------------------------------------------------

RAW_DEBUG_LOG = os.getenv("RAW_DEBUG_LOG")


def debug_dump(tag, text):
    if RAW_DEBUG_LOG:
        with open(RAW_DEBUG_LOG, "a", encoding="utf-8") as f:
            f.write(f"\n===== {tag} =====\n{str(text)}\n")


WINNER_KEYS = [
    "comprehensiveness_winner",
    "diversity_winner",
    "empowerment_winner",
    "directness_winner",
    "overall_winner",
]

# 'overall_winner_explanation' does not follow the "<crit>_explanation" pattern
EXPLANATION_KEYS = {
    "comprehensiveness_winner": "comprehensiveness_explanation",
    "diversity_winner": "diversity_explanation",
    "empowerment_winner": "empowerment_explanation",
    "directness_winner": "directness_explanation",
    "overall_winner": "overall_winner_explanation",
}


def extract_json(text):
    """Best-effort extraction of a JSON object from a chat completion."""
    if not text:
        return None
    t = text.strip()
    fence = re.search(r"```(?:json)?\s*(.*?)```", t, re.S)
    if fence:
        t = fence.group(1).strip()
    try:
        return json.loads(t)
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
        return json.loads(cand)
    except Exception:
        return None


def normalise(data, n_answers=7):
    """Turn a raw dict into the answerEval shape; return None if unusable."""
    if not isinstance(data, dict):
        return None
    out = {}
    for key in WINNER_KEYS:
        raw = data.get(key, data.get(key.replace("_winner", "")))
        val = None
        if isinstance(raw, bool):
            val = None
        elif isinstance(raw, int):
            val = raw
        elif isinstance(raw, str):
            m = re.search(r"\d+", raw)
            val = int(m.group()) if m else None
        if val is None or not (1 <= val <= n_answers):
            return None
        out[key] = val
        expl_key = EXPLANATION_KEYS[key]
        expl = data.get(expl_key, "")
        if not isinstance(expl, str):
            expl = str(expl)
        out[expl_key] = expl
    return out


def call_llm(client, model, system_prompt, prompt, max_tokens, temperature, max_attempts=3):
    """Ask the model for an evaluation. Structured output first, loose JSON second."""
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt},
    ]

    last_error = None
    for attempt in range(1, max_attempts + 1):
        # 1) Structured output (works with Strata's server, as with OpenAI cloud)
        try:
            response = client.beta.chat.completions.parse(
                messages=messages,
                model=model,
                response_format=answerEval,
                temperature=temperature,
                max_tokens=max_tokens,
            )
            msg = response.choices[0].message
            debug_dump(f"structured attempt {attempt}", {
                "content": msg.content,
                "reasoning": getattr(msg, "reasoning_content", None),
                "finish_reason": response.choices[0].finish_reason,
                "usage": getattr(response, "usage", None),
            })
            data = extract_json(msg.content)
            if data:
                normalised = normalise(data)
                if normalised:
                    return answerEval(**normalised)
                last_error = f"winner values out of range: {data}"
            else:
                last_error = "structured reply contained no parsable JSON"
        except Exception as e:
            last_error = f"structured call failed: {type(e).__name__}: {e}"

        # 2) Plain completion + loose JSON extraction
        try:
            response = client.chat.completions.create(
                messages=messages,
                model=model,
                temperature=temperature,
                max_tokens=max_tokens,
            )
            msg = response.choices[0].message
            content = msg.content
            if not content:
                content = getattr(msg, "reasoning_content", None)
            data = extract_json(content)
            if data:
                normalised = normalise(data)
                if normalised:
                    return answerEval(**normalised)
                last_error = f"winner values out of range: {data}"
            else:
                last_error = f"reply contained no parsable JSON: {str(content)[:120]}"
        except Exception as e:
            last_error = f"plain call failed: {type(e).__name__}: {e}"

        # Ask the model to self-correct on the next attempt
        messages.append({"role": "assistant", "content": str(last_error)})
        messages.append({
            "role": "user",
            "content": "That was not valid. Reply with ONLY one JSON object with exactly "
                       "these keys: " + ", ".join(RESULT_COLUMNS[1:]) +
                       ". Winner values must be integers between 1 and 7.",
        })

    return None


# ---------------------------------------------------------------------------
# Evaluation loop
# ---------------------------------------------------------------------------

def generation_evaluation(QA_df, approach1, approach2, approach3, approach4,
                          approach5, approach6, approach7, output_name,
                          client, model, max_tokens=2000, temperature=0.0,
                          max_attempts=3):
    file_path_name = f"generation_evaluation_{output_name}.csv"

    # Resume support: skip rows already written
    done_queries = set()
    if os.path.exists(file_path_name):
        try:
            prev = pd.read_csv(file_path_name)
            done_queries = set(prev["query"].astype(str))
            print(f"Resuming: {len(done_queries)} rows already in {file_path_name}")
        except Exception:
            print(f"Existing {file_path_name} is unreadable; starting fresh")
            os.remove(file_path_name)

    if not os.path.exists(file_path_name):
        with open(file_path_name, "w", newline="", encoding="utf-8") as f:
            csv.writer(f).writerow(RESULT_COLUMNS)

    approaches = [approach1, approach2, approach3, approach4, approach5, approach6, approach7]

    system_prompt = (
        "You are an expert tasked with evaluating several answers to the same question "
        "based on these criteria: **Comprehensiveness**, **Diversity**, **Empowerment**, "
        "and **Directness**. Consider also the given ground truth answer. "
        "Reply with ONLY a single JSON object, no prose, no markdown fences."
    )

    prompt_template = """You will evaluate the following answers to the same question based on these criteria: **Comprehensiveness**, **Diversity**, **Empowerment**, and **Directness**. Consider also the given ground truth answer.

- **Comprehensiveness**: How much detail does the answer provide to cover all aspects and details of the question?
- **Diversity**: How varied and rich is the answer in providing different perspectives and insights on the question?
- **Empowerment**: How well does the answer help the reader understand and make informed judgments about the topic?
- **Directness**: How clearly and directly does the answer address the question without unnecessary information?

For each criterion, choose the best answer (either Answer 1, Answer 2, Answer 3, ..., Answer 7) and explain why. Then, select an overall winner based on the given categories.

Here is the question:
{query}

Here is the ground truth answer:
{ground_truth_answer}

Here are the answers:

**Answer 1:**
{answer1}

**Answer 2:**
{answer2}

**Answer 3:**
{answer3}

**Answer 4:**
{answer4}

**Answer 5:**
{answer5}

**Answer 6:**
{answer6}

**Answer 7:**
{answer7}

Evaluate the answers using the criteria listed above and provide detailed explanations for each criterion. Only one winner should be selected for each criterion.
For the overall winner, consider the answers' performance across all criteria.

Reply with ONLY a JSON object of the form:
{{"comprehensiveness_winner": 1, "comprehensiveness_explanation": "...", "diversity_winner": 1, "diversity_explanation": "...", "empowerment_winner": 1, "empowerment_explanation": "...", "directness_winner": 1, "directness_explanation": "...", "overall_winner": 1, "overall_winner_explanation": "..."}}
Winner values must be integers between 1 and 7."""

    t_start = time.time()
    written = 0
    for i in range(QA_df.shape[0]):
        query = QA_df["Question"].iloc[i]
        ground_truth_answer = QA_df["Answer"].iloc[i]

        queries = {approach["query"].iloc[i] for approach in approaches}
        queries.add(str(query))
        if len(queries) > 1:
            print(f"Mismatch in queries at row {i}")
            break

        answers = [approach["answer"].iloc[i] for approach in approaches]

        if str(query) in done_queries:
            print(f"\rSkipped (done): {i + 1}/{QA_df.shape[0]}", end="", flush=True)
            continue

        prompt = prompt_template.format(
            query=query, ground_truth_answer=ground_truth_answer,
            answer1=answers[0], answer2=answers[1], answer3=answers[2],
            answer4=answers[3], answer5=answers[4], answer6=answers[5],
            answer7=answers[6],
        )

        answer = call_llm(client, model, system_prompt, prompt,
                          max_tokens=max_tokens, temperature=temperature,
                          max_attempts=max_attempts)
        if answer is None:
            print(f"\nRow {i}: model did not produce a valid evaluation, skipping: {query}")
            continue

        row = {"query": query}
        for col in RESULT_COLUMNS[1:]:
            row[col] = getattr(answer, col)

        with open(file_path_name, "a", newline="", encoding="utf-8") as f:
            csv.writer(f).writerow([row[c] for c in RESULT_COLUMNS])
        done_queries.add(str(query))
        written += 1

        elapsed = time.time() - t_start
        remaining = QA_df.shape[0] - written
        eta = elapsed / written * remaining if written else 0
        print(f"\rProgress: {i + 1}/{QA_df.shape[0]}  written={written}  "
              f"elapsed={int(elapsed // 60)}m{int(elapsed % 60):02d}s  "
              f"eta={int(eta // 60)}m{int(eta % 60):02d}s   ", end="", flush=True)

    print(f"\nSaved: {file_path_name} ({written} new rows)")


# ---------------------------------------------------------------------------
# Result aggregation / plots (unchanged logic)
# ---------------------------------------------------------------------------

def calculate_winner_percentage(eval_result_df):
    approach_map = {i + 1: name for i, name in enumerate(APPROACHES)}
    criteria = ["comprehensiveness", "diversity", "empowerment", "directness", "overall"]
    results = pd.DataFrame(index=criteria, columns=approach_map.values())

    for crit in criteria:
        winner_col = f"{crit}_winner"
        counts = eval_result_df[winner_col].value_counts().sort_index()
        total = counts.sum()
        for idx, count in counts.items():
            name = approach_map.get(idx, "None")
            results.loc[crit, name] = f"{(count / total * 100):.2f}%"

    print(results)
    results_numeric = results.map(lambda x: float(x.strip("%")) if isinstance(x, str) else 0.0)

    plt.figure(figsize=(12, 6))
    sns.heatmap(results_numeric, annot=True, fmt=".1f", cmap="RdYlGn",
                cbar_kws={"label": "Winner share (%)"})
    plt.title("Heatmap of Winner Distribution per Criterion")
    plt.xlabel("Approach")
    plt.ylabel("Criterion")
    plt.tight_layout()
    if matplotlib.get_backend() == "Agg":
        plt.savefig("winner_heatmap.png", dpi=200)
        print("No display available - saved winner_heatmap.png")
    else:
        plt.show()


def calculate_average_winner_percentage(csv_paths):
    approach_map = {i + 1: name for i, name in enumerate(APPROACHES)}
    criteria = ["comprehensiveness", "diversity", "empowerment", "directness", "overall"]
    all_result_dfs = []

    for path in csv_paths:
        df = pd.read_csv(path)
        result = pd.DataFrame(index=criteria, columns=approach_map.values(), dtype=float)
        for crit in criteria:
            winner_col = f"{crit}_winner"
            counts = df[winner_col].value_counts().sort_index()
            total = counts.sum()
            for idx in range(1, 8):
                name = approach_map[idx]
                count = counts.get(idx, 0)
                result.loc[crit, name] = count / total * 100
        all_result_dfs.append(result)

    avg_result = sum(all_result_dfs) / len(all_result_dfs)

    for row in avg_result.index:
        row_sum = avg_result.loc[row].sum()
        diff = 100 - row_sum
        max_col = avg_result.loc[row].idxmax()
        avg_result.loc[row, max_col] += diff

    avg_result_formatted = avg_result.map(lambda x: f"{x:.2f}%")
    print(avg_result_formatted)
    return avg_result_formatted


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

DATASETS = ["Converging", "Divergent", "Linear", "descriptive", "singleEntity", "yesNo", "NULL"]


def load_results(dataset):
    paths = {
        1: f"results/NaiveRAG_{dataset}.csv",
        2: f"results/NaiveRAG_Subquery_{dataset}.csv",
        3: f"results/HybridRAG_{dataset}.csv",
        4: f"results/RerankRAG_{dataset}.csv",
        5: f"results/Naive_GraphRAG_{dataset}.csv",
        6: f"results/KG_RAG_{dataset}.csv",
        7: f"results/GraphTRACE_{dataset}.csv",
    }
    dfs = {}
    for k, p in paths.items():
        if not os.path.exists(p):
            raise FileNotFoundError(f"Missing results file: {p} (run the approach first)")
        dfs[k] = pd.read_csv(p)
    return dfs


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="LLM-as-a-judge generation evaluation")
    parser.add_argument("--dataset", choices=DATASETS,
                        help="Run the judge on this dataset instead of aggregating results")
    parser.add_argument("--run", default="1", help="Run suffix, e.g. 1 -> ..._run1.csv")
    parser.add_argument("--local", action="store_true", help="Use Starta Model")
    parser.add_argument("--model", default=None, help="Model name (default: auto-detect)")
    parser.add_argument("--base-url", default="https://chat-ai.academiccloud.de/v1", help="Override endpoint, e.g. http://localhost:8080/v1")
    parser.add_argument("--api-key", default=None, help="Override endpoint API key")
    parser.add_argument("--max-tokens", type=int, default=2000)
    parser.add_argument("--temperature", type=float, default=0.0)
    parser.add_argument("--max-attempts", type=int, default=3)
    parser.add_argument("--limit", type=int, default=None, help="Only evaluate the first N rows (smoke test)")
    args = parser.parse_args()

    if args.dataset:
        client, model = build_client(use_local=args.local, base_url=args.base_url,
                                     api_key=args.api_key, model=args.model)
        QA_df = pd.read_csv(f"./data/QA_{args.dataset}.csv")
        if args.limit:
            QA_df = QA_df.head(args.limit).reset_index(drop=True)
        res = load_results(args.dataset)
        generation_evaluation(QA_df, res[1], res[2], res[3], res[4], res[5], res[6], res[7],
                              output_name=f"{args.dataset}_run{args.run}",
                              client=client, model=model,
                              max_tokens=args.max_tokens, temperature=args.temperature,
                              max_attempts=args.max_attempts)
    else:
        # Aggregate the published run results
        for label, paths in [
            ("Converging", ["generation_evaluation_Converging_run1.csv",
                            "generation_evaluation_Converging_run2.csv",
                            "generation_evaluation_Converging_run3.csv"]),
            ("Divergent", ["generation_evaluation_Divergent_run1.csv",
                           "generation_evaluation_Divergent_run2.csv",
                           "generation_evaluation_Divergent_run3.csv"]),
            ("Linear", ["generation_evaluation_Linear_run1.csv",
                        "generation_evaluation_Linear_run2.csv",
                        "generation_evaluation_Linear_run3.csv"]),
        ]:
            print(f"\nGeneration Evaluation - {label} - ### Average ###")
            calculate_average_winner_percentage(paths)
