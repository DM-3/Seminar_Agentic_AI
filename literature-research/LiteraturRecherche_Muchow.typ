#set page(
  paper: "a4",
  margin: (left: 35mm, right: 20mm, top: 20mm, bottom: 15mm),
  numbering: "1",
  footer: context {
    set text(fill: rgb("#666666"), size: 9pt)
    [Björn Maximilian Muchow]
    h(1fr)
    counter(page).display("1")
  }
)

#set text(font: "Arial", size: 9.5pt, lang: "de", bottom-edge: "descender", top-edge: "cap-height")
#set par(justify: true, leading: .45em)
#show link: set text(fill: rgb("#0077B6"))

#show heading: it => {
  set block(below: .7em, above: 1.2em)
  set text(hyphenate: false)
  set text(size: if it.level == 1 { 15pt } else if it.level == 2 { 12.5pt } else { 11pt })
  it
}

#set list(spacing: .6em)
#set enum(spacing: .6em, numbering: "1)")

#grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  [
    #text(fill: rgb("#00497f"), size: 9pt)[*Fakultät für Mathematik und Informatik* \ Institut für Informatik]
  ],
  image("../Seminar_Agentic_AI/TUBAF_typst_template/TUBAF_Logo_blau.svg", width: 35mm),
)
#v(1em)
#text(size: 16pt, weight: "bold", hyphenate: false)[Nachvollziehbares Multi-Hop-Question-Answering \ mit Knowledge Graphs]
#v(.3em)
#text(size: 11pt)[Projektseminar Agentic AI · Literaturrecherche · Ausgangspaper: GraphTrace]
#v(.3em)
#text(size: 9pt)[Björn Maximilian Muchow · 23. November 2026]
#v(.8em)

= Thema und Leitfrage

Mich interessiert, wie ein System für mehrstufige Fragen relevante Entitäten und Beziehungen findet, daraus passende Begründungspfade bildet und die Antwort auf überprüfbare Evidenz stützt. Die Literaturrecherche betrachtet daher nicht GraphRAG allgemein, sondern den Vergleich von textuellem Retrieval, Knowledge-Graph-Fragebeantwortung und pfadbasierten Verfahren. Leitend ist die Frage, wie sich Retrievalentscheidungen und Quellenbezüge in einer dokumentenbasierten Anwendung nachvollziehbar machen lassen.

Zur ersten Themenorientierung habe ich ChatGPT genutzt. GitHub Copilot unterstützte mich beim Erstellen der Typst-Datei.

= Forschungsstand

== Von textuellem RAG zu graphgestützter Fragebeantwortung

Lewis et al. verbinden in Retrieval-Augmented Generation das parametrische Wissen eines Sprachmodells mit einem nicht-parametrischen Dokument-Retriever @Lewis2020. RAG liefert damit eine Vergleichsbasis, macht aber die Antwortqualität von der Auswahl und Konsistenz der Textpassagen abhängig. ReAct erweitert die sequenzielle Antworterzeugung um abwechselnde Reasoning- und Werkzeugschritte @Yao2023. Self-RAG macht Retrievalentscheidungen adaptiv und lässt das Modell abgerufene Evidenz reflektieren @Asai2024. Diese Arbeiten motivieren nachvollziehbare Zwischenschritte, sie lösen jedoch nicht von sich aus die Auswahl relevanter Pfade in einem Knowledge Graph.

KGQA-Verfahren unterscheiden sich darin, wie Graphwissen in die Antwort gelangt. KAPING ruft passende Tripel ab und stellt sie dem Sprachmodell als Kontext bereit @Baek2023. StructGPT steuert den Datenzugriff über explizite Werkzeugaufrufe @StructGPT2023. GreaseLM und QA-GNN integrieren Graph- und Sprachrepräsentationen in die Modellarchitektur @Zhang2022 @Yasunaga2021. Dies sind die jeweiligen Architekturansätze der Arbeiten.

Für die vorliegende Fragestellung ergeben sich daraus unterschiedliche Stärken und offene Punkte. KAPING stellt Graphfakten direkt als Prompt-Kontext bereit, während StructGPT den strukturierten Zugriff über Werkzeuge organisiert. Beide Ansätze adressieren damit Wissenszugriff, aber nicht primär die Rangordnung einer expliziten Folge von Belegpfaden. GreaseLM und QA-GNN verarbeiten Graphwissen gemeinsam mit Sprachrepräsentationen. Diese Integration kann die gemeinsame Verarbeitung unterstützen, macht die Herkunft einzelner Antwortbestandteile aber nicht automatisch sichtbar. Das ist eine Einordnung im Hinblick auf die Projektfrage und kein von den Arbeiten direkt gemessener Nachteil.

GNN-RAG verbindet graphische Kandidatensuche mit sprachlicher Antwortgenerierung. Ein GNN sucht Antwortkandidaten in einem dichten Teilgraphen, danach werden verbindende Pfade extrahiert und dem Sprachmodell als Kontext übergeben @Mavromatis2024. Die Autoren berichten auf WebQSP und CWQ Verbesserungen von 8,9 bis 15,5 Prozentpunkten beim Answer-F1 für Multi-Hop- und Multi-Entity-Fragen. Die Pfade machen einen Teil der Evidenz sichtbar, doch die Auswahl der Kandidaten bleibt von der GNN-Suche abhängig. G-Retriever wählt relevante Teilgraphen für graphstrukturierte Frage-Antwort-Aufgaben aus @He2024. Aus Sicht dieser Review belegt ein ausgewählter Teilgraph allein noch nicht, welche Dokumentpassagen die einzelnen Beziehungen stützen. Diese Verfahren sind deshalb methodische Vergleichspunkte und keine direkt vergleichbaren Baselines, denn Aufgaben und Metriken unterscheiden sich.

== Pfadsuche, GraphRAG und GraphTrace

Reasoning on Graphs und Think-on-Graph lassen ein Sprachmodell die Graphumgebung schrittweise erkunden und relevante Beziehungen für die Frage auswählen @Luo2024 @Sun2024. Diese Arbeiten untersuchen adaptive Exploration. Für die Projektfrage bleibt zu prüfen, wie stabil und ressourcenintensiv die mehrstufige Auswahl im Vergleich zu einer modularen Pfadrangfolge ist.

Die von Edge et al. vorgestellte Microsoft-GraphRAG-Variante erzeugt aus einem Textkorpus Entitäten und Beziehungen und fasst diese in Communities für globale oder thematische Fragen zusammen @Edge2024. Das ist eine konkrete Strategie innerhalb der GraphRAG-Familie und keine allgemeine Eigenschaft aller GraphRAG-Systeme. Aus Sicht dieser Review ist die globale Zusammenfassung für übergreifende Fragen nützlich, während sie für die Prüfung einer einzelnen Beziehung weniger direkt auf einen konkreten Belegpfad verweist. Die Übersichten von Peng et al. und Pan et al. ordnen unterschiedliche GraphRAG-Architekturen ein und stützen damit die Unterscheidung zwischen Graphkonstruktion, Retrieval und Antwortgenerierung @Peng2024 @Pan2024.

GraphTrace ist der zentrale Bezugspunkt dieser Recherche. Die Pipeline extrahiert Frageentitäten, sucht Graphpfade, zerlegt die Frage in Teilanfragen, bewertet Pfade semantisch und aggregiert die höchstbewerteten Pfade für die Antwortgenerierung @GraphTrace2025. Die getrennten Module machen Retrieval und Ranking gezielt untersuchbar. Auf 267 Fragen des wirtschaftlichen EcoRAG-Datensatzes erreicht GraphTrace im Retrieval MRR 0,4477 und MAP 0,1906, bei Hit\@10 (0,8127) liegt eine Rerank-RAG-Baseline (0,8427) vorn. In der Generierung erzielt GraphTrace die beste Directness-Bewertung, während die Autoren Verbesserungsbedarf bei weiteren Antwortkriterien und an den Komplexitätsrändern berichten @GraphTrace2025. Das spricht für einen differenzierten Befund statt eines pauschalen Sieges über alle Baselines.

Die Evaluation betrachtet zwei Ziele, nämlich die Rangfolge relevanter Pfade und die Qualität der erzeugten Antworten. MRR und MAP bewerten die Rangposition relevanter Treffer. Hit\@10 erfasst, ob relevante Treffer unter den ersten zehn Ergebnissen liegen. Für die Generierung bewertet gpt-4o-mini Comprehensiveness, Diversity, Empowerment und Directness. GraphTrace schneidet bei Directness am stärksten ab, ist aber nicht in jedem Kriterium oder jeder Hop-Kategorie führend. Eine ergänzende menschliche Bewertung umfasst 40 Stichproben und erreicht 67 % Übereinstimmung der Bewertenden @GraphTrace2025. Die Generierungsbewertung fokussiert damit Antwortqualität, misst aber Korrektheit und Quellentreue nicht unmittelbar. Diese Einschränkung sowie die kleine menschliche Stichprobe begrenzen, wie weit sich die Ergebnisse auf faktische Verlässlichkeit übertragen lassen.

Die Ergebnisse verschiedener Systeme sollten nicht allein anhand publizierter Ranglisten verglichen werden. GNN-RAG wird auf WebQSP und CWQ mit Answer-F1 bewertet, GraphTrace dagegen unter anderem mit Retrieval-Rankingmetriken auf EcoRAG. Datensatz, Graphabdeckung, Fragetypen und Bewertungsverfahren beeinflussen den gemessenen Leistungsgewinn. Aus dieser Gegenüberstellung leite ich für das Projekt ab, mehrere Verfahren auf derselben Frage- und Graphbasis zu testen und neben der Antwortqualität auch den Aufwand für Graphaufbau und Retrieval zu dokumentieren. Eine Aufteilung nach Pfadkomplexität ist ebenfalls wichtig, da ein Gesamtwert mögliche Unterschiede zwischen kurzen, mittleren und langen Pfaden verdecken kann.

== Graphqualität und Projektlücke

Die Qualität der Pfade hängt bereits davon ab, wie der Knowledge Graph entsteht und gepflegt wird. Ji et al. ordnen Konstruktion und Qualität als zentrale Aspekte des Graphlebenszyklus ein @Ji2022. Trajanoska et al. untersuchen die Erzeugung von Graphen aus unstrukturiertem Text und vergleichen LLM-gestützte Extraktion mit spezialisierten Verfahren @Trajanoska2023. Als Befund beschreiben diese Arbeiten damit die Bedeutung der Graphkonstruktion. Für meine dokumentenbasierte Fragestellung leite ich zusätzlich ab, dass Entitäten und Beziehungen mit ihren konkreten Belegstellen verknüpft und geprüft werden sollten.

Für die geplante Anwendung schlage ich vor, jede extrahierte Beziehung mit einer stabilen Herkunftsangabe zu speichern, etwa einer Dokumentkennung und einer Textstelle. So ließe sich unterscheiden, ob ein Pfad im Graphen formal existiert und ob die zugrunde liegenden Passagen seine Beziehungen tatsächlich stützen. Eine plausible Graphverbindung allein belegt noch nicht, dass die generierte Aussage von den Quelldokumenten getragen wird. Daraus leite ich ab, dass die Pfadbewertung neben der Relevanz für die Frage auch Zugänglichkeit und Qualität der Belege berücksichtigen sollte.

Für die Evaluation schlage ich ein mehrstufiges Vorgehen vor. Zunächst wäre die Graphkonstruktion zu prüfen, einschließlich der korrekten Extraktion von Entitäten und Beziehungen sowie gültiger Fundstellen für jede Kante. Danach ließe sich die Pfadsuche mit Retrievalmetriken wie MRR, MAP und Hit\@k bewerten. Für die generierte Antwort wären zusätzlich Korrektheit und Quellentreue zu messen. Jede zentrale Aussage sollte auf eine konkrete Textstelle zurückführbar sein. Die getrennte Auswertung könnte verhindern, dass eine gute Antwort Fehler bei der Graphkonstruktion oder Pfadwahl verdeckt.

Für einen fairen Vergleich wären dieselben Dokumente, Fragen und möglichst dieselben Generierungsbedingungen für alle Baselines erforderlich. Ablationen könnten den Beitrag von Fragenzerlegung, Pfadranking und Herkunftsverknüpfung isolieren. Die Auswertung sollte nach Hop-Zahl und Fragetopologie aufgeschlüsselt werden, da GraphTrace unterschiedliche Leistungen je nach Pfadkomplexität zeigt @GraphTrace2025. Eine ergänzende menschliche Prüfung könnte feststellen, ob die angezeigten Belege die Antwort tatsächlich stützen und nachvollziehbar sind. Damit würde die Untersuchung nicht nur fragen, welches System die beste Antwort erzeugt, sondern auch, warum die Dokumente diese Antwort tragen.

Ein weiterer Testfall sind widersprüchliche oder zeitlich unterschiedliche Quellen. Wenn Dokumente einer Beziehung verschiedene Werte oder Gültigkeitszeiträume zuordnen, darf die Graphkonstruktion diese Aussagen nicht unbemerkt zu einer einzigen Kante zusammenführen. Herkunftsangaben sollten daher mehrere Belegstellen und, soweit verfügbar, deren Datum erhalten. Bei der Antwortbewertung wäre zusätzlich zu prüfen, ob das System Unsicherheit oder Konflikte kenntlich macht, statt eine scheinbar eindeutige Antwort zu erzeugen. Damit wird Provenienz nicht nur als Link zum Dokument verstanden, sondern als Grundlage, die Aussagekraft und Grenzen eines Begründungspfads zu beurteilen.

Aus dieser Literatur leite ich drei Prüfpunkte für das Projekt ab. Die Qualität des konstruierten Graphen, die Relevanz der ausgewählten Pfade und die Treue der generierten Antwort zu den zugrunde liegenden Quellen. Im Mittelpunkt steht, wie Graphknoten und Beziehungen mit konkreten Dokumentstellen verknüpft werden können und ob diese Herkunftsinformation bis in die Antwort nachvollziehbar bleibt. Ablationen und Vergleiche auf gemeinsamen Datensätzen könnten zeigen, welche Module und Evidenzformen dazu beitragen.

#pagebreak()
#show bibliography: set text(size: 9pt, lang: "de")
#show bibliography: set par(spacing: 0pt, leading: .2em)
#bibliography("bibliography.bib", style: "ieee", title: "Referenzen")
