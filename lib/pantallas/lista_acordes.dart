import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';

/// Pantalla con la lista de los 6 acordes disponibles
class PantallaListaAcordes extends StatelessWidget {
  final bool online;
  final bool verificando;
  final void Function(String acorde) alSeleccionar;
  final VoidCallback alVerificarConexion;

  const PantallaListaAcordes({
    super.key,
    required this.online,
    required this.verificando,
    required this.alSeleccionar,
    required this.alVerificarConexion,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Encabezado
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Text(
              'Acordes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w200,
                color: blanco,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            _PuntoCon(online: online, verificando: verificando, alTocar: alVerificarConexion),
          ]),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '${acordes.length} acordes · modelo MLP',
            style: const TextStyle(fontSize: 11, color: medio),
          ),
        ),
        const SizedBox(height: 16),
        // Lista
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: acordes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _TarjetaAcorde(
              acorde: acordes[i],
              alTocar: () {
                HapticFeedback.selectionClick();
                alSeleccionar(acordes[i]);
              },
            ),
          ),
        ),
      ]),
    );
  }
}

class _TarjetaAcorde extends StatelessWidget {
  final String acorde;
  final VoidCallback alTocar;

  const _TarjetaAcorde({required this.acorde, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: alTocar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(children: [
          // Diagrama pequeño
          SizedBox(
            width: 68,
            height: 100,
            child: DiagramaAcordeWidget(acorde: acorde, alto: 100),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(
                  acorde,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w200,
                    color: blanco,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  nombreAcorde[acorde] ?? '',
                  style: const TextStyle(fontSize: 11, color: medio),
                ),
              ]),
              const SizedBox(height: 8),
              // Notas
              Wrap(
                spacing: 5,
                children: (notasAcorde[acorde] ?? []).map((n) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(n, style: const TextStyle(fontSize: 11, color: blanco)),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                descripcionAcorde[acorde] ?? '',
                style: const TextStyle(fontSize: 11, color: medio, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, color: tenue, size: 12),
        ]),
      ),
    );
  }
}

/// Punto de estado de conexión reutilizable
class _PuntoCon extends StatelessWidget {
  final bool online;
  final bool verificando;
  final VoidCallback alTocar;

  const _PuntoCon({
    required this.online,
    required this.verificando,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final color = verificando ? ambar : online ? verde : rojo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: alTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
        ),
      ),
    );
  }
}
