/// Datos de los 6 acordes soportados por el modelo MLP

const List<String> acordes = ['A', 'Am', 'C', 'D', 'F', 'Bm7'];

const Map<String, String> nombreAcorde = {
  'A':   'LA Mayor',
  'Am':  'LA Menor',
  'C':   'DO Mayor',
  'D':   'RE Mayor',
  'F':   'FA Mayor',
  'Bm7': 'SI Menor 7ma',
};

const Map<String, List<String>> notasAcorde = {
  'A':   ['A', 'C#', 'E'],
  'Am':  ['A', 'C', 'E'],
  'C':   ['C', 'E', 'G'],
  'D':   ['D', 'F#', 'A'],
  'F':   ['F', 'A', 'C'],
  'Bm7': ['B', 'D', 'F#', 'A'],
};

const Map<String, String> descripcionAcorde = {
  'A':   'Tres dedos en el segundo traste, cuerdas D-G-B. Acorde abierto fácil.',
  'Am':  'Similar a A pero el dedo índice va en el primer traste de la cuerda B.',
  'C':   'Forma diagonal: dedo 3 en A traste 3, dedo 2 en D traste 2, dedo 1 en B traste 1.',
  'D':   'Solo se tocan 4 cuerdas (D-G-B-e). Forma de triángulo en trastes 2-3.',
  'F':   'Cejilla completa en traste 1. El reto clásico del principiante.',
  'Bm7': 'Cejilla en traste 2 con dos dedos adicionales en A y G.',
};

const Map<String, String> sampleAcorde = {
  'A':   'A-07-LAZARUS.wav',
  'Am':  'Am-08-LAZARUS.wav',
  'C':   'C-05-AT2020.wav',
  'D':   'D-01-LAZARUS.wav',
  'F':   'F-07-LAZARUS.wav',
  'Bm7': 'Bm7-01-AT2020.wav',
};

// ── Diagrama de traste ────────────────────────────────────
// string: 0 = E grave (6ta), 5 = e aguda (1ra)
// fret: relativo a startFret (1 = primer traste visible)

class Punto {
  final int cuerda;
  final int traste;
  final int dedo;
  const Punto(this.cuerda, this.traste, this.dedo);
}

class DiagramaAcorde {
  final int trasteInicio;
  final List<Punto> puntos;
  final List<int> cuerdaAlAire;   // O
  final List<int> cuerdaSilencio; // X
  final bool tieneCejilla;
  final int trastesCejilla;
  final int cejillaDesde;
  final int cejillaHasta;

  const DiagramaAcorde({
    this.trasteInicio = 1,
    required this.puntos,
    this.cuerdaAlAire  = const [],
    this.cuerdaSilencio = const [],
    this.tieneCejilla  = false,
    this.trastesCejilla = 0,
    this.cejillaDesde  = 0,
    this.cejillaHasta  = 5,
  });
}

// A: x02220
// Am: x02210
// C: x32010
// D: xx0232
// F: 133211 (cejilla traste 1)
// Bm7: x24232 (cejilla traste 2)
const Map<String, DiagramaAcorde> diagramas = {
  'A': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 1), Punto(3, 2, 2), Punto(4, 2, 3)],
    cuerdaAlAire:  [1, 5],
    cuerdaSilencio: [0],
  ),
  'Am': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 2), Punto(3, 2, 3), Punto(4, 1, 1)],
    cuerdaAlAire:  [1, 5],
    cuerdaSilencio: [0],
  ),
  'C': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 2, 2), Punto(4, 1, 1)],
    cuerdaAlAire:  [3, 5],
    cuerdaSilencio: [0],
  ),
  'D': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 1), Punto(4, 3, 3), Punto(5, 2, 2)],
    cuerdaAlAire:  [2],
    cuerdaSilencio: [0, 1],
  ),
  'F': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    tieneCejilla:   true,
    trastesCejilla: 1,
    cejillaDesde:   0,
    cejillaHasta:   5,
  ),
  'Bm7': DiagramaAcorde(
    trasteInicio: 2,
    puntos: [Punto(1, 3, 3), Punto(3, 1, 2)],
    cuerdaSilencio: [0],
    tieneCejilla:   true,
    trastesCejilla: 1,
    cejillaDesde:   1,
    cejillaHasta:   5,
  ),
};
