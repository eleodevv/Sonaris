import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';

class PantallaSplash extends StatelessWidget {
  final VoidCallback alComenzar;

  const PantallaSplash({super.key, required this.alComenzar});

  @override
  Widget build(BuildContext context) {
    final nombre = context.watch<SesionService>().nombre ?? 'músico';
    final firstName = nombre.trim().split(' ').first;

    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/fondo.png', fit: BoxFit.cover),
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x26000000),
              Color(0x73000000),
              Color(0xD9000000),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
      ),
      SafeArea(
        child: Column(children: [
          const Spacer(flex: 3),
          Text(
            'Hola, $firstName.',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w200,
              color: blanco,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'L I S T O  P A R A  T O C A R',
            style: TextStyle(
              fontSize: 11,
              color: blanco,
              letterSpacing: 3,
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
                color: verde,
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
