import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';

/// Pantalla de monitoreo de la API y el modelo
class PantallaApiMonitor extends StatelessWidget {
  final bool online;
  final bool verificando;
  final List<Map<String, dynamic>> historialPings;
  final VoidCallback alHacerPing;

  const PantallaApiMonitor({
    super.key,
    required this.online,
    required this.verificando,
    required this.historialPings,
    required this.alHacerPing,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Encabezado
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Text('API Monitor', style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w200, color: blanco)),
            const Spacer(),
            _PuntoEstado(online: online, verificando: verificando),
          ]),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('sonarisapi.onrender.com',
            style: TextStyle(fontSize: 11, color: tenue)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              _tarjetaEstado(online, verificando, alHacerPing),
              const SizedBox(height: 10),
              _tarjetaEndpoints(),
              const SizedBox(height: 10),
              _tarjetaModelo(),
              if (historialPings.isNotEmpty) ...[
                const SizedBox(height: 10),
                _tarjetaHistorial(historialPings),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _tarjetaEstado(bool online, bool verificando, VoidCallback alPing) {
    return _Tarjeta(
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: verificando ? ambar : online ? verde : rojo,
            boxShadow: [BoxShadow(
              color: (verificando ? ambar : online ? verde : rojo).withOpacity(0.5),
              blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            verificando ? 'Verificando...' : online ? 'Online' : 'Offline',
            style: const TextStyle(fontSize: 15, color: blanco, fontWeight: FontWeight.w400)),
          const SizedBox(height: 2),
          const Text('Modelo MLP · 6 acordes · 99.7% acc',
            style: TextStyle(fontSize: 11, color: tenue)),
        ])),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: alPing,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: tarjeta2, borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, color: medio, size: 14),
              SizedBox(width: 5),
              Text('Ping', style: TextStyle(fontSize: 11, color: medio)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _tarjetaEndpoints() {
    return _Tarjeta(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Etiqueta('ENDPOINTS'),
        const SizedBox(height: 12),
        _FilaEndpoint('POST', '/clasificar', 'MLP · 6 acordes', verde),
        const SizedBox(height: 8),
        _FilaEndpoint('POST', '/verificar',  'DSP fallback',    ambar),
        const SizedBox(height: 8),
        _FilaEndpoint('GET',  '/health',     'Health check',    medio),
        const SizedBox(height: 8),
        _FilaEndpoint('GET',  '/acordes',    'Lista acordes',   medio),
      ]),
    );
  }

  Widget _tarjetaModelo() {
    return _Tarjeta(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Etiqueta('MODELO'),
        const SizedBox(height: 12),
        _FilaInfo('Tipo',      'MLP (sklearn 1.5.2)'),
        _FilaInfo('Capas',     '128 → 64 → 6 (softmax)'),
        _FilaInfo('Dataset',   '12,360 archivos WAV reales'),
        _FilaInfo('Acordes',   acordes.join(' · ')),
        _FilaInfo('Accuracy',  '99.73%'),
        _FilaInfo('Features',  '31 (chroma + spectral + pitch)'),
      ]),
    );
  }

  Widget _tarjetaHistorial(List<Map<String, dynamic>> historial) {
    return _Tarjeta(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const _Etiqueta('HISTORIAL DE PINGS'),
          const Spacer(),
          const Text('auto cada 10s',
            style: TextStyle(fontSize: 9, color: tenue)),
        ]),
        const SizedBox(height: 12),
        ...historial.take(8).map((p) {
          final ok = p['ok'] as bool;
          final ms = p['ms'] as int;
          final t  = p['time'] as DateTime;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ok ? verde : rojo)),
              const SizedBox(width: 10),
              Text(
                '${t.hour.toString().padLeft(2,'0')}:'
                '${t.minute.toString().padLeft(2,'0')}:'
                '${t.second.toString().padLeft(2,'0')}',
                style: const TextStyle(fontSize: 11, color: medio)),
              const Spacer(),
              Text(
                ok ? '${ms}ms' : 'timeout',
                style: TextStyle(fontSize: 11,
                  color: ok
                    ? (ms < 500 ? verde : ms < 1500 ? ambar : rojo)
                    : rojo)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────

class _Tarjeta extends StatelessWidget {
  final Widget child;
  const _Tarjeta({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(texto, style: const TextStyle(
      fontSize: 9, color: tenue, letterSpacing: 2));
  }
}

class _FilaEndpoint extends StatelessWidget {
  final String metodo;
  final String ruta;
  final String descripcion;
  final Color color;
  const _FilaEndpoint(this.metodo, this.ruta, this.descripcion, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(metodo, style: TextStyle(
          fontSize: 9, color: color,
          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
      const SizedBox(width: 10),
      Text(ruta, style: const TextStyle(
        fontSize: 12, color: blanco, fontFamily: 'monospace')),
      const Spacer(),
      Text(descripcion, style: const TextStyle(fontSize: 11, color: tenue)),
    ]);
  }
}

class _FilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _FilaInfo(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80,
          child: Text(etiqueta,
            style: const TextStyle(fontSize: 12, color: medio))),
        Expanded(child: Text(valor,
          style: const TextStyle(fontSize: 12, color: blanco))),
      ]),
    );
  }
}

class _PuntoEstado extends StatelessWidget {
  final bool online;
  final bool verificando;
  const _PuntoEstado({required this.online, required this.verificando});

  @override
  Widget build(BuildContext context) {
    final color = verificando ? ambar : online ? verde : rojo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 7, height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
      ),
    );
  }
}
