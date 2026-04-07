/// Datos de los 30 acordes organizados por nivel

// ── Listas por nivel ──────────────────────────────────────────────────────────

const List<String> acordesBasicos = [
  'A', 'Am', 'C', 'D', 'Dm', 'E', 'Em', 'F', 'G', 'G7',
];

const List<String> acordesIntermedios = [
  'A7', 'Asus4', 'Bm', 'Cadd9', 'Cmaj7', 'D7', 'Dsus4', 'E7', 'Fmaj7',
];

const List<String> acordesAvanzados = [
  'Am7', 'Amaj7', 'Bbmaj7', 'Bm7', 'Dm7', 'Em7', 'F7', 'Fm', 'F#m', 'Gm', 'Gsus4',
];

const List<String> acordes = [
  ...acordesBasicos,
  ...acordesIntermedios,
  ...acordesAvanzados,
];

// ── Nombres ───────────────────────────────────────────────────────────────────

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

// ── Notas ─────────────────────────────────────────────────────────────────────

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

// ── Datos para flutter_guitar_chord ──────────────────────────────────────────
// fingers: '0 1 2 3 4 5' por cuerda (E A D G B e), 0=al aire, -1=silencio
// frets:   traste por cuerda, -1=silencio, 0=al aire

class ChordData {
  final String fingers;
  final String frets;
  final int baseFret;
  const ChordData({required this.fingers, required this.frets, this.baseFret = 1});
}

const Map<String, ChordData> chordData = {
  'A':     ChordData(fingers: '-1 0 1 2 2 2', frets: '-1 0 2 2 2 0'),
  'Am':    ChordData(fingers: '-1 0 1 2 3 0', frets: '-1 0 2 2 1 0'),
  'C':     ChordData(fingers: '-1 3 2 0 1 0', frets: '-1 3 2 0 1 0'),
  'D':     ChordData(fingers: '-1 -1 0 1 3 2', frets: '-1 -1 0 2 3 2'),
  'Dm':    ChordData(fingers: '-1 -1 0 2 3 1', frets: '-1 -1 0 2 3 1'),
  'E':     ChordData(fingers: '0 2 3 1 0 0',  frets: '0 2 2 1 0 0'),
  'Em':    ChordData(fingers: '0 2 3 0 0 0',  frets: '0 2 2 0 0 0'),
  'F':     ChordData(fingers: '1 1 2 3 4 1',  frets: '1 1 2 3 3 1'),
  'G':     ChordData(fingers: '2 1 0 0 3 4',  frets: '3 2 0 0 0 3'),
  'G7':    ChordData(fingers: '1 0 0 0 2 1',  frets: '3 2 0 0 0 1'),
  'A7':    ChordData(fingers: '-1 0 2 0 2 0', frets: '-1 0 2 0 2 0'),
  'Asus4': ChordData(fingers: '-1 0 2 2 3 0', frets: '-1 0 2 2 0 0'),
  'Bm':    ChordData(fingers: '-1 1 2 3 4 1', frets: '-1 2 4 4 3 2', baseFret: 2),
  'Cadd9': ChordData(fingers: '-1 3 2 0 3 0', frets: '-1 3 2 0 3 0'),
  'Cmaj7': ChordData(fingers: '-1 3 2 0 0 0', frets: '-1 3 2 0 0 0'),
  'D7':    ChordData(fingers: '-1 -1 0 2 1 2', frets: '-1 -1 0 2 1 2'),
  'Dsus4': ChordData(fingers: '-1 -1 0 2 3 3', frets: '-1 -1 0 2 3 3'),
  'E7':    ChordData(fingers: '0 2 0 1 0 0',  frets: '0 2 0 1 0 0'),
  'Fmaj7': ChordData(fingers: '-1 -1 3 2 1 0', frets: '-1 -1 3 2 1 0'),
  'Am7':   ChordData(fingers: '-1 0 2 0 1 0', frets: '-1 0 2 0 1 0'),
  'Amaj7': ChordData(fingers: '-1 0 1 1 1 0', frets: '-1 0 2 1 2 0'),
  'Bbmaj7':ChordData(fingers: '1 1 2 3 4 1',  frets: '1 1 2 3 3 1', baseFret: 1),
  'Bm7':   ChordData(fingers: '-1 1 2 1 3 1', frets: '-1 2 4 2 3 2', baseFret: 2),
  'Dm7':   ChordData(fingers: '-1 -1 0 2 1 1', frets: '-1 -1 0 2 1 1'),
  'Em7':   ChordData(fingers: '0 2 0 0 0 0',  frets: '0 2 2 0 0 0'),
  'F7':    ChordData(fingers: '1 1 2 1 4 1',  frets: '1 1 2 1 3 1'),
  'Fm':    ChordData(fingers: '1 1 3 3 4 1',  frets: '1 1 3 3 4 1'),
  'F#m':   ChordData(fingers: '1 1 3 3 4 1',  frets: '2 2 4 4 5 2', baseFret: 2),
  'Gm':    ChordData(fingers: '1 1 3 3 4 1',  frets: '3 5 5 3 3 3', baseFret: 3),
  'Gsus4': ChordData(fingers: '1 0 0 0 1 1',  frets: '3 3 0 0 1 3'),
};

// ── Samples de audio ──────────────────────────────────────────────────────────

const Map<String, String> sampleAcorde = {
  'A':   'A-07-LAZARUS.wav',
  'Am':  'Am-08-LAZARUS.wav',
  'C':   'C-05-AT2020.wav',
  'D':   'D-01-LAZARUS.wav',
  'F':   'F-07-LAZARUS.wav',
  'Bm7': 'Bm7-01-AT2020.wav',
};
