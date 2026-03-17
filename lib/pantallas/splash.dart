import 'package:flutter/material.dart';
import '../constantes/colores.dart';

class PantallaSplash extends StatelessWidget {
  final VoidCallback alComenzar;

  const PantallaSplash({super.key, required this.alComenzar});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/fondo.png', fit: BoxFit.cover),
      // Gradiente oscuro de abajo
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.15),
              Colors.black.withOpacity(0.45),
              Colors.black.withOpacity(0.85),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      ),
      SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),
          const Text(
            'Hola, músico.',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w200,
              color: blanco,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca. Aprende. Mejora.',
            style: TextStyle(
              fontSize: 12,
              color: blanco.withOpacity(0.4),
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(flex: 4),
          GestureDetector(
            onTap: alComenzar,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: blanco,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Text(
                'Comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: fondo,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    ]);
  }
}
