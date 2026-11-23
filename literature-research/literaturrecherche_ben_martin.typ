#import "../TUBAF_typst_template/tubaf_template.typ" as tubaf


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
    name: "Martin Werner",
    studentID: "",
  ),(
    name: "Ben Weckend",
    studentID: "",
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
  //extra_outlines: (table_outline, table_of_symbols,),
  references: "references.bib"
)

= Einleitung
#figure(
  image("../TUBAF_typst_template/TUBAF_Logo_blau.svg"),
  caption: tubaf.flex-caption(
    long: [Das Markenlogo ist das zentrale, identitätsstiftende Kernelement im visuellen Auftritt der Universität.],
    short: [Markenlogo])
)
#lorem(100)


