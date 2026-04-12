import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../constantes/curso_data.dart';
import '../services/curso_service.dart';
import 'pantalla_capitulo.dart';

class PantallaCurso extends StatelessWidget {
  const PantallaCurso({super.key});

  @override
  Widget build(BuildContext context) {
    final curso = context.watch<CursoService>();
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: medio, size: 18),
                ),
                const Expanded(
                  child: Text('Nivel Básico',
                      style: TextStyle(
                          fontSize: 16,
                          color: blanco,
                          fontWeight: FontWeight.w300)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: verde.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: verde.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.bolt_rounded, color: verde, size: 14),
                    const SizedBox(width: 4),
                    Text('${curso.xpTotal} XP',
                        style: const TextStyle(
                            fontSize: 12,
                            color: verde,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: capitulosBasico.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final cap = capitulosBasico[i];
                  final pct =
                      curso.porcentajeCapitulo(cap.id, cap.lecciones.length);
                  final completadas =
                      curso.progresoCapitulo(cap.id, cap.lecciones.length);
                  return _TarjetaCapitulo(
                    capitulo: cap,
                    porcentaje: pct,
                    completadas: completadas,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PantallaCapitulo(capitulo: cap))),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _TarjetaCapitulo extends StatelessWidget {
  final Capitulo capitulo;
  final double porcentaje;
  final int completadas;
  final VoidCallback onTap;

  const _TarjetaCapitulo({
    required this.capitulo,
    required this.porcentaje,
    required this.completadas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completo = porcentaje >= 1.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: completo
                  ? verde.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completo ? verde.withValues(alpha: 0.15) : tarjeta2,
              ),
              child: Center(
                child: Text(capitulo.numero,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: completo ? verde : medio)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(capitulo.titulo,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: blanco)),
                  const SizedBox(height: 2),
                  Text(capitulo.descripcion,
                      style: const TextStyle(fontSize: 11, color: medio)),
                ])),
            // Badge progreso
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: completo ? verde.withValues(alpha: 0.12) : tarjeta2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(completo ? '100%' : '${(porcentaje * 100).round()}%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: completo ? verde : medio)),
            ),
          ]),
          const SizedBox(height: 16),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 5,
              backgroundColor: tarjeta2,
              valueColor: AlwaysStoppedAnimation(
                  completo ? verde : verde.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: 10),
          Text('$completadas de ${capitulo.lecciones.length} lecciones',
              style: const TextStyle(fontSize: 10, color: tenue)),
        ]),
      ),
    );
  }
}
