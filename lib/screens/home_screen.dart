import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';
import '../services/audio_service.dart';

const bg      = Color(0xFF080808);
const bgCard  = Color(0xFF111111);
const bgCard2 = Color(0xFF1A1A1A);
const cWhite  = Color(0xFFF0F0F0);
const cDim    = Color(0xFF444444);
const cMid    = Color(0xFF777777);
const cGreen  = Color(0xFF00E676);
const cRed    = Color(0xFFFF5252);
const cAmber  = Color(0xFFFFD54F);

const List<String> kAcordes = ['A', 'Am', 'C', 'D', 'F', 'Bm7'];

const Map<String, String> kNombres = {
  'A': 'LA Mayor', 'Am': 'LA Menor', 'C': 'DO Mayor',
  'D': 'RE Mayor', 'F': 'FA Mayor',  'Bm7': 'SI Menor 7ma',
};

const Map<String, List<String>> kNotas = {
  'A': ['A','C#','E'], 'Am': ['A','C','E'], 'C': ['C','E','G'],
  'D': ['D','F#','A'], 'F': ['F','A','C'],  'Bm7': ['B','D','F#','A'],
};

const Map<String, String> kDescripcion = {
  'A':   'Tres dedos en el segundo traste, cuerdas 2-3-4. Acorde abierto.',
  'Am':  'Similar a A pero con el dedo 1 en cuerda 2, traste 1.',
  'C':   'Forma diagonal con 3 dedos. Uno de los primeros acordes a aprender.',
  'D':   'Tres dedos en cuerdas 1-2-3. Solo se tocan 4 cuerdas.',
  'F':   'Cejilla completa en traste 1. El reto clásico del principiante.',
  'Bm7': 'Cejilla en traste 2 con dos dedos adicionales.',
};

const Map<String, String> kSamples = {
  'A': 'sample_A.wav', 'Am': 'sample_Am.wav', 'C': 'sample_C.wav',
  'D': 'sample_D.wav', 'F': 'sample_F.wav',   'Bm7': 'sample_Bm7.wav',
};

class _Dot {
  final int string, fret, finger;
  const _Dot(this.string, this.fret, this.finger);
}

class ChordDiagram {
  final int startFret;
  final List<_Dot> dots;
  final List<int> openStrings;
  final List<int> mutedStrings;
  final bool hasBarre;
  final int barreFret, barreFrom, barreTo;
  const ChordDiagram({
    this.startFret = 1, required this.dots,
    this.openStrings = const [], this.mutedStrings = const [],
    this.hasBarre = false, this.barreFret = 0,
    this.barreFrom = 0, this.barreTo = 5,
  });
}

const Map<String, ChordDiagram> kDiagramas = {
  'A':   ChordDiagram(startFret:1, dots:[_Dot(1,2,1),_Dot(2,2,2),_Dot(3,2,3)], openStrings:[4,5], mutedStrings:[0]),
  'Am':  ChordDiagram(startFret:1, dots:[_Dot(1,2,2),_Dot(2,2,3),_Dot(3,1,1)], openStrings:[4,5], mutedStrings:[0]),
  'C':   ChordDiagram(startFret:1, dots:[_Dot(1,1,1),_Dot(2,2,2),_Dot(4,3,3)], openStrings:[3,5], mutedStrings:[0]),
  'D':   ChordDiagram(startFret:1, dots:[_Dot(1,2,1),_Dot(2,3,3),_Dot(3,2,2)], openStrings:[4],   mutedStrings:[0,5]),
  'F':   ChordDiagram(startFret:1, dots:[_Dot(2,2,2),_Dot(3,3,3),_Dot(4,3,4)], hasBarre:true, barreFret:1, barreFrom:0, barreTo:5),
  'Bm7': ChordDiagram(startFret:2, dots:[_Dot(1,2,3),_Dot(3,1,2)], mutedStrings:[0], hasBarre:true, barreFret:1, barreFrom:1, barreTo:5),
};

class ChordDiagramWidget extends StatelessWidget {
  final String chord;
  final double size;
  const ChordDiagramWidget({super.key, required this.chord, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final d = kDiagramas[chord];
    if (d == null) return const SizedBox();
    return CustomPaint(
      size: Size(size * 0.7, size),
      painter: _ChordPainter(d, chord),
    );
  }
}

class _ChordPainter extends CustomPainter {
  final ChordDiagram d;
  final String chord;
  _ChordPainter(this.d, this.chord);

  @override
  void paint(Canvas canvas, Size size) {
    const nS = 6; const nF = 4;
    const tp = 36.0; const sp = 16.0;
    final w = size.width - sp * 2;
    final h = size.height - tp - 12;
    final sw = w / (nS - 1);
    final fh = h / nF;

    final lp = Paint()..color = const Color(0xFF3A3A3A)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    final np = Paint()..color = const Color(0xFFAAAAAA)..strokeWidth = 3.5..style = PaintingStyle.stroke;
    final gp = Paint()..color = cGreen.withOpacity(0.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)..style = PaintingStyle.fill;
    final dp = Paint()..color = cGreen..style = PaintingStyle.fill;

    if (d.hasBarre) {
      final bx1 = sp + d.barreFrom * sw;
      final bx2 = sp + d.barreTo * sw;
      final by  = tp + (d.barreFret - 1) * fh + fh / 2;
      final rr  = fh * 0.3;
      final br  = RRect.fromLTRBR(bx1, by - rr, bx2, by + rr, Radius.circular(rr));
      canvas.drawRRect(br, gp);
      canvas.drawRRect(br, dp);
    }

    for (int s = 0; s < nS; s++) {
      canvas.drawLine(Offset(sp + s * sw, tp), Offset(sp + s * sw, tp + h), lp);
    }
    canvas.drawLine(Offset(sp, tp), Offset(sp + w, tp), d.startFret == 1 ? np : lp);
    for (int f = 1; f <= nF; f++) {
      canvas.drawLine(Offset(sp, tp + f * fh), Offset(sp + w, tp + f * fh), lp);
    }

    if (d.startFret > 1) {
      final tp2 = TextPainter(text: TextSpan(text: '${d.startFret}fr', style: const TextStyle(color: cMid, fontSize: 9)), textDirection: TextDirection.ltr)..layout();
      tp2.paint(canvas, Offset(sp + w + 3, tp + fh / 2 - 6));
    }

    for (int s = 0; s < nS; s++) {
      final x = sp + s * sw;
      String? sym;
      if (d.mutedStrings.contains(s)) sym = '×';
      if (d.openStrings.contains(s))  sym = 'o';
      if (sym != null) {
        final tp2 = TextPainter(text: TextSpan(text: sym, style: const TextStyle(color: cMid, fontSize: 12, fontWeight: FontWeight.w300)), textDirection: TextDirection.ltr)..layout();
        tp2.paint(canvas, Offset(x - tp2.width / 2, tp - 22));
      }
    }

    for (final dot in d.dots) {
      final x = sp + dot.string * sw;
      final y = tp + (dot.fret - 1) * fh + fh / 2;
      final r = fh * 0.3;
      canvas.drawCircle(Offset(x, y), r + 5, gp);
      canvas.drawCircle(Offset(x, y), r, dp);
      final tp2 = TextPainter(text: TextSpan(text: '${dot.finger}', style: const TextStyle(color: bg, fontSize: 10, fontWeight: FontWeight.w700)), textDirection: TextDirection.ltr)..layout();
      tp2.paint(canvas, Offset(x - tp2.width / 2, y - tp2.height / 2));
    }
  }

  @override
  bool shouldRepaint(_ChordPainter o) => o.chord != chord;
}

// ── HOME SCREEN ──────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audio  = AudioService();
  final AudioPlayer  _player = AudioPlayer();

  int     _page       = 0; // 0=splash 1=acordes 2=practica 3=api
  String? _acorde;
  bool    _recording  = false;
  bool    _processing = false;
  int     _progress   = 0;
  Timer?  _timer;
  Map<String, dynamic>? _result;
  bool    _online     = false;
  bool    _checking   = false;
  bool    _playing    = false;

  // API monitor
  List<Map<String, dynamic>> _pingHistory = [];
  Timer? _pingTimer;

  late AnimationController _navCtrl;
  late Animation<Offset>   _navSlide;
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;
  late AnimationController _pageCtrl;
  late Animation<double>   _pageFade;

  @override
  void initState() {
    super.initState();
    _navCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _navSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeOutCubic));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
    _checkServer();
  }

  @override
  void dispose() {
    _audio.dispose();
    _player.dispose();
    _timer?.cancel();
    _pingTimer?.cancel();
    _navCtrl.dispose();
    _pulseCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    setState(() => _checking = true);
    final ok = await context.read<ApiService>().checkHealth();
    if (mounted) setState(() { _online = ok; _checking = false; });
  }

  void _goTo(int page) {
    HapticFeedback.lightImpact();
    if (page == 3) _startPingMonitor();
    else _pingTimer?.cancel();
    setState(() { _page = page; _result = null; });
    _pageCtrl.reset();
    _pageCtrl.forward();
    if (page != 0) _navCtrl.forward();
  }

  void _startPingMonitor() {
    _pingTimer?.cancel();
    _doPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) => _doPing());
  }

  Future<void> _doPing() async {
    final t0 = DateTime.now();
    final ok = await context.read<ApiService>().checkHealth();
    final ms = DateTime.now().difference(t0).inMilliseconds;
    if (!mounted) return;
    setState(() {
      _online = ok;
      _pingHistory.insert(0, {'ok': ok, 'ms': ms, 'time': DateTime.now()});
      if (_pingHistory.length > 20) _pingHistory.removeLast();
    });
  }

  Future<void> _playSample(String acorde) async {
    if (_playing) { await _player.stop(); setState(() => _playing = false); return; }
    final sample = kSamples[acorde];
    if (sample == null) return;
    setState(() => _playing = true);
    await _player.play(AssetSource(sample));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
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
    if (_acorde == null) return;
    setState(() => _processing = true);
    try {
      final r = await context.read<ApiService>().clasificarAcorde(path);
      // Adaptar respuesta de /clasificar al formato que espera la UI
      final predicho  = r['acorde_predicho'] as String? ?? '';
      final confianza = (r['confianza'] as num?)?.toDouble() ?? 0.0;
      final correcto  = predicho.toUpperCase() == _acorde!.toUpperCase();
      setState(() => _result = {
        'es_correcto':      correcto,
        'acorde_predicho':  predicho,
        'confianza':        confianza,
        'top5':             r['top5'] ?? [],
      });
      HapticFeedback.heavyImpact();
    } on TimeoutException {
      _snack('Tiempo de espera agotado.');
    } catch (e) {
      _snack(e.toString().contains('SocketException') ? 'Sin conexión.' : 'Error al analizar.');
    } finally {
      setState(() => _processing = false);
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
        FadeTransition(opacity: _pageFade, child: _buildPage()),
        if (_page != 0)
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
      case 1:  return _buildAcordes();
      case 2:  return _buildPractica();
      case 3:  return _buildApiMonitor();
      default: return _buildSplash();
    }
  }

  // ── NAV BAR ──────────────────────────────────────────────
  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: bgCard.withOpacity(0.97),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      padding: EdgeInsets.only(
        top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(1, Icons.library_music_rounded,  Icons.library_music_outlined,  'Acordes'),
        _navItem(2, Icons.mic_rounded,             Icons.mic_none_rounded,         'Practicar'),
        _navItem(3, Icons.monitor_heart_rounded,   Icons.monitor_heart_outlined,   'API'),
      ]),
    );
  }

  Widget _navItem(int idx, IconData active, IconData inactive, String label) {
    final sel = _page == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goTo(idx),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(sel ? active : inactive, color: sel ? cWhite : cDim, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 10, letterSpacing: 0.5,
            color: sel ? cWhite : cDim,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
          )),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sel ? 14 : 0, height: 2,
            decoration: BoxDecoration(
              color: cGreen, borderRadius: BorderRadius.circular(1)),
          ),
        ]),
      ),
    );
  }

  // ── SPLASH ───────────────────────────────────────────────
  Widget _buildSplash() {
    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/fondo.png', fit: BoxFit.cover),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.88),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      ),
      SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),
          const Text('Hola, músico.',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w200,
              color: cWhite, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Toca. Aprende. Mejora.',
            style: TextStyle(fontSize: 12,
              color: cWhite.withOpacity(0.45), letterSpacing: 2.5)),
          const Spacer(flex: 4),
          GestureDetector(
            onTap: () => _goTo(1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: cWhite, borderRadius: BorderRadius.circular(32)),
              child: const Text('Comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                  color: bg, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 28),
        ]),
      ),
    ]);
  }

  // ── ACORDES (lista con diagrama) ─────────────────────────
  Widget _buildAcordes() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Text('Acordes', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w200, color: cWhite, letterSpacing: 0.5)),
            const Spacer(),
            _statusDot(),
          ]),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('${kAcordes.length} acordes disponibles',
            style: const TextStyle(fontSize: 12, color: cMid)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: kAcordes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _acordeCard(kAcordes[i]),
          ),
        ),
      ]),
    );
  }

  Widget _acordeCard(String acorde) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() { _acorde = acorde; _result = null; });
        _goTo(2);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(children: [
          // Diagrama pequeño
          SizedBox(
            width: 70, height: 100,
            child: ChordDiagramWidget(chord: acorde, size: 100),
          ),
          const SizedBox(width: 18),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(acorde, style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w200, color: cWhite, height: 1)),
              const SizedBox(width: 10),
              Text(kNombres[acorde] ?? '', style: const TextStyle(
                fontSize: 11, color: cMid)),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 5, children: (kNotas[acorde] ?? []).map((n) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(n, style: const TextStyle(fontSize: 11, color: cWhite)),
              )
            ).toList()),
            const SizedBox(height: 10),
            Text(kDescripcion[acorde] ?? '',
              style: const TextStyle(fontSize: 11, color: cMid, height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: cDim, size: 12),
        ]),
      ),
    );
  }

  // ── PRÁCTICA ─────────────────────────────────────────────
  Widget _buildPractica() {
    final correcto = _result?['es_correcto'] == true;

    return Column(children: [
      // Header
      Container(
        color: bg,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20, right: 20, bottom: 12),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _goTo(1),
            child: const Padding(padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: cMid, size: 18)),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Practicar',
            style: TextStyle(fontSize: 16, color: cWhite, fontWeight: FontWeight.w300))),
          // Botón aleatorio
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final r = kAcordes[Random().nextInt(kAcordes.length)];
              setState(() { _acorde = r; _result = null; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: bgCard2, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shuffle_rounded, color: cMid, size: 13),
                SizedBox(width: 5),
                Text('Aleatorio', style: TextStyle(fontSize: 11, color: cMid)),
              ]),
            ),
          ),
        ]),
      ),

      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(children: [
            // Selector de acordes
            Wrap(
              spacing: 8, runSpacing: 8,
              children: kAcordes.map((a) {
                final sel = _acorde == a;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() { _acorde = a; _result = null; });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? cGreen.withOpacity(0.1) : bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? cGreen.withOpacity(0.6) : Colors.white.withOpacity(0.06),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(a, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: sel ? cGreen : cMid,
                    )),
                  ),
                );
              }).toList(),
            ),

            if (_acorde != null) ...[
              const SizedBox(height: 20),
              // Card principal con diagrama
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Diagrama grande
                    ChordDiagramWidget(chord: _acorde!, size: 200),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_acorde!, style: const TextStyle(
                        fontSize: 56, fontWeight: FontWeight.w100, color: cWhite, height: 1)),
                      const SizedBox(height: 4),
                      Text(kNombres[_acorde!] ?? '',
                        style: const TextStyle(fontSize: 11, color: cMid)),
                      const SizedBox(height: 16),
                      const Text('NOTAS', style: TextStyle(
                        fontSize: 9, color: cDim, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6,
                        children: (kNotas[_acorde!] ?? []).map((n) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(n, style: const TextStyle(
                            fontSize: 12, color: cWhite, fontWeight: FontWeight.w500)),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Botón escuchar muestra
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _playSample(_acorde!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: _playing ? cGreen.withOpacity(0.12) : bgCard2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _playing ? cGreen.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                              color: _playing ? cGreen : cMid, size: 14),
                            const SizedBox(width: 6),
                            Text(_playing ? 'Detener' : 'Escuchar',
                              style: TextStyle(
                                fontSize: 11,
                                color: _playing ? cGreen : cMid)),
                          ]),
                        ),
                      ),
                    ])),
                  ]),
                  const SizedBox(height: 14),
                  // Descripción
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgCard2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(kDescripcion[_acorde!] ?? '',
                      style: const TextStyle(fontSize: 12, color: cMid, height: 1.5)),
                  ),
                ]),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 14),
              _buildResultCard(correcto),
            ],

            const SizedBox(height: 120),
          ]),
        ),
      ),

      _buildRecordBar(),
    ]);
  }

  Widget _buildResultCard(bool correcto) {
    final confianza  = (_result!['confianza'] ?? 0).toStringAsFixed(0);
    final predicho   = _result!['acorde_predicho'] ?? '';
    final top5       = List<Map<String, dynamic>>.from(
        (_result!['top5'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correcto ? cGreen.withOpacity(0.3) : cRed.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correcto ? cGreen : cRed,
              boxShadow: [BoxShadow(
                color: (correcto ? cGreen : cRed).withOpacity(0.5), blurRadius: 6)],
            )),
          const SizedBox(width: 10),
          Text(correcto ? '¡Correcto!' : 'Intenta de nuevo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: correcto ? cGreen : cRed)),
          const Spacer(),
          Text('$confianza%', style: const TextStyle(fontSize: 12, color: cDim)),
        ]),
        const SizedBox(height: 10),
        Text('Detectado: $predicho',
          style: const TextStyle(fontSize: 13, color: cWhite)),
        if (top5.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('PROBABILIDADES', style: TextStyle(
            fontSize: 9, color: cDim, letterSpacing: 2)),
          const SizedBox(height: 8),
          ...top5.take(3).map((e) {
            final pct = (e['probabilidad'] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(width: 36,
                  child: Text(e['acorde'] ?? '',
                    style: const TextStyle(fontSize: 12, color: cWhite))),
                const SizedBox(width: 8),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(
                      pct > 60 ? cGreen : pct > 30 ? cAmber : cDim),
                  ),
                )),
                const SizedBox(width: 8),
                Text('${pct.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11, color: cMid)),
              ]),
            );
          }),
        ],
      ]),
    );
  }

  Widget _buildRecordBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 80),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(children: [
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
                color: _recording ? cRed.withOpacity(0.12) : bgCard2,
                border: Border.all(
                  color: _recording ? cRed : Colors.white.withOpacity(0.1),
                  width: 1.5),
              ),
              child: _processing
                ? const Padding(padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: cMid))
                : Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: _recording ? cRed : cMid, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            _processing ? 'Analizando con IA...'
              : _recording ? 'ESCUCHANDO'
              : _acorde != null ? 'Toca el acorde y graba'
              : 'Selecciona un acorde',
            style: TextStyle(
              fontSize: _recording ? 11 : 14,
              color: _recording ? cGreen : cWhite,
              letterSpacing: _recording ? 2.5 : 0,
              fontWeight: FontWeight.w300, height: 1.4),
          ),
          if (_recording) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _progress / 30,
                minHeight: 2,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation(cGreen),
              ),
            ),
          ],
        ])),
      ]),
    );
  }

  // ── API MONITOR ──────────────────────────────────────────
  Widget _buildApiMonitor() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Text('API Monitor', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w200, color: cWhite)),
            const Spacer(),
            _statusDot(),
          ]),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('sonarisapi.onrender.com',
            style: const TextStyle(fontSize: 11, color: cDim)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              // Estado general
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _checking ? cAmber : _online ? cGreen : cRed,
                      boxShadow: [BoxShadow(
                        color: (_checking ? cAmber : _online ? cGreen : cRed).withOpacity(0.5),
                        blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _checking ? 'Verificando...' : _online ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 15, color: cWhite, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 2),
                    Text('Modelo: MLP · 6 acordes · 99.7% acc',
                      style: const TextStyle(fontSize: 11, color: cDim)),
                  ])),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _doPing,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: bgCard2, borderRadius: BorderRadius.circular(10)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.refresh_rounded, color: cMid, size: 14),
                        SizedBox(width: 5),
                        Text('Ping', style: TextStyle(fontSize: 11, color: cMid)),
                      ]),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 10),

              // Endpoints
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ENDPOINTS', style: TextStyle(
                    fontSize: 9, color: cDim, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  _endpointRow('POST', '/clasificar', 'MLP · 6 acordes', cGreen),
                  const SizedBox(height: 8),
                  _endpointRow('POST', '/verificar',  'DSP fallback',    cAmber),
                  const SizedBox(height: 8),
                  _endpointRow('GET',  '/health',     'Health check',    cMid),
                  const SizedBox(height: 8),
                  _endpointRow('GET',  '/acordes',    'Lista acordes',   cMid),
                ]),
              ),

              const SizedBox(height: 10),

              // Historial de pings
              if (_pingHistory.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('HISTORIAL DE PINGS', style: TextStyle(
                        fontSize: 9, color: cDim, letterSpacing: 2)),
                      const Spacer(),
                      Text('auto cada 10s', style: const TextStyle(
                        fontSize: 9, color: cDim)),
                    ]),
                    const SizedBox(height: 12),
                    ..._pingHistory.take(8).map((p) {
                      final ok = p['ok'] as bool;
                      final ms = p['ms'] as int;
                      final t  = p['time'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Container(width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ok ? cGreen : cRed)),
                          const SizedBox(width: 10),
                          Text('${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:${t.second.toString().padLeft(2,'0')}',
                            style: const TextStyle(fontSize: 11, color: cMid)),
                          const Spacer(),
                          Text(ok ? '${ms}ms' : 'timeout',
                            style: TextStyle(
                              fontSize: 11,
                              color: ok ? (ms < 500 ? cGreen : ms < 1500 ? cAmber : cRed) : cRed)),
                        ]),
                      );
                    }),
                  ]),
                ),
              ],

              // Info modelo
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('MODELO', style: TextStyle(
                    fontSize: 9, color: cDim, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  _infoRow('Tipo',      'MLP (sklearn)'),
                  _infoRow('Capas',     '128 → 64 → 6'),
                  _infoRow('Dataset',   '12,360 archivos WAV reales'),
                  _infoRow('Acordes',   'A · Am · C · D · F · Bm7'),
                  _infoRow('Accuracy',  '99.73%'),
                  _infoRow('Features',  '31 (chroma + spectral + pitch)'),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _endpointRow(String method, String path, String desc, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(method, style: TextStyle(
          fontSize: 9, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
      const SizedBox(width: 10),
      Text(path, style: const TextStyle(fontSize: 12, color: cWhite, fontFamily: 'monospace')),
      const Spacer(),
      Text(desc, style: const TextStyle(fontSize: 11, color: cDim)),
    ]);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80,
          child: Text(label, style: const TextStyle(fontSize: 12, color: cMid))),
        Expanded(child: Text(value,
          style: const TextStyle(fontSize: 12, color: cWhite))),
      ]),
    );
  }

  Widget _statusDot() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _checkServer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 7, height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _checking ? cAmber : _online ? cGreen : cRed,
          boxShadow: [BoxShadow(
            color: (_checking ? cAmber : _online ? cGreen : cRed).withOpacity(0.6),
            blurRadius: 6)],
        ),
      ),
    );
  }
}
