import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';

class PantallaModoLibre extends StatefulWidget {
  const PantallaModoLibre({super.key});

  @override
  State<PantallaModoLibre> createState() => _EstadoModoLibre();
}

class _EstadoModoLibre extends State<PantallaModoLibre>
    with TickerProviderStateMixin {
  bool _escuchando = false;
  String? _acordeDetectado;
  double _confianza = 0.0;

  late AnimationController _pulsoCtrl;
  late Animation<double> _pulsoAnim;
  late AnimationController _ondaCtrl;
  late Animation<double> _ondaAnim;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late AnimationController _entradaCtrl;
  late Animation<double> _entradaFade;
  late Animation<Offset> _entradaSlide;

  static final _todosAcordes = [
    ...acordesPorNivel['básico']!,
    ...acordesPorNivel['intermedio']!,
    ...acordesPorNivel['difícil']!,
  ];

  static const _coloresNivel = {
    'básico': Color(0xFF00E676),
    'intermedio': Color(0xFFFFD54F),
    'difícil': Color(0xFFFF5252),
  };

  Color get _colorActual {
    if (_acordeDetectado == null) return verde;
    final nivel = nivelAcorde[_acordeDetectado] ?? 'básico';
    return _coloresNivel[nivel] ?? verde;
  }

  Color _colorDeAcorde(String a) {
    final nivel = nivelAcorde[a] ?? 'básico';
    return _coloresNivel[nivel] ?? verde;
  }

  @override
  void initState() {
    super.initState();

    _pulsoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulsoAnim = Tween(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulsoCtrl, curve: Curves.easeInOut));

    _ondaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _ondaAnim = CurvedAnimation(parent: _ondaCtrl, curve: Curves.easeInOut);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _entradaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entradaFade = CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOut);
    _entradaSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOutCubic));
    _entradaCtrl.forward();
  }

  @override
  void dispose() {
    _pulsoCtrl.dispose();
    _ondaCtrl.dispose();
    _glowCtrl.dispose();
    _entradaCtrl.dispose();
    super.dispose();
  }

  void _toggleEscuchar() {
    setState(() {
      _escuchando = !_escuchando;
      if (!_escuchando) {
        _acordeDetectado = null;
        _confianza = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: fondo,
      body: FadeTransition(
        opacity: _entradaFade,
        child: SlideTransition(
          position: _entradaSlide,
          child: SafeArea(
            child: Column(children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: tarjeta2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.07))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: medio, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Modo Libre',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: blanco,
                                  letterSpacing: -0.3)),
                          Text('Toca y detecta acordes en tiempo real',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4))),
                        ]),
                  ),
                  // Badge estado
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _escuchando
                          ? verde.withValues(alpha: 0.15)
                          : tarjeta2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _escuchando
                              ? verde.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _escuchando ? verde : tenue,
                          boxShadow: _escuchando
                              ? [
                                  BoxShadow(
                                      color: verde.withValues(alpha: 0.6),
                                      blurRadius: 6)
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _escuchando ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                            fontSize: 11,
                            color: _escuchando ? verde : tenue,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),
                ]),
              ),

              // ── Visualizador central ─────────────────────
              Expanded(
                flex: 3,
                child: Stack(alignment: Alignment.center, children: [
                  // Glow de fondo animado
                  if (_escuchando)
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (_, __) => Container(
                        width: h * 0.35,
                        height: h * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            _colorActual.withValues(
                                alpha: _glowAnim.value * 0.12),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Acorde detectado / estado
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => ScaleTransition(
                              scale: CurvedAnimation(
                                  parent: anim, curve: Curves.easeOutBack),
                              child:
                                  FadeTransition(opacity: anim, child: child)),
                          child: _acordeDetectado != null
                              ? _VisualizadorAcorde(
                                  key: ValueKey(_acordeDetectado),
                                  acorde: _acordeDetectado!,
                                  nombre: nombreAcorde[_acordeDetectado] ?? '',
                                  color: _colorActual,
                                  confianza: _confianza,
                                )
                              : _EstadoEsperando(
                                  key: const ValueKey('esperando'),
                                  escuchando: _escuchando,
                                ),
                        ),

                        const SizedBox(height: 44),

                        // Botón micrófono
                        GestureDetector(
                          onTap: _toggleEscuchar,
                          child: Stack(alignment: Alignment.center, children: [
                            // Ondas expansivas
                            if (_escuchando) ...[
                              AnimatedBuilder(
                                animation: _ondaAnim,
                                builder: (_, __) => _Onda(
                                  radio: 50 + (_ondaAnim.value * 50),
                                  opacidad: 0.18 * (1 - _ondaAnim.value),
                                  color: _colorActual,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _ondaAnim,
                                builder: (_, __) {
                                  final v = (_ondaAnim.value + 0.5) % 1.0;
                                  return _Onda(
                                    radio: 50 + (v * 50),
                                    opacidad: 0.18 * (1 - v),
                                    color: _colorActual,
                                  );
                                },
                              ),
                            ],
                            // Botón principal
                            ScaleTransition(
                              scale: _escuchando
                                  ? _pulsoAnim
                                  : const AlwaysStoppedAnimation(1.0),
                              child: _BotonMicrofono(
                                escuchando: _escuchando,
                                color: _colorActual,
                              ),
                            ),
                          ]),
                        ),

                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _escuchando
                                ? 'Toca para detener'
                                : 'Toca para escuchar',
                            key: ValueKey(_escuchando),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.3),
                                letterSpacing: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

              // ── Grid de acordes ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D14),
                  border: Border(
                      top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06))),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 4,
                          height: 14,
                          decoration: BoxDecoration(
                            color: verde,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('ACORDES DETECTABLES',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${_todosAcordes.length} acordes',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.25))),
                      ]),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _todosAcordes.length,
                          itemBuilder: (_, i) {
                            final a = _todosAcordes[i];
                            final esDetectado = _acordeDetectado == a;
                            final color = _colorDeAcorde(a);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: esDetectado
                                    ? color.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.04),
                                border: Border.all(
                                  color: esDetectado
                                      ? color.withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.07),
                                  width: esDetectado ? 1.5 : 1,
                                ),
                                boxShadow: esDetectado
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.45),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: esDetectado ? 11 : 10,
                                    fontWeight: esDetectado
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: esDetectado
                                        ? color
                                        : Colors.white.withValues(alpha: 0.35),
                                  ),
                                  child: Text(a),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────

class _VisualizadorAcorde extends StatelessWidget {
  final String acorde;
  final String nombre;
  final Color color;
  final double confianza;

  const _VisualizadorAcorde({
    super.key,
    required this.acorde,
    required this.nombre,
    required this.color,
    required this.confianza,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Nombre del acorde grande
      Text(
        acorde,
        style: TextStyle(
          fontSize: 88,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -3,
          height: 1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        nombre,
        style: TextStyle(
          fontSize: 16,
          color: color.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 16),
      // Barra de confianza mejorada
      Column(children: [
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: confianza),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(confianza * 100).toStringAsFixed(0)}% confianza',
          style: TextStyle(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
        ),
      ]),
    ]);
  }
}

class _EstadoEsperando extends StatelessWidget {
  final bool escuchando;
  const _EstadoEsperando({super.key, required this.escuchando});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Ícono grande
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(
          escuchando ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
          size: 36,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        escuchando ? 'Escuchando...' : 'Toca un acorde',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.25),
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        escuchando
            ? 'Detectando en tiempo real'
            : 'Presiona el micrófono para comenzar',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    ]);
  }
}

class _Onda extends StatelessWidget {
  final double radio;
  final double opacidad;
  final Color color;
  const _Onda(
      {required this.radio, required this.opacidad, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radio * 2,
      height: radio * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacidad),
          width: 1.5,
        ),
      ),
    );
  }
}

class _BotonMicrofono extends StatelessWidget {
  final bool escuchando;
  final Color color;
  const _BotonMicrofono({required this.escuchando, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: escuchando ? color : tarjeta,
        border: Border.all(
          color: escuchando
              ? color.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: 2,
        ),
        boxShadow: escuchando
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ]
            : [],
      ),
      child: Icon(
        escuchando ? Icons.stop_rounded : Icons.mic_rounded,
        color: escuchando ? fondo : Colors.white.withValues(alpha: 0.5),
        size: 38,
      ),
    );
  }
}
