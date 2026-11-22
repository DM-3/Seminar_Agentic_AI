#import "../TUBAF_typst_template/tubaf.typ": tubaf-article

#show: tubaf-article.with(
  subject: "Literaturrecherche",
  title: "Knowledge-Graph-basiertes Retrieval für Multi-Hop Question Answering",
  subtitle: "Projektseminar · Ausgangspaper: GraphTrace (Osipjan et al., 2025)",
  authors: ("Felix Görg",""),
  date: "21. November 2026",
  short-title: "Literaturrecherche zu KG-basiertem Retrieval",
)

= Hintergrund: LLMs und Wissensbasierte Aufgaben

Große Sprachmodelle (LLMs) erzeugen flüssige Texte, stützen sich aber auf statisches, parametrisches Wissen. In wissensintensiven Aufgaben wie Question Answering (QA) führt das zu Halluzinationen, also zu Ausgaben, die von der Eingabe, vom Kontext oder von der Realität abweichen. Dises Phänomen wird von Zhang et al. [1] systematisch eiongeordnet, und Liu et al. stellen einen Benchmark vor, der Halluzinationen in freiem Text auf Token-Ebene und ohne Referenztext erkennt [3]. Für QA kommt eine zweite Dimension hinzu: Eine Antwort kann sachlich korrekt sein, ohne der bereitgestellten Quelle treu (faithful) zu bleiben. Dies bezüglich untersuchen Adlakha et al., wie sich Korrektheit und Faithfulness bei instruktionsfolgenden Modellen bewerten lassen [2]. Daraus folgt die Motivation für Retrieval: Eine Antwort soll auf nachprüfbarer Evidenz beruhen. Knowledge Graphs (KGs) liefern solche Beweise in strukturierter Form. Zhu et al. evaluieren ChatGPT und GPT-4 empirisch auf KG-Konstruktion und KG-Reasoning und finden, dass LLMs sich eher als Inferenzassistenten denn als Few-Shot-Extraktoren eignen [4]. Das spricht dafür, LLMs für das Schlussfolgern über einen vorhandenen Graphen einzusetzen.

= Grundlagen der Retrieval-Augmented Generation

Lewis et al. führen RAG (Retrieval-augmented generation) ein in dem sie ein parametrisches Sprachmodell mit einem nicht-parametrischen Abruf externer Dokumente kombinieren [5]. Der Survey von Gao et al. gliedert die Entwicklung in drei Stufen [6]. *Naive RAG* holt eine feste Zahl von Dokumenten und fügt sie direkt in den Prompt ein. Das ist einfach und schnell, aber ohne Strukturwissen und ohne Zerlegung der Anfrage. *Advanced RAG* ergänzt Vor- und Nachbearbeitung, etwa Query-Erweiterung oder Reranking, bleibt aber eine lineare Pipeline. *Modular RAG* zerlegt das System in austauschbare Module, die sich neu kombinieren lassen, und beschreibt es als „LEGO-artig“ rekonfigurierbar [7]. Yu et al. geben einen Überblick über die Evaluation von RAG-Systemen [8]. Für diese Arbeit ist die Modularität das tragende Argument: Wenn Entitätserkennung, Retrieval, Ranking und Generierung getrennte Komponenten sind, lassen sie sich einzeln austauschen, einzeln bewerten und in Ablationen gezielt entfernen. GraphTrace greift diese Dreiteilung auf und überträgt sie auf KG-Retrieval [30].

= Graphenbasierte RAG-Systeme

Graphenbasierte RAG-Systeme beziehen ihr Wissen aus wissensbasierten Graphen auch Knowledge Graphs (KG) genannt. Man kann sie in vie verschiedene retrieval Strtegien aufteilen.

*Global / Summarization.* Microsoft GraphRAG [9] baut aus einem Textkorpus einen Graphen, bildet per hierarchischem Clustering mehrstufige Community-Zusammenfassungen und beantwortet damit query-focused Summarization-Fragen. Osipjan et al. kritisieren, dass die Communities vorab berechnet werden und die Zusammenfassung feine Beziehungen zwischen Knoten einebnet, sodass eine anfragespezifische Pfadexploration fehlt [30]. LazyGraphRAG [10] verschiebt Arbeit in die Anfragezeit. Laut Osipjan et al. kombiniert es Best-first-Suche nach Vektorähnlichkeit mit Breitensuche und ist dabei kostenbewusst, stützt sich aber weiter auf Vektorheuristiken statt auf eine semantische Pfadbewertung [30].

*Iterative LLM-guided exploration.* Think-on-Graph (ToG) [12] lässt das LLM den KG per Beam Search erkunden und entscheidet nach jedem Schritt, ob der gesammelte Kontext reicht. KG-RAG [13] lässt das LLM einen Explorationsplan erstellen und wählen, ob Knoten oder Relationen untersucht werden. Inference-Scaled GraphRAG [11] skaliert die Rechenzeit zur Inferenzzeit sequenziell (mehr Schritte) und parallel (Majority Voting über Trajektorien). Auf GRBench übertrifft es klassisches GraphRAG um 64,7 % und frühere Traversal-Methoden um 30,3 %; schwere Multi-Hop-Fragen beantwortet es zu 31,44 % richtig gegenüber 15,26 % bei den Baselines. Der Ansatz gehört damit zu den iterativen Verfahren und nicht zur Summarization-Gruppe. UniGFM-RAG [14] ist ein Gegenentwurf zu wiederholten LLM-Aufrufen: Ein Graph Foundation Model als Retriever wird über eine differenzierbare „Graph Bridge“ end-to-end mit dem LLM-Generator trainiert (Preprint, Oktober 2026).

*Traversal / steering.* GRAG [15] konstruiert einen ego-zentrierten Teilgraphen um die Anfrage-Entitäten und reicht ihn als textuellen Hard Prompt und als gelernten Soft Prompt an das LLM weiter. PolyG [16] klassifiziert Fragen in vier Typen, lässt das LLM je Typ eine Traversal-Strategie wählen und erzeugt Cypher-Abfragen; es erreicht 75 % Win-Rate in der Generierungsqualität bei bis zu vierfach schnellerer Antwort. StepChain GraphRAG [17] verbindet Fragenzerlegung mit einer Breitensuche und baut den Graphen zur Laufzeit aus abgerufenen Passagen auf (HotpotQA: +4,70 EM). S-Path-RAG [18] (WWW 2026) zählt längenbegrenzte, semantisch gewichtete Pfade per k-kürzeste-Pfade-, Beam- und Random-Walk-Strategie auf, bewertet sie mit einem gelernten Scorer plus Verifier und führt sie als Soft Prompt in das LLM ein. Die Autoren verweisen auf GraphTrace als modulare Retrieve–Rank–Generate-Pipeline. BYOKG-RAG [19] lässt das LLM Graph-Artefakte (Entitäten, Pfade, OpenCypher-Abfragen) erzeugen, die Graph-Werkzeuge mit dem KG verknüpfen. Es liegt 4,5 Prozentpunkte vor der zweitbesten Methode und zielt auf beliebige, eigene KGs.

*Modularized GraphRAG.* LEGO-GraphRAG [20] überträgt die Modular-RAG-Idee auf Graphen und erkundet den Entwurfsraum mit frei kombinierbaren Modulen für Entitäten, Traversal, semantisches Ranking und Kontextintegration. Es ist der nächste Nachbar von GraphTrace. Laut Osipjan et al. fehlen dort aber die Zerlegung der Anfrage und die Ausrichtung von Teilanfragen auf Pfade [30].

Peng et al. [21] und Han et al. [22] systematisieren GraphRAG (Han et al. mit den Komponenten Query Processor, Retriever, Organizer, Generator und Datenquelle). Kritisch fragen Fan et al. „Do We Still Need GraphRAG?“ [23]: Agentische Suche verringert den Abstand von dichtem RAG zu GraphRAG, aber für komplexes Multi-Hop-Reasoning bleibt GraphRAG im Vorteil und verhält sich stabiler, wenn sich der Offline-Aufwand amortisiert. Chen et al. kommen zu einem differenzierten Bild: GraphRAG ist für relationale Anfragen vielversprechend, einfachere RAG-Varianten sind bei geringerem Aufwand konkurrenzfähig, und agentisches RAG schneidet am besten ab [31]. Zhou et al. zeigen, dass KG-RAG-Methoden empfindlich auf unvollständige Graphen reagieren (z. B. fällt die Accuracy von RoG auf WebQSP von 76,75 % auf 50,46 %), aber auch unvollständige KGs noch deutlich nutzen [24].

= Multi-hop QA

Mavi et al. geben einen Überblick über Multi-hop QA [25]. Im allgemeinen beschreibt der Begriff ein mehrschrittiges Verfahren zur Beantwortung von in natürlicher Sprache gestellten Fragen. Bei diesem Ansatz gibt es jedoch mehrere Schwierigkeiten. (a) Die Evidenz liegt verteilt vor, und One-shot-Retrieval verpasst entweder entscheidende Details oder überflutet das Modell mit irrelevantem Kontext [17]. (b) Lange Pfade haben oft nur latente Relevanz: Sie können entscheidenden Kontext enthalten, ohne offensichtlich mit der Frage verbunden zu sein, und Heuristiken wie Pfadlänge, gemeinsame Knoten oder Kantenhäufigkeit erfassen die semantische Passung nicht [30]. (c) Mit steigender Hop-Zahl sinkt die Leistung; in der GraphTrace-Auswertung fallen die meisten Methoden jenseits von sechs Hops ab [30]. (d) Die Subgraph-Topologie spielt eine Rolle; Ob diese linear, konvergierend oder divergierend ist [27, 30]. (e) LLMs selbst sind begrenzt: Agrawal et al. testen LLMs an zehn Graph-Traversal-Problemen steigender Komplexität, beschreiben eine Tendenz, die Abwesenheit einer gültigen Lösung nicht zu erkennen (positive response bias), und schlagen die Prompting-Technik PathCompare vor [29].

*Benchmarks.* MultiHop-RAG [26] bewertet RAG-Systeme auf Multi-Hop-Anfragen über Textkorpora. EcoRAG [27] ist der direkte Benchmark von GraphTrace: ein Multi-Hop-QA-Datensatz über einen wirtschaftlichen KG zu den Folgen der COVID-19-Pandemie, den Khorashadizadeh et al. aus 62 Berichten und Bulletins (u. a. Weltbank, IWF, EZB) mit über 30.000 Tripeln aufgebaut haben [28]. Die Fragen umfassen die Topologien linear, konvergierend und divergierend, in der frühen Version mit vier bis acht Hops.

= GraphTrace

GraphTrace [30] (Osipjan et al., _Computers_ 14(9), 2025) ist eine modulare Pipeline mit fünf Komponenten. (1) *Entity Extraction*: gpt-4o-mini extrahiert Schlüsselentitäten als JSON. (2) *Path Finding*: Die Entitäten werden per Cypher-Abfrage im KG verifiziert, danach werden mit allShortestPaths alle kürzesten Pfade zwischen Entitätspaaren gesucht, ohne Selbstschleifen und mit anschließender Kanonisierung. (3) *Query Decomposition*: Das LLM zerlegt die Anfrage in Teilanfragen. (4) *Path Ranking*: Ein Cross-Encoder bewertet jedes Paar aus Teilanfrage und Pfad. (5) *Aggregation*: Pro Teilanfrage gehen die drei besten Pfade in den Kontext für die LLM-Antwort ein.

*Evaluation.* Die Autoren nutzen eine frühe EcoRAG-Version mit 267 QA-Paaren (90 konvergierend, 90 divergierend, 87 linear) und vergleichen mit Naive RAG, Naive RAG mit Subquery, Hybrid RAG, Rerank RAG, Naive GraphRAG und KG-RAG; ToG wird im Text als Baseline beschrieben, erscheint aber nicht in den Ergebnistabellen. Im Retrieval erreicht GraphTrace die besten Werte bei MRR (0,4477) und MAP (0,1906); bei Hit\@10 (0,8127) liegt Rerank RAG mit 0,8427 vorn. Die graphbasierten Baselines schneiden im Retrieval sehr schwach ab (MRR unter 0,09), liefern aber in der Generierung gute Antworten. In der Generierung (LLM-as-a-Judge mit gpt-4o-mini, Kriterien nach Edge et al. [9]) hat GraphTrace in allen drei Datensätzen die höchste Directness. Die Stärke liegt bei 5–7 Hops, etwa MRR 0,5377 gegenüber 0,3482 bei Naive RAG auf 7-Hop-Fragen der konvergierenden Menge.

*Grenzen und Anknüpfungspunkte.* Die Autoren nennen schwächere Ergebnisse bei niedriger und hoher Komplexität. Bei acht Hops liegt Naive RAG mit Subquery vorn (MRR 0,2908 gegenüber 0,1960). Zudem sind Empowerment und Comprehensiveness verbesserbar, und Korrektheit sowie Halluzinationsraten sind noch nicht ausgewertet. Die menschliche Bewertung umfasst nur 40 Stichproben bei 67 % Übereinstimmung. Hinzu kommt, dass GraphTrace auf einem einzigen, vorab konstruierten KG und mit einem proprietären LLM evaluiert wurde und keine adaptive Hop-Steuerung besitzt. Daraus ergeben sich Fragen für unser Projekt: Welche Module tragen den Gewinn (Ablation)? Wie verhält sich die Pipeline mit Open-Source-LLMs, bei 8+ Hops und bei unvollständigem KG [24]? Und wie schneidet sie gegen neuere Verfahren wie PolyG [16], StepChain [17] oder S-Path-RAG [18] ab?


#bibliography("../bibliography/individual/LitRech.bib")

#heading(numbering: none)[Literatur]
#[
#set text(size: 7.5pt)
#set par(justify: false, leading: 0.4em, spacing: 0.4em, hanging-indent: 1.6em)
#columns(2, gutter: 14pt)[
[1] Y. Zhang et al.: Siren’s Song in the AI Ocean: A Survey on Hallucination in Large Language Models. arXiv:2309.01219, 2023.

[2] V. Adlakha et al.: Evaluating Correctness and Faithfulness of Instruction-Following Models for Question Answering. TACL 12, 681–699, 2024.

[3] T. Liu et al.: A Token-level Reference-free Hallucination Detection Benchmark for Free-form Text Generation. arXiv:2104.08704, 2021.

[4] Y. Zhu et al.: LLMs for Knowledge Graph Construction and Reasoning: Recent Capabilities and Future Opportunities. arXiv:2305.13168, 2023.

[5] P. Lewis et al.: Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks. NeurIPS 33, 9459–9474, 2020.

[6] Y. Gao et al.: Retrieval-Augmented Generation for Large Language Models: A Survey. arXiv:2312.10997, 2023.

[7] Y. Gao et al.: Modular RAG: Transforming RAG Systems into LEGO-like Reconfigurable Frameworks. arXiv:2407.21059, 2024.

[8] H. Yu et al.: Evaluation of Retrieval-Augmented Generation: A Survey. In: Big Data, Springer, 102–120, 2025.

[9] D. Edge et al.: From Local to Global: A Graph RAG Approach to Query-Focused Summarization. arXiv:2404.16130, 2025.

[10] D. Edge, H. Trinh, J. Larson: LazyGraphRAG: Setting a New Standard for Quality and Cost. Microsoft Research Blog, 2024.

[11] T. Thompson et al.: Inference Scaled GraphRAG: Improving Multi Hop Question Answering on Knowledge Graphs. arXiv:2506.19967, 2025.

[12] J. Sun et al.: Think-on-Graph: Deep and Responsible Reasoning of Large Language Model on Knowledge Graph. arXiv:2307.07697, 2023.

[13] D. Sanmartín: KG-RAG: Bridging the Gap Between Knowledge and Creativity. arXiv:2405.12035, 2024.

[14] Z. Zhao et al.: UniGFM-RAG: Unify Graph Foundation Models and Large Language Models for End-to-End Retrieval and Reasoning. arXiv:2610.34866, 2026.

[15] Y. Hu et al.: GRAG: Graph Retrieval-Augmented Generation. arXiv:2405.16506, 2024.

[16] R. Liu et al.: PolyG: Effective and Efficient GraphRAG with Adaptive Graph Traversal. arXiv:2504.02112, 2025.

[17] T. Ni et al.: StepChain GraphRAG: Reasoning Over Knowledge Graphs for Multi-Hop Question Answering. arXiv:2510.02827, 2025.

[18] R. Fu et al.: S-Path-RAG: Semantic-Aware Shortest-Path Retrieval Augmented Generation for Multi-Hop Knowledge Graph Question Answering. WWW 2026, arXiv:2603.23512.

[19] C. Mavromatis et al.: BYOKG-RAG: Multi-Strategy Graph Retrieval for Knowledge Graph Question Answering. EMNLP 2025, 27869–27886.

[20] Y. Cao et al.: LEGO-GraphRAG: Modularizing Graph-based Retrieval-Augmented Generation for Design Space Exploration. PVLDB, 2025, doi:10.14778/3748191.3748194.

[21] B. Peng et al.: Graph Retrieval-Augmented Generation: A Survey. arXiv:2408.08921, 2024.

[22] H. Han et al.: Retrieval-Augmented Generation with Graphs (GraphRAG). arXiv:2501.00309, 2025.

[23] D. Fan et al.: Do We Still Need GraphRAG? Benchmarking RAG and GraphRAG for Agentic Search Systems. arXiv:2604.09666, 2026.

[24] D. Zhou et al.: Evaluating Knowledge Graph Based Retrieval Augmented Generation Methods under Knowledge Incompleteness. arXiv:2504.05163, 2025.

[25] V. Mavi, A. Jangra, A. Jatowt: Multi-hop Question Answering. Found. Trends Inf. Retr. 17, 457–586, 2024.

[26] Y. Tang, Y. Yang: MultiHop-RAG: Benchmarking Retrieval-Augmented Generation for Multi-Hop Queries. arXiv:2401.15391, 2024.

[27] H. Khorashadizadeh et al.: EcoRAG: A Multi-hop Economic QA Benchmark for Retrieval Augmented Generation Using Knowledge Graphs. NLDB 2025, 163–173, doi:10.1007/978-3-031-97144-0_15.

[28] H. Khorashadizadeh et al.: Construction and Canonicalization of Economic Knowledge Graphs with LLMs. KGSWC 2024, 334–343.

[29] P. Agrawal, S. Vasania, C. Tan: Can LLMs Perform Structured Graph Reasoning? ICPR 2024, arXiv:2402.01805.

[30] A. Osipjan et al.: GraphTrace: A Modular Retrieval Framework Combining Knowledge Graphs and Large Language Models for Multi-Hop Question Answering. Computers 14(9), 382, 2025, doi:10.3390/computers14090382.

[31] L. Chen et al.: Is GraphRAG Needed? From Basic RAG to Graph-/Agentic Solutions with Context Optimization. GEM Workshop 2026, arXiv:2606.25656.
]
]
