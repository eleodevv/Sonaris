import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';
import '../services/audio_service.dart';

// ── CHORD DATA ───────────────────────────────────────────
const Map<String, List<String>> acordesBasicos = {
  'A': ['A','C#','E'], 'Am': ['A','C','E'], 'C': ['C','E','G'],
  'D': ['D','F#','A'], 'Dm': ['D','F','A'], 'E': ['E','G#','B'],
  'Em': ['E','G','B'], 'G': ['G','B','D'],
  'C7': ['C','E','G','A#'], 'G7': ['G','B','D','F'],
};
const Map<String, List<String>> acordesMedios = {
  'F': ['F','A','C'], 'Bm': ['B','D','F#'],
  'A7': ['A','C#','E','G'], 'E7': ['E','G#','B','D'],
  'Am7': ['A','C','E','G'], 'Cmaj7': ['C','E','G','B'],
  'Dsus4': ['D','G','A'], 'Asus4': ['A','D','E'],
};
const Map<String, List<String>> acordesAvanzados = {
  'Gm': ['G','A#','D'], 'F#m': ['F#','A','C#'],
};

const Map<String, String> chordNames = {
  'A':'LA Mayor','Am':'LA Menor','C':'DO Mayor','D':'RE Mayor',
  'Dm':'RE Menor','E':'MI Mayor','Em':'MI Menor','G':'SOL Mayor',
  'C7':'DO Séptima','G7':'SOL Séptima','F':'FA Mayor','Bm':'SI Menor',
  'A7':'LA Séptima','E7':'MI Séptima','Am7':'LA Men. 7ma',
  'Cmaj7':'DO May. 7ma','Dsus4':'RE Sus4','Asus4':'LA Sus4',
  'Gm':'SOL Menor','F#m':'FA# Menor',
};

// Posiciones en el mástil [cuerda(0-5), traste(0-4)] para cada acorde
// cuerda 0 = E grave, 5 = E agudo
const Map<String, List<List<int>>> chordFrets = {
  'A':  [[1,2],[2,2],[3,2]],
  'Am': [[1,2],[2,2],[3,1]],
  'C':  [[1,3],[2,2],[4,1]],
  'D':  [[1,3],[2,2],[3,3]],
  'Dm': [[1,3],[2,2],[3,1]],
  'E':  [[3,1],[4,2],[5,2]],
  'Em': [[4,2],[5,2]],
  'G':  [[0,3],[4,2],[5,3]],
  'C7': [[1,3],[2,2],[3,3],[4,1]],
  'G7': [[0,3],[1,1],[4,2],[5,1]],
  'F':  [[0,1],[1,1],[2,2],[3,3],[4,3],[5,1]],
  'Bm': [[1,2],[2,4],[3,4],[4,3]],
  'A7': [[1,2],[3,2]],
  'E7': [[3,1],[4,2]],
  'Am7':[[1,2],[3,1]],
  'Cmaj7':[[1,3],[2,2],[3,4]],
  'Dsus4':[[1,3],[2,3],[3,2]],
  'Asus4':[[1,2],[2,2],[3,2]],
  'Gm': [[0,3],[1,1],[2,2],[3,3],[4,3],[5,1]],
  'F#m':[[0,2],[1,2],[2,4],[3,4],[4,3]],
};

// ── COLORS ───────────────────────────────────────────────
const bgDark    = Color(0xFF0A0A0A);
const bgCard    = Color(0xFF141414);
const bgCard2   = Color(0xFF1C1C1C);
const neonGreen = Color(0xFF00FF7F);
const dimGreen  = Color(0xFF00C060);
const textWhite = Color(0xFFF0F0F0);
const textGray  = Color(0xFF666666);
const textMid   = Color(0xFF999999);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  int     _tab        = 1; // 0=Trivia, 1=Inicio, 2=Configurar
  String  _nivel      = 'basico';
  String? _acorde;
  bool    _recording  = false;
  bool    _processing = false;
  int     _progress   = 0;
  Timer?  _timer;
  Map<String, dynamic>? _result;
  bool    _online     = false;
  bool    _showPractice = false; // false=selección nivel, true=práctica

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _checkServer();
  }

  @override
  void dispose() {
    _audio.dispose();
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _acordes {
    if (_nivel == 'medio')    return acordesMedios;
    if (_nivel == 'avanzado') return acordesAvanzados;
    return acordesBasicos;
  }

  Future<void> _checkServer() async {
    final ok = await context.read<ApiService>().checkHealth();
    if (mounted) setState(() => _online = ok);
  }

  void _setAcorde(String a) => setState(() { _acorde = a; _result = null; });

  void _randomAcorde() {
    final keys = _acordes.keys.toList();
    _setAcorde(keys[Random().nextInt(keys.length)]);
  }

  Future<void> _startRec() async {
    if (_acorde == null) { _snack('Selecciona un acorde primero'); return; }
    final ok = await _audio.startRecording();
    if (!ok) { _snack('Sin permiso de micrófono'); return; }
    setState(() { _recording = true; _progress = 0; _result = null; });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _progress++);
      if (_progress >= 30) { t.cancel(); _stopRec(); }
    });
  }

  Future<void> _stopRec() async {
    _timer?.cancel();
    final path = await _audio.stopRecording();
    setState(() { _recording = false; _progress = 0; });
    if (path != null) await _process(path);
  }

  Future<void> _process(String path) async {
    setState(() => _processing = true);
    try {
      final r = await context.read<ApiService>().detectarAcorde(path, acordeEsperado: _acorde);
      setState(() => _result = r);
    } on TimeoutException {
      _snack('Tiempo de espera agotado. Verifica tu conexión.');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Connection refused')) {
        _snack('No se pudo conectar a la API.');
      } else {
        _snack('Error al analizar: ${msg.substring(0, msg.length.clamp(0, 80))}');
      }
    } finally {
      setState(() => _processing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: textWhite)),
      backgroundColor: const Color(0xFF2A0A0A),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Column(children: [
        Expanded(child: _buildBody()),
        _buildNavBar(),
      ]),
    );
  }

  Widget _buildBody() {
    if (_tab == 1) {
      return _showPractice ? _buildPractice() : _buildNivelSelect();
    }
    if (_tab == 0) return _buildTrivia();
    return _buildConfig();
  }

  // ── NAV BAR ─────────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      color: bgCard,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 10,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(0, Icons.quiz_outlined, Icons.quiz_rounded, 'TRIVIAS'),
        _navItem(1, Icons.home_outlined, Icons.home_rounded, 'INICIO'),
        _navItem(2, Icons.settings_outlined, Icons.settings_rounded, 'CONFIGURAR'),
      ]),
    );
  }

  Widget _navItem(int idx, IconData off, IconData on, String label) {
    final sel = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() { _tab = idx; if (idx != 1) _showPractice = false; }),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(sel ? on : off, color: sel ? neonGreen : textGray, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 9, letterSpacing: 1,
          color: sel ? neonGreen : textGray,
          fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
        )),
      ]),
    );
  }

  // ── SELECCIÓN DE NIVEL ───────────────────────────────────
  Widget _buildNivelSelect() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Selección de Nivel',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textWhite)),
            const SizedBox(height: 4),
            Row(children: [
              const Text('APRENDIZAJE CON IA',
                  style: TextStyle(fontSize: 11, color: textGray, letterSpacing: 1.5)),
              const SizedBox(width: 10),
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _online ? neonGreen : Colors.red)),
            ]),
          ]),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _nivelCard('Básico', 'Fundamentos y acordes', 'basico', neonGreen, 0.40, true),
              const SizedBox(height: 14),
              _nivelCard('Intermedio', 'Escalas y rítmica', 'medio', const Color(0xFF888800), 0.12, false),
              const SizedBox(height: 14),
              _nivelCard('Avanzado', 'Solos y teoría compleja', 'avanzado', Colors.red.shade700, 0.0, false),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _nivelCard(String title, String sub, String nivel, Color color, double progreso, bool active) {
    return GestureDetector(
      onTap: () => setState(() { _nivel = nivel; _acorde = null; _result = null; _showPractice = true; }),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textWhite)),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 13, color: textGray)),
            ])),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: active ? color : textGray.withOpacity(0.3), width: 2),
              ),
              child: active
                ? Icon(Icons.circle, color: color, size: 14)
                : Icon(Icons.grid_view_rounded, color: textGray.withOpacity(0.4), size: 14),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            const Text('PROGRESO', style: TextStyle(fontSize: 10, color: textGray, letterSpacing: 1)),
            const Spacer(),
            Text('${(progreso * 100).toInt()}%',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.07),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ]),
      ),
    );
  }

  // ── PRÁCTICA ─────────────────────────────────────────────
  Widget _buildPractice() {
    final correcto = _result?['es_correcto'] ?? false;
    final notas = _acorde != null ? (_acordes[_acorde!] ?? []) : [];

    return SafeArea(
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => setState(() { _showPractice = false; _result = null; }),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: textWhite, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _nivel == 'basico' ? 'Acordes Básicos'
                  : _nivel == 'medio' ? 'Acordes Intermedios' : 'Acordes Avanzados',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textWhite),
              ),
              Text('PRÁCTICA', style: TextStyle(fontSize: 9, color: neonGreen, letterSpacing: 1.5)),
            ])),
            GestureDetector(
              onTap: _randomAcorde,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgCard2, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Row(children: [
                  Icon(Icons.shuffle_rounded, color: neonGreen, size: 14),
                  SizedBox(width: 5),
                  Text('Aleatorio', style: TextStyle(fontSize: 11, color: neonGreen)),
                ]),
              ),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              const SizedBox(height: 16),

              // Grid de acordes
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgCard, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _acordes.keys.map((a) => GestureDetector(
                    onTap: () => _setAcorde(a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _acorde == a ? neonGreen.withOpacity(0.15) : bgCard2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _acorde == a ? neonGreen : Colors.white.withOpacity(0.08),
                          width: _acorde == a ? 1.5 : 1,
                        ),
                      ),
                      child: Text(a, style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: _acorde == a ? neonGreen : textMid,
                      )),
                    ),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Diagrama del acorde + nombre
              if (_acorde != null) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Diagrama mástil
                  _buildFretboard(_acorde!),
                  const SizedBox(width: 20),
                  // Info del acorde
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 8),
                    Text(_acorde!, style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold, color: textWhite,
                      height: 1,
                    )),
                    Text(chordNames[_acorde!] ?? '', style: const TextStyle(
                      fontSize: 14, color: textGray,
                    )),
                    const SizedBox(height: 16),
                    const Text('NOTAS', style: TextStyle(
                      fontSize: 10, color: textGray, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6,
                      children: notas.map((n) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: neonGreen.withOpacity(0.4)),
                        ),
                        child: Text(n, style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold, color: neonGreen,
                        )),
                      )).toList(),
                    ),
                  ])),
                ]),
                const SizedBox(height: 20),
              ],

              // Resultado
              if (_result != null)
                _buildResultCard(correcto),

              const SizedBox(height: 20),
            ]),
          ),
        ),

        // Botón grabar + barra progreso
        _buildRecordSection(),
      ]),
    );
  }

  // ── DIAGRAMA MÁSTIL ──────────────────────────────────────
  Widget _buildFretboard(String acorde) {
    final dots = chordFrets[acorde] ?? [];
    const strings = 6;
    const frets   = 4;
    const cellW   = 28.0;
    const cellH   = 22.0;
    const dotR    = 9.0;

    return Container(
      width: cellW * strings + 16,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Cejuela (nut)
        Container(
          height: 4,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: textWhite.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Grid
        SizedBox(
          width: cellW * strings,
          height: cellH * frets,
          child: CustomPaint(
            painter: _FretboardPainter(
              dots: dots,
              strings: strings,
              frets: frets,
              cellW: cellW,
              cellH: cellH,
              dotR: dotR,
            ),
          ),
        ),
      ]),
    );
  }

  // ── RESULTADO ────────────────────────────────────────────
  Widget _buildResultCard(bool correcto) {
    final confianza = (_result!['confianza'] ?? 0).toStringAsFixed(0);
    final notasDetectadas = List<String>.from(_result!['notas_detectadas'] ?? []);
    final notasFaltantes  = List<String>.from(_result!['notas_faltantes']  ?? []);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: correcto ? neonGreen.withOpacity(0.08) : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correcto ? neonGreen.withOpacity(0.5) : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Column(children: [
        Text(
          correcto ? '¡Perfecto!' : 'Intenta de nuevo',
          style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold,
            color: correcto ? neonGreen : const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(height: 8),
        if (correcto) ...[
          Text('Confianza: $confianza%',
              style: const TextStyle(fontSize: 13, color: textMid)),
          const SizedBox(height: 4),
          Text('Detectadas: ${notasDetectadas.take(4).join(', ')}',
              style: const TextStyle(fontSize: 12, color: textGray)),
        ] else ...[
          if (notasFaltantes.isNotEmpty)
            Text('Notas faltantes: ${notasFaltantes.join(', ')}',
                style: const TextStyle(fontSize: 13, color: Color(0xFFFF6B6B))),
          const SizedBox(height: 4),
          Text('Confianza: $confianza%',
              style: const TextStyle(fontSize: 12, color: textGray)),
        ],
      ]),
    );
  }

  // ── SECCIÓN GRABAR ───────────────────────────────────────
  Widget _buildRecordSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_recording)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress / 30,
                minHeight: 3,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(neonGreen),
              ),
            ),
          ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScaleTransition(
            scale: _recording ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: _processing ? null : (_recording ? _stopRec : _startRec),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _recording ? Colors.red.shade700 : neonGreen.withOpacity(0.15),
                  border: Border.all(
                    color: _recording ? Colors.red : neonGreen,
                    width: 2,
                  ),
                  boxShadow: [BoxShadow(
                    color: (_recording ? Colors.red : neonGreen).withOpacity(0.3),
                    blurRadius: 20,
                  )],
                ),
                child: _processing
                  ? const Padding(padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(color: neonGreen, strokeWidth: 2))
                  : Icon(
                      _recording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: _recording ? textWhite : neonGreen,
                      size: 28,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _processing ? 'Analizando...' : _recording ? 'ESCUCHANDO' : '¡Tu turno!\nToca el acorde',
            style: TextStyle(
              fontSize: _recording ? 11 : 14,
              color: _recording ? neonGreen : textMid,
              letterSpacing: _recording ? 2 : 0,
              fontWeight: _recording ? FontWeight.w600 : FontWeight.normal,
              height: 1.4,
            ),
          ),
        ]),
      ]),
    );
  }

  // ── TRIVIA (placeholder) ─────────────────────────────────
  Widget _buildTrivia() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: bgCard, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: const Column(children: [
                Text('🎸', style: TextStyle(fontSize: 52)),
                SizedBox(height: 14),
                Text('Trivia de Acordes', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: textWhite)),
                SizedBox(height: 8),
                Text('Próximamente', style: TextStyle(fontSize: 13, color: textGray)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── CONFIG (placeholder) ─────────────────────────────────
  Widget _buildConfig() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          const Text('Configuración', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold, color: textWhite)),
          const SizedBox(height: 4),
          const Text('AJUSTES DE LA APP', style: TextStyle(
            fontSize: 10, color: textGray, letterSpacing: 1.5)),
          const SizedBox(height: 28),
          _configTile(Icons.wifi_rounded, 'Estado API',
            _online ? 'Conectada' : 'Desconectada',
            _online ? neonGreen : Colors.red,
            onTap: _checkServer,
          ),
          const SizedBox(height: 12),
          _configTile(Icons.info_outline_rounded, 'Versión', '1.0.0', textGray),
        ]),
      ),
    );
  }

  Widget _configTile(IconData icon, String title, String value, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, color: textWhite))),
          Text(value, style: TextStyle(fontSize: 13, color: color)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.refresh_rounded, color: textGray, size: 16),
          ],
        ]),
      ),
    );
  }
}

// ── FRETBOARD PAINTER ────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final List<List<int>> dots;
  final int strings;
  final int frets;
  final double cellW;
  final double cellH;
  final double dotR;

  const _FretboardPainter({
    required this.dots,
    required this.strings,
    required this.frets,
    required this.cellW,
    required this.cellH,
    required this.dotR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;

    // Líneas verticales (cuerdas)
    for (int s = 0; s < strings; s++) {
      final x = s * cellW + cellW / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Líneas horizontales (trastes)
    for (int f = 0; f <= frets; f++) {
      final y = f * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Puntos del acorde
    final dotPaint = Paint()..color = const Color(0xFF00FF7F);
    final shadowPaint = Paint()
      ..color = const Color(0xFF00FF7F).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (final dot in dots) {
      if (dot.length < 2) continue;
      final s = dot[0]; // cuerda
      final f = dot[1]; // traste
      if (s < 0 || s >= strings || f < 1 || f > frets) continue;

      final x = s * cellW + cellW / 2;
      final y = (f - 1) * cellH + cellH / 2;

      // Sombra glow
      canvas.drawCircle(Offset(x, y), dotR + 3, shadowPaint);
      // Punto
      canvas.drawCircle(Offset(x, y), dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_FretboardPainter old) => old.dots != dots;
}
