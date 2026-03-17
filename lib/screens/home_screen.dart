import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
const Map<String, List<List<int>>> chordFrets = {
  'A':  [[1,2],[2,2],[3,2]],   'Am': [[1,2],[2,2],[3,1]],
  'C':  [[1,3],[2,2],[4,1]],   'D':  [[1,3],[2,2],[3,3]],
  'Dm': [[1,3],[2,2],[3,1]],   'E':  [[3,1],[4,2],[5,2]],
  'Em': [[4,2],[5,2]],         'G':  [[0,3],[4,2],[5,3]],
  'C7': [[1,3],[2,2],[3,3],[4,1]], 'G7': [[0,3],[1,1],[4,2],[5,1]],
  'F':  [[0,1],[1,1],[2,2],[3,3],[4,3],[5,1]],
  'Bm': [[1,2],[2,4],[3,4],[4,3]], 'A7': [[1,2],[3,2]],
  'E7': [[3,1],[4,2]],         'Am7':[[1,2],[3,1]],
  'Cmaj7':[[1,3],[2,2],[3,4]], 'Dsus4':[[1,3],[2,3],[3,2]],
  'Asus4':[[1,2],[2,2],[3,2]], 'Gm': [[0,3],[1,1],[2,2],[3,3],[4,3],[5,1]],
  'F#m':[[0,2],[1,2],[2,4],[3,4],[4,3]],
};

// ── COLORS ───────────────────────────────────────────────
const bg      = Color(0xFF080808);
const bgCard  = Color(0xFF111111);
const bgCard2 = Color(0xFF1C1C1C);
const cWhite  = Color(0xFFF0F0F0);
const cDim    = Color(0xFF555555);
const cMid    = Color(0xFF888888);
const cGreen  = Color(0xFF00E676);
const cRed    = Color(0xFFFF5252);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  // 0=splash, 1=inicio, 2=practica, 3=config
  int     _page      = 0;
  String  _nivel     = 'basico';
  String? _acorde;
  bool    _recording = false;
  bool    _processing= false;
  int     _progress  = 0;
  Timer?  _timer;
  Map<String, dynamic>? _result;
  bool    _online    = false;
  bool    _checking  = false;

  // Mic test
  bool    _micTesting   = false;
  bool?   _micOk;
  Timer?  _micTimer;

  late AnimationController _navCtrl;
  late Animation<Offset>   _navSlide;
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  late AnimationController _pageCtrl;
  late Animation<double>   _pageFade;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _navSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeOutCubic));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
    _checkServer();
  }

  @override
  void dispose() {
    _audio.dispose();
    _timer?.cancel();
    _micTimer?.cancel();
    _navCtrl.dispose();
    _pulseCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _acordes {
    if (_nivel == 'medio')    return acordesMedios;
    if (_nivel == 'avanzado') return acordesAvanzados;
    return acordesBasicos;
  }

  Future<void> _checkServer() async {
    setState(() => _checking = true);
    final ok = await context.read<ApiService>().checkHealth();
    if (mounted) setState(() { _online = ok; _checking = false; });
  }

  void _goTo(int page) {
    HapticFeedback.lightImpact();
    setState(() { _page = page; _result = null; });
    _pageCtrl.reset();
    _pageCtrl.forward();
    if (page != 0) _navCtrl.forward();
  }

  bool get _navVisible => _page != 0;

  void _setAcorde(String a) {
    HapticFeedback.selectionClick();
    setState(() { _acorde = a; _result = null; });
  }

  void _randomAcorde() {
    final keys = _acordes.keys.toList();
    _setAcorde(keys[Random().nextInt(keys.length)]);
  }

  Future<void> _startRec() async {
    if (_acorde == null) { _snack('Selecciona un acorde primero'); return; }
    final ok = await _audio.startRecording();
    if (!ok) { _snack('Sin permiso de micrófono'); return; }
    HapticFeedback.mediumImpact();
    setState(() { _recording = true; _progress = 0; _result = null; });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _progress++);
      if (_progress >= 30) { t.cancel(); _stopRec(); }
    });
  }

  Future<void> _stopRec() async {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    final path = await _audio.stopRecording();
    setState(() { _recording = false; _progress = 0; });
    if (path != null) await _process(path);
  }

  Future<void> _process(String path) async {
    setState(() => _processing = true);
    try {
      final r = await context.read<ApiService>().detectarAcorde(path, acordeEsperado: _acorde);
      setState(() => _result = r);
      HapticFeedback.heavyImpact();
    } on TimeoutException {
      _snack('Tiempo de espera agotado.');
    } catch (e) {
      final msg = e.toString();
      _snack(msg.contains('SocketException') ? 'Sin conexión a la API.' : 'Error al analizar.');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _testMic() async {
    setState(() { _micTesting = true; _micOk = null; });
    final ok = await _audio.startRecording();
    if (ok) {
      _micTimer = Timer(const Duration(seconds: 2), () async {
        await _audio.stopRecording();
        if (mounted) setState(() { _micTesting = false; _micOk = true; });
      });
    } else {
      setState(() { _micTesting = false; _micOk = false; });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: cWhite, fontSize: 13)),
      backgroundColor: bgCard2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        // Contenido con fade
        FadeTransition(
          opacity: _pageFade,
          child: _buildPage(),
        ),
        // Nav bar inferior animada
        if (_navVisible)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(position: _navSlide, child: _buildNavBar()),
          ),
      ]),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case 0:  return _buildSplash();
      case 1:  return _buildInicio();
      case 2:  return _buildPractica();
      case 3:  return _buildConfig();
      default: return _buildSplash();
    }
  }

  // ── NAV BAR INFERIOR ─────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(1, Icons.home_rounded,        Icons.home_outlined,        'Inicio'),
        _navItem(2, Icons.music_note_rounded,  Icons.music_note_outlined,  'Practicar'),
        _navItem(3, Icons.settings_rounded,    Icons.settings_outlined,    'Ajustes'),
      ]),
    );
  }

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final sel = _page == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goTo(idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(sel ? active : inactive,
              key: ValueKey(sel),
              color: sel ? cWhite : cDim, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 10, letterSpacing: 0.5,
            color: sel ? cWhite : cDim,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          )),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sel ? 16 : 0, height: 2,
            decoration: BoxDecoration(
              color: cGreen,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ]),
      ),
    );
  }

  // ── SPLASH ───────────────────────────────────────────────
  Widget _buildSplash() {
    return Stack(fit: StackFit.expand, children: [
      // Imagen de fondo
      Image.asset('assets/fondo.png', fit: BoxFit.cover),
      // Blur + gradiente oscuro
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.92),
              Colors.black,
            ],
            stops: const [0.0, 0.35, 0.7, 1.0],
          ),
        ),
      ),
      // Contenido
      SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),
          // Logo
          Image.asset('assets/logo.png', width: 72, height: 72),
          const SizedBox(height: 20),
          const Text('Hola, músico.',
            style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w200,
              color: cWhite, letterSpacing: -0.5,
            )),
          const SizedBox(height: 8),
          Text('Toca. Aprende. Mejora.',
            style: TextStyle(
              fontSize: 13, color: cWhite.withOpacity(0.5),
              letterSpacing: 2,
            )),
          const Spacer(flex: 4),
          // Botón entrar
          GestureDetector(
            onTap: () => _goTo(1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cWhite,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('Comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: bg, letterSpacing: 0.5,
                )),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _goTo(3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Configuración',
                style: TextStyle(fontSize: 13, color: cWhite.withOpacity(0.4))),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    ]);
  }

  // ── INICIO ───────────────────────────────────────────────
  Widget _buildInicio() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(children: [
            Image.asset('assets/logo.png', width: 32, height: 32),
            const SizedBox(width: 10),
            const Text('Sonaris', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w300, color: cWhite, letterSpacing: 1,
            )),
            const Spacer(),
            Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _online ? cGreen : cRed,
                boxShadow: [BoxShadow(
                  color: (_online ? cGreen : cRed).withOpacity(0.6),
                  blurRadius: 6,
                )],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 36),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('¿Qué quieres\npracticar hoy?',
            style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w200,
              color: cWhite, height: 1.2,
            )),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _levelCard('Básico', 'Fundamentos y acordes abiertos',
                  '${acordesBasicos.length} acordes', 'basico', cGreen),
              const SizedBox(height: 12),
              _levelCard('Intermedio', 'Cejillas y acordes con séptima',
                  '${acordesMedios.length} acordes', 'medio', const Color(0xFFFFD54F)),
              const SizedBox(height: 12),
              _levelCard('Avanzado', 'Acordes complejos y variaciones',
                  '${acordesAvanzados.length} acordes', 'avanzado', cRed),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _levelCard(String title, String sub, String count, String nivel, Color color) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() { _nivel = nivel; _acorde = null; _result = null; });
        _goTo(2);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: cWhite)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 12, color: cMid)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(count, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: cDim, size: 12),
          ]),
        ]),
      ),
    );
  }

  // ── PRÁCTICA ─────────────────────────────────────────────
  Widget _buildPractica() {
    final correcto = _result?['es_correcto'] ?? false;
    final notas = _acorde != null ? (_acordes[_acorde!] ?? []) : [];

    return Column(children: [
      // Header con safe area
      Container(
        color: bg,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20, right: 20, bottom: 12,
        ),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _goTo(1),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: cMid, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _nivel == 'basico' ? 'Básico'
              : _nivel == 'medio' ? 'Intermedio' : 'Avanzado',
            style: const TextStyle(fontSize: 16, color: cWhite, fontWeight: FontWeight.w400),
          )),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _randomAcorde,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgCard2, borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shuffle_rounded, color: cMid, size: 14),
                SizedBox(width: 6),
                Text('Aleatorio', style: TextStyle(fontSize: 12, color: cMid)),
              ]),
            ),
          ),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(children: [
            // Grid acordes — chips grandes con tap area generosa
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _acordes.keys.map((a) {
                final sel = _acorde == a;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _setAcorde(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? cWhite.withOpacity(0.12) : bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? cWhite.withOpacity(0.6) : Colors.white.withOpacity(0.07),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(a, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: sel ? cWhite : cMid,
                    )),
                  ),
                );
              }).toList(),
            ),

            if (_acorde != null) ...[
              const SizedBox(height: 28),
              // Diagrama + info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildFretboard(_acorde!),
                  const SizedBox(width: 20),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_acorde!, style: const TextStyle(
                      fontSize: 56, fontWeight: FontWeight.w100,
                      color: cWhite, height: 1,
                    )),
                    const SizedBox(height: 4),
                    Text(chordNames[_acorde!] ?? '', style: const TextStyle(
                      fontSize: 12, color: cMid,
                    )),
                    const SizedBox(height: 16),
                    const Text('NOTAS', style: TextStyle(
                      fontSize: 9, color: cDim, letterSpacing: 2,
                    )),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6,
                      children: notas.map((n) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(n, style: const TextStyle(
                          fontSize: 12, color: cWhite, fontWeight: FontWeight.w500,
                        )),
                      )).toList(),
                    ),
                  ])),
                ]),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(correcto),
            ],

            const SizedBox(height: 100),
          ]),
        ),
      ),

      _buildRecordBar(),
    ]);
  }

  // ── CONFIG ───────────────────────────────────────────────
  Widget _buildConfig() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _goTo(1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: cMid, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Ajustes', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w300, color: cWhite,
            )),
          ]),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── Sección API ──
              _sectionLabel('CONEXIÓN'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(children: [
                  Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _checking ? Colors.amber
                            : _online ? cGreen : cRed,
                        boxShadow: [BoxShadow(
                          color: (_checking ? Colors.amber
                              : _online ? cGreen : cRed).withOpacity(0.5),
                          blurRadius: 8,
                        )],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        _checking ? 'Verificando...' : _online ? 'API conectada' : 'Sin conexión',
                        style: const TextStyle(fontSize: 14, color: cWhite, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 2),
                      const Text('sonarisapi.onrender.com',
                          style: TextStyle(fontSize: 11, color: cDim)),
                    ])),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _checking ? null : _checkServer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: bgCard2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _checking
                          ? const SizedBox(width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: cMid))
                          : const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.refresh_rounded, color: cMid, size: 14),
                              SizedBox(width: 5),
                              Text('Reconectar', style: TextStyle(fontSize: 11, color: cMid)),
                            ]),
                      ),
                    ),
                  ]),
                  if (!_online && !_checking) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cRed.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cRed.withOpacity(0.15)),
                      ),
                      child: const Text(
                        'Sin conexión. Render free tier puede tardar ~30s en despertar. Toca Reconectar.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFFF8080), height: 1.5),
                      ),
                    ),
                  ],
                ]),
              ),

              const SizedBox(height: 20),

              // ── Sección Micrófono ──
              _sectionLabel('MICRÓFONO'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: bgCard2, borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.mic_rounded, color: cMid, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Prueba de micrófono',
                          style: TextStyle(fontSize: 14, color: cWhite, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 2),
                      Text(
                        _micTesting ? 'Grabando 2 segundos...'
                          : _micOk == true  ? 'Micrófono funcionando ✓'
                          : _micOk == false ? 'Sin permiso de micrófono'
                          : 'Verifica que el micrófono funcione',
                        style: TextStyle(
                          fontSize: 11,
                          color: _micOk == true ? cGreen
                              : _micOk == false ? cRed : cDim,
                        ),
                      ),
                    ])),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _micTesting ? null : _testMic,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: bgCard2, borderRadius: BorderRadius.circular(10),
                        ),
                        child: _micTesting
                          ? const SizedBox(width: 14, height: 14,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: cMid))
                          : const Text('Probar', style: TextStyle(fontSize: 11, color: cMid)),
                      ),
                    ),
                  ]),
                  if (_micOk == false) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cRed.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: cRed.withOpacity(0.15)),
                      ),
                      child: const Text(
                        'Ve a Ajustes → Privacidad → Micrófono → Sonaris y activa el permiso.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFFF8080), height: 1.5),
                      ),
                    ),
                  ],
                ]),
              ),

              const SizedBox(height: 20),

              // ── Info ──
              _sectionLabel('ACERCA DE'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(children: [
                  Image.asset('assets/logo.png', width: 36, height: 36),
                  const SizedBox(width: 14),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Sonaris', style: TextStyle(fontSize: 15, color: cWhite, fontWeight: FontWeight.w400)),
                    SizedBox(height: 2),
                    Text('v1.0.0 · Detección DSP sin ML',
                        style: TextStyle(fontSize: 11, color: cDim)),
                  ]),
                ]),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
    style: const TextStyle(fontSize: 10, color: cDim, letterSpacing: 2, fontWeight: FontWeight.w500));

  // ── RESULTADO ────────────────────────────────────────────
  Widget _buildResultCard(bool correcto) {
    final confianza = (_result!['confianza'] ?? 0).toStringAsFixed(0);
    final faltantes = List<String>.from(_result!['notas_faltantes'] ?? []);
    final detectadas = List<String>.from(_result!['notas_detectadas'] ?? []);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correcto ? cGreen.withOpacity(0.3) : cRed.withOpacity(0.2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correcto ? cGreen : cRed,
              boxShadow: [BoxShadow(
                color: (correcto ? cGreen : cRed).withOpacity(0.5),
                blurRadius: 6,
              )],
            )),
          const SizedBox(width: 10),
          Text(correcto ? 'Correcto' : 'Intenta de nuevo',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: correcto ? cGreen : cRed,
            )),
          const Spacer(),
          Text('$confianza%', style: const TextStyle(fontSize: 12, color: cDim)),
        ]),
        if (correcto && detectadas.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Detectadas: ${detectadas.take(4).join(', ')}',
              style: const TextStyle(fontSize: 12, color: cMid)),
        ],
        if (!correcto && faltantes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Notas faltantes: ${faltantes.join(', ')}',
              style: const TextStyle(fontSize: 12, color: cMid)),
        ],
      ]),
    );
  }

  // ── BARRA GRABAR ─────────────────────────────────────────
  Widget _buildRecordBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(children: [
        // Botón mic
        ScaleTransition(
          scale: _recording ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _processing ? null : (_recording ? _stopRec : _startRec),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58, height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _recording ? cRed.withOpacity(0.15) : bgCard2,
                border: Border.all(
                  color: _recording ? cRed : Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: _processing
                ? const Padding(padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: cMid))
                : Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: _recording ? cRed : cMid, size: 26,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _processing ? 'Analizando...'
              : _recording ? 'ESCUCHANDO'
              : _acorde != null ? '¡Tu turno!\nToca el acorde'
              : 'Selecciona un acorde',
            style: TextStyle(
              fontSize: _recording ? 11 : 14,
              color: _recording ? cGreen : cWhite,
              letterSpacing: _recording ? 2.5 : 0,
              fontWeight: FontWeight.w300, height: 1.4,
            ),
          ),
          if (_recording) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _progress / 30,
                minHeight: 2,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: const AlwaysStoppedAnimation(cGreen),
              ),
            ),
          ],
        ])),
      ]),
    );
  }

  // ── FRETBOARD ────────────────────────────────────────────
  Widget _buildFretboard(String acorde) {
    final dots = chordFrets[acorde] ?? [];
    const s = 6; const f = 4;
    const cW = 26.0; const cH = 22.0; const dR = 8.0;
    return Container(
      width: cW * s + 16,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgCard2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: 3, margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: cWhite.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
        SizedBox(
          width: cW * s, height: cH * f,
          child: CustomPaint(painter: _FretPainter(
            dots: dots, strings: s, frets: f, cW: cW, cH: cH, dR: dR)),
        ),
      ]),
    );
  }
}

// ── FRETBOARD PAINTER ────────────────────────────────────
class _FretPainter extends CustomPainter {
  final List<List<int>> dots;
  final int strings, frets;
  final double cW, cH, dR;
  const _FretPainter({required this.dots, required this.strings,
    required this.frets, required this.cW, required this.cH, required this.dR});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 0.8;
    for (int s = 0; s < strings; s++) {
      final x = s * cW + cW / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (int f = 0; f <= frets; f++) {
      canvas.drawLine(Offset(0, f * cH), Offset(size.width, f * cH), line);
    }
    final dot  = Paint()..color = const Color(0xFFF0F0F0);
    final glow = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (final d in dots) {
      if (d.length < 2) continue;
      final s = d[0]; final f = d[1];
      if (s < 0 || s >= strings || f < 1 || f > frets) continue;
      final x = s * cW + cW / 2;
      final y = (f - 1) * cH + cH / 2;
      canvas.drawCircle(Offset(x, y), dR + 5, glow);
      canvas.drawCircle(Offset(x, y), dR, dot);
    }
  }

  @override
  bool shouldRepaint(_FretPainter o) => o.dots != dots;
}
