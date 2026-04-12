import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'practica.dart';

class PantallaDetalleAcorde extends StatelessWidget {
  final String acorde;
  const PantallaDetalleAcorde({super.key, required this.acorde});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: medio, size: 18),
              ),
              Text(acorde,
                  style: const TextStyle(
                      fontSize: 16,
                      color: blanco,
                      fontWeight: FontWeight.w300)),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: TarjetaAcorde(acorde: acorde),
            ),
          ),
        ]),
      ),
    );
  }
}
