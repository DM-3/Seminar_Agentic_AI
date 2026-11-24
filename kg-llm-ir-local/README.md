# kg-llm-ir
Github Repository of my master's thesis "Leveraging KGs and LLMs for Optimized Information Retrieval"


### Instructions to get started
1. Install Visual Studio Code
2. Install git
3. Install Python
4. Install neo4j Desktop
5. Clone this GitHub repository (git clone https://github.com/AnnaO8/kg-llm-ir.git)
6. Create a virtual environment in VS Code (python -m venv venv)
7. Activate virtual environment (.venv\Scripts\activate (Windows), source venv/bin/activate (Linux))
   (if you have security issues, you can temporarly bypass it by running "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process")
9. Install requirements (pip install -r requirements.txt)
10. Finished :)


Folder structure
```bash
kg-llm-ir/
├── baselines/          # Implementations of baseline methods
│   ├── NaiveRAG.py
│   ├── NaiveRAG_Subquery.py
│   ├── RerankRAG.py
│   ├── HybridRAG.py
│   ├── KG_RAG.py
│   └── ToG.py
│
├── data/               # .csv files of KG, QA data sets
│   ├── Economic_KG.csv
│   ├── Economic_KG_withUnterscore.csv
│   ├── Economic-KG-with-blank.csv
│   ├── QA_Converging.csv
│   ├── QA_Divergent.csv
│   ├── QA_Linear.csv
│   ├── QA_descriptive.csv
│   ├── QA_singleEntity.csv
│   ├── QA_yesNo.csv
│   └── QA_NULL.csv
│
├── evaluation/        # Evaluation scripts and metric outputs
│   ├── results/       # here are the retrieval evaluation results located
│   ├── retrieval_evaluation.py
│   ├── generation_evaluation.py
│   ├── retrieval_evaluation_output.txt
│   ├── generation_evaluation_output.txt
│   └── generation_evaluation_xxx.csv    # here are the generation evaluation results located
│
├── proposed_approach/  # Implementation of Graph TRACE (the proposed approach)
│   └── GraphTRACE.py
│
├── qa_generation       # QA generation pipeline
│   └── qa_gen_neo4j.py
│
├── utils/              # Utility functions and shared tools
│
├── .env                # Environment variables (HERE you have to include your private OpenAI API key)
```

### Instructions how to set up the graph data base in neo4j Desktop (on your local machine)
1. Create a new instance
2. Use theses credentials  
   URI = "bolt://localhost:7687 (you might have to change the port number in the code to the provided port number by neo4j)  
   USERNAME = "neo4j"  
   **PASSWORD = "875421963"** (you have to choose a password, when you create a new neo4j project, if different credentials are used, replace them in the python scripts)  
3. Add Economic_KG.csv into the import folder of the instance (click on "open folder" in the instance, create folder "import" if  not present already)
4. Insert nodes into neo4j  
   LOAD CSV WITH HEADERS FROM 'file:///Economic_KG.csv'  
   AS row MERGE (n:Entity {name: row.n}) MERGE (m:Entity {name: row.m});
5. Insert edges into neo4j  
   LOAD CSV WITH HEADERS FROM 'file:///Economic_KG.csv'  
   AS row  
   MATCH (a:Entity {name: row.n})  
   MATCH (b:Entity {name: row.m})  
   MERGE (a)-[r:RELATIONSHIP {type: row.r}]->(b);
6. In order to Check and visualize 100 tripels of KG  
   MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 100;  


### How to reproduce the evaluations
To reproduce the evaluations for retrieval and generation results, simply run these comands in the ./evaluation/ folder  
- python retrieval_evaluation.py
- python generation_evaluation.py


### How to simply look at the results (without recalculation) 
The following documents includes the retrieval and generation evaluation results that are published in the thesis
- ./evaluation/retrieval_evaluation_output.txt  
- ./evaluation/generation_evaluation_output.txt


### How to run one of the approaches (baselines or Graph TRACE)
1. Navigate to the respective folder (/baselines/ or /proposed_approach/)
2. run "python approach.py" (e.g. python GraphTRACE.py)


### How to use OpenAI's LLM (gpt4o-mini)
The credentials are automatically used by dotenv, but initially you have to insert your private API key 
OPEN_API_KEY=...


### How to run the generation evaluation with a local Strata model
`generation_evaluation.py` runs the LLM-as-a-judge evaluation against a **local model served by Strata** (OpenAI-compatible endpoint) instead of the OpenAI cloud. Start Strata with the model served, then run from `./evaluation/`:

    python generation_evaluation.py --dataset Linear --run 1

The endpoint URL, API key and model name are auto-discovered from the running Strata instance (`~/.strata/data/native-instances/*.json`), so no key needs to be pasted into `.env`. Overrides: `--base-url`, `--api-key`, `--model`, or the env vars `STRATA_BASE_URL`, `STRATA_API_KEY`, `STRATA_MODEL`. `--cloud` switches back to OpenAI (gpt-4o-mini).

Other useful flags: `--max-tokens` (default 2000; local models spend part of the budget on reasoning, so keep it generous), `--temperature` (default 0), `--max-attempts` (retry on unparsable/invalid replies), `--limit N` (smoke test on the first N rows).

Results are written incrementally to `generation_evaluation_<dataset>_run<run>.csv`, so an interrupted run can be restarted and finished rows are skipped. On a local GPU the judge needs roughly 1-2 minutes per row, so a full run over 90 rows takes about 2 hours.

Running `python generation_evaluation.py` without `--dataset` only aggregates the published run CSVs and prints the averages, as before.


### CAUTION ###
In the most scripts the command **df.to_csv(...)** is used. If you don't want to overwrite the respective file, you have to choose another file name or comment out this line.
