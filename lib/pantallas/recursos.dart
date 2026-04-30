import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constantes/colores.dart';
import 'quiz.dart';
import 'practica_acordes.dart';
import 'metronomo.dart';

class PantallaRecursos extends StatelessWidget {
  const PantallaRecursos({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header con imagen
        Stack(children: [
          Image.asset('assets/imagenFondo2.png',
              width: double.infinity, height: 180, fit: BoxFit.cover),
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x44000000), Color(0xFF0A0A0F)],
              ),
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 20,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recursos',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: blanco)),
              SizedBox(height: 4),
              Text('Practica y pon a prueba tu nivel',
                  style: TextStyle(fontSize: 13, color: medio)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              _TarjetaGrande(
                titulo: 'Quiz de acordes',
                subtitulo: 'Teoría · Preguntas interactivas',
                descripcion:
                    'Pon a prueba tu conocimiento sobre acordes, notas y teoría musical.',
                color: verde,
                imagenUrl:
                    'https://raw.githubusercontent.com/jordi23-acosta/sonaris/main/assets/quizsonaris.png',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PantallaQuiz())),
              ),
              const SizedBox(height: 14),
              _TarjetaGrande(
                titulo: 'Práctica de acordes',
                subtitulo: 'Básico · Intermedio · Difícil',
                descripcion:
                    'Explora los 6 acordes disponibles organizados por nivel de dificultad.',
                color: const Color(0xFF64B5F6),
                imagenUrl:
                    'https://raw.githubusercontent.com/jordi23-acosta/sonaris/main/assets/practicasonaris.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PantallaPracticaAcordes())),
              ),
              const SizedBox(height: 14),
              _TarjetaGrande(
                titulo: 'Metrónomo',
                subtitulo: 'Ritmo · Tempo · Compás',
                descripcion:
                    'Practica con el tempo correcto. Ajusta los BPM y el compás.',
                color: ambar,
                imagenUrl:
                    'https://raw.githubusercontent.com/jordi23-acosta/sonaris/main/assets/metronomosonaris.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PantallaMetronomo())),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _TarjetaGrande extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String descripcion;
  final Color color;
  final String? imagenUrl;
  final String? imagenAsset;
  final VoidCallback onTap;

  const _TarjetaGrande({
    required this.titulo,
    required this.subtitulo,
    required this.descripcion,
    required this.color,
    this.imagenUrl,
    this.imagenAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Banner superior con imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(children: [
              // Imagen de fondo
              SizedBox(
                width: double.infinity,
                height: 140,
                child: imagenUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imagenUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: color.withValues(alpha: 0.08)),
                        errorWidget: (context, url, error) =>
                            Container(color: color.withValues(alpha: 0.08)))
                    : imagenAsset != null
                        ? Image.asset(imagenAsset!,
                            fit: BoxFit.contain,
                            color: color.withValues(alpha: 0.6),
                            colorBlendMode: BlendMode.modulate)
                        : Container(color: color.withValues(alpha: 0.08)),
              ),
              // Gradiente encima
              Container(
                height: 140,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6)
                    ])),
              ),
              // Botón empezar
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Empezar',
                        style: TextStyle(
                            fontSize: 12,
                            color: fondo,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: fondo, size: 14),
                  ]),
                ),
              ),
            ]),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subtitulo,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: blanco)),
              const SizedBox(height: 6),
              Text(descripcion,
                  style:
                      const TextStyle(fontSize: 12, color: medio, height: 1.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}
