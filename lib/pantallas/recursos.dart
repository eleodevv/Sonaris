import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'quiz.dart';
import 'practica_acordes.dart';

class PantallaRecursos extends StatelessWidget {
  const PantallaRecursos({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text('Recursos',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w200,
                    color: blanco,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Acordes · Quiz',
                style: TextStyle(fontSize: 11, color: medio)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                _TarjetaAccion(
                  icono: Icons.quiz_rounded,
                  titulo: 'Quiz de acordes',
                  subtitulo: 'Pon a prueba tu conocimiento',
                  color: verde,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PantallaQuiz())),
                ),
                const SizedBox(height: 12),
                _TarjetaAccion(
                  icono: Icons.music_note_rounded,
                  titulo: 'Práctica de acordes',
                  subtitulo: 'Explora los acordes por nivel',
                  color: const Color(0xFF64B5F6),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaPracticaAcordes())),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Tarjeta de acción (quiz) ──────────────────────────────

class _TarjetaAccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaAccion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: blanco)),
                const SizedBox(height: 3),
                Text(subtitulo,
                    style: const TextStyle(fontSize: 12, color: medio)),
              ])),
          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
        ]),
      ),
    );
  }
}
