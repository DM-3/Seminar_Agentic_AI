#set page(
  paper: "a4", 
  margin: (left: 2cm, right: 2cm, top: 18mm, bottom: 12mm),
  footer: {
    set text(fill: rgb("#666666"))
    [Martin Werner (67641)]
    h(1fr)
    [Projektseminar Agentic AI]
    h(1fr)
    [#datetime.today().display("[day].[month].[year]")]
  }
)

#set text(font: "Arial", size: 10pt, lang: "de", bottom-edge: "descender", top-edge: "cap-height")
#set par(justify: true, leading: .5em)   // 1.5 line spacing

#show heading: it => {
  set block(below: 0.5em, above: 1em)
  set text(hyphenate: false)
  set text(size: 16pt)
  it
}

#set list(spacing: 0.5em)
#set enum(spacing: 0.5em, numbering: "1)")


= Projektseminar Agentic AI -- Projekt Management \ Knowledge Graphen & GraphTrace
#v(0.8em, weak: true)
#line(length: 100%, stroke: 0.5pt)
#v(0.5em)

= Projektziel
Im Rahmen des Projektseminars Agentic AI soll zum Thema "Knowledge Graphen & GraphTrace" eine wissenschaftliche Arbeit angefertigt werden. Als Hauptquelle soll der Artikel "GraphTrace: A Modular Retrieval Framework Combining Knowledge Graphs and Large Language Models for Multi-Hop Question Answering" @GraphTrace2025 herangezogen werden, welcher GraphTrace vorstellt als neuartiges Framework zur Abrufung von Informationen bei komplexen Fragestellungen, unter Nutzung von Knowledge Graphen und Large Language Models.

Für die eigene Arbeit mögen grob drei Ziele verfolgt werden. Das erste Ziel ist das Untersuchen von Methoden zur Erstellung von Knowledge Graphen aus Dateiinhalten und der Vergleich dieser Methoden hinsichtlich der Qualität der Graphen. Das zweite Ziel ist die Erweiterung von Knowledge Graphen um Referenzen auf die Quellen der Informationen in den zugrundeliegenden Dateien. Diese Referenzen sollen dann auch bei Abrufung von Informationen aus dem Knowledge Graphen mit aufgeführt werden, um die Erklärbarkeit der Ausgaben von Systemen wie GraphTrace zu verbessern. Zuletzt sollte ein Ziel sein das bessere Verstehen von GraphTrace selbst, sowie möglicherweise die Untersuchung von Modifikation zur Verbesserung. So wäre eventuell denkbar, dass eine andere Architektur des Abrufmechanismus' noch bessere Resultate erzielen könnte, aber auch der Algorithmus für die Pfadsuche auf dem Knowledge Graphen, sowie die Gestaltung der Systemprompts für die Entity Extraction und Query Decomposition könnten im Detail untersucht werden. Letzteres Ziel sehe ich persönlich als am spannendsten an, mit dem Potential auch durch eigene Ideen zur Weiterentwicklung derartiger Systeme beizutragen.

= Zusammenarbeit
Nach diesen individuellen Überlegungen zum Management des Projektes und zur möglichen Zielsetzung, besteht der erste Schritt der Zusammenarbeit in der Gruppe darin, sich gemeinsam auf ein Projektziel zu einigen. Alle Gruppenmitglieder sollten dann, ebenfalls individuell, Literatur zum Thema recherchieren, die anschließend zusammengetragen wird. So können hoffentlich die Lücken bei der Recherche größtenteils geschlossen werden. Das Zusammentragen erfolgt in Form einer BibTex Datei, die jeder mit einem Werkzeug seiner Wahl (in meinem Fall JabRef) verwalten möge. Eine Checkliste für jede Quelle sollte als Kommentar beigefügt werden -- da das Prisma Schema auf \"systematic review paper\" ausgelegt ist @PRISMA_2020 sollten wir uns hier auf eine eigene Checkliste einigen.

Die Versionsverwaltung von Quellcode und schriftlichen Ausarbeitungen, sowie Präsentationen und Literaturverzeichnis erfolgt über ein gemeinsames Repository auf Github. Dies vereinfacht das gemeinsame Arbeiten, das Nachvollziehen von Änderungen, sowie aber auch die Koordination der Aufgabenverteilung über Issues. Die Arbeit und Präsentationen sollen mit der Beschreibungssprache Typst erstellt werden, welche Ausgaben gleich zu LaTex erstellt, jedoch sehr bequem auch lokal genutzt werden kann.
Für die Umsetzung in Code gilt es zunächst das System aus @GraphTrace2025, sowie die darin beschriebene Generierung des verwendeten Knowledge Graphen, zu rekonstruieren. Gleichzeitig kann bereits das Kapitel zu den Grundlagen und dem Stand der Technik verfasst werden. Darauf aufbauend werden dann die entsprechenden Erweiterungen für das festgelegte Projektziel vorgenommen und Ergebnisse dokumentiert.


#bibliography("../bibliography/references.bib", title: "Referenzen")
