import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';

class PantallaSplash extends StatefulWidget {
  final VoidCallback alComenzar;
  const PantallaSplash({super.key, required this.alComenzar});

  @override
  State<PantallaSplash> createState() => _EstadoSplash();
}

class _EstadoSplash extends State<PantallaSplash>
    with TickerProviderStateMixin {
  final PageController _ctrl = PageController();
  int _pagina = 0;
  Timer? _timer;

  // Controla el fade-in del header al abrir la pantalla.
  late final AnimationController _ctrlHeader;
  // Pulso suave para el dot activo del indicador.
  late final AnimationController _ctrlPulse;
  // Spring scale del botón "Siguiente / Comenzar".
  late final AnimationController _ctrlPress;

  static const _paginas = [
    _DatosPagina(
      imagen: 'assets/onboarding1.png',
      icono: Icons.waving_hand_rounded,
      titulo: 'Detecta tus acordes',
      descripcion:
          'Toca tu guitarra y la IA reconoce el acorde en tiempo real con alta precisión.',
      esSaludo: true,
    ),
    _DatosPagina(
      imagen: 'assets/onboarding2.png',
      icono: Icons.mic_rounded,
      titulo: 'Detecta tus acordes',
      descripcion:
          'Toca tu guitarra y la IA reconoce el acorde en tiempo real con alta precisión.',
    ),
    _DatosPagina(
      imagen: 'assets/onboarding3.png',
      icono: Icons.school_rounded,
      titulo: 'Aprende paso a paso',
      descripcion:
          'Módulos de video organizados por nivel para que avances a tu ritmo.',
    ),
    _DatosPagina(
      imagen: 'assets/onboarding4.png',
      icono: Icons.quiz_rounded,
      titulo: 'Pon a prueba tu nivel',
      descripcion:
          'Quiz de teoría musical y práctica de acordes para medir tu progreso.',
    ),
    _DatosPagina(
      imagen: 'assets/onboarding5.png',
      icono: Icons.auto_awesome_rounded,
      titulo: 'Asistente con IA',
      descripcion:
          'Pregúntale al asistente sobre acordes, técnicas y teoría musical en cualquier momento.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _ctrlHeader = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _ctrlPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _ctrlPress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pagina < _paginas.length - 1) {
        _ctrl.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _ctrlHeader.dispose();
    _ctrlPulse.dispose();
    _ctrlPress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<SesionService>().nombre ?? 'músico';
    final firstName = nombre.trim().split(' ').first;
    final esUltima = _pagina == _paginas.length - 1;

    return Stack(fit: StackFit.expand, children: [
      // Carrusel de páginas
      PageView.builder(
        controller: _ctrl,
        onPageChanged: (i) => setState(() => _pagina = i),
        itemCount: _paginas.length,
        itemBuilder: (_, i) => _PaginaCarrusel(
          datos: _paginas[i],
          nombre: _paginas[i].esSaludo ? firstName : null,
          activa: i == _pagina,
        ),
      ),

      // Título Sonaris arriba (con fade-in al abrir).
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _ctrlHeader,
                curve: Curves.easeOut,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.25),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _ctrlHeader,
                  curve: Curves.easeOutCubic,
                )),
                child: Row(children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Image.asset(
                      'assets/logo_sonaris.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sonaris',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: blanco,
                      letterSpacing: -0.4,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),

      // Contenido inferior fijo
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicadores de página (con pulso suave en el activo).
              AnimatedBuilder(
                animation: _ctrlPulse,
                builder: (context, _) {
                  // 0 → 1 → 0; lo usamos como factor de glow.
                  final pulse = (_ctrlPulse.value * 2 - 1).abs();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_paginas.length, (i) {
                      final sel = i == _pagina;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: sel ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: sel
                              ? morado
                              : Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: morado.withValues(
                                      alpha: 0.45 + 0.25 * pulse,
                                    ),
                                    blurRadius: 10 + 6 * pulse,
                                    spreadRadius: 0.5,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 30),
              // Botón "Siguiente / Comenzar" con spring scale al presionar.
              GestureDetector(
                onTapDown: (_) => _ctrlPress.forward(),
                onTapCancel: () => _ctrlPress.reverse(),
                onTapUp: (_) => _ctrlPress.reverse(),
                onTap: esUltima
                    ? widget.alComenzar
                    : () {
                        _ctrl.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                child: AnimatedBuilder(
                  animation: _ctrlPress,
                  builder: (context, child) {
                    final scale = 1.0 - (_ctrlPress.value * 0.04);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: morado,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: morado.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          esUltima ? 'Comenzar' : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: blanco,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!esUltima) ...[
                const SizedBox(height: 16),
                _BotonSaltar(onTap: widget.alComenzar),
              ],
            ],
          ),
        ),
      ),
    ]);
  }
}

// ── Página individual del carrusel ────────────────────────

class _PaginaCarrusel extends StatefulWidget {
  final _DatosPagina datos;
  final String? nombre;
  final bool activa;
  const _PaginaCarrusel({
    required this.datos,
    this.nombre,
    this.activa = true,
  });

  @override
  State<_PaginaCarrusel> createState() => _EstadoPaginaCarrusel();
}

class _EstadoPaginaCarrusel extends State<_PaginaCarrusel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _fadeIn;
  late final Animation<double> _iconScale;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _descSlide;
  late final Animation<double> _descFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.7, curve: Curves.elasticOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    ));

    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    );

    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _descFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    if (widget.activa) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _PaginaCarrusel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activa && !oldWidget.activa) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    final nombre = widget.nombre;
    final esSaludo = nombre != null;

    return Stack(fit: StackFit.expand, children: [
      // Imagen de fondo.
      Image.asset(datos.imagen, fit: BoxFit.cover),
      // Gradiente principal: oscuro arriba, casi negro abajo.
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x66000000),
              Color(0x33000000),
              Color(0xCC000000),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.25, 0.7, 1.0],
          ),
        ),
        child: SizedBox.expand(),
      ),
      // Contenido animado.
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono con gradiente y glow + spring scale al entrar.
              FadeTransition(
                opacity: _fadeIn,
                child: ScaleTransition(
                  scale: _iconScale,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6A2BFF),
                          morado,
                          Color(0xFF2E0894),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: morado.withValues(alpha: 0.55),
                          blurRadius: 28,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: morado.withValues(alpha: 0.3),
                          blurRadius: 60,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(datos.icono, color: blanco, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Título: slide-up + fade.
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Text(
                    esSaludo ? 'Hola, $nombre.' : datos.titulo,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: blanco,
                      height: 1.05,
                      letterSpacing: -0.8,
                      shadows: [
                        Shadow(
                          color: morado.withValues(alpha: 0.45),
                          blurRadius: 20,
                        ),
                        const Shadow(
                          color: Color(0x66000000),
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Descripción: slide-up + fade, con jerarquía distinta para saludo.
              SlideTransition(
                position: _descSlide,
                child: FadeTransition(
                  opacity: _descFade,
                  child: esSaludo
                      ? Text(
                          'LISTO PARA TOCAR',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 4,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          datos.descripcion,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ── Botón "Saltar" con underline animado al tocar ─────────

class _BotonSaltar extends StatefulWidget {
  final VoidCallback onTap;
  const _BotonSaltar({required this.onTap});

  @override
  State<_BotonSaltar> createState() => _EstadoBotonSaltar();
}

class _EstadoBotonSaltar extends State<_BotonSaltar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _underline = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.reverse(),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saltar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedBuilder(
              animation: _underline,
              builder: (context, _) {
                return Container(
                  height: 1.2,
                  width: 36 * _underline.value,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modelo de datos ───────────────────────────────────────

class _DatosPagina {
  final String imagen;
  final IconData icono;
  final String titulo;
  final String descripcion;
  final bool esSaludo;
  const _DatosPagina({
    required this.imagen,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.esSaludo = false,
  });
}
