import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'login.dart';
import 'registro.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  static const _fotos = [
    'assets/grid/grid1.png',
    'assets/grid/grid2.png',
    'assets/grid/grid3.png',
    'assets/grid/grid4.png',
    'assets/grid/grid5.png',
    'assets/grid/grid6.png',
    'assets/grid/grid7.png',
    'assets/grid/grid8.png',
    'assets/grid/grid9.png',
  ];

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Column(children: [
          // Grid masonry asimétrico (68% de la pantalla)
          SizedBox(
            height: h * 0.68,
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Columna 1: 1 muy grande + 2 pequeñas
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 4, bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[0], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 4, bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[3], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[6], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Columna 2: 1 pequeña + 1 muy grande + 1 pequeña
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 4, bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[1], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 4, bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[4], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[7], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Columna 3: 3 pequeñas + 1 muy grande
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[2], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    Image.asset(_fotos[5], fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(_fotos[8], fit: BoxFit.cover),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Gradiente inferior suave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: h * 0.25,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        Color(0xDD000000),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Logo
              Positioned(
                bottom: 30,
                left: 24,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset('assets/logo_sonaris.png',
                      fit: BoxFit.contain),
                ),
              ),
            ]),
          ),
          // Contenido inferior
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [blanco, Color(0xFF666666)],
                    stops: [0.0, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'Sonaris: Tu viaje\ncon la guitarra',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: blanco,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aprende acordes, técnicas y canciones con planes personalizados. Tu viaje musical comienza aquí.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                // Botón principal
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaRegistro())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: verde,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Text(
                      'Comenzar ahora',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: blanco,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Link login
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PantallaLogin())),
                  child: const Center(
                    child: Text(
                      'Ya tengo una cuenta',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
