import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../constantes/curso_data.dart';
import '../services/curso_service.dart';

class PantallaLeccion extends StatefulWidget {
  final Leccion leccion;
  const PantallaLeccion({super.key, required this.leccion});

  @override
  State<PantallaLeccion> createState() => _EstadoLeccion();
}

class _EstadoLeccion extends State<PantallaLeccion> {
  int? _seleccion;
  bool _respondido = false;

  void _responder(int idx) {
    if (_respondido) return;
    HapticFeedback.selectionClick();
    final correcto = idx == widget.leccion.ejercicio!.respuestaCorrecta;
    if (correcto) HapticFeedback.mediumImpact();
    setState(() {
      _seleccion = idx;
      _respondido = true;
    });
  }

  Future<void> _completar() async {
    await context
        .read<CursoService>()
        .completarLeccion(widget.leccion.id, widget.leccion.xp);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final leccion = widget.leccion;
    final yaCompletada =
        context.watch<CursoService>().estaCompletada(leccion.id);

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: medio, size: 22),
                ),
                Expanded(
                    child: Text(leccion.titulo,
                        style: const TextStyle(
                            fontSize: 15,
                            color: blanco,
                            fontWeight: FontWeight.w300),
                        overflow: TextOverflow.ellipsis)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ambar.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.bolt_rounded, color: ambar, size: 13),
                    const SizedBox(width: 3),
                    Text('${leccion.xp} XP',
                        style: const TextStyle(
                            fontSize: 11,
                            color: ambar,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen si existe
                      if (leccion.imagenAsset != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(leccion.imagenAsset!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Contenido
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: tarjeta,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(leccion.contenido,
                            style: const TextStyle(
                                fontSize: 14, color: blanco, height: 1.7)),
                      ),
                      // Mini ejercicio
                      if (leccion.ejercicio != null) ...[
                        const SizedBox(height: 24),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: verde.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('MINI EJERCICIO',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: verde,
                                    letterSpacing: 2)),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: tarjeta,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: verde.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(leccion.ejercicio!.pregunta,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: blanco,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4)),
                                const SizedBox(height: 16),
                                ...leccion.ejercicio!.opciones
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  final idx = e.key;
                                  final texto = e.value;
                                  final esCorrecta = idx ==
                                      leccion.ejercicio!.respuestaCorrecta;
                                  final seleccionada = _seleccion == idx;

                                  Color borderColor =
                                      Colors.white.withValues(alpha: 0.08);
                                  Color bgColor = tarjeta2;
                                  Color textColor = blanco;
                                  Widget? trailing;

                                  if (_respondido) {
                                    if (esCorrecta) {
                                      borderColor =
                                          verde.withValues(alpha: 0.5);
                                      bgColor = verde.withValues(alpha: 0.08);
                                      textColor = verde;
                                      trailing = const Icon(
                                          Icons.check_circle_rounded,
                                          color: verde,
                                          size: 18);
                                    } else if (seleccionada) {
                                      borderColor = rojo.withValues(alpha: 0.5);
                                      bgColor = rojo.withValues(alpha: 0.08);
                                      textColor = rojo;
                                      trailing = const Icon(
                                          Icons.cancel_rounded,
                                          color: rojo,
                                          size: 18);
                                    }
                                  } else if (seleccionada) {
                                    borderColor = verde.withValues(alpha: 0.3);
                                  }

                                  return GestureDetector(
                                    onTap: () => _responder(idx),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 13),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(texto,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: textColor))),
                                        if (trailing != null) trailing,
                                      ]),
                                    ),
                                  );
                                }),
                                // Feedback
                                if (_respondido) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: (_seleccion ==
                                                  leccion.ejercicio!
                                                      .respuestaCorrecta
                                              ? verde
                                              : rojo)
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(children: [
                                      Icon(
                                          _seleccion ==
                                                  leccion.ejercicio!
                                                      .respuestaCorrecta
                                              ? Icons.check_circle_rounded
                                              : Icons.info_rounded,
                                          color: _seleccion ==
                                                  leccion.ejercicio!
                                                      .respuestaCorrecta
                                              ? verde
                                              : ambar,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              _seleccion ==
                                                      leccion.ejercicio!
                                                          .respuestaCorrecta
                                                  ? '¡Correcto! Muy bien.'
                                                  : 'La respuesta correcta es: ${leccion.ejercicio!.opciones[leccion.ejercicio!.respuestaCorrecta]}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: _seleccion ==
                                                          leccion.ejercicio!
                                                              .respuestaCorrecta
                                                      ? verde
                                                      : ambar))),
                                    ]),
                                  ),
                                ],
                              ]),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Botón completar
                      if (!yaCompletada)
                        GestureDetector(
                          onTap: (leccion.ejercicio == null || _respondido)
                              ? _completar
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: (leccion.ejercicio == null || _respondido)
                                  ? verde
                                  : tenue,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.bolt_rounded,
                                      color: fondo, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                      (leccion.ejercicio == null || _respondido)
                                          ? 'Completar · +${leccion.xp} XP'
                                          : 'Responde el ejercicio primero',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: fondo)),
                                ]),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: verde.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: verde.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: verde, size: 18),
                                SizedBox(width: 8),
                                Text('Lección completada',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: verde,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
