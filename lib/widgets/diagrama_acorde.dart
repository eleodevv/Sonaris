import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';

/// Widget que dibuja el diagrama de traste de un acorde
class DiagramaAcordeWidget extends StatelessWidget {
  final String acorde;
  final double alto;

  const DiagramaAcordeWidget({
    super.key,
    required this.acorde,
    this.alto = 200,
  });

  @override
  Widget build(BuildContext context) {
    final diagrama = diagramas[acorde];
    if (diagrama == null) return const SizedBox();
    return CustomPaint(
      size: Size(alto * 0.68, alto),
      painter: _PintorDiagrama(diagrama: diagrama, acorde: acorde),
    );
  }
}

class _PintorDiagrama extends CustomPainter {
  final DiagramaAcorde diagrama;
  final String acorde;

  _PintorDiagrama({required this.diagrama, required this.acorde});

  @override
  void paint(Canvas canvas, Size size) {
    const cuerdas  = 6;
    const trastes  = 4;
    const padTop   = 30.0;
    const padLado  = 14.0;

    final ancho    = size.width  - padLado * 2;
    final alto     = size.height - padTop - 10;
    final sepCuerda = ancho / (cuerdas - 1);
    final sepTraste = alto  / trastes;

    final pinturaRed  = Paint()..color = const Color(0xFF333333)..strokeWidth = 1.0;
    final pinturaNut  = Paint()..color = const Color(0xFFBBBBBB)..strokeWidth = 4.0;
    final pinturaPunto = Paint()..color = verde..style = PaintingStyle.fill;
    final pinturaGlow  = Paint()
      ..color = verde.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;

    // ── Cejilla ───────────────────────────────────────────
    if (diagrama.tieneCejilla) {
      final x1 = padLado + diagrama.cejillaDesde * sepCuerda;
      final x2 = padLado + diagrama.cejillaHasta * sepCuerda;
      final y  = padTop  + (diagrama.trastesCejilla - 1) * sepTraste + sepTraste / 2;
      final r  = sepTraste * 0.28;
      final rect = RRect.fromLTRBR(x1, y - r, x2, y + r, Radius.circular(r));
      canvas.drawRRect(rect, pinturaGlow);
      canvas.drawRRect(rect, pinturaPunto);
    }

    // ── Cuerdas verticales ────────────────────────────────
    for (int c = 0; c < cuerdas; c++) {
      final x = padLado + c * sepCuerda;
      canvas.drawLine(Offset(x, padTop), Offset(x, padTop + alto), pinturaRed);
    }

    // ── Trastes horizontales ──────────────────────────────
    final esNut = diagrama.trasteInicio == 1;
    canvas.drawLine(
      Offset(padLado, padTop),
      Offset(padLado + ancho, padTop),
      esNut ? pinturaNut : pinturaRed,
    );
    for (int t = 1; t <= trastes; t++) {
      final y = padTop + t * sepTraste;
      canvas.drawLine(Offset(padLado, y), Offset(padLado + ancho, y), pinturaRed);
    }

    // ── Número de traste si no empieza en 1 ──────────────
    if (diagrama.trasteInicio > 1) {
      _texto(canvas, '${diagrama.trasteInicio}fr', medio, 10,
          Offset(padLado + ancho + 5, padTop + sepTraste / 2 - 6));
    }

    // ── Indicadores O / X arriba ──────────────────────────
    for (int c = 0; c < cuerdas; c++) {
      final x = padLado + c * sepCuerda;
      if (diagrama.cuerdaSilencio.contains(c)) {
        _texto(canvas, '×', medio, 14, Offset(x - 5, padTop - 24));
      } else if (diagrama.cuerdaAlAire.contains(c)) {
        _texto(canvas, 'o', medio, 12, Offset(x - 4, padTop - 22));
      }
    }

    // ── Puntos con número de dedo ─────────────────────────
    for (final p in diagrama.puntos) {
      final x = padLado + p.cuerda * sepCuerda;
      final y = padTop  + (p.traste - 1) * sepTraste + sepTraste / 2;
      final r = sepTraste * 0.28;
      canvas.drawCircle(Offset(x, y), r + 5, pinturaGlow);
      canvas.drawCircle(Offset(x, y), r, pinturaPunto);
      _texto(canvas, '${p.dedo}', fondo, 10,
          Offset(x - 4, y - 6), negrita: true);
    }
  }

  void _texto(Canvas canvas, String texto, Color color, double tam,
      Offset pos, {bool negrita = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          color: color,
          fontSize: tam,
          fontWeight: negrita ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(_PintorDiagrama viejo) => viejo.acorde != acorde;
}
