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
const bg       = Color(0xFF080808);
const bgCard   = Color(0xFF111111);
const bgCard2  = Color(0xFF1A1A1A);
const accent   = Color(0xFFE8E8E8);
const accentDim= Color(0xFF666666);
const accentG  = Color(0xFF00FF88);
const textW    = Color(0xFFF5F5F5);
const textD    = Color(0xFF555555);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  // nav: -1=splash, 0=inicio, 1=practica, 2=config
  int     _page       = -1;
  bool    _menuOpen   = false;
  String  _nivel      = 'basico';
  String? _acorde;
  bool    _recording  = false;
  bool    _processing = false;
  int     _progress   = 0;
  Timer?  _timer;
  Map<String, dynamic>? _result;
  bool    _online     = false;
  bool    _checking   = false;

  late AnimationController _menuCtrl;
  late Animation<Offset>   _menuSlide;
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _menuSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    _checkServer();
  }

  @override
  void dispose() {
    _audio.dispose();
    _timer?.cancel();
    _menuCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
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

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    _menuOpen ? _menuCtrl.forward() : _menuCtrl.reverse();
  }

  void _goTo(int page) {
    setState(() { _page = page; _menuOpen = false; _result = null; });
    _menuCtrl.reverse();
    _fadeCtrl.reset();
    _fadeCtrl.forward();
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
        _snack('Error: ${msg.substring(0, msg.length.clamp(0, 60))}');
      }
    } finally {
      setState(() => _processing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: textW, fontSize: 13)),
      backgroundColor: bgCard2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        // Contenido principal
        FadeTransition(
          opacity: _fadeAnim,
          child: _page == -1 ? _buildSplash()
              : _page == 0   ? _buildInicio()
              : _page == 1   ? _buildPractica()
              :                _buildConfig(),
        ),
        // Overlay oscuro cuando menú abierto
        if (_menuOpen)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
        // Menú deslizable desde abajo
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _menuSlide,
            child: _buildMenu(),
          ),
        ),
      ]),
    );
  }

  // ── SPLASH / BIENVENIDA ──────────────────────────────────
  Widget _buildSplash() {
    return SafeArea(
      child: Column(children: [
        const Spacer(flex: 2),
        // Logo
        Image.asset('assets/logo.png', width: 90, height: 90),
        const SizedBox(height: 28),
        const Text('Hola, músico.',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300,
                color: textW, letterSpacing: -0.5)),
        const SizedBox(height: 10),
        const Text('Toca. Aprende. Mejora.',
            style: TextStyle(fontSize: 14, color: accentDim, letterSpacing: 1.5)),
        const Spacer(flex: 3),
        // Botón menú
        _buildMenuButton(),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ── INICIO ───────────────────────────────────────────────
  Widget _buildInicio() {
    return SafeArea(
      child: Column(children: [
        const Spacer(flex: 2),
        Image.asset('assets/logo.png', width: 64, height: 64),
        const SizedBox(height: 20),
        const Text('Sonaris', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w300, color: textW, letterSpacing: 2)),
        const SizedBox(height: 6),
        const Text('Detección de acordes DSP',
            style: TextStyle(fontSize: 12, color: accentDim, letterSpacing: 1.5)),
        const Spacer(flex: 1),
        // Cards de nivel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            _nivelCard('Básico', '${acordesBasicos.length} acordes', 'basico'),
            const SizedBox(height: 10),
            _nivelCard('Intermedio', '${acordesMedios.length} acordes', 'medio'),
            const SizedBox(height: 10),
            _nivelCard('Avanzado', '${acordesAvanzados.length} acordes', 'avanzado'),
          ]),
        ),
        const Spacer(flex: 2),
        _buildMenuButton(),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _nivelCard(String title, String sub, String nivel) {
    return GestureDetector(
      onTap: () {
        setState(() { _nivel = nivel; _acorde = null; _result = null; });
        _goTo(1);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textW)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 12, color: accentDim)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: accentDim, size: 14),
        ]),
      ),
    );
  }

  // ── PRÁCTICA ─────────────────────────────────────────────
  Widget _buildPractica() {
    final correcto = _result?['es_correcto'] ?? false;
    final notas = _acorde != null ? (_acordes[_acorde!] ?? []) : [];

    return SafeArea(
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => _goTo(0),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: accentDim, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _nivel == 'basico' ? 'Básico' : _nivel == 'medio' ? 'Intermedio' : 'Avanzado',
              style: const TextStyle(fontSize: 15, color: textW, fontWeight: FontWeight.w400),
            )),
            GestureDetector(
              onTap: _randomAcorde,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgCard2, borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shuffle_rounded, color: accentDim, size: 13),
                  SizedBox(width: 5),
                  Text('Aleatorio', style: TextStyle(fontSize: 11, color: accentDim)),
                ]),
              ),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              const SizedBox(height: 20),
              // Grid acordes
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _acordes.keys.map((a) => GestureDetector(
                  onTap: () => _setAcorde(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _acorde == a ? textW.withOpacity(0.1) : bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _acorde == a ? textW.withOpacity(0.5) : Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Text(a, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: _acorde == a ? textW : accentDim,
                    )),
                  ),
                )).toList(),
              ),

              if (_acorde != null) ...[
                const SizedBox(height: 28),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildFretboard(_acorde!),
                  const SizedBox(width: 20),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 4),
                    Text(_acorde!, style: const TextStyle(
                      fontSize: 52, fontWeight: FontWeight.w200, color: textW, height: 1,
                    )),
                    Text(chordNames[_acorde!] ?? '', style: const TextStyle(
                      fontSize: 12, color: accentDim, letterSpacing: 0.5,
                    )),
                    const SizedBox(height: 18),
                    Wrap(spacing: 6, runSpacing: 6,
                      children: notas.map((n) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(n, style: const TextStyle(
                          fontSize: 12, color: textW, fontWeight: FontWeight.w500,
                        )),
                      )).toList(),
                    ),
                  ])),
                ]),
              ],

              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(correcto),
              ],

              const SizedBox(height: 24),
            ]),
          ),
        ),

        // Sección grabar
        _buildRecordSection(),
      ]),
    );
  }

  // ── CONFIG ───────────────────────────────────────────────
  Widget _buildConfig() {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => _goTo(0),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: accentDim, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Configuración', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w300, color: textW, letterSpacing: 0.5,
            )),
          ]),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            // Card estado API
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('API', style: TextStyle(
                  fontSize: 10, color: accentDim, letterSpacing: 2,
                )),
                const SizedBox(height: 14),
                Row(children: [
                  // Indicador
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _checking ? Colors.amber
                           : _online   ? accentG
                           :             Colors.red.shade400,
                      boxShadow: [BoxShadow(
                        color: (_checking ? Colors.amber
                              : _online   ? accentG
                              :             Colors.red.shade400).withOpacity(0.5),
                        blurRadius: 8,
                      )],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _checking ? 'Verificando...'
                          : _online ? 'Conectada'
                          : 'Sin conexión',
                      style: TextStyle(
                        fontSize: 15, color: textW, fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('sonarisapi.onrender.com',
                        style: TextStyle(fontSize: 11, color: accentDim)),
                  ])),
                  // Botón reconectar
                  GestureDetector(
                    onTap: _checking ? null : _checkServer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgCard2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (_checking)
                          const SizedBox(width: 12, height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: accentDim))
                        else
                          const Icon(Icons.refresh_rounded, color: accentDim, size: 14),
                        const SizedBox(width: 6),
                        Text(_checking ? 'Verificando' : 'Reconectar',
                            style: const TextStyle(fontSize: 11, color: accentDim)),
                      ]),
                    ),
                  ),
                ]),
                if (!_online && !_checking) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.15)),
                    ),
                    child: const Text(
                      'La API no responde. Verifica tu conexión a internet o espera a que el servidor despierte (Render free tier puede tardar ~30s).',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFF8080), height: 1.5),
                    ),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            // Info versión
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(children: [
                Image.asset('assets/logo.png', width: 28, height: 28),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Sonaris', style: TextStyle(fontSize: 14, color: textW, fontWeight: FontWeight.w400)),
                  Text('v1.0.0 · DSP sin ML', style: TextStyle(fontSize: 11, color: accentDim)),
                ])),
              ]),
            ),
          ]),
        ),
        const Spacer(),
        _buildMenuButton(),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ── MENÚ DESLIZABLE ──────────────────────────────────────
  Widget _buildMenu() {
    final items = [
      (Icons.home_outlined,       'Inicio',        0),
      (Icons.music_note_outlined, 'Practicar',     1),
      (Icons.settings_outlined,   'Configuración', 2),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
          width: 36, height: 3,
          margin: const EdgeInsets.only(bottom: 20, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        ...items.map((item) => GestureDetector(
          onTap: () => _goTo(item.$3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Row(children: [
              Icon(item.$1,
                color: _page == item.$3 ? textW : accentDim,
                size: 20),
              const SizedBox(width: 16),
              Text(item.$2, style: TextStyle(
                fontSize: 16,
                color: _page == item.$3 ? textW : accentDim,
                fontWeight: _page == item.$3 ? FontWeight.w500 : FontWeight.w300,
              )),
              if (_page == item.$3) ...[
                const Spacer(),
                Container(width: 5, height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: accentG)),
              ],
            ]),
          ),
        )),
      ]),
    );
  }

  // ── BOTÓN MENÚ (hamburguesa) ─────────────────────────────
  Widget _buildMenuButton() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: _toggleMenu,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgCard2,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(
            _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
            color: textW, size: 22,
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Text('MENÚ', style: TextStyle(
        fontSize: 9, color: accentDim, letterSpacing: 2,
      )),
    ]);
  }

  // ── FRETBOARD ────────────────────────────────────────────
  Widget _buildFretboard(String acorde) {
    final dots = chordFrets[acorde] ?? [];
    const strings = 6;
    const frets   = 4;
    const cellW   = 26.0;
    const cellH   = 20.0;
    const dotR    = 8.0;

    return Container(
      width: cellW * strings + 16,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgCard2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: 3, margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: textW.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          )),
        SizedBox(
          width: cellW * strings,
          height: cellH * frets,
          child: CustomPaint(painter: _FretboardPainter(
            dots: dots, strings: strings, frets: frets,
            cellW: cellW, cellH: cellH, dotR: dotR,
          )),
        ),
      ]),
    );
  }

  // ── RESULTADO ────────────────────────────────────────────
  Widget _buildResultCard(bool correcto) {
    final confianza = (_result!['confianza'] ?? 0).toStringAsFixed(0);
    final faltantes = List<String>.from(_result!['notas_faltantes'] ?? []);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: correcto ? accentG.withOpacity(0.3) : Colors.red.withOpacity(0.2),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correcto ? accentG : Colors.red.shade400,
            )),
          const SizedBox(width: 8),
          Text(
            correcto ? 'Correcto' : 'Intenta de nuevo',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500,
              color: correcto ? accentG : Colors.red.shade300,
            ),
          ),
          const Spacer(),
          Text('$confianza%', style: const TextStyle(fontSize: 12, color: accentDim)),
        ]),
        if (!correcto && faltantes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Notas faltantes: ${faltantes.join(', ')}',
              style: const TextStyle(fontSize: 12, color: accentDim)),
        ],
      ]),
    );
  }

  // ── SECCIÓN GRABAR ───────────────────────────────────────
  Widget _buildRecordSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
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
            onTap: _processing ? null : (_recording ? _stopRec : _startRec),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _recording ? Colors.red.withOpacity(0.15) : bgCard2,
                border: Border.all(
                  color: _recording ? Colors.red.shade400 : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: _processing
                ? const Padding(padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: accentDim))
                : Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: _recording ? Colors.red.shade300 : accentDim,
                    size: 24,
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
              color: _recording ? accentG : textW,
              letterSpacing: _recording ? 2 : 0,
              fontWeight: FontWeight.w300,
              height: 1.4,
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
                valueColor: const AlwaysStoppedAnimation(accentG),
              ),
            ),
          ],
        ])),
      ]),
    );
  }
}

// ── FRETBOARD PAINTER ────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final List<List<int>> dots;
  final int strings, frets;
  final double cellW, cellH, dotR;

  const _FretboardPainter({
    required this.dots, required this.strings, required this.frets,
    required this.cellW, required this.cellH, required this.dotR,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.8;

    for (int s = 0; s < strings; s++) {
      final x = s * cellW + cellW / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (int f = 0; f <= frets; f++) {
      final y = f * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    final dot = Paint()..color = textW;
    final glow = Paint()
      ..color = textW.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (final d in dots) {
      if (d.length < 2) continue;
      final s = d[0]; final f = d[1];
      if (s < 0 || s >= strings || f < 1 || f > frets) continue;
      final x = s * cellW + cellW / 2;
      final y = (f - 1) * cellH + cellH / 2;
      canvas.drawCircle(Offset(x, y), dotR + 4, glow);
      canvas.drawCircle(Offset(x, y), dotR, dot);
    }
  }

  @override
  bool shouldRepaint(_FretboardPainter old) => old.dots != dots;
}
