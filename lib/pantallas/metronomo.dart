import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constantes/colores.dart';

class PantallaMetronomo extends StatefulWidget {
  const PantallaMetronomo({super.key});

  @override
  State<PantallaMetronomo> createState() => _EstadoMetronomo();
}

class _EstadoMetronomo extends State<PantallaMetronomo>
    with SingleTickerProviderStateMixin {
  int _bpm = 80;
  bool _activo = false;
  int _beat = 0;
  int _compas = 4;
  Timer? _timer;

  late AnimationController _pulsoCtrl;
  late Animation<double> _pulsoAnim;

  @override
  void initState() {
    super.initState();
    _pulsoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pulsoAnim = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulsoCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulsoCtrl.dispose();
    super.dispose();
  }

  void _toggleMetronomo() {
    if (_activo) {
      _timer?.cancel();
      setState(() {
        _activo = false;
        _beat = 0;
      });
    } else {
      setState(() => _activo = true);
      _tick();
      _timer = Timer.periodic(
          Duration(milliseconds: (60000 / _bpm).round()), (_) => _tick());
    }
  }

  void _tick() {
    setState(() => _beat = (_beat % _compas) + 1);
    _beat == 1 ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
    _pulsoCtrl.forward(from: 0);
  }

  void _cambiarBpm(int delta) {
    final nuevo = (_bpm + delta).clamp(20, 240);
    if (nuevo == _bpm) return;
    setState(() => _bpm = nuevo);
    if (_activo) {
      _timer?.cancel();
      _timer = Timer.periodic(
          Duration(milliseconds: (60000 / _bpm).round()), (_) => _tick());
    }
  }

  String _tempoNombre() {
    if (_bpm < 60) return 'Largo';
    if (_bpm < 76) return 'Adagio';
    if (_bpm < 108) return 'Andante';
    if (_bpm < 120) return 'Moderato';
    if (_bpm < 156) return 'Allegro';
    if (_bpm < 176) return 'Vivace';
    if (_bpm < 200) return 'Presto';
    return 'Prestissimo';
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: medio, size: 18)),
              const Expanded(
                  child: Text('Metrónomo',
                      style: TextStyle(
                          fontSize: 16,
                          color: blanco,
                          fontWeight: FontWeight.w300))),
              // Tempo badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: verde.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: verde.withValues(alpha: 0.2))),
                child: Text(_tempoNombre(),
                    style: const TextStyle(
                        fontSize: 12,
                        color: verde,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          SizedBox(height: h * 0.04),

          // Péndulo visual
          SizedBox(
            height: 120,
            child: _Pendulo(activo: _activo, bpm: _bpm, beat: _beat),
          ),

          SizedBox(height: h * 0.03),

          // Beats visuales
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_compas, (i) {
                final esteActivo = _activo && _beat == i + 1;
                final esPrimero = i == 0;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: esteActivo ? 52 : 40,
                    decoration: BoxDecoration(
                      color: esteActivo
                          ? (esPrimero ? verde : verde.withValues(alpha: 0.5))
                          : tarjeta,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: esteActivo
                              ? verde.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.06)),
                      boxShadow: esteActivo
                          ? [
                              BoxShadow(
                                  color: verde.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 1)
                            ]
                          : [],
                    ),
                    child: esPrimero && esteActivo
                        ? const Center(
                            child: Icon(Icons.arrow_drop_up_rounded,
                                color: fondo, size: 20))
                        : null,
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: h * 0.04),

          // BPM grande
          ScaleTransition(
            scale: _pulsoAnim,
            child: Column(children: [
              Text('$_bpm',
                  style: TextStyle(
                    fontSize: 96,
                    fontWeight: FontWeight.w100,
                    color: _activo ? verde : blanco,
                    height: 1,
                    letterSpacing: -4,
                  )),
              const SizedBox(height: 4),
              const Text('BPM',
                  style: TextStyle(
                      fontSize: 12,
                      color: medio,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w300)),
            ]),
          ),

          SizedBox(height: h * 0.03),

          // Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: verde,
                inactiveTrackColor: tarjeta2,
                thumbColor: verde,
                overlayColor: verde.withValues(alpha: 0.1),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _bpm.toDouble(),
                min: 20,
                max: 240,
                onChanged: (v) => _cambiarBpm(v.round() - _bpm),
              ),
            ),
          ),

          // Botones BPM
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _BpmBtn(label: '−10', onTap: () => _cambiarBpm(-10)),
            const SizedBox(width: 8),
            _BpmBtn(label: '−1', onTap: () => _cambiarBpm(-1)),
            const SizedBox(width: 20),
            _BpmBtn(label: '+1', onTap: () => _cambiarBpm(1)),
            const SizedBox(width: 8),
            _BpmBtn(label: '+10', onTap: () => _cambiarBpm(10)),
          ]),

          SizedBox(height: h * 0.025),

          // Selector compás
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Compás  ',
                style: const TextStyle(fontSize: 12, color: tenue)),
            ...[2, 3, 4, 6].map((n) => GestureDetector(
                  onTap: () => setState(() {
                    _compas = n;
                    _beat = 0;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _compas == n
                            ? verde.withValues(alpha: 0.12)
                            : tarjeta,
                        border: Border.all(
                            color: _compas == n
                                ? verde
                                : Colors.white.withValues(alpha: 0.07))),
                    child: Center(
                        child: Text('$n',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _compas == n ? verde : medio))),
                  ),
                )),
          ]),

          const Spacer(),

          // Botón play
          GestureDetector(
            onTap: _toggleMetronomo,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _activo ? rojo : verde,
                boxShadow: [
                  BoxShadow(
                      color: (_activo ? rojo : verde).withValues(alpha: 0.4),
                      blurRadius: 28,
                      spreadRadius: 4)
                ],
              ),
              child: Icon(
                  _activo ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: fondo,
                  size: 36),
            ),
          ),

          SizedBox(height: h * 0.05),
        ]),
      ),
    );
  }
}

// ── Péndulo animado ───────────────────────────────────────

class _Pendulo extends StatefulWidget {
  final bool activo;
  final int bpm;
  final int beat;
  const _Pendulo({required this.activo, required this.bpm, required this.beat});

  @override
  State<_Pendulo> createState() => _EstadoPendulo();
}

class _EstadoPendulo extends State<_Pendulo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (60000 / max(widget.bpm, 1)).round()));
    _anim = Tween(begin: -0.4, end: 0.4)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_Pendulo old) {
    super.didUpdateWidget(old);
    final dur = Duration(milliseconds: (60000 / max(widget.bpm, 1)).round());
    _ctrl.duration = dur;
    if (widget.activo && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.activo) {
      _ctrl.stop();
      _ctrl.value = 0.5;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(double.infinity, 120),
        painter: _PenduloPainter(angulo: _anim.value, activo: widget.activo),
      ),
    );
  }
}

class _PenduloPainter extends CustomPainter {
  final double angulo;
  final bool activo;
  const _PenduloPainter({required this.angulo, required this.activo});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = 10.0;
    final largo = size.height - 20;

    final px = cx + sin(angulo) * largo;
    final py = cy + cos(angulo) * largo;

    // Línea del péndulo
    final paintLinea = Paint()
      ..color = activo ? verde.withAlpha(180) : Colors.white.withAlpha(40)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(px, py), paintLinea);

    // Bola
    final paintBola = Paint()..color = activo ? verde : const Color(0xFF333333);
    canvas.drawCircle(Offset(px, py), 10, paintBola);

    if (activo) {
      final paintGlow = Paint()
        ..color = verde.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(px, py), 14, paintGlow);
    }

    // Pivote
    final paintPivote = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx, cy), 4, paintPivote);
  }

  @override
  bool shouldRepaint(_PenduloPainter old) =>
      old.angulo != angulo || old.activo != activo;
}

// ── Botón BPM ─────────────────────────────────────────────

class _BpmBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BpmBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14, color: blanco, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
