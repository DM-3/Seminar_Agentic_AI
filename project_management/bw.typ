#set page(
  paper: "a4",
  margin: (left: 2cm, right: 2cm, top: 18mm, bottom: 12mm),
  header: {
    set text(fill: rgb("#666666"))
    [Ben Weckend 67551]
    h(1fr)
    [Projektseminar Agentic AI]
    h(1fr)
    [#datetime.today().display("[day].[month].[year]")]
  }
)

#set text(font: "Arial", size: 10pt, lang: "de", bottom-edge: "descender", top-edge: "cap-height")
#set par(justify: true, leading: .5em)

#show heading: it => {
  set block(below: 0.5em, above: 1em)
  set text(hyphenate: false)
  set text(size: 16pt)
  it
}

#set list(spacing: 0.5em)
#set enum(spacing: 0.5em, numbering: "1)")

#show link: it => box(stroke: 0.3pt + red, inset: 2pt, outset: 0pt)[#it]

#v(2em)
= Projektmanagement: Knowledge Graphen & GraphTrace
#v(0.8em, weak: true)
#line(length: 100%, stroke: 0.5pt)
#v(0.5em)


== Projektidee und Ziel

Bei komplexen Fragestellungen müssen häufig Informationen aus mehreren Textstellen miteinander verknüpft werden. Knowledge Graphen bilden dafür Entitäten und ihre Beziehungen strukturiert ab. Das Framework GraphTrace nutzt solche Verbindungen, um relevante Informationen für die Beantwortung von Fragen zu finden und einem Sprachmodell bereitzustellen. Im Projekt soll untersucht werden, wie sich dieser Ansatz auf Dokumentensammlungen anwenden und nachvollziehbarer gestalten lässt.

Dafür gibt es drei vorgegebene inhaltliche Schwerpunkte: erstens sollen verschiedene Ansätze zur Generierung von Knowledge Graphen aus Dokumenten untersucht und Möglichkeiten zur Verbesserung ihrer Qualität erprobt werden. Zweitens sollen Knoten und Beziehungen auf konkrete Fundstellen in den Ausgangsdokumenten verweisen. Drittens soll GraphTrace so erweitert werden, dass bei der Beantwortung einer Frage neben dem Ergebnis auch die verwendeten Graphverbindungen und Textbelege erkennbar sind. Das Ziel dieser Projektarbeit ist ein Prototyp, an dem sich diese drei Aspekte gemeinsam untersuchen lassen.

Besondes Interressant wäre es ein System zu entwickeln, das Fragen zu technischen Geräten oder komplexen Systemen anhand ihrer Dokumentation beantwortet. Beispielsweise könnten Bedienungsanleitungen, Wartungshandbücher oder technische Spezifikationen als Grundlage dienen.

Vorteile dieser Anwendung:
- Gut abgrenzbarer Anwendungsbereich.
- Viele mögliche Beziehungen zwischen Entitäten.
- Multi-Hop-Fragen lassen sich sinnvoll konstruieren.

== Geplantes Vorgehen

Für die Umsetzung halte ich ein schrittweises Vorgehen mit klaren Zwischenergebnissen für sinnvoll. Zu Beginn sollte das vorgegebene #link("https://www.mdpi.com/2073-431x/14/9/382")[GraphTrace-Paper] und die verfügbare #link("https://github.com/AnnaO8/kg-llm-ir")[Implementierung] untersucht werden. Die ursprüngliche Version dient anschließend als Ausgangspunkt, um Veränderungen später beurteilen zu können.

Darauf aufbauend wird zunächst eine einfache Verarbeitung vom Dokument zum Graphen umgesetzt. Dabei sollen die Herkunft und die Fundstellen extrahierter Informationen bereits berücksichtigt werden, damit diese später eindeutig zugeordnet werden können. Anschließend werden die Qualität der erzeugten Graphen untersucht und mögliche Verbesserungen erprobt. Danach folgt die Erweiterung von GraphTrace, sodass Fragen mithilfe der Graphinformationen beantwortet und die zugehörigen Textbelege ausgegeben werden können.

== Zusammenarbeit und Projektsteuerung

Die Aufgabenverteilung sollte sich an den Arbeitsbereichen Dokumentenverarbeitung, Graphaufbau, GraphTrace-Erweiterung und Auswertung orientieren.
Für die Organisation, Projektbearbeitung und Dokumentation bietet sich ein gemeinsames GitHub-Repository an. Aufgaben könnten über Issues verteilt und der jeweilige Bearbeitungsstand nachvollziehbar festgehalten werden.


== Überprüfung und angestrebtes Ergebnis

Die Bewertung sollte anhand zuvor festgelegter Testfälle erfolgen. Dabei wird getrennt untersucht, wie korrekt die extrahierten Entitäten und Beziehungen sind, ob die Quellenverweise auf passende Textstellen führen und inwieweit die generierten Antworten durch diese Belege gestützt werden. Dafür können ausgewählte Graphinformationen und Antworten manuell überprüft werden.

Ein Vergleich mit der ursprünglichen GraphTrace-Version unter möglichst gleichen Testbedingungen soll den Nutzen unserer Erweiterungen sichtbar machen. Da die größte Gefahr in einem zu umfangreichen Vorhaben liegt, hat ein kleiner, durchgehend funktionierender Prototyp Vorrang vor weiteren Funktionen. Als Abschluss sind eine nachvollziehbare Demonstration und eine dokumentierte Auswertung der Ergebnisse vorgesehen.
