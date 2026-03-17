import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';

const int _metaPorAcorde = 20;

class PantallaEntrenar extends StatefulWidget {
  const PantallaEntrenar({super.key});
  @override
  State<PantallaEntrenar> createState() => _EstadoEntrenar();
}

class _EstadoEntrenar extends State<PantallaEntrenar> {
  final AudioService _audio = AudioService();
  Map<String, int> _conteo  = {for (var a in acordes) a: 0};
  bool _cargando     = true;
  bool _grabando     = false;
  bool _subiendo     = false;
  bool _reentrenando = false;
  String? _acordeActivo;
  int _progreso = 0;
  Timer? _timer;
  String? _mensajeExito;

  @override
  void initState() { super.initState(); _cargarEstado(); }

  @override
  void dispose() { _timer?.cancel(); _audio.dispose(); super.dispose(); }

  Future<void> _cargarEstado() async {
    setState(() => _cargando = true);
    try {
      final r = await context.read<ApiService>().estadoSamples();
      final p = Map<String, dynamic>.from(r['por_acorde'] ?? {});
      setState(() => _conteo = { for (var a in acordes) a: (p[a] as num?)?.toInt() ?? 0 });
    } catch (_) {}
    setState(() => _cargando = false);
  }

  Future<void> _grabar(String acorde) async {
    if (_grabando || _subiendo) return;
    final ok = await _audio.startRecording();
    if (!ok) { _snack('Sin permiso de micrófono'); return; }
    HapticFeedback.mediumImpact();
    setState(() { _grabando = true; _acordeActivo = acorde; _progreso = 0; });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _progreso++);
      if (_progreso >= 30) { t.cancel(); _detener(); }
    });
  }

  Future<void> _detener() async {
    _timer?.cancel();
    final ruta = await _audio.stopRecording();
    setState(() { _grabando = false; _progreso = 0; });
    if (ruta != null && _acordeActivo != null) await _subir(ruta, _acordeActivo!);
  }

  Future<void> _subir(String ruta, String acorde) async {
    setState(() => _subiendo = true);
    try {
      final r = await context.read<ApiService>().subirSample(ruta, acorde);
      final p = Map<String, dynamic>.from(r['por_acorde'] ?? {});
      HapticFeedback.lightImpact();
      setState(() {
        _conteo = { for (var a in acordes) a: (p[a] as num?)?.toInt() ?? 0 };
        _mensajeExito = acorde;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _mensajeExito = null);
      });
    } catch (_) { _snack('Error subiendo sample'); }
    setState(() => _subiendo = false);
  }

  Future<void> _reentrenar() async {
    setState(() => _reentrenando = true);
    try {
      final r = await context.read<ApiService>().reentrenar();
      _snack('Modelo actualizado · ${r["accuracy"]}% precisión');
      HapticFeedback.heavyImpact();
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    }
    setState(() => _reentrenando = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: blanco, fontSize: 13)),
      backgroundColor: tarjeta2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    ));
  }

  bool get _listoParaEntrenar => _conteo.values.every((v) => v >= 10);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mejorar modelo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w200, color: blanco)),
              SizedBox(height: 2),
              Text('Graba tus acordes para personalizar la IA',
                style: TextStyle(fontSize: 11, color: medio)),
            ])),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _cargando ? null : _cargarEstado,
              child: const Padding(padding: EdgeInsets.all(8),
                child: Icon(Icons.refresh_rounded, color: tenue, size: 18)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _cargando
            ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: verde))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...acordes.map((a) => _FilaAcorde(
                    acorde: a,
                    cantidad: _conteo[a] ?? 0,
                    meta: _metaPorAcorde,
                    grabando: _grabando && _acordeActivo == a,
                    subiendo: _subiendo && _acordeActivo == a,
                    progreso: _progreso,
                    exito: _mensajeExito == a,
                    bloqueado: (_grabando || _subiendo) && _acordeActivo != a,
                    alGrabar: () => _grabar(a),
                    alDetener: _detener,
                  )),
                  const SizedBox(height: 16),
                  _BotonReentrenar(
                    listo: _listoParaEntrenar,
                    reentrenando: _reentrenando,
                    alReentrenar: _reentrenar,
                    conteo: _conteo,
                  ),
                ],
              ),
        ),
      ]),
    );
  }
}

class _FilaAcorde extends StatelessWidget {
  final String acorde;
  final int cantidad, meta, progreso;
  final bool grabando, subiendo, exito, bloqueado;
  final VoidCallback alGrabar, alDetener;

  const _FilaAcorde({
    required this.acorde, required this.cantidad, required this.meta,
    required this.grabando, required this.subiendo, required this.progreso,
    required this.exito, required this.bloqueado,
    required this.alGrabar, required this.alDetener,
  });

  @override
  Widget build(BuildContext context) {
    final pct      = (cantidad / meta).clamp(0.0, 1.0);
    final completo = cantidad >= meta;
    final barColor = grabando ? verde : completo ? verde : exito ? verde : tenue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: grabando
          ? verde.withOpacity(0.35)
          : exito ? verde.withOpacity(0.25)
          : Colors.white.withOpacity(0.05)),
      ),
      child: Row(children: [
        SizedBox(width: 44,
          child: Text(acorde, style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w200, color: blanco))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: grabando ? progreso / 30 : pct,
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            grabando ? 'Grabando...' : subiendo ? 'Subiendo...' : '$cantidad / $meta',
            style: TextStyle(fontSize: 10, color: grabando || subiendo ? verde : tenue),
          ),
        ])),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: bloqueado ? null : grabando ? alDetener : alGrabar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: grabando
                ? rojo.withOpacity(0.12)
                : bloqueado ? tarjeta2.withOpacity(0.4)
                : completo ? verde.withOpacity(0.08)
                : tarjeta2,
              border: Border.all(
                color: grabando ? rojo
                  : bloqueado ? Colors.white.withOpacity(0.04)
                  : completo ? verde.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1)),
            ),
            child: subiendo
              ? const Padding(padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: verde))
              : Icon(
                  grabando ? Icons.stop_rounded
                    : completo ? Icons.check_rounded
                    : Icons.mic_rounded,
                  size: 18,
                  color: grabando ? rojo
                    : bloqueado ? tenue.withOpacity(0.3)
                    : completo ? verde
                    : medio,
                ),
          ),
        ),
      ]),
    );
  }
}

class _BotonReentrenar extends StatelessWidget {
  final bool listo, reentrenando;
  final VoidCallback alReentrenar;
  final Map<String, int> conteo;

  const _BotonReentrenar({
    required this.listo, required this.reentrenando,
    required this.alReentrenar, required this.conteo,
  });

  @override
  Widget build(BuildContext context) {
    final minimo = conteo.values.isEmpty ? 0 : conteo.values.reduce((a, b) => a < b ? a : b);
    final falta  = 10 - minimo;

    return Column(children: [
      if (!listo)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Necesitas al menos 10 samples por acorde · faltan $falta en alguno',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: tenue),
          ),
        ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: listo && !reentrenando ? alReentrenar : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: listo ? verde.withOpacity(0.1) : tarjeta2.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: listo ? verde.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
          ),
          child: reentrenando
            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: verde)),
                SizedBox(width: 10),
                Text('Entrenando...', style: TextStyle(fontSize: 14, color: verde)),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.auto_awesome_rounded,
                  color: listo ? verde : tenue, size: 16),
                const SizedBox(width: 8),
                Text('Reentrenar modelo',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w400,
                    color: listo ? verde : tenue)),
              ]),
        ),
      ),
    ]);
  }
}
