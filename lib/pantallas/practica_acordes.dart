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
      color: Color(0xFF00E676),
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
      color: Color(0xFFFFD54F),
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: medio, size: 18),
                ),
                const Expanded(
                  child: Text('Práctica de acordes',
                      style: TextStyle(
                          fontSize: 16,
                          color: blanco,
                          fontWeight: FontWeight.w300)),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
      const SizedBox(height: 20),
      // Etiqueta de nivel
      Row(children: [
        Icon(nivel.icono, color: nivel.color, size: 16),
        const SizedBox(width: 8),
        Text(nivel.titulo.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                color: nivel.color,
                letterSpacing: 2,
                fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 12),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          SizedBox(
            width: 68,
            height: 100,
            child: DiagramaAcordeWidget(acorde: acorde, alto: 100),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(acorde,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w200,
                          color: blanco,
                          height: 1)),
                  const SizedBox(width: 10),
                  Text(nombreAcorde[acorde] ?? '',
                      style: const TextStyle(fontSize: 11, color: medio)),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  children: (notasAcorde[acorde] ?? [])
                      .map((n) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: color.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(n,
                                style: TextStyle(fontSize: 11, color: color)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(descripcionAcorde[acorde] ?? '',
                    style: const TextStyle(
                        fontSize: 11, color: medio, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ])),
        ]),
      ),
    );
  }
}
