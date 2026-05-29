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
    with TickerProviderStateMixin {
  int _bpm = 80;
  bool _activo = false;
  int _beat = 0;
  int _compas = 4;
  Timer? _timer;

  late AnimationController _pulsoCtrl;
  late Animation<double> _pulsoAnim;
  late AnimationController _entradaCtrl;
  late Animation<double> _entradaFade;
  late Animation<Offset> _entradaSlide;

  @override
  void initState() {
    super.initState();
    _pulsoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _pulsoAnim = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulsoCtrl, curve: Curves.easeOut));

    _entradaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entradaFade = CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOut);
    _entradaSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
            CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOutCubic));
    _entradaCtrl.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulsoCtrl.dispose();
    _entradaCtrl.dispose();
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
        child: FadeTransition(
          opacity: _entradaFade,
          child: SlideTransition(
            position: _entradaSlide,
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 20, 4),
                child: Row(children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: blanco, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Metrónomo',
                            style: TextStyle(
                                fontSize: 24,
                                color: blanco,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.1)),
                        SizedBox(height: 2),
                        Text('Encuentra tu ritmo',
                            style: TextStyle(
                                fontSize: 12,
                                color: medio,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  // Tempo badge with morado glow
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: morado.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: morado.withValues(alpha: 0.35)),
                      boxShadow: [
                        BoxShadow(
                            color: morado.withValues(alpha: 0.25),
                            blurRadius: 14,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Text(_tempoNombre(),
                        style: const TextStyle(
                            fontSize: 12,
                            color: morado,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                  ),
                ]),
              ),

              SizedBox(height: h * 0.035),

              // Péndulo visual
              SizedBox(
                height: 130,
                child: _Pendulo(activo: _activo, bpm: _bpm, beat: _beat),
              ),

              SizedBox(height: h * 0.03),

              // Beats visuales (compás)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_compas, (i) {
                    final esteActivo = _activo && _beat == i + 1;
                    final esPrimero = i == 0;
                    final escala = esteActivo ? (esPrimero ? 1.1 : 1.0) : 0.96;
                    return Expanded(
                      child: AnimatedScale(
                        scale: escala,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: esteActivo ? 54 : 42,
                          decoration: BoxDecoration(
                            color: esteActivo
                                ? (esPrimero
                                    ? morado
                                    : morado.withValues(alpha: 0.55))
                                : tarjeta2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: esteActivo
                                    ? morado.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.05)),
                            boxShadow: esteActivo
                                ? [
                                    BoxShadow(
                                        color: morado.withValues(alpha: 0.45),
                                        blurRadius: 18,
                                        spreadRadius: 1),
                                    BoxShadow(
                                        color: morado.withValues(alpha: 0.2),
                                        blurRadius: 32,
                                        spreadRadius: 4),
                                  ]
                                : const [],
                          ),
                          child: esPrimero
                              ? Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: esteActivo ? 7 : 5,
                                    height: esteActivo ? 7 : 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: esteActivo
                                          ? blanco
                                          : morado.withValues(alpha: 0.5),
                                    ),
                                  ),
                                )
                              : null,
                        ),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w100,
                      color: _activo ? morado : blanco,
                      height: 1,
                      letterSpacing: -4,
                      shadows: _activo
                          ? [
                              Shadow(
                                  color: morado.withValues(alpha: 0.55),
                                  blurRadius: 28),
                              Shadow(
                                  color: morado.withValues(alpha: 0.25),
                                  blurRadius: 60),
                            ]
                          : const [],
                    ),
                    child: Text('$_bpm'),
                  ),
                  const SizedBox(height: 4),
                  const Text('BPM',
                      style: TextStyle(
                          fontSize: 12,
                          color: medio,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w300)),
                ]),
              ),

              SizedBox(height: h * 0.025),

              // Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: morado,
                    inactiveTrackColor: tarjeta2,
                    thumbColor: morado,
                    overlayColor: morado.withValues(alpha: 0.18),
                    trackHeight: 4,
                    trackShape: const RoundedRectSliderTrackShape(),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                        elevation: 4,
                        pressedElevation: 8),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 22),
                  ),
                  child: Slider(
                    value: _bpm.toDouble(),
                    min: 20,
                    max: 240,
                    onChanged: (v) => _cambiarBpm(v.round() - _bpm),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Botones BPM
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _BpmBtn(label: '−10', onTap: () => _cambiarBpm(-10)),
                const SizedBox(width: 10),
                _BpmBtn(label: '−1', onTap: () => _cambiarBpm(-1)),
                const SizedBox(width: 22),
                _BpmBtn(label: '+1', onTap: () => _cambiarBpm(1)),
                const SizedBox(width: 10),
                _BpmBtn(label: '+10', onTap: () => _cambiarBpm(10)),
              ]),

              SizedBox(height: h * 0.03),

              // Selector compás
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text('Compás',
                      style: TextStyle(
                          fontSize: 12,
                          color: tenue,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
                ),
                ...[2, 3, 4, 6].map((n) {
                  final seleccionado = _compas == n;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _compas = n;
                      _beat = 0;
                    }),
                    child: AnimatedScale(
                      scale: seleccionado ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: seleccionado
                              ? morado.withValues(alpha: 0.18)
                              : tarjeta,
                          border: Border.all(
                              color: seleccionado
                                  ? morado
                                  : Colors.white.withValues(alpha: 0.06),
                              width: seleccionado ? 1.4 : 1),
                          boxShadow: seleccionado
                              ? [
                                  BoxShadow(
                                      color: morado.withValues(alpha: 0.4),
                                      blurRadius: 14,
                                      spreadRadius: 0),
                                ]
                              : const [],
                        ),
                        child: Center(
                          child: Text('$n',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: seleccionado ? morado : medio)),
                        ),
                      ),
                    ),
                  );
                }),
              ]),

              const Spacer(),

              // Botón play
              _BotonPlay(activo: _activo, onTap: _toggleMetronomo),

              SizedBox(height: h * 0.05),
            ]),
          ),
        ),
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
    const cy = 12.0;
    final largo = size.height - 22;

    final px = cx + sin(angulo) * largo;
    final py = cy + cos(angulo) * largo;

    // Glow detrás de la bola (cuando está activo)
    if (activo) {
      final paintGlowOuter = Paint()
        ..color = morado.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(px, py), 22, paintGlowOuter);

      final paintGlowInner = Paint()
        ..color = morado.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(px, py), 14, paintGlowInner);
    }

    // Línea del péndulo (más gruesa)
    final paintLinea = Paint()
      ..color = activo
          ? morado.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(px, py), paintLinea);

    // Base/pivote suave en la parte superior
    final paintPivoteHalo = Paint()
      ..color = (activo ? morado : Colors.white).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy), 12, paintPivoteHalo);

    final paintPivoteBase = Paint()
      ..color = tarjeta2
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 7, paintPivoteBase);

    final paintPivoteBorde = Paint()
      ..color = activo
          ? morado.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, cy), 7, paintPivoteBorde);

    final paintPivoteCentro = Paint()..color = activo ? morado : medio;
    canvas.drawCircle(Offset(cx, cy), 2.5, paintPivoteCentro);

    // Bola
    final paintBola = Paint()
      ..color = activo ? morado : const Color(0xFF333333);
    canvas.drawCircle(Offset(px, py), 11, paintBola);

    if (activo) {
      // Highlight pequeño en la bola
      final paintHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(px - 3, py - 3), 3, paintHighlight);
    }
  }

  @override
  bool shouldRepaint(_PenduloPainter old) =>
      old.angulo != angulo || old.activo != activo;
}

// ── Botón BPM ─────────────────────────────────────────────

class _BpmBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _BpmBtn({required this.label, required this.onTap});

  @override
  State<_BpmBtn> createState() => _EstadoBpmBtn();
}

class _EstadoBpmBtn extends State<_BpmBtn> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _presionado ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _presionado ? morado.withValues(alpha: 0.14) : tarjeta,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _presionado
                    ? morado.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.07)),
            boxShadow: _presionado
                ? [
                    BoxShadow(
                        color: morado.withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 0),
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
          ),
          child: Text(widget.label,
              style: TextStyle(
                  fontSize: 14,
                  color: _presionado ? morado : blanco,
                  fontWeight: FontWeight.w700,
                  shadows: _presionado
                      ? [
                          Shadow(
                              color: morado.withValues(alpha: 0.6),
                              blurRadius: 10),
                        ]
                      : null)),
        ),
      ),
    );
  }
}

// ── Botón Play central ────────────────────────────────────

class _BotonPlay extends StatefulWidget {
  final bool activo;
  final VoidCallback onTap;
  const _BotonPlay({required this.activo, required this.onTap});

  @override
  State<_BotonPlay> createState() => _EstadoBotonPlay();
}

class _EstadoBotonPlay extends State<_BotonPlay> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.activo ? rojo : morado;
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _presionado ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anillo exterior cuando está activo
              if (widget.activo)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withValues(alpha: 0.35), width: 1.5),
                  ),
                ),
              // Botón principal
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.55),
                        blurRadius: 32,
                        spreadRadius: 4),
                    BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 60,
                        spreadRadius: 8),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Icon(
                    widget.activo
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    color: blanco,
                    size: 42),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
