#set page(
  paper: "a4",
  margin: (left: 2cm, right: 2cm, top: 18mm, bottom: 12mm),
  footer: {
    set text(fill: rgb("#666666"))
    [Felix Görg (69021)]
    h(1fr)
    [Projektseminar Agentic AI]
    h(1fr)
    [#datetime.today().display("[day].[month].[year]")]
  }
)
#set text(lang: "de", size: 10pt, font: "Adwaita Sans")
#set par(justify: true, leading: 0.55em)
#set heading(numbering: "1.")
#show heading: set block(above: 1em, below: 0.6em)
#show heading.where(level: 1): set text(size: 11.5pt)

#align(center)[
  #text(size: 15pt, weight: "bold")[Projektmanagement GraphTrace]\
  #text(size: 11pt)[Projektseminar: Agentic Ai]\
  #v(2pt)
  #text(size: 8.5pt, fill: gray)[Ausgangspaper: Osipjan et al., _GraphTrace: A Modular Retrieval Framework Combining Knowledge Graphs and Large Language Models for Multi-Hop Question Answering_, Computers 14(9), 2025, doi:10.3390/computers14090382]
]

= Konkretes Projektziel

Das Ausgangspaper stellt _GraphTrace_ vor, ein modulares Retrieval-Framework (Entity Extraction, Path Finding, Query Decomposition, Semantic Path Ranking, Context Aggregation, LLM-Antwortgenerierung), das auf einem COVID-19-Wirtschafts-Knowledge-Graph Standard-RAG und GraphRAG übertrifft, vor allem bei 5–6-Hop-Anfragen @GraphTrace2025. Ziel unseres Projekts ist es, diese Ergebnisse *nachzubauen, zu überprüfen und gezielt zu erweitern*:

+ *Reimplementierung:* Lauffähige Pipeline mit allen fünf GraphTrace-Modulen sowie den Baselines RAG und GraphRAG auf einem Knowledge Graph (z. B. Neo4j).
+ *Evaluation:* Vergleich der Ansätze in Retrieval- und Generierungs-Setting nach Hop-Anzahl (2–7 Hops) mit den Metriken des Papers (u. a. Directness).
+ *Erweiterung (Eigenbeitrag):* Ablationsstudie der Module (z. B. ohne Query Decomposition oder Path Ranking) und Test mit einem Open-Source-LLM bzw. einer zweiten Domäne, um die Übertragbarkeit zu prüfen.
+ *Ergebnisse:* Git-Repository, Abschlussbericht und Abschlusspräsentation.

*Erfolgskriterium:* Die Pipeline läuft reproduzierbar, und die Trends des Papers (GraphTrace > GraphRAG > RAG bei mittlerer Komplexität) werden bestätigt oder begründet widerlegt.

= Zusammenarbeit im Team

Wichtig für eine Gute Zusammenarbeit ist eine klare Rollen-, Aufgaben-, und Verantwortlichkeitsverteilung. Da das exakte Projektziel und die Kompetenzen der Teammitlglieder zum Zeitpunkt der erstellung dieses Documents noch unbekannt sind, kann darauf nicht weiter eingeganen werden.

= Organisation

*Treffen und Kommunikation:* Regelmäßige Treffen (mind. alle 2 Wochen) um Fortschritte abzugleichen und Grundsätzliche Richtungsfragen zu klären; Alltägliche Abstimmung über Chat (z. B. Discord oder Whatsapp); Für plötztlich Auftrettende Probleme und Entscheidungsfragen abstimmung über Onlinemeetings.

*Werkzeuge:* GitHub (Code, Issues, Kanban-Board), Python mit LangChain bzw. LlamaIndex, Neo4j, Computer des URZ zur Ausführrung, gemeinsames Literaturverzeichnis und Typst für den Berichte.

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.4pt + gray,
  inset: 4pt,
  fill: (_, row) => if row == 0 { luma(230) },
  [*Datum*], [*Abgabe*],
  [23.11.2026], [Literaturrecherche],
  [16.12.2026], [Zwischenvortrag],
  [10.02.2027], [Abschlussvortrag],
  [15.03.2027], [Schriftliche Ausarbeitung]
)

*Risiken und Gegenmaßnahmen:*
+ Schwierigkeiten mit Datensatz → Rückgriff auf einen öffentlichen KG (z. B. Wikidata-Ausschnitt) und Anpassung der Testfragen.
+ Computer des URZ nicht verfübar → Lokales Modell als Alternative.
+ Zeitverzug → Pflichtumfang (Ziele 1, 2, 4) vor Erweiterung (Ziel 3) priorisieren.


#bibliography("../bibliography/references.bib", title: "Referenzen")
