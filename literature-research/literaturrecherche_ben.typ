#import "../TUBAF_typst_template/tubaf_template.typ" as tubaf

#show strong: set text(weight: "regular")
//#show heading: set text(weight: "regular")


// function for list of tables
#let table_outline() = {
  show outline: set heading(outlined: true)
  outline(title: "Tabellenverzeichnis", target: figure.where(kind: table))
}


// function for table of symbols and acronyms
//#let table_of_symbols() = {
//  show outline: set heading(outlined: true)
//  outline(
//    title: "Symbol- und Abkürzungsverzeichnis",
//    target: figure.where(caption: "-")
//  )
//
//  text()[*Formelzeichen*]
//  grid(
//    columns: (1fr, 1cm, 8fr),
//    gutter: .5em,
//    $bb(Z)$, "", [Menge der ganzen Zahlen],
//    $bb(R)$, "", [Menge der reellen Zahlen],
//  )
//
//  linebreak()
//  text()[*Abkürzungen*]
//  grid(
//    columns: (1fr, 1cm, 8fr),
//    gutter: .5em,
//    "Cobot", "", [kollaborativer Roboter],
//  )
//}


// report template
#show: tubaf.report.with(
  type: "Literaturrecherche",
  title: "Knowledge-Graphen und GraphTrace",
  subtitle: "Knowledge-Graph-basierte Fragebeantwortung: Stand der Forschung zu Graphgenerierung, Retrieval und Erklärbarkeit",
  authors: ((
    name: "Ben Weckend",
    studentID: "67551",
  ),),
  supervisors: ((
    title: "M. Sc.",
    name: "Pascal Biegemann",
  ),),
  examiners: ((
    title: "Prof. Dr.",
    name: "Sven Groppe",
  ),),
  lang: "de",
  list-of-images: false,
  heading-pagebreak: false,
  heading-sizes: (14pt, 12pt, 11pt),
  //extra_outlines: (table_outline, table_of_symbols,),
  references: "../bibliography/lit_rech_references.bib"
)


= Thema und Ziel der Literaturrecherche

Wer eine technische Dokumentation durchsucht, findet die Antwort auf eine Frage oft nicht an einer einzigen Stelle. Eine Fehlerbeschreibung kann beispielsweise auf eine Komponente verweisen, deren Funktion erst in einem anderen Kapitel erklärt wird. Für solche Fragen reicht es nicht immer, einzelne Textabschnitte nach Ähnlichkeit zu suchen. Die Zusammenhänge zwischen ihnen sind ebenso wichtig.

Im Projektseminar soll deshalb die bestehende GraphTrace-Implementierung @Anna auf technische Dokumentationen angewendet und erweitert werden. GraphTrace sucht in einem Knowledge-Graphen nach relevanten Verbindungen zwischen Entitäten und verwendet diese für die Beantwortung mehrstufiger Fragen @GraphTrace2025. Neben der Antwortqualität interessiert uns besonders, ob sich die verwendeten Informationen bis zu konkreten Stellen im Ausgangsdokument zurückverfolgen lassen. Dazu betrachten wir Verfahren für Graphaufbau, Retrieval und Quellenbelege.

= Stand der Forschung

== Von technischen Dokumenten zum Knowledge-Graphen

Bevor GraphTrace eine Frage bearbeiten kann, muss ein geeigneter Knowledge-Graph vorhanden sein. Gerade bei technischen PDFs ist dessen Erstellung nicht selbstverständlich: Neben Fließtext enthalten sie häufig Tabellen, Abbildungen oder Anweisungen, deren Bedeutung vom Layout abhängt. MinerU beschäftigt sich mit der Extraktion solcher Dokumentinhalte @wang2024mineruopensourcesolutionprecise. LayoutLMv3 berücksichtigt zusätzlich visuelle Informationen beim Dokumentverständnis @ACM_Conference. Für uns wären sie dann interessant, wenn eine rein textbasierte Verarbeitung Informationen verliert. Beziehungen zwischen Entitäten erkennen sie damit noch nicht automatisch.

Liu und Lu untersuchen dieses Problem direkt für industrielle Wartungshandbücher @liu2024taskcentric. Ihr Ansatz modelliert nicht nur einzelne Bauteile, sondern auch Fehlerursachen, Symptome sowie Diagnose- und Reparaturaufgaben. Dafür werden Textmerkmale mit visuellen und räumlichen Informationen kombiniert. Für unser Projekt ist daran besonders relevant, wie das Graphschema an die Inhalte der Wartungshandbücher angepasst wird Die vollständige Architektur wäre für unseren Prototyp zu aufwendig, ihr Graphschema könnte uns aber als Orientierung dienen.

Für die automatische Extraktion von Beziehungen ist REBEL ein möglicher Ausgangspunkt: Das Modell erzeugt aus Texten Tripel aus Entität, Beziehung und Entität @huguet-cabot-navigli-2021-rebel-relation. Schwieriger ist die Frage, worauf eine erkannte Beziehung beruht. Hier setzt EIDER an. Das Verfahren erkennt neben dokumentweiten Beziehungen auch Sätze, die als Belege für diese Beziehungen dienen, und verwendet diese Evidenz bei der Vorhersage @xie-etal-2022-eider. Für uns ist vor allem das Prinzip interessant: Eine Graphkante sollte möglichst schon bei ihrer Erstellung mit einer Fundstelle verbunden werden. Die Fundstelle wäre anschließend noch auf ihre Aussagekraft zu prüfen.

== Graphbasiertes Retrieval und GraphTrace

Auch mit einem guten Knowledge-Graphen bleibt offen, wie die für eine Frage passenden Informationen gefunden werden. GraphTrace zerlegt eine Anfrage in Teilfragen, sucht verbindende Graphpfade und bewertet deren Relevanz, bevor ausgewählte Pfade an das Sprachmodell weitergegeben werden @GraphTrace2025.

Andere Arbeiten verfolgen teils andere Ziele. Microsoft GraphRAG bildet aus Dokumentbeständen Graphstrukturen und Community Zusammenfassungen, um eher übergreifende Fragen zu beantworten @edge2025localglobalgraphrag. HippoRAG nutzt unter anderem Personalized PageRank, während LightRAG graphbasierte und vektorbasierte Suche verbindet @NEURIPS2024_6ddc001d @guo-etal-2025-lightrag. Diese Ansätze bieten Vergleichspunkte, sind wegen ihrer unterschiedlichen Ziele aber keine direkt austauschbaren Komponenten.

Besonders nah an unserer Idee liegt KG²RAG. Dort werden Graphtripel bereits mit den Textabschnitten verknüpft, aus denen sie gewonnen wurden. Nach einer ersten semantischen Suche können weitere Abschnitte über Graphbeziehungen erschlossen und gemeinsam für die Antwort aufbereitet werden @zhu-etal-2025-knowledge. Für GraphTrace könnte ein ähnlicher Zusammenhang zwischen Graphpfad und Originaltext nützlich sein. Wir möchten zunächst die vorhandene Pfadsuche um passende Dokumentstellen ergänzen, statt das Retrieval zu ersetzen.

== Quellenbelege und nachvollziehbare Antworten

Ein angezeigter Graphpfad macht sichtbar, welche Beziehungen das System verwendet hat. Er beantwortet aber noch nicht die Frage, ob diese Beziehungen tatsächlich in den Ausgangsdokumenten stehen. Unter Nachvollziehbarkeit verstehen wir deshalb vor allem die Möglichkeit, Aussagen anhand konkreter Textstellen zu überprüfen. Die internen Entscheidungen des Sprachmodells lassen sich damit nicht vollständig erklären.

Wie eine solche Darstellung aussehen kann, zeigt SemanticRAG. Das System erlaubt, Antworten verschiedener Retrieval-Verfahren gegenüberzustellen und deren Herkunft in einer Benutzeroberfläche einzusehen @sapidis2026semanticrag. Das bietet Anregungen für unsere GUI, ohne dass wir das System nachbauen müssen. Für die Bewertung solcher Systeme ist KILT relevant, da dort neben der Antwort auch die Herkunft der verwendeten Informationen berücksichtigt wird @petroni-etal-2021-kilt. ALCE geht genauer auf die Qualität von Quellenangaben ein: Eine Textstelle ist nur dann ein brauchbarer Beleg, wenn sie die jeweilige Aussage auch tatsächlich stützt @gao-etal-2023-enabling. Für unsere Erweiterung genügt es daher nicht, lediglich Dokumenttitel oder Seitenzahlen anzuzeigen.

== Evaluation

Zur Überprüfung brauchen wir Fragen, bei denen mehrere Informationen miteinander verbunden werden müssen. HotpotQA ist dafür ein hilfreiches Vorbild, da der Datensatz mehrstufige Fragen und zugehörige Belegsätze enthält @yang-etal-2018-hotpotqa. Da die Fragen nicht aus technischen Dokumentationen stammen, benötigen wir einen eigenen kleinen Testsatz mit bekannten Graphbeziehungen und Belegstellen.

RAGAs und ARES zeigen Möglichkeiten, Retrieval und generierte Antworten anhand unterschiedlicher Kriterien zu bewerten @es-etal-2024-ragas @saad-falcon-etal-2024-ares. Für unser Projekt sollten mindestens vier Aspekte getrennt betrachtet werden: die Korrektheit der extrahierten Beziehungen, die Relevanz gefundener Pfade, die Antwortqualität und die Gültigkeit der Quellenbelege. Einige Fälle sollten zusätzlich von Hand geprüft werden.

= Einordnung für das eigene Projekt

Die betrachteten Ansätze zeigen, dass keine einzelne Methode sämtliche Anforderungen vollständig abdeckt. Für den Graphaufbau sind insbesondere Liu und Lu sowie EIDER interessant. KG²RAG liefert eine konkrete Idee zur Verbindung von Graphinformationen und Textabschnitten. SemanticRAG zeigt eine mögliche Darstellung dieser Informationen, während ALCE Anhaltspunkte für ihre Bewertung gibt.

Wir wollen dennoch bei der vorhandenen GraphTrace Implementierung bleiben. Geplant ist, sie zunächst unverändert zum Laufen zu bringen und anschließend einen Knowledge-Graphen aus ausgewählten technischen Dokumentationen einzubinden. Im nächsten Schritt sollen Graphbeziehungen mit ihren Fundstellen gespeichert und bei der Antwortgenerierung ausgegeben werden. Eine einfache Oberfläche könnte die gefundenen Pfade und Belege gemeinsam darstellen. Weitere Änderungen am Ranking würden wir erst bei erkennbaren Schwächen des Ausgangssystems vornehmen.

Der eigene Beitrag liegt damit vor allem in der durchgängigen Verknüpfung von Dokumentstellen, Graphbeziehungen und Antworten innerhalb von GraphTrace. Ob diese Erweiterung tatsächlich zu besser überprüfbaren Ergebnissen führt, lässt sich nur durch eine getrennte Bewertung von Antworten und Belegen feststellen. Genau dafür bietet die betrachtete Literatur eine Grundlage.