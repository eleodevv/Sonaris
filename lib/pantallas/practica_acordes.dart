import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';
import 'detalle_acorde.dart';

class PantallaPracticaAcordes extends StatelessWidget {
  const PantallaPracticaAcordes({super.key});

  static const _niveles = [
    _InfoNivel(
      titulo: 'Básico',
      acordes: ['A', 'Am', 'D'],
      color: verde,
      icono: Icons.stairs_rounded,
    ),
    _InfoNivel(
      titulo: 'Intermedio',
      acordes: ['C'],
      color: Color(0xFF64B5F6),
      icono: Icons.speed_rounded,
    ),
    _InfoNivel(
      titulo: 'Difícil',
      acordes: ['F', 'Bm7'],
      color: ambar,
      icono: Icons.emoji_events_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header mejorado
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 20),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: tarjeta2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: medio, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Práctica de acordes',
                          style: TextStyle(
                              fontSize: 20,
                              color: blanco,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Domina cada nivel progresivamente',
                          style: TextStyle(fontSize: 12, color: medio)),
                    ],
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: _niveles.map((n) => _SeccionNivel(nivel: n)).toList(),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoNivel {
  final String titulo;
  final List<String> acordes;
  final Color color;
  final IconData icono;
  const _InfoNivel({
    required this.titulo,
    required this.acordes,
    required this.color,
    required this.icono,
  });
}

class _SeccionNivel extends StatelessWidget {
  final _InfoNivel nivel;
  const _SeccionNivel({required this.nivel});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      // Etiqueta de nivel mejorada
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: nivel.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: nivel.color.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(nivel.icono, color: nivel.color, size: 14),
          const SizedBox(width: 8),
          Text(nivel.titulo.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: nivel.color,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 14),
      // Tarjetas de acordes
      ...nivel.acordes
          .map((a) => _TarjetaAcorde(acorde: a, color: nivel.color)),
    ]);
  }
}

class _TarjetaAcorde extends StatelessWidget {
  final String acorde;
  final Color color;
  const _TarjetaAcorde({required this.acorde, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PantallaDetalleAcorde(acorde: acorde))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // Diagrama mejorado
          Container(
            width: 72,
            height: 104,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              color: tarjeta2,
            ),
            child: DiagramaAcordeWidget(acorde: acorde, alto: 100),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Nombre del acorde
                Row(children: [
                  Text(acorde,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(nombreAcorde[acorde] ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: medio,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 10),
                // Notas del acorde
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (notasAcorde[acorde] ?? [])
                      .map((n) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              border: Border.all(
                                  color: color.withValues(alpha: 0.4),
                                  width: 1.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(n,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                // Descripción
                Text(descripcionAcorde[acorde] ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: medio, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
      ),
    );
  }
}
