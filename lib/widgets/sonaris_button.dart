import 'dart:math';
import 'package:flutter/material.dart';
import '../constantes/colores.dart';

// ── Botón principal Sonaris con Skia ─────────────────────
// Inspirado en el logo: cuerpo de guitarra con curvas y cuerdas

class SonarisButton extends StatefulWidget {
  final String texto;
  final VoidCallback? onTap;
  final bool cargando;
  final double height;
  final SonarisButtonStyle estilo;

  const SonarisButton({
    super.key,
    required this.texto,
    this.onTap,
    this.cargando = false,
    this.height = 56,
    this.estilo = SonarisButtonStyle.primario,
  });

  @override
  State<SonarisButton> createState() => _EstadoSonarisButton();
}

enum SonarisButtonStyle { primario, secundario, fantasma }

class _EstadoSonarisButton extends State<SonarisButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glowAnim;
  bool _presionado = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _glowAnim = Tween(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) {
        setState(() => _presionado = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, child) => CustomPaint(
            painter: _SonarisButtonPainter(
              estilo: widget.estilo,
              glowIntensidad: widget.estilo == SonarisButtonStyle.primario
                  ? _glowAnim.value
                  : 0.0,
              presionado: _presionado,
            ),
            child: child,
          ),
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: Center(
              child: widget.cargando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: blanco))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        widget.texto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.estilo == SonarisButtonStyle.fantasma
                              ? verde
                              : blanco,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (widget.estilo == SonarisButtonStyle.primario) ...[
                        const SizedBox(width: 8),
                        // Mini cuerdas de guitarra decorativas
                        _MiniCuerdas(),
                      ],
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Painter principal del botón ───────────────────────────

class _SonarisButtonPainter extends CustomPainter {
  final SonarisButtonStyle estilo;
  final double glowIntensidad;
  final bool presionado;

  const _SonarisButtonPainter({
    required this.estilo,
    required this.glowIntensidad,
    required this.presionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = h / 2; // radio de las esquinas

    // ── Path con forma inspirada en cuerpo de guitarra ──
    // Esquinas redondeadas con pequeñas "muescas" en los lados
    // como el cuerpo de una guitarra acústica
    final path = Path();
    final indent = h * 0.12; // profundidad de la muesca lateral

    path.moveTo(r, 0);
    // Borde superior
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    // Lado derecho con muesca suave (cintura de guitarra)
    path.lineTo(w, h * 0.35);
    path.cubicTo(
      w - indent,
      h * 0.4,
      w - indent,
      h * 0.6,
      w,
      h * 0.65,
    );
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    // Borde inferior
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    // Lado izquierdo con muesca suave
    path.lineTo(0, h * 0.65);
    path.cubicTo(
      indent,
      h * 0.6,
      indent,
      h * 0.4,
      0,
      h * 0.35,
    );
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.close();

    switch (estilo) {
      case SonarisButtonStyle.primario:
        _pintarPrimario(canvas, size, path);
      case SonarisButtonStyle.secundario:
        _pintarSecundario(canvas, size, path);
      case SonarisButtonStyle.fantasma:
        _pintarFantasma(canvas, size, path);
    }

    // ── Cuerdas decorativas sutiles ──────────────────────
    if (estilo == SonarisButtonStyle.primario) {
      _pintarCuerdas(canvas, size);
    }
  }

  void _pintarPrimario(Canvas canvas, Size size, Path path) {
    // Glow exterior animado
    final paintGlow = Paint()
      ..color = verde.withValues(alpha: glowIntensidad * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 16)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintGlow);

    // Gradiente de fondo
    final paintFondo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF5A1FE8),
          verde,
          const Color(0xFF3A0DB8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFondo);

    // Brillo superior (highlight)
    final paintHighlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintHighlight);

    // Borde sutil
    final paintBorde = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paintBorde);
  }

  void _pintarSecundario(Canvas canvas, Size size, Path path) {
    final paintFondo = Paint()
      ..color = verde.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFondo);

    final paintBorde = Paint()
      ..color = verde.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, paintBorde);
  }

  void _pintarFantasma(Canvas canvas, Size size, Path path) {
    final paintBorde = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paintBorde);
  }

  void _pintarCuerdas(Canvas canvas, Size size) {
    // 3 cuerdas horizontales muy sutiles en el centro
    final paintCuerda = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final ancho = size.width * 0.3;

    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.35 + i * 0.15);
      canvas.drawLine(
        Offset(cx - ancho / 2, y),
        Offset(cx + ancho / 2, y),
        paintCuerda,
      );
    }

    // Punto de "boca" de guitarra (círculo pequeño en el centro)
    final paintBoca = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.22,
      paintBoca,
    );
  }

  @override
  bool shouldRepaint(_SonarisButtonPainter old) =>
      old.glowIntensidad != glowIntensidad || old.presionado != presionado;
}

// ── Mini cuerdas decorativas ──────────────────────────────

class _MiniCuerdas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 14),
      painter: _MiniCuerdasPainter(),
    );
  }
}

class _MiniCuerdasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Botón de ícono circular estilo Sonaris ────────────────

class SonarisIconButton extends StatefulWidget {
  final IconData icono;
  final VoidCallback? onTap;
  final double size;
  final bool activo;

  const SonarisIconButton({
    super.key,
    required this.icono,
    this.onTap,
    this.size = 52,
    this.activo = false,
  });

  @override
  State<SonarisIconButton> createState() => _EstadoSonarisIconButton();
}

class _EstadoSonarisIconButton extends State<SonarisIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulsoAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulsoAnim = Tween(begin: 0.4, end: 0.8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulsoAnim,
        builder: (_, child) => CustomPaint(
          painter: _IconButtonPainter(
            activo: widget.activo,
            pulso: widget.activo ? _pulsoAnim.value : 0.0,
          ),
          child: child,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Icon(widget.icono,
                color: widget.activo
                    ? blanco
                    : Colors.white.withValues(alpha: 0.5),
                size: widget.size * 0.42),
          ),
        ),
      ),
    );
  }
}

class _IconButtonPainter extends CustomPainter {
  final bool activo;
  final double pulso;

  const _IconButtonPainter({required this.activo, required this.pulso});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    if (activo) {
      // Glow pulsante
      final paintGlow = Paint()
        ..color = verde.withValues(alpha: pulso * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 14);
      canvas.drawCircle(center, r, paintGlow);

      // Fondo con gradiente
      final paintFondo = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF5A1FE8), verde],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paintFondo);

      // Highlight
      final paintHL = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawCircle(center, r, paintHL);
    } else {
      // Fondo oscuro
      final paintFondo = Paint()
        ..color = const Color(0xFF1A1A2A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, paintFondo);

      // Borde sutil
      final paintBorde = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, r, paintBorde);
    }

    // Detalle: pequeño arco decorativo (cuerda de guitarra)
    final paintArco = Paint()
      ..color = Colors.white.withValues(alpha: activo ? 0.15 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.7),
      pi * 0.8,
      pi * 0.4,
      false,
      paintArco,
    );
  }

  @override
  bool shouldRepaint(_IconButtonPainter old) =>
      old.activo != activo || old.pulso != pulso;
}
