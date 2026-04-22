import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'ajustes.dart';
import 'pantalla_videos.dart';

class PantallaListaAcordes extends StatelessWidget {
  final bool online;
  final bool verificando;
  final void Function(String acorde) alSeleccionar;
  final VoidCallback alVerificarConexion;
  final VoidCallback alAbrirApi;

  const PantallaListaAcordes({
    super.key,
    required this.online,
    required this.verificando,
    required this.alSeleccionar,
    required this.alVerificarConexion,
    required this.alAbrirApi,
  });

  static final _modulos = [
    _DatosModulo(
      numero: '1',
      titulo: 'Conoce tu guitarra',
      descripcion: 'Fundamentos básicos para empezar',
      videoCount: 5,
      color: verde,
      thumb: 'https://img.youtube.com/vi/g6h2ztdqCc8/hqdefault.jpg',
      desbloqueado: true,
    ),
    _DatosModulo(
      numero: '2',
      titulo: 'Acordes básicos',
      descripcion: 'Aprende A, Am y D — tus primeros acordes',
      videoCount: 5,
      color: const Color(0xFF64B5F6),
      thumb: 'https://img.youtube.com/vi/g6h2ztdqCc8/hqdefault.jpg',
      desbloqueado: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Header con imagen
      Stack(children: [
        Image.asset('assets/fondo.png',
            width: double.infinity, height: 220, fit: BoxFit.cover),
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x55000000), Color(0xFF0A0A0F)],
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                const Spacer(),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PantallaAjustes(
                                alAbrirApiMonitor: alAbrirApi))),
                    child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.settings_rounded,
                            color: blanco, size: 20))),
                const SizedBox(width: 4),
                _PuntoCon(
                    online: online,
                    verificando: verificando,
                    alTocar: alVerificarConexion),
              ]),
            ),
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aprende guitarra',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: blanco)),
                      SizedBox(height: 4),
                      Text('Módulos de aprendizaje paso a paso',
                          style: TextStyle(fontSize: 13, color: medio)),
                    ]),
              ),
            ),
          ]),
        ),
      ]),
      Expanded(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          itemCount: _modulos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            final m = _modulos[i];
            return _TarjetaModulo(
              datos: m,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PantallaVideos())),
            );
          },
        ),
      ),
    ]);
  }
}

class _DatosModulo {
  final String numero;
  final String titulo;
  final String descripcion;
  final int videoCount;
  final Color color;
  final String thumb;
  final bool desbloqueado;

  const _DatosModulo({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.videoCount,
    required this.color,
    required this.thumb,
    this.desbloqueado = false,
  });
}

class _TarjetaModulo extends StatelessWidget {
  final _DatosModulo datos;
  final VoidCallback? onTap;

  const _TarjetaModulo({required this.datos, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: datos.desbloqueado ? onTap : null,
      child: AnimatedOpacity(
        opacity: datos.desbloqueado ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: datos.color.withValues(alpha: 0.2)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Thumbnail del primer video
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                Image.network(datos.thumb,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: tarjeta2,
                        child: Center(
                            child: Icon(Icons.music_note_rounded,
                                color: datos.color, size: 40)))),
                Container(
                    height: 160,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5)
                        ]))),
                Positioned(
                    bottom: 10,
                    left: 14,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: datos.color.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Módulo ${datos.numero}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: fondo,
                                fontWeight: FontWeight.w700)))),
                Positioned(
                    bottom: 10,
                    right: 14,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.play_circle_outline_rounded,
                              color: blanco, size: 12),
                          const SizedBox(width: 4),
                          Text('${datos.videoCount} video',
                              style:
                                  const TextStyle(fontSize: 11, color: blanco)),
                        ]))),
              ]),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(datos.titulo,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: blanco)),
                      const SizedBox(height: 4),
                      Text(datos.descripcion,
                          style: const TextStyle(fontSize: 12, color: medio)),
                    ])),
                datos.desbloqueado
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: datos.color.withValues(alpha: 0.12)),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: datos.color, size: 18))
                    : const Icon(Icons.lock_rounded, color: tenue, size: 20),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PuntoCon extends StatelessWidget {
  final bool online;
  final bool verificando;
  final VoidCallback alTocar;

  const _PuntoCon(
      {required this.online, required this.verificando, required this.alTocar});

  @override
  Widget build(BuildContext context) {
    final color = verificando
        ? ambar
        : online
            ? verde
            : rojo;
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
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)
            ]),
      ),
    );
  }
}
