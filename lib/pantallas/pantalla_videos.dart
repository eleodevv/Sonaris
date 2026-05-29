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
  final bool esShort;

  const VideoModulo({
    required this.titulo,
    required this.subtitulo,
    required this.youtubeId,
    required this.duracion,
    required this.descripcion,
    required this.aprenderas,
    required this.instructor,
    required this.rolInstructor,
    this.esShort = false,
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
    titulo: 'Conociendo tu guitarra',
    subtitulo: 'Módulo 1 · Video 1',
    youtubeId: 'X0v4aT96rXM',
    duracion: 'Short',
    descripcion:
        'Descubre qué es la guitarra, para qué sirve y por qué es uno de los instrumentos más populares del mundo.',
    aprenderas: [
      'Qué es la guitarra y sus tipos principales',
      'Para qué sirve aprender a tocarla',
      'Motivación y mentalidad para empezar'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Cómo colocarse la guitarra',
    subtitulo: 'Módulo 1 · Video 2',
    youtubeId: '6Qo2FK-IudU',
    duracion: 'Short',
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
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Cómo afinar mi guitarra',
    subtitulo: 'Módulo 1 · Video 3',
    youtubeId: 'S9ryVINTbLo',
    duracion: 'Short',
    descripcion:
        'Aprende a afinar tu guitarra correctamente usando un afinador o de oído para que siempre suene bien.',
    aprenderas: [
      'Cómo usar un afinador digital',
      'Nombres y notas de cada cuerda',
      'Técnica para girar las clavijas correctamente',
      'Verificar la afinación de oído'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
];

// ── Contenido del Módulo 2: Acordes básicos ───────────────

final _itemsModulo2 = [
  const ItemModulo.video(VideoModulo(
    titulo: 'Acorde DO (C)',
    subtitulo: 'Módulo 2 · Video 1',
    youtubeId: 'xFMDVSPvzr8',
    duracion: 'Short',
    descripcion:
        'Aprende a tocar el acorde de DO Mayor (C), con forma diagonal en el diapasón.',
    aprenderas: [
      'Posición de los dedos para el acorde C',
      'Forma diagonal en trastes 1, 2 y 3',
      'Cuerdas que suenan y cuáles no',
      'Consejos para que suene limpio'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Acorde LA (A)',
    subtitulo: 'Módulo 2 · Video 2',
    youtubeId: 'dH5TwByFSTE',
    duracion: 'Short',
    descripcion:
        'Aprende a tocar el acorde de LA Mayor (A), uno de los acordes más usados en guitarra.',
    aprenderas: [
      'Posición de los dedos para el acorde A',
      'Cuerdas que se tocan y cuáles no',
      'Consejos para que suene limpio',
      'Ejercicio de cambio de acorde'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Acorde RE (D)',
    subtitulo: 'Módulo 2 · Video 3',
    youtubeId: 'uBwDPGuVia8',
    duracion: 'Short',
    descripcion:
        'Aprende a tocar el acorde de RE Mayor (D), con forma de triángulo en los trastes 2 y 3.',
    aprenderas: [
      'Posición de los dedos para el acorde D',
      'Solo se tocan 4 cuerdas (D-G-B-e)',
      'Forma de triángulo en el diapasón',
      'Transición entre A y D'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Acorde MI Mayor (E)',
    subtitulo: 'Módulo 2 · Video 4',
    youtubeId: 'cUF3pDTZVcc',
    duracion: 'Short',
    descripcion:
        'Aprende a tocar el acorde de MI Mayor (E), donde todas las cuerdas suenan.',
    aprenderas: [
      'Posición de los dedos para el acorde E',
      'Todas las cuerdas suenan en este acorde',
      'Colocación en trastes 1 y 2',
      'Transición entre D y E'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
  const ItemModulo.video(VideoModulo(
    titulo: 'Acorde SOL (G)',
    subtitulo: 'Módulo 2 · Video 5',
    youtubeId: 'fHBCjd8uNJ4',
    duracion: 'Short',
    descripcion:
        'Aprende a tocar el acorde de SOL Mayor (G), con los dedos en los extremos del mástil.',
    aprenderas: [
      'Posición de los dedos para el acorde G',
      'Todas las cuerdas suenan',
      'Estiramiento de dedos en el diapasón',
      'Transición entre E y G'
    ],
    instructor: 'Sonaris Team',
    rolInstructor: 'Equipo de instructores de guitarra',
    esShort: true,
  )),
];

// ── Pantalla principal ────────────────────────────────────

class PantallaVideos extends StatefulWidget {
  final int modulo;
  const PantallaVideos({super.key, this.modulo = 1});
  @override
  State<PantallaVideos> createState() => _EstadoPantallaVideos();
}

class _EstadoPantallaVideos extends State<PantallaVideos>
    with SingleTickerProviderStateMixin {
  Set<String> _completados = {};
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  List<ItemModulo> get _items =>
      widget.modulo == 2 ? _itemsModulo2 : _itemsModulo1;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _cargarProgreso();
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('videos_completados') ?? [];
    if (mounted) setState(() => _completados = lista.toSet());
  }

  Future<void> _marcarCompletado(String youtubeId) async {
    final prefs = await SharedPreferences.getInstance();
    _completados.add(youtubeId);
    await prefs.setStringList('videos_completados', _completados.toList());
    if (mounted) setState(() {});
  }

  bool _estaDesbloqueado(int indice) {
    if (indice == 0) return true;
    final videos = _items.where((i) => i.esVideo).toList();
    return _completados.contains(videos[indice - 1].video!.youtubeId);
  }

  @override
  Widget build(BuildContext context) {
    final videos = _items.where((i) => i.esVideo).toList();
    final totalVideos = videos.length;
    final completados = _completados.length.clamp(0, totalVideos);
    final progreso = totalVideos > 0 ? completados / totalVideos : 0.0;

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: Column(children: [
          // ── Header mejorado con imagen de fondo ──
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Stack(children: [
                Image.asset(
                  'assets/fondo.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x88000000), Color(0xFF080808)],
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
                              color: blanco, size: 18),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: verde.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: verde.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'MÓDULO ${widget.modulo}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: verde,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.modulo == 2
                                  ? 'Acordes básicos'
                                  : 'Fundamentos',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: blanco,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          // ── Barra de progreso ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.play_circle_outline_rounded,
                      color: medio, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '$completados/$totalVideos completados',
                    style: const TextStyle(fontSize: 12, color: medio),
                  ),
                  const Spacer(),
                  Text(
                    '${(progreso * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 12,
                        color: verde,
                        fontWeight: FontWeight.w600),
                  ),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progreso),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => LinearProgressIndicator(
                      value: value,
                      minHeight: 5,
                      backgroundColor: tenue.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(verde),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Lista de videos ──
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
                  indice: i,
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

// ── Tarjeta del video con animaciones ────────────────────

class _TarjetaVideo extends StatefulWidget {
  final VideoModulo video;
  final bool desbloqueado;
  final bool completado;
  final int indice;
  final VoidCallback alCompletar;

  const _TarjetaVideo({
    required this.video,
    required this.desbloqueado,
    required this.completado,
    required this.indice,
    required this.alCompletar,
  });

  @override
  State<_TarjetaVideo> createState() => _EstadoTarjetaVideo();
}

class _EstadoTarjetaVideo extends State<_TarjetaVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _entradaCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  double _escala = 1.0;

  @override
  void initState() {
    super.initState();
    _entradaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOutCubic));

    // Staggered delay: index * 100ms
    Future.delayed(Duration(milliseconds: widget.indice * 100), () {
      if (mounted) _entradaCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entradaCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.desbloqueado) return;
    setState(() => _escala = 0.97);
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.desbloqueado) return;
    setState(() => _escala = 1.0);
  }

  void _onTapCancel() {
    setState(() => _escala = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final thumb =
        'https://img.youtube.com/vi/${widget.video.youtubeId}/hqdefault.jpg';

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.desbloqueado
              ? () {
                  setState(() => _escala = 1.0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaDetalleVideo(
                        video: widget.video,
                        alCompletar: widget.alCompletar,
                      ),
                    ),
                  );
                }
              : null,
          child: AnimatedScale(
            scale: _escala,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: widget.desbloqueado ? 1.0 : 0.55,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: tarjeta,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.completado
                        ? verde.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Thumbnail ──
                    Stack(children: [
                      Hero(
                        tag: 'video_thumb_${widget.video.youtubeId}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: ColorFiltered(
                            colorFilter: widget.desbloqueado
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
                            child: Image.network(
                              thumb,
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 190,
                                color: tarjeta2,
                                child: const Center(
                                  child: Icon(Icons.play_circle_outline_rounded,
                                      color: medio, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradiente inferior
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Icono central (play / lock / check)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.desbloqueado
                                  ? verde.withValues(alpha: 0.95)
                                  : Colors.black.withValues(alpha: 0.65),
                              border: widget.desbloqueado
                                  ? null
                                  : Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.25)),
                              boxShadow: widget.desbloqueado
                                  ? [
                                      BoxShadow(
                                        color: verde.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              widget.desbloqueado
                                  ? (widget.completado
                                      ? Icons.check_rounded
                                      : Icons.play_arrow_rounded)
                                  : Icons.lock_rounded,
                              color: widget.desbloqueado ? fondo : blanco,
                              size: widget.desbloqueado ? 34 : 26,
                            ),
                          ),
                        ),
                      ),
                      // Overlay verde completado
                      if (widget.completado)
                        Positioned(
                          top: 10,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: verde.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded,
                                    color: blanco, size: 11),
                                SizedBox(width: 4),
                                Text('Completado',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: blanco,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      // Badge "Short" con estilo pill morado
                      if (widget.video.esShort)
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: morado,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: morado.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: blanco, size: 12),
                                SizedBox(width: 3),
                                Text('Short',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: blanco,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        )
                      else if (widget.video.duracion.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(widget.video.duracion,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: blanco,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                    ]),
                    // ── Info ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.subtitulo,
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.desbloqueado ? verde : medio,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.video.titulo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: widget.desbloqueado ? blanco : medio,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: verde.withValues(alpha: 0.12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image.asset('assets/logo_sonaris.png',
                                    fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.video.instructor,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: blanco,
                                        fontWeight: FontWeight.w500)),
                                Text(widget.video.rolInstructor,
                                    style: const TextStyle(
                                        fontSize: 11, color: medio)),
                              ],
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pantalla de detalle ───────────────────────────────────

class PantallaDetalleVideo extends StatefulWidget {
  final VideoModulo video;
  final VoidCallback alCompletar;

  const PantallaDetalleVideo({
    super.key,
    required this.video,
    required this.alCompletar,
  });

  @override
  State<PantallaDetalleVideo> createState() => _EstadoPantallaDetalleVideo();
}

class _EstadoPantallaDetalleVideo extends State<PantallaDetalleVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  // Sections: 0=title, 1=instructor, 2=description, 3=aprenderas, 4=button
  static const int _secciones = 5;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fades = List.generate(_secciones, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slides = List.generate(_secciones, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animado(int index, Widget child) => FadeTransition(
        opacity: _fades[index],
        child: SlideTransition(position: _slides[index], child: child),
      );

  @override
  Widget build(BuildContext context) {
    final thumb =
        'https://img.youtube.com/vi/${widget.video.youtubeId}/hqdefault.jpg';

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Scaffold(
        backgroundColor: fondo,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero thumbnail ──
              Stack(children: [
                Hero(
                  tag: 'video_thumb_${widget.video.youtubeId}',
                  child: Image.network(
                    thumb,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 220, color: tarjeta2),
                  ),
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: blanco, size: 18),
                      ),
                    ]),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sección 0: Título ──
                    _animado(
                      0,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(widget.video.subtitulo,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: medio,
                                    letterSpacing: 1)),
                            const Spacer(),
                            if (widget.video.esShort)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: morado,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: morado.withValues(alpha: 0.45),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded,
                                        color: blanco, size: 12),
                                    SizedBox(width: 3),
                                    Text('Short',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: blanco,
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              )
                            else if (widget.video.duracion.isNotEmpty) ...[
                              const Icon(Icons.access_time_rounded,
                                  color: medio, size: 13),
                              const SizedBox(width: 4),
                              Text(widget.video.duracion,
                                  style: const TextStyle(
                                      fontSize: 11, color: medio)),
                            ],
                          ]),
                          const SizedBox(height: 8),
                          Text(widget.video.titulo,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: blanco,
                                  height: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Sección 1: Instructor ──
                    _animado(
                      1,
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: tarjeta,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: verde.withValues(alpha: 0.2)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: verde.withValues(alpha: 0.15),
                              border: Border.all(
                                  color: verde.withValues(alpha: 0.35)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset('assets/logo_sonaris.png',
                                  fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.video.instructor,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: blanco)),
                              Text(widget.video.rolInstructor,
                                  style: const TextStyle(
                                      fontSize: 11, color: verde)),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Sección 2: Descripción ──
                    _animado(
                      2,
                      Text(widget.video.descripcion,
                          style: const TextStyle(
                              fontSize: 14, color: medio, height: 1.6)),
                    ),
                    const SizedBox(height: 20),
                    // ── Sección 3: Lo que aprenderás ──
                    _animado(
                      3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lo que aprenderás',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: blanco)),
                          const SizedBox(height: 12),
                          ...widget.video.aprenderas
                              .asMap()
                              .entries
                              .map((entry) => _ItemAprenderas(
                                    texto: entry.value,
                                    indice: entry.key,
                                  )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Sección 4: Botón reproducir ──
                    _animado(
                      4,
                      _BotonReproducir(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _PantallaReproductor(
                              video: widget.video,
                              alCompletar: widget.alCompletar,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item animado de "Lo que aprenderás" ──────────────────

class _ItemAprenderas extends StatefulWidget {
  final String texto;
  final int indice;
  const _ItemAprenderas({required this.texto, required this.indice});

  @override
  State<_ItemAprenderas> createState() => _EstadoItemAprenderas();
}

class _EstadoItemAprenderas extends State<_ItemAprenderas>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 300 + widget.indice * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: verde, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.texto,
                    style: const TextStyle(
                        fontSize: 13, color: blanco, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Botón "Reproducir video" con glow morado ─────────────

class _BotonReproducir extends StatefulWidget {
  final VoidCallback onTap;
  const _BotonReproducir({required this.onTap});

  @override
  State<_BotonReproducir> createState() => _EstadoBotonReproducir();
}

class _EstadoBotonReproducir extends State<_BotonReproducir> {
  double _escala = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _escala = 0.97),
      onTapUp: (_) {
        setState(() => _escala = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _escala = 1.0),
      child: AnimatedScale(
        scale: _escala,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: morado,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: morado.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: blanco, size: 22),
              SizedBox(width: 8),
              Text('Reproducir video',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
            ],
          ),
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
    if (widget.video.esShort) {
      return _ReproductorShort(ctrl: _ctrl, video: widget.video);
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ctrl,
        showVideoProgressIndicator: true,
        progressIndicatorColor: verde,
      ),
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
                      color: medio, size: 18),
                ),
                Expanded(
                  child: Text(widget.video.titulo,
                      style: const TextStyle(
                          fontSize: 14,
                          color: blanco,
                          fontWeight: FontWeight.w300),
                      overflow: TextOverflow.ellipsis),
                ),
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

// ── Reproductor Short (formato vertical TikTok) ───────────

class _ReproductorShort extends StatelessWidget {
  final YoutubePlayerController ctrl;
  final VideoModulo video;
  const _ReproductorShort({required this.ctrl, required this.video});

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: ctrl,
        showVideoProgressIndicator: true,
        progressIndicatorColor: verde,
        progressColors: const ProgressBarColors(
          playedColor: verde,
          handleColor: verde,
        ),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [
          // Video a pantalla completa vertical
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: player,
            ),
          ),

          // Overlay superior con gradiente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Overlay inferior con gradiente
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    ctrl.pause();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: blanco, size: 16),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: morado,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: morado.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bolt_rounded, color: blanco, size: 14),
                    SizedBox(width: 4),
                    Text('Short',
                        style: TextStyle(
                            color: blanco,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
          ),

          // Info inferior tipo TikTok
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 72, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: verde.withValues(alpha: 0.2),
                          border:
                              Border.all(color: verde.withValues(alpha: 0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset('assets/logo_sonaris.png',
                              fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Sonaris Team',
                          style: TextStyle(
                              color: blanco,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: verde,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Seguir',
                            style: TextStyle(
                                color: blanco,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(video.titulo,
                        style: const TextStyle(
                          color: blanco,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        )),
                    const SizedBox(height: 6),
                    Text(video.subtitulo,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ),

          // Botones laterales tipo TikTok
          Positioned(
            right: 12,
            bottom: 100,
            child: SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _BotonLateral(icono: Icons.favorite_rounded, label: 'Me gusta'),
                const SizedBox(height: 20),
                _BotonLateral(icono: Icons.share_rounded, label: 'Compartir'),
                const SizedBox(height: 20),
                _BotonLateral(icono: Icons.bookmark_rounded, label: 'Guardar'),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BotonLateral extends StatelessWidget {
  final IconData icono;
  final String label;
  const _BotonLateral({required this.icono, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icono, color: blanco, size: 24),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500)),
    ]);
  }
}
