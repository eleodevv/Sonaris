/// Datos de los 6 acordes soportados por el modelo MLP

const List<String> acordes = ['A', 'Am', 'C', 'D', 'F', 'Bm7'];

const Map<String, String> nivelAcorde = {
  'A': 'básico',
  'Am': 'básico',
  'D': 'básico',
  'C': 'intermedio',
  'F': 'difícil',
  'Bm7': 'difícil',
};

const Map<String, List<String>> acordesPorNivel = {
  'básico': ['A', 'Am', 'C', 'D', 'Dm', 'E', 'Em', 'F', 'G', 'G7'],
  'intermedio': [
    'C',
    'A7',
    'Asus4',
    'B7',
    'Bm',
    'Cadd9',
    'Cmaj7',
    'D7',
    'Dsus4',
    'E7',
    'Fmaj7'
  ],
  'difícil': [
    'F',
    'Bm7',
    'Am7',
    'Amaj7',
    'Bbmaj7',
    'Dm7',
    'Em7',
    'F#m',
    'F7',
    'Fm',
    'Gm',
    'Gsus4'
  ],
};

const Map<String, String> nombreAcorde = {
  'A': 'LA Mayor',
  'Am': 'LA Menor',
  'C': 'DO Mayor',
  'D': 'RE Mayor',
  'Dm': 'RE Menor',
  'E': 'MI Mayor',
  'Em': 'MI Menor',
  'F': 'FA Mayor',
  'Bm7': 'SI Menor 7ma',
  'G': 'SOL Mayor',
  'G7': 'SOL Séptima',
  'A7': 'LA Séptima',
  'Asus4': 'LA Sus4',
  'B7': 'SI Séptima',
  'Bm': 'SI Menor',
  'Cadd9': 'DO Add9',
  'Cmaj7': 'DO Mayor 7ma',
  'D7': 'RE Séptima',
  'Dsus4': 'RE Sus4',
  'E7': 'MI Séptima',
  'Fmaj7': 'FA Mayor 7ma',
  'Am7': 'LA Menor 7ma',
  'Amaj7': 'LA Mayor 7ma',
  'Bbmaj7': 'SIb Mayor 7ma',
  'Dm7': 'RE Menor 7ma',
  'Em7': 'MI Menor 7ma',
  'F#m': 'FA# Menor',
  'F7': 'FA Séptima',
  'Fm': 'FA Menor',
  'Gm': 'SOL Menor',
  'Gsus4': 'SOL Sus4',
};

const Map<String, List<String>> notasAcorde = {
  'A': ['A', 'C#', 'E'],
  'Am': ['A', 'C', 'E'],
  'C': ['C', 'E', 'G'],
  'D': ['D', 'F#', 'A'],
  'Dm': ['D', 'F', 'A'],
  'E': ['E', 'G#', 'B'],
  'Em': ['E', 'G', 'B'],
  'F': ['F', 'A', 'C'],
  'Bm7': ['B', 'D', 'F#', 'A'],
  'G': ['G', 'B', 'D'],
  'G7': ['G', 'B', 'D', 'F'],
  'A7': ['A', 'C#', 'E', 'G'],
  'Asus4': ['A', 'D', 'E'],
  'B7': ['B', 'D#', 'F#', 'A'],
  'Bm': ['B', 'D', 'F#'],
  'Cadd9': ['C', 'E', 'G', 'D'],
  'Cmaj7': ['C', 'E', 'G', 'B'],
  'D7': ['D', 'F#', 'A', 'C'],
  'Dsus4': ['D', 'G', 'A'],
  'E7': ['E', 'G#', 'B', 'D'],
  'Fmaj7': ['F', 'A', 'C', 'E'],
  'Am7': ['A', 'C', 'E', 'G'],
  'Amaj7': ['A', 'C#', 'E', 'G#'],
  'Bbmaj7': ['Bb', 'D', 'F', 'A'],
  'Dm7': ['D', 'F', 'A', 'C'],
  'Em7': ['E', 'G', 'B', 'D'],
  'F#m': ['F#', 'A', 'C#'],
  'F7': ['F', 'A', 'C', 'Eb'],
  'Fm': ['F', 'Ab', 'C'],
  'Gm': ['G', 'Bb', 'D'],
  'Gsus4': ['G', 'C', 'D'],
};

const Map<String, String> descripcionAcorde = {
  'A': 'Tres dedos en el segundo traste, cuerdas D-G-B. Acorde abierto fácil.',
  'Am':
      'Similar a A pero el dedo índice va en el primer traste de la cuerda B.',
  'C':
      'Forma diagonal: dedo 3 en A traste 3, dedo 2 en D traste 2, dedo 1 en B traste 1.',
  'D': 'Solo se tocan 4 cuerdas (D-G-B-e). Forma de triángulo en trastes 2-3.',
  'Dm': 'Como D Mayor pero el dedo índice baja al traste 1 en la cuerda e.',
  'E':
      'Dos dedos en A y D traste 2, uno en G traste 1. Todas las cuerdas suenan.',
  'Em': 'Solo dos dedos en A y D traste 2. El acorde más fácil de la guitarra.',
  'F': 'Cejilla completa en traste 1. El reto clásico del principiante.',
  'Bm7': 'Cejilla en traste 2 con dos dedos adicionales en A y G.',
  'G': 'Tres dedos en los extremos del mástil. Todas las cuerdas suenan.',
  'G7': 'Como G Mayor pero el meñique baja al traste 1 de la cuerda e.',
  'A7':
      'Como A Mayor pero sin el dedo del traste 2 en la cuerda G. Sonido bluesy.',
  'Asus4':
      'Como A Mayor pero agrega el dedo meñique en el traste 3 de la cuerda B.',
  'B7': 'Acorde abierto con 4 dedos. Muy usado en blues y rock.',
  'Bm': 'Cejilla en traste 2. Versión menor del acorde B.',
  'Cadd9':
      'Como C Mayor pero agrega el dedo meñique en el traste 3 de la cuerda e.',
  'Cmaj7':
      'Como C Mayor pero sin el dedo en la cuerda B. Sonido suave y romántico.',
  'D7':
      'Como D Mayor pero agrega el dedo índice en el traste 1 de la cuerda B.',
  'Dsus4': 'Como D Mayor pero el dedo del traste 2 en B sube al traste 3.',
  'E7': 'Como E Mayor pero sin el dedo en la cuerda G. Muy usado en blues.',
  'Fmaj7': 'Versión simplificada de F con el meñique levantado. Sonido suave.',
  'Am7': 'Como Am pero sin el dedo en la cuerda G. Sonido suave y melancólico.',
  'Amaj7': 'Como A Mayor con el dedo índice en el traste 1 de la cuerda G.',
  'Bbmaj7': 'Cejilla en traste 1 con forma de Amaj7. Acorde de jazz.',
  'Dm7': 'Como Dm pero agrega el dedo índice en el traste 1 de la cuerda e.',
  'Em7': 'Como Em pero sin el dedo en la cuerda A. Muy fácil y versátil.',
  'F#m': 'Cejilla en traste 2 con forma de Em. Acorde menor oscuro.',
  'F7': 'Como F Mayor con el meñique en el traste 3 de la cuerda G.',
  'Fm': 'Cejilla en traste 1 con forma de Em. Sonido oscuro y dramático.',
  'Gm': 'Cejilla en traste 3 con forma de Em. Muy usado en pop y rock.',
  'Gsus4':
      'Como G Mayor pero el dedo en B sube al traste 3. Sonido suspendido.',
};

const Map<String, String> sampleAcorde = {
  'A': 'A-07-LAZARUS.wav',
  'Am': 'Am-08-LAZARUS.wav',
  'C': 'C-05-AT2020.wav',
  'D': 'D-01-LAZARUS.wav',
  'F': 'F-07-LAZARUS.wav',
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
  final List<int> cuerdaAlAire; // O
  final List<int> cuerdaSilencio; // X
  final bool tieneCejilla;
  final int trastesCejilla;
  final int cejillaDesde;
  final int cejillaHasta;

  const DiagramaAcorde({
    this.trasteInicio = 1,
    required this.puntos,
    this.cuerdaAlAire = const [],
    this.cuerdaSilencio = const [],
    this.tieneCejilla = false,
    this.trastesCejilla = 0,
    this.cejillaDesde = 0,
    this.cejillaHasta = 5,
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
    cuerdaAlAire: [1, 5],
    cuerdaSilencio: [0],
  ),
  'Am': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 2), Punto(3, 2, 3), Punto(4, 1, 1)],
    cuerdaAlAire: [1, 5],
    cuerdaSilencio: [0],
  ),
  'C': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 2, 2), Punto(4, 1, 1)],
    cuerdaAlAire: [3, 5],
    cuerdaSilencio: [0],
  ),
  'D': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 1), Punto(4, 3, 3), Punto(5, 2, 2)],
    cuerdaAlAire: [2],
    cuerdaSilencio: [0, 1],
  ),
  'Dm': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 2), Punto(4, 3, 3), Punto(5, 1, 1)],
    cuerdaAlAire: [2],
    cuerdaSilencio: [0, 1],
  ),
  'E': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 2, 3), Punto(2, 2, 2), Punto(3, 1, 1)],
    cuerdaAlAire: [0, 4, 5],
  ),
  'Em': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 2, 1), Punto(2, 2, 2)],
    cuerdaAlAire: [0, 3, 4, 5],
  ),
  'F': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 0,
    cejillaHasta: 5,
  ),
  'Bm7': DiagramaAcorde(
    trasteInicio: 2,
    puntos: [Punto(1, 3, 3), Punto(3, 1, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 1,
    cejillaHasta: 5,
  ),
  // ── Acordes intermedios ───────────────────────────────
  'A7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 1), Punto(4, 2, 2)],
    cuerdaAlAire: [1, 3, 5],
    cuerdaSilencio: [0],
  ),
  'Asus4': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 1), Punto(3, 2, 2), Punto(4, 2, 3), Punto(5, 3, 4)],
    cuerdaAlAire: [1],
    cuerdaSilencio: [0],
  ),
  'B7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 2, 1), Punto(2, 4, 4), Punto(3, 3, 3), Punto(4, 2, 2)],
    cuerdaAlAire: [5],
    cuerdaSilencio: [0],
  ),
  'Bm': DiagramaAcorde(
    trasteInicio: 2,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 1,
    cejillaHasta: 5,
  ),
  'Cadd9': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 2, 2), Punto(4, 1, 1), Punto(5, 3, 4)],
    cuerdaAlAire: [3],
    cuerdaSilencio: [0],
  ),
  'Cmaj7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 2, 2)],
    cuerdaAlAire: [3, 4, 5],
    cuerdaSilencio: [0],
  ),
  'D7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 1), Punto(4, 1, 2), Punto(5, 2, 3)],
    cuerdaAlAire: [2],
    cuerdaSilencio: [0, 1],
  ),
  'Dsus4': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 1), Punto(4, 3, 3), Punto(5, 3, 4)],
    cuerdaAlAire: [2],
    cuerdaSilencio: [0, 1],
  ),
  'E7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 2, 2), Punto(2, 2, 3)],
    cuerdaAlAire: [0, 3, 4, 5],
  ),
  'Fmaj7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    cuerdaAlAire: [5],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 1,
    cejillaHasta: 4,
  ),
  // ── Acordes avanzados ─────────────────────────────────
  'Am7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 2), Punto(3, 2, 3)],
    cuerdaAlAire: [1, 4, 5],
    cuerdaSilencio: [0],
  ),
  'Amaj7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 2), Punto(3, 1, 1), Punto(4, 2, 3)],
    cuerdaAlAire: [1, 5],
    cuerdaSilencio: [0],
  ),
  'Bbmaj7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 3, 3), Punto(3, 2, 2), Punto(4, 3, 4)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 1,
    cejillaHasta: 5,
  ),
  'Dm7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 2), Punto(4, 3, 3), Punto(5, 1, 1)],
    cuerdaAlAire: [2],
    cuerdaSilencio: [0, 1],
  ),
  'Em7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 2, 1)],
    cuerdaAlAire: [0, 2, 3, 4, 5],
  ),
  'F#m': DiagramaAcorde(
    trasteInicio: 2,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 1,
    cejillaHasta: 5,
  ),
  'F7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 3, 2)],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 0,
    cejillaHasta: 5,
  ),
  'Fm': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 0,
    cejillaHasta: 5,
  ),
  'Gm': DiagramaAcorde(
    trasteInicio: 3,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true,
    trastesCejilla: 1,
    cejillaDesde: 0,
    cejillaHasta: 5,
  ),
  'Gsus4': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(0, 3, 2), Punto(1, 3, 3), Punto(5, 2, 1)],
    cuerdaAlAire: [2, 3, 4],
  ),
  'G': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(0, 3, 2), Punto(1, 3, 3), Punto(5, 2, 1)],
    cuerdaAlAire: [2, 3, 4],
  ),
  'G7': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(0, 3, 3), Punto(1, 1, 1), Punto(5, 2, 2)],
    cuerdaAlAire: [2, 3, 4],
  ),
};
