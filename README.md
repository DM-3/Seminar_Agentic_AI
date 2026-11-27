# Seminar_Agentic_AI
Github repository for our seminar project on Agentic AI.

### directory structure
```bash
Seminar_Agentic_AI/
├── src/                    # source code and data for resulting application
│   ├── data/                   # files for raw documents, KG, QA data sets
│   ├── kg-construction/        # code for knowledge graph generation
│   ├── qa-inference/           # code for GraphTrace-based question answering
│   ├── gui/                    # code for graphical user interface
│   ├── requirements.txt        # required dependencies for virtual environment
│   └── .env                    # ! must create yourself; place OpenAI API key
│
├── bibliography/           # referenced literature
│   └── references.bib
│
├── report/                 # written report
│   ├── main.typ
│   ├── chapter_01.typ
│   └── chapter_xx.typ
│
├── midterm_presentation/
|
├── final_presentation/
|
├── .gitignore
├── .gitsubmodules
├── LICENSE
└── README.md
```



## Get Started
1. navigate to src directory (```cd src```)
2. create a virtual environment (```python -m venv venv```)
3. activate virtual environment (```source venv/bin/activate```)
4. install requirements (```pip install -r requirements.txt```)


## Knowledge Graph Construction
- convert source documents to structured data (docling)
```bash
docling <doc>.pdf --to md
```
- named entity recognition
- relation extraction
- (attribute extraction)


## Question Answering Inference
based on [GraphTrace](https://github.com/AnnaO8/kg-llm-ir)


## GUI
- return answer to question
- visualize knowledge graph traversal
- show relevant sections in sources
