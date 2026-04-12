import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../constantes/curso_data.dart';
import '../services/curso_service.dart';
import 'pantalla_leccion.dart';

class PantallaCapitulo extends StatelessWidget {
  final Capitulo capitulo;
  const PantallaCapitulo({super.key, required this.capitulo});

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
                Expanded(
                    child: Text('Capítulo ${capitulo.numero}',
                        style: const TextStyle(
                            fontSize: 16,
                            color: blanco,
                            fontWeight: FontWeight.w300))),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capitulo.titulo,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: blanco)),
                    const SizedBox(height: 4),
                    Text(capitulo.descripcion,
                        style: const TextStyle(fontSize: 12, color: medio)),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: curso.porcentajeCapitulo(
                            capitulo.id, capitulo.lecciones.length),
                        minHeight: 4,
                        backgroundColor: tarjeta2,
                        valueColor: const AlwaysStoppedAnimation(verde),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: capitulo.lecciones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final leccion = capitulo.lecciones[i];
                  final completada = curso.estaCompletada(leccion.id);
                  return _ItemLeccion(
                    numero: i + 1,
                    leccion: leccion,
                    completada: completada,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PantallaLeccion(leccion: leccion))),
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

class _ItemLeccion extends StatelessWidget {
  final int numero;
  final Leccion leccion;
  final bool completada;
  final VoidCallback onTap;

  const _ItemLeccion({
    required this.numero,
    required this.leccion,
    required this.completada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: completada
                  ? verde.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completada ? verde.withValues(alpha: 0.15) : tarjeta2,
            ),
            child: Center(
              child: completada
                  ? const Icon(Icons.check_rounded, color: verde, size: 16)
                  : Text('$numero',
                      style: const TextStyle(
                          fontSize: 13,
                          color: medio,
                          fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(leccion.titulo,
                  style: TextStyle(
                      fontSize: 14, color: completada ? verde : blanco))),
          Row(children: [
            const Icon(Icons.bolt_rounded, color: ambar, size: 13),
            const SizedBox(width: 3),
            Text('${leccion.xp} XP',
                style: const TextStyle(fontSize: 11, color: ambar)),
          ]),
          const SizedBox(width: 8),
          Icon(
              completada
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: completada ? verde : tenue,
              size: completada ? 18 : 12),
        ]),
      ),
    );
  }
}
