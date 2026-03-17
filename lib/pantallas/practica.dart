import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';

// ── Selector de acordes ───────────────────────────────────
class SelectorAcordes extends StatelessWidget {
  final String? seleccionado;
  final void Function(String) alSeleccionar;
  const SelectorAcordes({super.key, this.seleccionado, required this.alSeleccionar});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: acordes.map((a) {
        final sel = seleccionado == a;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () { HapticFeedback.selectionClick(); alSeleccionar(a); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? verde.withOpacity(0.1) : tarjeta,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? verde.withOpacity(0.6) : Colors.white.withOpacity(0.06),
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Text(a, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: sel ? verde : medio,
            )),
          ),
        );
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

class _EstadoTarjetaAcorde extends State<TarjetaAcorde> {
  final AudioPlayer _player = AudioPlayer();
  bool _reproduciendo = false;

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  Future<void> _reproducir() async {
    if (_reproduciendo) {
      await _player.stop();
      setState(() => _reproduciendo = false);
      return;
    }
    final sample = sampleAcorde[widget.acorde];
    if (sample == null) return;
    setState(() => _reproduciendo = true);
    await _player.play(AssetSource(sample));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _reproduciendo = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notas = notasAcorde[widget.acorde] ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Diagrama grande
          DiagramaAcordeWidget(acorde: widget.acorde, alto: 200),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.acorde, style: const TextStyle(
              fontSize: 52, fontWeight: FontWeight.w100, color: blanco, height: 1)),
            const SizedBox(height: 4),
            Text(nombreAcorde[widget.acorde] ?? '',
              style: const TextStyle(fontSize: 11, color: medio)),
            const SizedBox(height: 16),
            const Text('NOTAS', style: TextStyle(
              fontSize: 9, color: tenue, letterSpacing: 2)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6,
              children: notas.map((n) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(n, style: const TextStyle(
                  fontSize: 12, color: blanco, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            // Botón escuchar
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _reproducir,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _reproduciendo ? verde.withOpacity(0.12) : tarjeta2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _reproduciendo
                        ? verde.withOpacity(0.4)
                        : Colors.white.withOpacity(0.08)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    _reproduciendo ? Icons.stop_rounded : Icons.volume_up_rounded,
                    color: _reproduciendo ? verde : medio, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _reproduciendo ? 'Detener' : 'Escuchar',
                    style: TextStyle(
                      fontSize: 11,
                      color: _reproduciendo ? verde : medio)),
                ]),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 14),
        // Descripción
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tarjeta2, borderRadius: BorderRadius.circular(10)),
          child: Text(descripcionAcorde[widget.acorde] ?? '',
            style: const TextStyle(fontSize: 12, color: medio, height: 1.5)),
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
    final correcto  = resultado['es_correcto'] == true;
    final confianza = (resultado['confianza'] ?? 0).toStringAsFixed(0);
    final predicho  = resultado['acorde_predicho'] ?? '';
    final top5      = List<Map<String, dynamic>>.from(
        (resultado['top5'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correcto ? verde.withOpacity(0.3) : rojo.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: correcto ? verde : rojo,
              boxShadow: [BoxShadow(
                color: (correcto ? verde : rojo).withOpacity(0.5), blurRadius: 6)],
            )),
          const SizedBox(width: 10),
          Text(correcto ? '¡Correcto!' : 'Intenta de nuevo',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
              color: correcto ? verde : rojo)),
          const Spacer(),
          Text('$confianza%', style: const TextStyle(fontSize: 12, color: tenue)),
        ]),
        const SizedBox(height: 10),
        Text('Detectado: $predicho',
          style: const TextStyle(fontSize: 13, color: blanco)),
        if (top5.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('PROBABILIDADES', style: TextStyle(
            fontSize: 9, color: tenue, letterSpacing: 2)),
          const SizedBox(height: 8),
          ...top5.take(3).map((e) {
            final pct = (e['probabilidad'] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(width: 36,
                  child: Text(e['acorde'] ?? '',
                    style: const TextStyle(fontSize: 12, color: blanco))),
                const SizedBox(width: 8),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(
                      pct > 60 ? verde : pct > 30 ? ambar : tenue),
                  ),
                )),
                const SizedBox(width: 8),
                Text('${pct.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11, color: medio)),
              ]),
            );
          }),
        ],
      ]),
    );
  }
}

// ── Barra de grabación centrada ───────────────────────────
class BarraGrabacion extends StatelessWidget {
  final bool grabando;
  final bool procesando;
  final String? acorde;
  final int progreso;
  final Animation<double> pulsoAnim;
  final VoidCallback alTocar;

  const BarraGrabacion({
    super.key,
    required this.grabando,
    required this.procesando,
    required this.acorde,
    required this.progreso,
    required this.pulsoAnim,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      decoration: BoxDecoration(
        color: fondo,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Texto de estado
        Text(
          procesando ? 'Analizando con IA...'
            : grabando ? 'ESCUCHANDO...'
            : acorde != null ? 'Toca el acorde y graba'
            : 'Selecciona un acorde',
          style: TextStyle(
            fontSize: grabando ? 11 : 13,
            color: grabando ? verde : medio,
            letterSpacing: grabando ? 2.5 : 0,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 12),
        // Barra de progreso
        if (grabando) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progreso / 30,
              minHeight: 2,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(verde),
            ),
          ),
          const SizedBox(height: 14),
        ],
        // Botón central
        ScaleTransition(
          scale: grabando ? pulsoAnim : const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: procesando ? null : alTocar,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: grabando ? rojo.withOpacity(0.12) : tarjeta2,
                border: Border.all(
                  color: grabando ? rojo : Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: procesando
                ? const Padding(padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: medio))
                : Icon(
                    grabando ? Icons.stop_rounded : Icons.mic_rounded,
                    color: grabando ? rojo : medio, size: 28),
            ),
          ),
        ),
      ]),
    );
  }
}
