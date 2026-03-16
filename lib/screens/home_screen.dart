import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';
import '../services/audio_service.dart';

// Acordes por nivel
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

// Colores
const bgDark    = Color(0xFF0D0D1A);
const bgCard    = Color(0xFF1A1A2E);
const bgCard2   = Color(0xFF16213E);
const purple    = Color(0xFF7C3AED);
const purpleL   = Color(0xFFA855F7);
const green     = Color(0xFF10B981);
const greenL    = Color(0xFF34D399);
const textWhite = Color(0xFFF8FAFC);
const textGray  = Color(0xFF94A3B8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  int    _tab        = 0;
  String _nivel      = 'basico';
  String? _acorde;
  bool   _recording  = false;
  bool   _processing = false;
  int    _progress   = 0;
  Timer? _timer;
  Map<String, dynamic>? _result;
  bool   _online     = false;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.12).animate(
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
    setState(() => _online = ok);
  }

  void _setAcorde(String a) => setState(() { _acorde = a; _result = null; });

  void _randomAcorde() {
    final keys = _acordes.keys.toList();
    _setAcorde(keys[Random().nextInt(keys.length)]);
  }

  Future<void> _startRec() async {
    if (_acorde == null) {
      _snack('Selecciona un acorde primero');
      return;
    }
    final ok = await _audio.startRecording();
    if (!ok) {
      _snack('Sin permiso de micrófono. Ve a Ajustes → Privacidad → Micrófono → Sonaris');
      return;
    }
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
    } catch (e) {
      _snack('Error al analizar: ${e.toString().substring(0, e.toString().length.clamp(0, 80))}');
    } finally {
      setState(() => _processing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade800,
               behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Column(children: [
        Expanded(child: _tab == 0 ? _buildInicio() : _tab == 1 ? _buildAprender() : _buildProgreso()),
        _buildNavBar(),
      ]),
    );
  }

  // ── NAV BAR ─────────────────────────────────────────────
  Widget _buildNavBar() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
      (Icons.music_note_rounded, Icons.music_note_outlined, 'Aprender'),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Progreso'),
    ];
    return Container(
      color: bgCard,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final sel = _tab == i;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(sel ? items[i].$1 : items[i].$2,
                   color: sel ? purpleL : textGray, size: 24),
              const SizedBox(height: 4),
              Text(items[i].$3,
                   style: TextStyle(fontSize: 11,
                       color: sel ? purpleL : textGray,
                       fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
            ]),
          );
        }),
      ),
    );
  }

  // ── INICIO ──────────────────────────────────────────────
  Widget _buildInicio() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [purple, purpleL],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: purple.withOpacity(0.4),
                  blurRadius: 30, offset: const Offset(0, 10))]),
            child: const Icon(Icons.music_note_rounded, color: textWhite, size: 44)),
          const SizedBox(height: 20),
          const Text('Sonaris', style: TextStyle(fontSize: 36,
              fontWeight: FontWeight.bold, color: textWhite)),
          const SizedBox(height: 6),
          const Text('Aprende acordes de guitarra',
              style: TextStyle(fontSize: 15, color: textGray)),
          const SizedBox(height: 8),
          // Server status
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 8, height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _online ? green : Colors.red)),
            const SizedBox(width: 6),
            Text(_online ? 'API conectada' : 'API desconectada',
                style: TextStyle(fontSize: 12,
                    color: _online ? green : Colors.red)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _checkServer,
              child: const Icon(Icons.refresh_rounded, color: textGray, size: 16)),
          ]),
          const SizedBox(height: 32),
          // Stats cards
          Row(children: [
            _statCard('🟢', 'Básicos', '${acordesBasicos.length}', green),
            const SizedBox(width: 12),
            _statCard('🟡', 'Medios', '${acordesMedios.length}', Colors.amber),
            const SizedBox(width: 12),
            _statCard('🔴', 'Avanzados', '${acordesAvanzados.length}', Colors.red),
          ]),
          const SizedBox(height: 32),
          // CTA button
          GestureDetector(
            onTap: () => setState(() => _tab = 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [purple, purpleL]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: purple.withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8))]),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_arrow_rounded, color: textWhite, size: 24),
                SizedBox(width: 8),
                Text('Comenzar a practicar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: textWhite)),
              ])),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _statCard(String emoji, String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: bgCard, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(count, style: TextStyle(fontSize: 22,
              fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: textGray)),
        ]),
      ),
    );
  }

  // ── APRENDER ────────────────────────────────────────────
  Widget _buildAprender() {
    final notas = _acorde != null ? (_acordes[_acorde!] ?? []) : [];
    final correcto = _result?['es_correcto'] ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Práctica', style: TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold, color: textWhite)),
                  Row(children: [
                    Container(width: 7, height: 7,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: green)),
                    const SizedBox(width: 5),
                    const Text('DSP activo', style: TextStyle(fontSize: 11, color: green)),
                  ]),
                ]),
                GestureDetector(
                  onTap: _randomAcorde,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: bgCard2,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.shuffle_rounded, color: purpleL, size: 16),
                      SizedBox(width: 6),
                      Text('Aleatorio', style: TextStyle(fontSize: 12, color: purpleL)),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Waveform decorativo
          Container(
            margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            height: 56,
            decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text('〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜',
                  style: TextStyle(fontSize: 18,
                      color: _recording ? green : purpleL))),
          ),

          // Nombre del acorde
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Text(
                _acorde != null ? (chordNames[_acorde!] ?? _acorde!) : 'Selecciona un acorde',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
                    color: purpleL),
                textAlign: TextAlign.center),
              if (_acorde != null) ...[
                const SizedBox(height: 4),
                Text('${_acorde!} CHORD',
                    style: const TextStyle(fontSize: 11, color: textGray,
                        letterSpacing: 2)),
              ],
            ]),
          ),

          // Notas chips
          if (notas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: notas.map((n) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF6D28D9),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(n, style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.bold, color: textWhite)),
                  )).toList()),
            ),

          const SizedBox(height: 14),

          // Selector de nivel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _nivelBtn('🟢 Básico', 'basico'),
              const SizedBox(width: 8),
              _nivelBtn('🟡 Medio', 'medio'),
              const SizedBox(width: 8),
              _nivelBtn('🔴 Avanzado', 'avanzado'),
            ]),
          ),

          const SizedBox(height: 12),

          // Grid de acordes
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgCard,
                borderRadius: BorderRadius.circular(20)),
            child: Wrap(spacing: 8, runSpacing: 8,
                children: _acordes.keys.map((a) => GestureDetector(
                  onTap: () => _setAcorde(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: _acorde == a ? purple : bgCard2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _acorde == a ? purpleL : purple, width: 1.5)),
                    child: Text(a, style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _acorde == a ? textWhite : textGray)),
                  ),
                )).toList()),
          ),

          const SizedBox(height: 14),

          // Resultado
          if (_result != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: correcto ? const Color(0xFF064E3B) : const Color(0xFF450A0A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: correcto ? green : Colors.red, width: 1.5)),
              child: Column(children: [
                Text(correcto ? '¡Perfecto! ✅' : 'Intenta de nuevo ❌',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: correcto ? greenL : const Color(0xFFFCA5A5)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(
                  correcto
                    ? 'Confianza: ${(_result!['confianza'] ?? 0).toStringAsFixed(0)}%  ·  ${(List<String>.from(_result!['notas_detectadas'] ?? [])).take(4).join(', ')}'
                    : '"Sigue practicando, ¡lo lograrás!"',
                  style: const TextStyle(fontSize: 13, color: textGray),
                  textAlign: TextAlign.center),
              ]),
            ),

          const SizedBox(height: 16),

          // Botón micrófono
          Column(children: [
            ScaleTransition(
              scale: _recording ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: _processing ? null : (_recording ? _stopRec : _startRec),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _recording ? Colors.red : purple,
                    boxShadow: [BoxShadow(
                        color: (_recording ? Colors.red : purple).withOpacity(0.5),
                        blurRadius: 24, offset: const Offset(0, 8))]),
                  child: _processing
                    ? const Padding(padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: textWhite, strokeWidth: 2))
                    : Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: textWhite, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_recording)
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress / 30,
                    backgroundColor: bgCard2,
                    valueColor: const AlwaysStoppedAnimation(green)),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              _processing ? 'Analizando...' : _recording ? 'Grabando...' : 'Pulsa para analizar',
              style: const TextStyle(fontSize: 13, color: textGray)),
          ]),

          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _nivelBtn(String label, String value) {
    final sel = _nivel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _nivel = value; _acorde = null; _result = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: sel ? purple : bgCard2,
              borderRadius: BorderRadius.circular(20)),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11,
                  color: sel ? textWhite : textGray,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
        ),
      ),
    );
  }

  // ── PROGRESO ────────────────────────────────────────────
  Widget _buildProgreso() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: bgCard,
                  borderRadius: BorderRadius.circular(24)),
              child: const Column(children: [
                Text('📊', style: TextStyle(fontSize: 56)),
                SizedBox(height: 16),
                Text('Progreso', style: TextStyle(fontSize: 24,
                    fontWeight: FontWeight.bold, color: textWhite)),
                SizedBox(height: 8),
                Text('Aquí verás tu historial\nde práctica y progreso',
                    style: TextStyle(fontSize: 14, color: textGray),
                    textAlign: TextAlign.center),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
