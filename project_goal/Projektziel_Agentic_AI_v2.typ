#set page(
  paper: "a4", 
  margin: (left: 2cm, right: 2cm, top: 18mm, bottom: 16mm),
  footer: {
    set text(fill: rgb("#666666"))
    [Görg · Muchow · Werner · Weckend]
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

#let table-style = (
  inset: (x: 4pt, y: 3pt),
  stroke: 0.45pt + rgb("#C9C9C9"),
  fill: (x, y) => if y == 0 { rgb("#EEEEEE") } else { white },
)


= Projektseminar Agentic AI -- Projektziel \
Knowledge Graphen & GraphTrace
#v(0.8em, weak: true)
#line(length: 100%, stroke: 0.5pt)
#v(0.5em)

#set heading(numbering: "1.")
= Projektvision und gemeinsame Ziele

*Welches Problem lösen wir?* \
Technische Dokumentationen enthalten Informationen über Komponenten, Funktionen und Zusammenhänge, die über verschiedene Textstellen verteilt sind. Die Beantwortung komplexer Fragen erfordert daher oft die Verknüpfung mehrerer Informationen. Zugleich ist bei KI-generierten Antworten häufig schwer zu erkennen, welche Textstellen und Beziehungen das Ergebnis stützen.

Als methodische Grundlage dient GraphTrace nach dem Paper: „GraphTrace: A Modular Retrieval Framework Combining Knowledge Graphs and Large Language Models for Multi-Hop Question Answering“, von A. Osipjan, H. Khorashadizadeh, A.-L. Kessel, S. Groppe, und J. Groppe @GraphTrace2025.

*Gemeinsames Projektziel:* \
Wir entwickeln und evaluieren einen Prototyp, der aus technischen Dokumentationen einmalig einen Knowledge Graph aufbaut und mithilfe von GraphTrace, sowie neuen von uns in GraphTrace implementierten Funktionen, komplexe Multi-Hop-Fragen beantwortet. Die genutzten Graphpfade sowie ihre Fundstellen in den Quelldokumenten sollen nachvollziehbar dargestellt werden.

*Angestrebtes Produkt:* \
Eine lokal ausführbare Verarbeitungskette von technischen Dokumenten über den Knowledge Graph und GraphTrace bis zur Antwort mit überprüfbaren Quellenbelegen. Eine grafische Oberfläche (GUI) soll Antwort, relevante Beziehungen und Textbelege zusammen anzeigen. Unter „Erklärbarkeit“ verstehen wir die Nachvollziehbarkeit anhand von Graphpfaden und Quellen, nicht die vollständige Offenlegung interner LLM-Entscheidungsprozesse.

*Konkrete Teilziele:* 
+ GraphTrace lokal lauffähig einrichten
+ Verfahren zur Erzeugung und Verbesserung dokumentenbasierter Knowledge Graphs untersuchen
+ Knoten und Beziehungen mit Quelldokumenten und Fundstellen verknüpfen
+ GraphTrace und eine GUI für die Ausgabe dieser Belege erweitern
+ Qualität, Korrektheit und Nachvollziehbarkeit anhand definierter Testfragen evaluieren

= Aufgabenverteilung

Die folgende Aufteilung ist ein *konkreter Vorschlag auf Grundlage der bisherigen Interessen und Planungen*, aber noch keine bestätigte Zuweisung. Die Gruppe beschließt die endgültigen Verantwortlichkeiten und Vertretungen beim nächsten Treffen. Alle Mitglieder beteiligen sich an Literaturrecherche, Tests und gegenseitigen Reviews.

#table(
  columns: (1.05fr, 2.55fr, 1.45fr, 0.6fr),
  ..table-style,
  table.header([*Mitglied*], [*Vorgeschlagene Hauptverantwortung*], [*Ergebnis / Schnittstelle*], [*Prio*]),
  [Felix Görg], [GraphTrace lokal einrichten; Rechnerbetrieb und abgesicherter SSH-Zugang; technische Integration], [Lauffähige, dokumentierte GraphTrace-Umgebung], [Hoch],
  [Martin Werner], [Verfahren zur Knowledge-Graph-Generierung; Strukturierung und Herkunftsmetadaten; GraphTrace erweitern], [Knowledge Graph mit Quellenverweisen], [Hoch],
  [Björn M. Muchow], [GUI-Konzept, Visualisierung der Graphpfade und Quellen; gemeinsame Darstellung], [Bedienbare Demonstrationsoberfläche], [Hoch],
  [Ben Weckend], [Technische Dokumente, Testfragen, Evaluationskonzept und Ergebnisprüfung], [Testdatensatz und reproduzierbare Auswertung], [Hoch],
)

= Projektplanung und Meilensteine

Die Umsetzung folgt dem gemeinsam besprochenden Ablaufdiagramm. Die Nummern 0.5 bis 4 bezeichnen die dort vereinbarten Arbeitsblöcke; nicht alle Arbeiten laufen strikt nacheinander. Literaturrecherche und GUI-Konzeption können teilweise parallel zur technischen Entwicklung stattfinden.

#table(
  columns: (0.75fr, 1.65fr, 3.55fr),
  ..table-style,
  table.header([*Schritt*], [*Arbeitsbereich*], [*Geplantes Ergebnis*]),
  [0.5], [Planung / Recherche], [Gemeinsame Such- und Bewertungskriterien, tabellarischer Paperkatalog, Auswahlkriterien für Dokumente und Testfragen.],
  [1], [GraphTrace-Basis], [Originalimplementierung lokal ausführen; Teamzugriff über abgesichertes SSH; Installation dokumentieren.],
  [2], [Knowledge Graphs / Literatur / GUI-Entwurf], [Technische Dokumentation auswählen, Knowledge Graph erzeugen und prüfen; Quellenreferenzen zu Textstellen ergänzen. Parallel: Literaturvertiefung und gemeinsames GUI-Visionboard.],
  [3], [GUI mit Referenzen], [Antworten, benutzte Graphpfade und passende Dokumentfundstellen sichtbar und bedienbar machen.],
  [4], [GraphTrace modifizieren], [GraphTrace auf den dokumentenbasierten Graphen und die Quellenmetadaten anpassen; bei ausreichender Zeit weitere begründete Änderungen untersuchen.],
  [—], [Test / Abschluss], [Definierte Multi-Hop-Fragen ausführen, Fehler beheben, Veränderungen beurteilen, Demonstration und Abschlussdokumentation erstellen.],
)

== Zeitplan mit Terminen

Die folgenden *internen Meilensteine sind Planungsvorschläge*. Die vier Seminar-Termine stammen aus dem bisherigen Einzelentwurf und müssen vor Abgabe anhand der offiziellen Seminarplanung bestätigt werden. Der Zeitplan enthält einen Puffer für Integration, Fehlerbehebung und Nacharbeit.

#table(
  columns: (1.15fr, 1.3fr, 3.7fr, 1fr),
  ..table-style,
  table.header([*Termin*], [*Phase*], [*Meilenstein / Abgabe*], [*Status*]),
  [12.11.2026], [Planung], [Kriterien der Literaturrecherche, Rollen und Dokumentenauswahl abgestimmt.], [Intern],
  [23.11.2026], [Planung], [Gemeinsame Projektmanagement-Ausarbeitung eingereicht.], [Seminar],
  [04.12.2026], [Konzeption], [GraphTrace lokal lauffähig; SSH-Zugriff und Einrichtung dokumentiert.], [Intern],
  [16.12.2026], [Zwischenstand], [Zwischenvortrag: Architektur, Datenbasis und erste Tests.], [Seminar],
  [08.01.2027], [Entwicklung], [Erster Knowledge Graph aus technischen Dokumenten erzeugt und geprüft.], [Intern],
  [22.01.2027], [Entwicklung], [Quellenreferenzen integriert; GUI-Prototyp und GraphTrace-Anbindung vorhanden.], [Intern],
  [03.02.2027], [Testing / Puffer], [Testfragen ausgewertet; Fehlerbehebung und Präsentation vorbereitet.], [Intern],
  [10.02.2027], [Abschlussvortrag], [Demonstration des Systems und Vorstellung der Evaluation.], [Seminar],
  [15.03.2027], [Abschluss], [Schriftliche Ausarbeitung abgeschlossen und abgegeben.], [Seminar],
)

#text(size: 7.8pt, fill: rgb("#5B6672"))[Hinweis: „Intern“ = durch die Gruppe zu bestätigender Plantermin; „Seminar“ = aus einem früheren Einzelentwurf übernommener Termin, mit offiziellen Angaben abzugleichen.]

= Kommunikation und Zusammenarbeit

Die laufende Kommunikation erfolgt über die bestehende *WhatsApp-Gruppe* und über *discord*. Für größere Entscheidungen, Architekturabstimmung und Fortschrittskontrolle planen wir *mindestens alle zwei Wochen ein Treffen*. Ergebnisse und offene Entscheidungen werden knapp protokolliert. Vor der Implementierung stimmen wir Datenformat, Schnittstellen und Aufgabenübergaben gemeinsam ab.

Das bestehende *GitHub-Repository*#footnote[https://github.com/DM-3/Seminar_Agentic_AI] ist die zentrale Plattform für Code, Issues, Aufgabenstatus, Literatur und Dokumentation. Änderungen werden in nachvollziehbaren Commits und nach Möglichkeit per gegenseitigem Review integriert. Über die Sinnhaftigkeit eines CHANGELOGs werden wir intern noch diskutieren. Zu jeder Komponente gehören ein kurzer Eintrag im README, Hinweise zur Ausführung und geeignete Tests. Die Literaturrecherche wird in Form einer BibTeX-Datei zusammengetragen. Zu jeder Quelle werden wichtige Kriterien tabellarisch dokumentiert. Dafür haben wir uns auf eine modifizierte Version der Checkliste aus @PRISMA_2020 geeinigt und diese mit dem Betreuer abgesprochen. Ausarbeitung und Präsentationen erstellen wir mit einheitlichen Typst-Vorlagen.


Es besteht die Möglichkeit Felix' Rechner ist als gemeinsame Entwicklungsumgebung zu verwenden. Der SSH-Zugriff erfolgt ausschließlich mit individuellen Zugängen und geeigneter Absicherung. Konfigurationsgeheimnisse werden nicht im Repository abgelegt. Als Alternative muss noch diskutiert werden ob das Projekt auf den Rechnern des PC Pools der Uni laufen lässt, oder falls es sich als Sinnhaft ergibt auf dem Cluster der TU Freiberg.

= Risiken und Lösungen

#table(
  columns: (1.55fr, 2.15fr, 3fr),
  ..table-style,
  table.header([*Risiko*], [*Mögliche Auswirkung*], [*Vorbeugung / Gegenmaßnahme*]),
  [Abhängigkeit von einem Rechner], [Ausfall oder fehlender SSH-Zugriff blockiert Arbeiten.], [Installation und Abhängigkeiten dokumentieren; Sicherung im Repository; reduzierte lokale Alternative vorbereiten.],
  [Schwierige Dokumentenverarbeitung], [Unvollständige oder fehlerhafte Entitäten und Beziehungen.], [Mit kleiner, gut prüfbarer Dokumentensammlung beginnen. stichproben manuell bewerten.],
  [Fehlerhafte Quellenzuordnung], [Antworten wirken belegt, obwohl Fundstellen nicht passen.], [Quell-IDs und Fundstellen bei der Extraktion mitführen. Quellenverweise separat testen.],
  [Zeitverzug / zu großer Umfang], [Integration oder Abschluss gerät in Gefahr.], [Kernpipeline priorisieren; optionale Retrieval-Experimente zurückstellen; Test- und Zeitpuffer einplanen.],
  [Kommunikationsprobleme / Ausfall], [Unklare Schnittstellen, doppelte Arbeit oder Stillstand.], [Regelmäßige Meetings, Issues, dokumentierte Entscheidungen und Stellvertretungen.],
)

= Gemeinsames Erfolgsziel und nächste Schritte

*Projektabschluss:* Ein demonstrierbarer Prototyp samt dokumentiertem Code, ausgewählter technischer Dokumentensammlung, Knowledge Graph, GraphTrace-Anbindung, Quellenreferenzen und GUI liegt vor. Hinzu kommen dokumentierte Testfälle, Auswertung, Zwischen- und Abschlussvortrag sowie die schriftliche Ausarbeitung.

*Erfolgskriterien:* Die Pipeline:

*Dokument → Knowledge Graph → GraphTrace → Antwort mit Graphpfad und Quellenbeleg* 

funktioniert reproduzierbar. Die Herkunft der für die Antwort verwendeten Graphinformationen lässt sich auf konkrete Fundstellen zurückführen. An vorab festgelegten Multi-Hop-Testfragen werden (1) Entitäts- und Relationsqualität, (2) Passgenauigkeit der Quellen, (3) Antwortkorrektheit sowie (4) Übereinstimmung zwischen Antwort und Textbeleg geprüft. Soweit machbar, vergleichen wir die angepasste Version unter gleichen Bedingungen mit GraphTrace ohne unsere Erweiterungen. Eine Qualitätssteigerung ist eine zu prüfende Hypothese, keine vorausgesetzte Eigenschaft.

*Qualitätsansprüche:* Reproduzierbare Installationsschritte, nachvollziehbare Quellen und Literaturangaben, konsistente Datenformate, verständliche GUI, versionierter Code und eine transparente Dokumentation auch fehlgeschlagener Tests.

*Nächste Schritte:* 
+ Rollen und interne Termine verbindlich bestätigen
+ gemeinsame Literatur- und Auswahlkriterien beschließen
+ Dokumente und erste Testfragen auswählen
+ GraphTrace auf dem vorgesehenen Rechner starten und die Schnittstellen für den Knowledge Graph sowie Quellenreferenzen festlegen

#bibliography("../bibliography/references.bib", title: "Referenzen")


