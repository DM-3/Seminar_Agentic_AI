#set page(
  paper: "a4",
  margin: (left: 35mm, right: 20mm, top: 20mm, bottom: 15mm),
  numbering: "1",
  footer: context {
    set text(fill: rgb("#666666"), size: 9pt)
    [Martin Werner]
    h(1fr)
    counter(page).display("1")
  }
)

#set text(font: "Arial", size: 10pt, lang: "de", bottom-edge: "descender", top-edge: "cap-height")
#set par(justify: true, leading: .45em)
#show link: set text(fill: rgb("#0077B6"))

#show heading: it => {
  set block(below: .7em, above: 1.2em)
  set text(hyphenate: false)
  set text(size: if it.level == 1 { 15pt } else if it.level == 2 { 13pt } else { 12pt })
  it
}

#set list(spacing: .6em)
#set enum(spacing: .6em, numbering: "1)")

#image("../TUBAF_typst_template/logos/TUBAF_Logo_blau.svg", width: 35mm)
#text(fill: rgb("#00497f"), size: 9pt)[*Fakultät für Mathematik und Informatik* \ Institut für Informatik]

#align(center)[
  #v(1em)
  #text(size: 16pt, weight: "bold", hyphenate: false)[Knowledge Graphen & GraphTrace] \
  #text(size: 11pt)[Projektseminar Agentic AI · Literaturrecherche]

  #text(size: 9pt)[Martin Werner · 23. November 2026]
  #v(1em)
]



=== Large Language Models

Für die Verarbeitung natürlicher Sprache durch Systeme der künstlichen Intelligenz stellen aktuell _pre-trained language models_ (PLM), insbesondere _pre-trained Transformer_, sehr viel versprechende Ansätze dar @LLMSurvey2026. Durch die sogenannten Skalierungsgesetze wird die Beobachtung ausgedrückt, dass die Modelle durch die Erhöhung der Anzahl an Parametern signifikant an Leistungsfähigkeit zunehmen und emergente Fähigkeiten, wie zum Beispiel _in-context learning_, aufweisen können @LLMSurvey2026.

Große Sprachmodelle (LLMs) können erstaunlich gut Texte in natürlicher Sprache und mit sehr gutem kontextuellem Verständnis ausgeben. Das Wissen was reine Sequenz-zu-Sequenz Sprachmodelle besitzen entstammt den Trainingsdaten und muss während des Trainings aufgenommen und damit implizit statisch in den Modellparametern gespeichert werden @LLMStruggles2023. Eine natürliche Folge ist, dass LLMs abhängig von der Gestalt der Trainingsdaten Wissenslücken aufweisen bei domänenspezifischen Fachfragen oder stark faktenbasierten Aufgaben @LLMStruggles2023. Unter anderem als Resultat von Wissenslücken kann das Phänomen des \"Halluzinierens\" auftreten @LLMHallucination2025, faktisch falsche und von der Anfrage abweichende Antworten. Eine Wissenslücke sind dabei auch immer aktuelle Informationen, die noch nicht in das Training einbezogen werden konnten.

=== Retrieval Augmented Generation
_Retrieval Augmented Generation_ (RAG), eingeführt von @RAG2021, zielt darauf ab die oben genannten Probleme zu lösen, indem beim Generieren von Sprachausgaben das parametrische Wissen des eigentlichen Sprachmodells durch nicht-parametrisches Wissen ergänzt wird. Bei der ursprünglichen Implementation von RAG übersetzt im _Retriever_-Teil ein _Query-Encoder_ die Nutzeranfrage und stellt im Abgleich mit einer externen Wissensbasis relevante Dokumente zusammen @RAG2021. Die best geeignetsten Dokumente werden gemeinsam mit der Nutzeranfrage an den Generator, ein vortrainiertes Sprachmodell, übergeben @RAG2021. RAG stellt eine Weiterentwicklung von _Retrieval Augmentation_ @REALM2020 dar und wurde seit seiner Einführung wiederum selbst in zahlreichen Abwandlungen erforscht @RAGSurvey2023.

Bei Anfragen welche die Komposition von Informationen aus einer Mehrzahl von Quelldokumenten benötigen spricht man von _Multi-hop_-Anfragen @RAGMultihopBench2024. Multi-hop-Anfragen stellen für herkömmliche RAG-Systeme eine erhebliche Schwierigkeit dar @RAGMultihopBench2024, da das Herstellen von Zusammenhängen zwischen den angesammelten Dokumenten allein dem Sprachmodell überlassen wird, beziehungsweise weil Informationen über die Struktur der Daten nicht abgedeckt werden @GRAG2025. 

=== Graph RAG
Einen geeigneteren Ansatz stellen graphenbasierte RAG Techniken dar @GraphRAG2025. Als Wissensbasis wird üblicherweise ein Knowledge-Graph verwendet. Abfragen werden zunächst übersetzt in relevante Knoten des Graphen und über die Kanten werden anhand verschiedener Verfahren weitere relevante Knoten angesammelt um diese schließlich wieder zu linearisieren und der Sprachgenerierung beizufügen @GRAG2025 @GraphRAG2025.

Die Frage nach dem Verfahren zur Auswahl der Knoten aus dem Graphen ist unter anderem Gegenstand von @ThinkOnGraph2024 und @GraphTrace2025, wobei letztere ein konkretes Verfahren zur Pfadsuche zwischen mehreren hervorgehobenen Knoten beschreiben.

=== Knowledge Graphs
@GraphTrace2025 zitiert @KGConstruction2024 zur Beschreibung eines Verfahren für die Erstellung von Knowledge-Graphen. Dabei werden aus den zugrundeliegenden Dokumenten mittels eines weiteren LLMs Teilbeziehungen zwischen Entitäten extrahiert und zu einem Graphen zusammengefügt.

Die Erstellung eines Knowledge Graphen für das Anwendungsbeispiel technischer Dokumentation, wie es in dieser Arbeit umgesetzt werden soll, wird in @DocuRAG2026 beschrieben. Hinzu kommt die Herausforderung neben Textbasierten Quelldokumenten auch Bilder und eventuell andere Dateitypen mit einzubeziehen, wofür @MultiModalRAG2023 das _Multi-Model-RAG_ einführt.

#v(1cm)
#bibliography("../bibliography/references.bib")
