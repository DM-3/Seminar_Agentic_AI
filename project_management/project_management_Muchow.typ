#set page(
  paper: "a4", 
  margin: (left: 2cm, right: 2cm, top: 18mm, bottom: 12mm),
  footer: {
    set text(fill: rgb("#666666"))
    [Björn Maximilian Muchow]
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

= Fachliche Ausrichtung und Zielvorstellung
Ausgangspunkt unserer Arbeit ist das Paper „GraphTrace: A Modular Retrieval Framework Combining Knowledge Graphs and Large Language Models for Multi-Hop Question Answering“ von Osipjan et al. (2025)@GraphTrace2025. Besonders interessant finde ich dabei die Verbindung von Knowledge Graphs mit Large Language Models, um Informationen nicht nur textbasiert abzurufen, sondern auch Beziehungen zwischen verschiedenen Wissenselementen auszunutzen.

Ich würde diesen Ansatz gerne aus der Perspektive der Robotik betrachten. Im Bereich Physical AI müssen KI-Systeme ihre Umgebung erfassen, vorhandenes Wissen einordnen und daraus sinnvolle Handlungen ableiten können. Knowledge Graphs könnten dabei beispielsweise Informationen über Objekte, deren Eigenschaften, räumliche Beziehungen oder die Fähigkeiten eines Roboters strukturiert bereitstellen. Darauf aufbauend ließe sich untersuchen, welchen Beitrag Verfahren wie GraphTrace zur semantischen Umgebungsinterpretation und zur übergeordneten Aufgabenplanung leisten können.

= Zusammenarbeit
Zu Beginn sollten wir als Gruppe ein gemeinsames Verständnis davon entwickeln, was wir untersuchen und welches Ergebnis am Ende stehen soll. Anschließend bietet es sich an, die Arbeit in thematische Abschnitte aufzuteilen. Dabei sollten wir nicht nur Verantwortlichkeiten festlegen, sondern auch klären, welche Inhalte aufeinander aufbauen und wie die einzelnen Beiträge in der Gesamtarbeit zusammengeführt werden.

Für die Literaturrecherche halte ich eine zunächst individuelle Bearbeitung für sinnvoll. Damit die Ergebnisse später vergleichbar sind, sollten wir vorher gemeinsame Kriterien für die Suche und Bewertung wissenschaftlicher Quellen vereinbaren. Die PRISMA-2020-Leitlinie @PRISMA_2020 kann hierfür als Orientierung dienen. Kriterien müssten allerdings an unsere konkrete Projektarbeit angepasst werden. Die gefundenen Veröffentlichungen und Rechercheergebnisse sollten anschließend zentral gesammelt und gemeinsam ausgewertet werden.

= Organisation und Präsentation

Ein weiterer Bestandteil soll die Entwicklung einer gemeinsamen GUI sein. Bereits vor der Implementierung sollte sich jedes Gruppenmitglied überlegen, welche Funktionen die Oberfläche erfüllen könnte und wie eine sinnvolle Bedienung aussehen würde. Da ich technische Konzepte bevorzugt gemeinsam erarbeite, würde ich vor dem Programmierbeginn gerne mindestens ein Treffen in Präsenz einplanen. Dort können wir Entwürfe vergleichen, eine gemeinsame Richtung bestimmen und Schnittstellen sowie Aufgabenverteilung abstimmen.

Als zentrale Arbeitsplattform haben wir bereits ein gemeinsames Git-Repository. Dort werden wir Quellcode, Dokumentation, Literatur und Präsentationsmaterial gebündelt verwalten. Für kurzfristige Absprachen und die laufende Kommunikation greifen wir auf eine WhatsApp-Gruppe zurück.

Für ein einheitliches Erscheinungsbild sollten wir möglichst früh eine Präsentationsvorlage festlegen. Dabei können wir auf eine vorhandene Vorlage der Universität zurückgreifen oder bei Bedarf eine eigene erstellen. Inhaltlich würde ich die Vorträge an der Gliederung der schriftlichen Arbeit ausrichten. Die Folien erstellt jedes Gruppenmitglied für seinen jeweiligen Themenbereich selbst. Die gemeinsame Vorlage und eine abschließende Abstimmung sorgen für einen zusammenhängenden Gesamtvortrag.


#bibliography("../bibliography/references.bib", title: "Referenzen")