import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';

// ── Selector de acordes por nivel ────────────────────────
class SelectorAcordes extends StatelessWidget {
  final String? seleccionado;
  final void Function(String) alSeleccionar;
  const SelectorAcordes(
      {super.key, this.seleccionado, required this.alSeleccionar});

  static const _coloresNivel = {
    'básico': Color(0xFF00E676),
    'intermedio': Color(0xFFFFD54F),
    'difícil': Color(0xFFFF5252),
  };

  static const _nombresNivel = {
    'básico': 'Básico',
    'intermedio': 'Intermedio',
    'difícil': 'Difícil',
  };

  static const _iconosNivel = {
    'básico': Icons.signal_cellular_alt_1_bar_rounded,
    'intermedio': Icons.signal_cellular_alt_2_bar_rounded,
    'difícil': Icons.signal_cellular_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: acordesPorNivel.entries.map((entry) {
        final nivel = entry.key;
        final lista = entry.value;
        final color = _coloresNivel[nivel]!;
        final icono = _iconosNivel[nivel]!;
        final nombre = _nombresNivel[nivel]!;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Etiqueta del nivel mejorada
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color, size: 14),
              ),
              const SizedBox(width: 10),
              Text(nombre.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(width: 8),
              Expanded(
                  child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        color.withValues(alpha: 0.3),
                        Colors.transparent
                      ])))),
            ]),
          ),
          // Grid de acordes
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
            children: lista.map((a) {
              final sel = seleccionado == a;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  alSeleccionar(a);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: sel ? color.withValues(alpha: 0.12) : tarjeta,
                    shape: BoxShape.circle,
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel
                            ? color.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.07),
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: sel ? 15 : 14,
                          fontWeight: FontWeight.w700,
                          color: sel ? color : blanco,
                          letterSpacing: -0.3,
                        ),
                        child: Text(a),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ]);
      }).toList(),
    );
  }
}

// ── Tarjeta del acorde con diagrama y audio ───────────────
class TarjetaAcorde extends StatefulWidget {
  final String acorde;
  const TarjetaAcorde({super.key, required this.acorde});

  @override
  State<TarjetaAcorde> createState() => _EstadoTarjetaAcorde();
}

class _EstadoTarjetaAcorde extends State<TarjetaAcorde>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _reproduciendo = false;

  // Animación de entrada
  late AnimationController _entradaCtrl;

  // Animación spring del botón escuchar
  late AnimationController _botonCtrl;
  late Animation<double> _botonScale;

  // Colores por nivel
  static const _coloresNivel = {
    'básico': Color(0xFF00E676),
    'intermedio': Color(0xFFFFD54F),
    'difícil': Color(0xFFFF5252),
  };

  Color get _colorNivel {
    // Buscar en qué nivel está el acorde
    for (final entry in acordesPorNivel.entries) {
      if (entry.value.contains(widget.acorde)) {
        return _coloresNivel[entry.key] ?? verde;
      }
    }
    return verde;
  }

  @override
  void initState() {
    super.initState();

    _entradaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _botonCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _botonScale = Tween<double>(begin: 0.93, end: 1.0).animate(
        CurvedAnimation(parent: _botonCtrl, curve: Curves.easeOutBack));
    _botonCtrl.value = 1.0;

    _entradaCtrl.forward();
  }

  @override
  void dispose() {
    _player.dispose();
    _entradaCtrl.dispose();
    _botonCtrl.dispose();
    super.dispose();
  }

  Future<void> _reproducir() async {
    if (_reproduciendo) {
      await _player.stop();
      setState(() => _reproduciendo = false);
      return;
    }
    final sample = sampleAcorde[widget.acorde];
    if (sample == null) return;
    // Spring animation on press
    _botonCtrl.reverse().then((_) {
      if (mounted) _botonCtrl.forward();
    });
    setState(() => _reproduciendo = true);
    await _player.play(AssetSource(sample));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _reproduciendo = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notas = notasAcorde[widget.acorde] ?? [];
    final colorNivel = _colorNivel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorNivel.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: colorNivel.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Diagrama grande
          DiagramaAcordeWidget(acorde: widget.acorde, alto: 200),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Nombre grande con color de nivel
                Text(widget.acorde,
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: colorNivel,
                        height: 1,
                        letterSpacing: -2)),
                const SizedBox(height: 4),
                Text(nombreAcorde[widget.acorde] ?? '',
                    style: const TextStyle(
                        fontSize: 11,
                        color: medio,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 16),
                Text('NOTAS',
                    style: TextStyle(
                        fontSize: 9,
                        color: colorNivel.withValues(alpha: 0.6),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                // Chips de notas con color de nivel
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: notas
                      .map((n) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: colorNivel.withValues(alpha: 0.1),
                              border: Border.all(
                                  color: colorNivel.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(n,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: colorNivel,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Botón escuchar con spring
                ScaleTransition(
                  scale: _botonScale,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _reproducir,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _reproduciendo
                            ? colorNivel.withValues(alpha: 0.15)
                            : tarjeta2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _reproduciendo
                                ? colorNivel.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.08)),
                        boxShadow: _reproduciendo
                            ? [
                                BoxShadow(
                                  color: colorNivel.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                )
                              ]
                            : [],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            _reproduciendo
                                ? Icons.stop_rounded
                                : Icons.volume_up_rounded,
                            color: _reproduciendo ? colorNivel : medio,
                            size: 14),
                        const SizedBox(width: 6),
                        Text(_reproduciendo ? 'Detener' : 'Escuchar',
                            style: TextStyle(
                                fontSize: 11,
                                color: _reproduciendo ? colorNivel : medio,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ),
              ])),
        ]),
        const SizedBox(height: 16),
        // Descripción con borde izquierdo de color nivel
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: colorNivel,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Text(
                      descripcionAcorde[widget.acorde] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE0E0E0),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Tarjeta de resultado ──────────────────────────────────
class TarjetaResultado extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const TarjetaResultado({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final correcto = resultado['es_correcto'] == true;
    final confianza = (resultado['confianza'] ?? 0).toStringAsFixed(0);
    final color = correcto ? verde : rojo;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)
            ],
          ),
          child: Icon(
            correcto ? Icons.check_rounded : Icons.close_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          correcto ? 'Correcto' : 'Incorrecto',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w300, color: color),
        ),
        const Spacer(),
        if (correcto)
          Text(
            '$confianza%',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w200, color: color),
          ),
      ]),
    );
  }
}
