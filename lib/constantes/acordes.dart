/// Datos de acordes organizados por nivel

// ── Listas por nivel ──────────────────────────────────────
const List<String> acordesBasicos = [
  'A', 'Am', 'C', 'D', 'Dm', 'E', 'Em', 'F', 'G', 'G7',
];
const List<String> acordesIntermedios = [
  'A7', 'Asus4', 'Bm', 'Cadd9', 'Cmaj7', 'D7', 'Dsus4', 'E7', 'Fmaj7',
];
const List<String> acordesAvanzados = [
  'Am7', 'Amaj7', 'Bbmaj7', 'Bm7', 'Dm7', 'Em7', 'F7', 'Fm', 'F#m', 'Gm', 'Gsus4',
];

/// Lista completa (compatibilidad con código existente)
const List<String> acordes = [...acordesBasicos, ...acordesIntermedios, ...acordesAvanzados];

// ── Nombres legibles ──────────────────────────────────────
const Map<String, String> nombreAcorde = {
  'A':     'LA Mayor',     'Am':    'LA Menor',      'C':     'DO Mayor',
  'D':     'RE Mayor',     'Dm':    'RE Menor',       'E':     'MI Mayor',
  'Em':    'MI Menor',     'F':     'FA Mayor',       'G':     'SOL Mayor',
  'G7':    'SOL 7ma',      'A7':    'LA 7ma',         'Asus4': 'LA Sus4',
  'Bm':    'SI Menor',     'Cadd9': 'DO Add9',        'Cmaj7': 'DO Maj7',
  'D7':    'RE 7ma',       'Dsus4': 'RE Sus4',        'E7':    'MI 7ma',
  'Fmaj7': 'FA Maj7',      'Am7':   'LA Menor 7ma',   'Amaj7': 'LA Maj7',
  'Bbmaj7':'SIb Maj7',     'Bm7':   'SI Menor 7ma',   'Dm7':   'RE Menor 7ma',
  'Em7':   'MI Menor 7ma', 'F7':    'FA 7ma',         'Fm':    'FA Menor',
  'F#m':   'FA# Menor',    'Gm':    'SOL Menor',      'Gsus4': 'SOL Sus4',
};

// ── Notas de cada acorde ──────────────────────────────────
const Map<String, List<String>> notasAcorde = {
  'A':     ['A', 'C#', 'E'],
  'Am':    ['A', 'C', 'E'],
  'C':     ['C', 'E', 'G'],
  'D':     ['D', 'F#', 'A'],
  'Dm':    ['D', 'F', 'A'],
  'E':     ['E', 'G#', 'B'],
  'Em':    ['E', 'G', 'B'],
  'F':     ['F', 'A', 'C'],
  'G':     ['G', 'B', 'D'],
  'G7':    ['G', 'B', 'D', 'F'],
  'A7':    ['A', 'C#', 'E', 'G'],
  'Asus4': ['A', 'D', 'E'],
  'Bm':    ['B', 'D', 'F#'],
  'Cadd9': ['C', 'E', 'G', 'D'],
  'Cmaj7': ['C', 'E', 'G', 'B'],
  'D7':    ['D', 'F#', 'A', 'C'],
  'Dsus4': ['D', 'G', 'A'],
  'E7':    ['E', 'G#', 'B', 'D'],
  'Fmaj7': ['F', 'A', 'C', 'E'],
  'Am7':   ['A', 'C', 'E', 'G'],
  'Amaj7': ['A', 'C#', 'E', 'G#'],
  'Bbmaj7':['A#', 'D', 'F', 'A'],
  'Bm7':   ['B', 'D', 'F#', 'A'],
  'Dm7':   ['D', 'F', 'A', 'C'],
  'Em7':   ['E', 'G', 'B', 'D'],
  'F7':    ['F', 'A', 'C', 'D#'],
  'Fm':    ['F', 'G#', 'C'],
  'F#m':   ['F#', 'A', 'C#'],
  'Gm':    ['G', 'A#', 'D'],
  'Gsus4': ['G', 'C', 'D'],
};

// ── Datos para flutter_guitar_chord ──────────────────────
// fingers: posición de cada cuerda (6→1), 0=al aire, -1=silencio
// frets:   traste de cada cuerda, -1=silencio, 0=al aire
class ChordData {
  final String fingers; // ej: '0 1 2 2 0 0'
  final String frets;   // ej: '0 1 2 2 0 0'
  final int baseFret;
  const ChordData(this.fingers, this.frets, this.baseFret);
}

const Map<String, ChordData> chordData = {
  // Básicos
  'A':     ChordData('0 1 2 3 0 0',  '-1 0 2 2 2 0',  1),
  'Am':    ChordData('0 1 2 3 0 0',  '-1 0 2 2 1 0',  1),
  'C':     ChordData('0 3 2 0 1 0',  '-1 3 2 0 1 0',  1),
  'D':     ChordData('0 0 0 1 3 2',  '-1 -1 0 2 3 2', 1),
  'Dm':    ChordData('0 0 0 1 3 2',  '-1 -1 0 2 3 1', 1),
  'E':     ChordData('0 2 3 1 0 0',  '0 2 2 1 0 0',   1),
  'Em':    ChordData('0 2 3 0 0 0',  '0 2 2 0 0 0',   1),
  'F':     ChordData('1 1 2 3 4 1',  '1 1 2 3 3 1',   1),
  'G':     ChordData('2 1 0 0 0 3',  '3 2 0 0 0 3',   1),
  'G7':    ChordData('2 1 0 0 0 3',  '3 2 0 0 0 1',   1),
  // Intermedios
  'A7':    ChordData('0 1 0 2 0 0',  '-1 0 2 0 2 0',  1),
  'Asus4': ChordData('0 1 2 2 0 0',  '-1 0 2 2 0 0',  1),
  'Bm':    ChordData('1 1 2 3 4 1',  '-1 2 4 4 3 2',  2),
  'Cadd9': ChordData('0 3 2 0 0 3',  '-1 3 2 0 3 3',  1),
  'Cmaj7': ChordData('0 3 2 0 0 0',  '-1 3 2 0 0 0',  1),
  'D7':    ChordData('0 0 0 2 1 2',  '-1 -1 0 2 1 2', 1),
  'Dsus4': ChordData('0 0 0 1 3 3',  '-1 -1 0 2 3 3', 1),
  'E7':    ChordData('0 2 0 1 0 0',  '0 2 2 1 3 0',   1),
  'Fmaj7': ChordData('0 1 2 3 0 0',  '-1 -1 3 2 1 0', 1),
  // Avanzados
  'Am7':   ChordData('0 1 0 2 0 0',  '-1 0 2 0 1 0',  1),
  'Amaj7': ChordData('0 1 2 3 0 0',  '-1 0 2 1 2 0',  1),
  'Bbmaj7':ChordData('1 1 2 3 4 1',  '1 1 3 2 3 1',   1),
  'Bm7':   ChordData('1 1 2 0 3 1',  '-1 2 4 2 3 2',  2),
  'Dm7':   ChordData('0 0 0 2 1 1',  '-1 -1 0 2 1 1', 1),
  'Em7':   ChordData('0 2 0 0 0 0',  '0 2 2 0 3 0',   1),
  'F7':    ChordData('1 1 2 3 1 1',  '1 1 2 3 1 1',   1),
  'Fm':    ChordData('1 1 2 3 4 1',  '1 1 3 3 2 1',   1),
  'F#m':   ChordData('1 1 2 3 4 1',  '2 2 4 4 3 2',   2),
  'Gm':    ChordData('1 1 2 3 4 1',  '3 3 5 5 4 3',   3),
  'Gsus4': ChordData('2 1 0 0 1 3',  '3 3 0 0 1 3',   1),
};

// ── Datos legacy (compatibilidad con DiagramaAcordeWidget) ─
class Punto {
  final int cuerda;
  final int traste;
  final int dedo;
  const Punto(this.cuerda, this.traste, this.dedo);
}

class DiagramaAcorde {
  final int trasteInicio;
  final List<Punto> puntos;
  final List<int> cuerdaAlAire;
  final List<int> cuerdaSilencio;
  final bool tieneCejilla;
  final int trastesCejilla;
  final int cejillaDesde;
  final int cejillaHasta;

  const DiagramaAcorde({
    this.trasteInicio = 1,
    required this.puntos,
    this.cuerdaAlAire   = const [],
    this.cuerdaSilencio = const [],
    this.tieneCejilla   = false,
    this.trastesCejilla = 0,
    this.cejillaDesde   = 0,
    this.cejillaHasta   = 5,
  });
}

const Map<String, DiagramaAcorde> diagramas = {
  'A': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 1), Punto(3, 2, 2), Punto(4, 2, 3)],
    cuerdaAlAire: [1, 5], cuerdaSilencio: [0],
  ),
  'Am': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(2, 2, 2), Punto(3, 2, 3), Punto(4, 1, 1)],
    cuerdaAlAire: [1, 5], cuerdaSilencio: [0],
  ),
  'C': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 2, 2), Punto(4, 1, 1)],
    cuerdaAlAire: [3, 5], cuerdaSilencio: [0],
  ),
  'D': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(3, 2, 1), Punto(4, 3, 3), Punto(5, 2, 2)],
    cuerdaAlAire: [2], cuerdaSilencio: [0, 1],
  ),
  'F': DiagramaAcorde(
    trasteInicio: 1,
    puntos: [Punto(1, 3, 3), Punto(2, 3, 4), Punto(3, 2, 2)],
    tieneCejilla: true, trastesCejilla: 1, cejillaDesde: 0, cejillaHasta: 5,
  ),
  'Bm7': DiagramaAcorde(
    trasteInicio: 2,
    puntos: [Punto(1, 3, 3), Punto(3, 1, 2)],
    cuerdaSilencio: [0],
    tieneCejilla: true, trastesCejilla: 1, cejillaDesde: 1, cejillaHasta: 5,
  ),
};

// ── Descripciones ─────────────────────────────────────────
const Map<String, String> descripcionAcorde = {
  'A':     'Tres dedos en el segundo traste, cuerdas D-G-B. Acorde abierto fácil.',
  'Am':    'Similar a A pero el índice va en el primer traste de la cuerda B.',
  'C':     'Forma diagonal: dedo 3 en A traste 3, dedo 2 en D traste 2, dedo 1 en B traste 1.',
  'D':     'Solo se tocan 4 cuerdas (D-G-B-e). Forma de triángulo en trastes 2-3.',
  'Dm':    'Similar a D pero con la cuerda B en traste 1. Sonido más oscuro.',
  'E':     'Acorde abierto clásico. Tres dedos en trastes 1 y 2.',
  'Em':    'El más fácil. Solo dos dedos en cuerdas A y D traste 2.',
  'F':     'Cejilla completa en traste 1. El reto clásico del principiante.',
  'G':     'Acorde abierto con dedos en trastes 2 y 3.',
  'G7':    'Como G pero con el meñique en la cuerda e traste 1.',
  'A7':    'A con el dedo del G levantado. Sonido bluesy.',
  'Asus4': 'A sin el dedo de la cuerda B. Sonido suspendido.',
  'Bm':    'Cejilla en traste 2. Primer barré importante.',
  'Cadd9': 'C con el dedo meñique en la cuerda e traste 3.',
  'Cmaj7': 'C sin el dedo de la cuerda B. Sonido suave y jazzístico.',
  'D7':    'D con el dedo índice en la cuerda B traste 1.',
  'Dsus4': 'D con el dedo meñique en la cuerda e traste 3.',
  'E7':    'E con el dedo del G levantado.',
  'Fmaj7': 'F sin la cuerda E grave. Sonido más abierto.',
  'Am7':   'Am con el dedo del G levantado. Muy usado en pop.',
  'Amaj7': 'A con el índice en la cuerda G traste 1.',
  'Bbmaj7':'Cejilla en traste 1 con forma de Amaj7.',
  'Bm7':   'Cejilla en traste 2 con dos dedos adicionales.',
  'Dm7':   'Dm con el meñique en la cuerda e traste 1.',
  'Em7':   'Em con el dedo del D levantado.',
  'F7':    'F con el meñique en la cuerda G traste 3.',
  'Fm':    'Cejilla en traste 1 con forma de Em.',
  'F#m':   'Cejilla en traste 2 con forma de Em. Barré real.',
  'Gm':    'Cejilla en traste 3 con forma de Em.',
  'Gsus4': 'G con el índice en la cuerda B traste 1.',
};

const Map<String, String> sampleAcorde = {
  'A':   'A-07-LAZARUS.wav',
  'Am':  'Am-08-LAZARUS.wav',
  'C':   'C-05-AT2020.wav',
  'D':   'D-01-LAZARUS.wav',
  'F':   'F-07-LAZARUS.wav',
  'Bm7': 'Bm7-01-AT2020.wav',
};
