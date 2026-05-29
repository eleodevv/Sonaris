import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';
import 'detalle_acorde.dart';

class PantallaPracticaAcordes extends StatefulWidget {
  const PantallaPracticaAcordes({super.key});

  @override
  State<PantallaPracticaAcordes> createState() => _EstadoPracticaAcordes();
}

class _EstadoPracticaAcordes extends State<PantallaPracticaAcordes> {
  bool _entrada = false;

  static const _niveles = [
    _InfoNivel(
      titulo: 'Básico',
      acordes: ['A', 'Am', 'C', 'D', 'Dm', 'E', 'Em', 'F', 'G', 'G7'],
      color: morado,
      icono: Icons.stairs_rounded,
    ),
    _InfoNivel(
      titulo: 'Intermedio',
      acordes: [
        'A7',
        'Asus4',
        'B7',
        'Bm',
        'Cadd9',
        'Cmaj7',
        'D7',
        'Dsus4',
        'E7',
        'Fmaj7'
      ],
      color: Color(0xFF64B5F6),
      icono: Icons.speed_rounded,
    ),
    _InfoNivel(
      titulo: 'Avanzado',
      acordes: [
        'Am7',
        'Amaj7',
        'Bbmaj7',
        'Bm7',
        'Dm7',
        'Em7',
        'F#m',
        'F7',
        'Fm',
        'Gm',
        'Gsus4'
      ],
      color: ambar,
      icono: Icons.emoji_events_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _entrada = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAcordes = _niveles.fold<int>(0, (s, n) => s + n.acordes.length);

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 20, 8),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tarjeta2,
                            tarjeta.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: blanco, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Práctica de acordes',
                            style: TextStyle(
                                fontSize: 22,
                                color: blanco,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 3),
                        Text('Domina cada nivel progresivamente',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: medio.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  // Badge total
                  AnimatedOpacity(
                    opacity: _entrada ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: morado.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: morado.withValues(alpha: 0.25)),
                      ),
                      child: Text('$totalAcordes',
                          style: const TextStyle(
                              fontSize: 13,
                              color: morado,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),

              // ── Content ──
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    for (int i = 0; i < _niveles.length; i++)
                      _SeccionNivel(
                        nivel: _niveles[i],
                        sectionIndex: i,
                        entrada: _entrada,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────

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

// ── Section ───────────────────────────────────────────────

class _SeccionNivel extends StatelessWidget {
  final _InfoNivel nivel;
  final int sectionIndex;
  final bool entrada;

  const _SeccionNivel({
    required this.nivel,
    required this.sectionIndex,
    required this.entrada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Level badge with stagger
        AnimatedOpacity(
          opacity: entrada ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: entrada ? Offset.zero : const Offset(-0.1, 0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        nivel.color.withValues(alpha: 0.15),
                        nivel.color.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: nivel.color.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: nivel.color.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(nivel.icono, color: nivel.color, size: 15),
                    const SizedBox(width: 8),
                    Text(nivel.titulo.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11.5,
                            color: nivel.color,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tarjeta2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${nivel.acordes.length}',
                      style: TextStyle(
                          fontSize: 11,
                          color: nivel.color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Chord cards
        ...List.generate(nivel.acordes.length, (i) {
          return _TarjetaAcorde(
            acorde: nivel.acordes[i],
            color: nivel.color,
            index: sectionIndex * 4 + i,
          );
        }),
      ],
    );
  }
}

// ── Chord Card ────────────────────────────────────────────

class _TarjetaAcorde extends StatefulWidget {
  final String acorde;
  final Color color;
  final int index;

  const _TarjetaAcorde({
    required this.acorde,
    required this.color,
    required this.index,
  });

  @override
  State<_TarjetaAcorde> createState() => _TarjetaAcordeState();
}

class _TarjetaAcordeState extends State<_TarjetaAcorde> {
  bool _pressed = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 150 + widget.index * 50), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final notas = notasAcorde[widget.acorde] ?? [];
    final nombre = nombreAcorde[widget.acorde] ?? '';
    final desc = descripcionAcorde[widget.acorde] ?? '';

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaDetalleAcorde(acorde: widget.acorde),
              ),
            );
          },
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tarjeta,
                    tarjeta2.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _pressed
                      ? c.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.04),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _pressed ? 0.2 : 0.1),
                    blurRadius: _pressed ? 16 : 8,
                    offset: const Offset(0, 3),
                  ),
                  if (_pressed)
                    BoxShadow(
                      color: c.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(children: [
                // Diagrama
                Container(
                  width: 68,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: tarjeta2,
                    border: Border.all(color: c.withValues(alpha: 0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child:
                        DiagramaAcordeWidget(acorde: widget.acorde, alto: 92),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Row(children: [
                        Text(widget.acorde,
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: c,
                                height: 1.1)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(nombre,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: medio,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Notas
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: notas
                            .map((n) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        c.withValues(alpha: 0.18),
                                        c.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: c.withValues(alpha: 0.3),
                                        width: 1),
                                  ),
                                  child: Text(n,
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: c,
                                          fontWeight: FontWeight.w700)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      // Descripción
                      Text(desc,
                          style: TextStyle(
                              fontSize: 11.5,
                              color: medio.withValues(alpha: 0.85),
                              height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Chevron
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.chevron_right_rounded,
                      color: c.withValues(alpha: 0.4), size: 20),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
