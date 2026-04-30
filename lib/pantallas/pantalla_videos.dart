import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constantes/colores.dart';

// ── Modelos ───────────────────────────────────────────────

class VideoModulo {
  final String titulo;
  final String subtitulo;
  final String youtubeId;
  final String duracion;
  final String descripcion;
  final List<String> aprenderas;
  final String instructor;
  final String rolInstructor;

  const VideoModulo({
    required this.titulo,
    required this.subtitulo,
    required this.youtubeId,
    required this.duracion,
    required this.descripcion,
    required this.aprenderas,
    required this.instructor,
    required this.rolInstructor,
  });
}

class TarjetaTeoria {
  final String titulo;
  final String contenido;
  final IconData icono;
  final List<String> puntos;
  const TarjetaTeoria({
    required this.titulo,
    required this.contenido,
    required this.icono,
    this.puntos = const [],
  });
}

class ItemModulo {
  final VideoModulo? video;
  final TarjetaTeoria? teoria;
  const ItemModulo.video(this.video) : teoria = null;
  const ItemModulo.teoria(this.teoria) : video = null;
  bool get esVideo => video != null;
}

// ── Contenido del Módulo 1 ────────────────────────────────

final _itemsModulo1 = [
  const ItemModulo.video(VideoModulo(
    titulo: '¿Qué es la guitarra y cómo se usa?',
    subtitulo: 'Módulo 1 · Video 1',
    youtubeId: 'g6h2ztdqCc8',
    duracion: '5 min',
    descripcion:
        'Descubre qué es la guitarra, para qué sirve y por qué es uno de los instrumentos más populares del mundo.',
    aprenderas: [
      'Qué es la guitarra y sus tipos principales',
      'Para qué sirve aprender a tocarla',
      'Motivación y mentalidad para empezar'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Partes de la guitarra',
    subtitulo: 'Módulo 1 · Video 2',
    youtubeId: 'QQQzzLrC95c',
    duracion: '',
    descripcion:
        'Conoce cada parte de tu guitarra: cabeza, clavijas, mástil, trastes, cuerdas, caja y puente.',
    aprenderas: [
      'Identificar la cabeza y las clavijas',
      'Conocer el mástil y los trastes',
      'Entender la importancia de las cuerdas',
      'Reconocer la caja y el puente'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Cómo sostener la guitarra correctamente',
    subtitulo: 'Módulo 1 · Video 3',
    youtubeId: '44xkDPJdW2Q',
    duracion: '',
    descripcion:
        'Aprende la postura correcta para tocar guitarra sentado, la posición de ambas manos y los errores más comunes a evitar.',
    aprenderas: [
      'Posición correcta sentado',
      'Cómo colocar la mano izquierda en el diapasón',
      'Posición de la mano derecha para rasguear',
      'Errores comunes que debes evitar'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Las cuerdas y cómo se afinan',
    subtitulo: 'Módulo 1 · Video 4',
    youtubeId: 'p2i9tyWpqDA',
    duracion: '',
    descripcion:
        'Aprende los nombres de las 6 cuerdas de la guitarra y cómo afinarlas correctamente antes de tocar.',
    aprenderas: [
      'Nombres de las 6 cuerdas: Mi, La, Re, Sol, Si, Mi',
      'Cómo usar un afinador',
      'Por qué es importante afinar antes de practicar'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Tu primer sonido (antes de acordes)',
    subtitulo: 'Módulo 1 · Video 5',
    youtubeId: 'l3YyTCqwIn0',
    duracion: '',
    descripcion:
        'Antes de aprender acordes, practica tu primer rasgueo, toca cuerdas al aire y siente el ritmo básico.',
    aprenderas: [
      'Rasgueo básico hacia abajo',
      'Tocar cuerdas al aire',
      'Ritmo simple para principiantes'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
  )),
];

// ── Pantalla principal ────────────────────────────────────

class PantallaVideos extends StatefulWidget {
  const PantallaVideos({super.key});
  @override
  State<PantallaVideos> createState() => _EstadoPantallaVideos();
}

class _EstadoPantallaVideos extends State<PantallaVideos> {
  Set<String> _completados = {};

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('videos_completados') ?? [];
    setState(() => _completados = lista.toSet());
  }

  Future<void> _marcarCompletado(String youtubeId) async {
    final prefs = await SharedPreferences.getInstance();
    _completados.add(youtubeId);
    await prefs.setStringList('videos_completados', _completados.toList());
    setState(() {});
  }

  bool _estaDesbloqueado(int indice) {
    if (indice == 0) return true;
    final videos = _itemsModulo1.where((i) => i.esVideo).toList();
    return _completados.contains(videos[indice - 1].video!.youtubeId);
  }

  @override
  Widget build(BuildContext context) {
    final videos = _itemsModulo1.where((i) => i.esVideo).toList();
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: Column(children: [
          // Header
          Stack(children: [
            Container(
              height: 130,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1040), Color(0xFF0A0A0F)],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: blanco, size: 18)),
                    ]),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MÓDULO 1',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: verde,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Conoce tu guitarra',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: blanco)),
                          ]),
                    ),
                  ]),
            ),
          ]),
          // Contador
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(children: [
              const Icon(Icons.play_circle_outline_rounded,
                  color: medio, size: 14),
              const SizedBox(width: 6),
              Text('${_completados.length}/${videos.length} completados',
                  style: const TextStyle(fontSize: 12, color: medio)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final video = videos[i].video!;
                final desbloqueado = _estaDesbloqueado(i);
                final completado = _completados.contains(video.youtubeId);
                return _TarjetaVideo(
                  video: video,
                  desbloqueado: desbloqueado,
                  completado: completado,
                  alCompletar: () => _marcarCompletado(video.youtubeId),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Tarjeta del video ─────────────────────────────────────

class _TarjetaVideo extends StatelessWidget {
  final VideoModulo video;
  final bool desbloqueado;
  final bool completado;
  final VoidCallback alCompletar;

  const _TarjetaVideo({
    required this.video,
    required this.desbloqueado,
    required this.completado,
    required this.alCompletar,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = 'https://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg';
    return GestureDetector(
      onTap: desbloqueado
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PantallaDetalleVideo(
                      video: video, alCompletar: alCompletar)))
          : null,
      child: AnimatedOpacity(
        opacity: desbloqueado ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: completado
                    ? verde.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Thumbnail
            Stack(children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: ColorFiltered(
                  colorFilter: desbloqueado
                      ? const ColorFilter.mode(
                          Colors.transparent, BlendMode.saturation)
                      : const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                  child: Image.network(thumb,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 190,
                          color: tarjeta2,
                          child: const Center(
                              child: Icon(Icons.play_circle_outline_rounded,
                                  color: medio, size: 48)))),
                ),
              ),
              // Gradiente
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent
                          ])),
                ),
              ),
              // Icono central
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: desbloqueado
                          ? (completado
                              ? verde.withValues(alpha: 0.9)
                              : verde.withValues(alpha: 0.95))
                          : Colors.black.withValues(alpha: 0.65),
                      border: desbloqueado
                          ? null
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.25)),
                      boxShadow: desbloqueado
                          ? [
                              BoxShadow(
                                  color: verde.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2)
                            ]
                          : [],
                    ),
                    child: Icon(
                        desbloqueado
                            ? (completado
                                ? Icons.check_rounded
                                : Icons.play_arrow_rounded)
                            : Icons.lock_rounded,
                        color: desbloqueado ? fondo : blanco,
                        size: desbloqueado ? 34 : 26),
                  ),
                ),
              ),
              // Duración
              if (video.duracion.isNotEmpty)
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(video.duracion,
                        style: const TextStyle(
                            fontSize: 11,
                            color: blanco,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
            ]),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(video.subtitulo,
                        style: TextStyle(
                            fontSize: 10,
                            color: desbloqueado ? verde : medio,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(video.titulo,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: desbloqueado ? blanco : medio,
                            height: 1.3)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: verde.withValues(alpha: 0.12)),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset('assets/logo_sonaris.png',
                                fit: BoxFit.contain),
                          )),
                      const SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.instructor,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: blanco,
                                    fontWeight: FontWeight.w500)),
                            Text(video.rolInstructor,
                                style: const TextStyle(
                                    fontSize: 11, color: medio)),
                          ]),
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Pantalla de detalle ───────────────────────────────────

class PantallaDetalleVideo extends StatelessWidget {
  final VideoModulo video;
  final VoidCallback alCompletar;

  const PantallaDetalleVideo({
    super.key,
    required this.video,
    required this.alCompletar,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = 'https://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg';
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              Image.network(thumb,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 220, color: tarjeta2)),
              Container(
                height: 220,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent
                    ])),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: blanco, size: 18)),
                  ]),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(video.subtitulo,
                          style: const TextStyle(
                              fontSize: 11, color: medio, letterSpacing: 1)),
                      const Spacer(),
                      if (video.duracion.isNotEmpty) ...[
                        const Icon(Icons.access_time_rounded,
                            color: medio, size: 13),
                        const SizedBox(width: 4),
                        Text(video.duracion,
                            style: const TextStyle(fontSize: 11, color: medio)),
                      ],
                    ]),
                    const SizedBox(height: 8),
                    Text(video.titulo,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: blanco,
                            height: 1.2)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: tarjeta,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: verde.withValues(alpha: 0.15)),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset('assets/logo_sonaris.png',
                                  fit: BoxFit.contain),
                            )),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(video.instructor,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: blanco)),
                              Text(video.rolInstructor,
                                  style: const TextStyle(
                                      fontSize: 11, color: medio)),
                            ]),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Text(video.descripcion,
                        style: const TextStyle(
                            fontSize: 14, color: medio, height: 1.6)),
                    const SizedBox(height: 20),
                    const Text('Lo que aprenderás',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: blanco)),
                    const SizedBox(height: 12),
                    ...video.aprenderas.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: verde, size: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(item,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: blanco,
                                            height: 1.4))),
                              ]),
                        )),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _PantallaReproductor(
                                  video: video, alCompletar: alCompletar))),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: verde,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: fondo, size: 22),
                              SizedBox(width: 8),
                              Text('Reproducir video',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: fondo)),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Reproductor ───────────────────────────────────────────

class _PantallaReproductor extends StatefulWidget {
  final VideoModulo video;
  final VoidCallback alCompletar;
  const _PantallaReproductor({required this.video, required this.alCompletar});

  @override
  State<_PantallaReproductor> createState() => _EstadoReproductor();
}

class _EstadoReproductor extends State<_PantallaReproductor> {
  late YoutubePlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
    _ctrl.addListener(_escucharEstado);
  }

  void _escucharEstado() {
    if (_ctrl.value.playerState == PlayerState.ended) {
      widget.alCompletar();
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_escucharEstado);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
          controller: _ctrl,
          showVideoProgressIndicator: true,
          progressIndicatorColor: verde),
      builder: (context, player) => Scaffold(
        backgroundColor: fondo,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      _ctrl.pause();
                      SystemChrome.setPreferredOrientations(
                          [DeviceOrientation.portraitUp]);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: medio, size: 18)),
                Expanded(
                    child: Text(widget.video.titulo,
                        style: const TextStyle(
                            fontSize: 14,
                            color: blanco,
                            fontWeight: FontWeight.w300),
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
            const SizedBox(height: 12),
            player,
          ]),
        ),
      ),
    );
  }
}
