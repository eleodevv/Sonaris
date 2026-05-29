import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../services/api_service.dart';
import '../services/turso_service.dart';
import '../services/sesion_service.dart';
import '../services/audio_service.dart';
import 'splash.dart';
import 'lista_acordes.dart';
import 'practica.dart';
import 'api_monitor.dart';
import 'recursos.dart';
import 'modo_libre.dart';
import '../widgets/asistente_ia.dart';

/// Pantalla raíz que maneja la navegación y el estado global
class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _EstadoHome();
}

class _EstadoHome extends State<PantallaHome> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();

  // 0=splash 1=acordes 2=practica 3=api
  int _pagina = 0;
  String? _acorde;
  bool _grabando = false;
  bool _procesando = false;
  int _progreso = 0;
  Timer? _temporizador;
  Map<String, dynamic>? _resultado;

  // Conexión
  bool _online = false;
  bool _verificando = false;

  // API Monitor
  final List<Map<String, dynamic>> _historialPings = [];
  Timer? _timerPing;

  late AnimationController _navCtrl;
  late Animation<Offset> _navSlide;
  late AnimationController _pulsoCtrl;
  late Animation<double> _pulsoAnim;
  late AnimationController _paginaCtrl;
  late Animation<double> _paginaFade;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _navSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeOutCubic));
    _pulsoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulsoAnim = Tween(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulsoCtrl, curve: Curves.easeInOut));
    _paginaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _paginaFade = CurvedAnimation(parent: _paginaCtrl, curve: Curves.easeOut);
    _paginaCtrl.forward();
    _verificarServidor();
  }

  @override
  void dispose() {
    _audio.dispose();
    _temporizador?.cancel();
    _timerPing?.cancel();
    _navCtrl.dispose();
    _pulsoCtrl.dispose();
    _paginaCtrl.dispose();
    super.dispose();
  }

  // ── Navegación ────────────────────────────────────────────
  void _irA(int pagina) {
    HapticFeedback.lightImpact();
    if (pagina == 3) {
      _iniciarMonitorPing();
    } else {
      _timerPing?.cancel();
    }
    setState(() {
      _pagina = pagina;
      _resultado = null;
    });
    _paginaCtrl.reset();
    _paginaCtrl.forward();
    if (pagina != 0) _navCtrl.forward();
  }

  void _seleccionarAcorde(String a) {
    setState(() {
      _acorde = a;
      _resultado = null;
    });
    _irA(2);
  }

  // ── Conexión ──────────────────────────────────────────────
  Future<void> _verificarServidor() async {
    setState(() => _verificando = true);
    final ok = await context.read<ApiService>().checkHealth();
    if (mounted) {
      setState(() {
        _online = ok;
        _verificando = false;
      });
    }
  }

  // ── Monitor de API ────────────────────────────────────────
  void _iniciarMonitorPing() {
    _timerPing?.cancel();
    _hacerPing();
    _timerPing =
        Timer.periodic(const Duration(seconds: 10), (_) => _hacerPing());
  }

  Future<void> _hacerPing() async {
    final t0 = DateTime.now();
    final ok = await context.read<ApiService>().checkHealth();
    final ms = DateTime.now().difference(t0).inMilliseconds;
    if (!mounted) return;
    setState(() {
      _online = ok;
      _historialPings.insert(0, {'ok': ok, 'ms': ms, 'time': DateTime.now()});
      if (_historialPings.length > 20) _historialPings.removeLast();
    });
  }

  // ── Grabación ─────────────────────────────────────────────
  Future<void> _iniciarGrabacion() async {
    if (_acorde == null) {
      _mostrarMensaje('Selecciona un acorde primero');
      return;
    }
    final ok = await _audio.startRecording();
    if (!ok) {
      _mostrarMensaje('Sin permiso de micrófono');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _grabando = true;
      _progreso = 0;
      _resultado = null;
    });
    _temporizador = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _progreso++);
      if (_progreso >= 50) {
        t.cancel();
        _detenerGrabacion();
      }
    });
  }

  Future<void> _detenerGrabacion() async {
    _temporizador?.cancel();
    HapticFeedback.mediumImpact();
    final ruta = await _audio.stopRecording();
    setState(() {
      _grabando = false;
      _progreso = 0;
    });
    if (ruta != null) await _procesarAudio(ruta);
  }

  Future<void> _procesarAudio(String ruta) async {
    if (_acorde == null) return;
    setState(() => _procesando = true);
    try {
      final r = await context.read<ApiService>().clasificarAcorde(ruta);
      final predicho = r['acorde_predicho'] as String? ?? '';
      final confianza = (r['confianza'] as num?)?.toDouble() ?? 0.0;
      final correcto = predicho.toUpperCase() == _acorde!.toUpperCase();
      setState(() => _resultado = {
            'es_correcto': correcto,
            'acorde_predicho': predicho,
            'confianza': confianza,
            'top5': r['top5'] ?? [],
          });
      HapticFeedback.heavyImpact();
      // Guardar intento en Turso con el usuario logueado
      final uid = context.read<SesionService>().usuarioId ?? 1;
      context
          .read<TursoService>()
          .registrarIntento(
            usuarioId: uid,
            acorde: _acorde!,
            correcto: correcto,
            confianza: confianza,
          )
          .catchError((_) {});
    } on TimeoutException {
      _mostrarMensaje('Tiempo de espera agotado.');
    } catch (e) {
      _mostrarMensaje(e.toString().contains('SocketException')
          ? 'Sin conexión a la API.'
          : 'Error al analizar.');
    } finally {
      setState(() => _procesando = false);
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: blanco, fontSize: 13)),
      backgroundColor: tarjeta2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: Stack(children: [
        FadeTransition(opacity: _paginaFade, child: _construirPagina()),
        if (_pagina != 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child:
                SlideTransition(position: _navSlide, child: _construirNavBar()),
          ),
        // Botón flotante IA
        if (_pagina != 0)
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 90,
            child: const BotonAsistenteIA(),
          ),
      ]),
    );
  }

  Widget _construirPagina() {
    switch (_pagina) {
      case 0:
        return PantallaSplash(alComenzar: () => _irA(1));
      case 1:
        return PantallaListaAcordes(
          online: _online,
          verificando: _verificando,
          alSeleccionar: _seleccionarAcorde,
          alVerificarConexion: _verificarServidor,
          alAbrirApi: () => _irA(3),
        );
      case 2:
        return _construirPractica();
      case 3:
        return PantallaApiMonitor(
          online: _online,
          verificando: _verificando,
          historialPings: _historialPings,
          alHacerPing: _hacerPing,
        );
      case 4:
        return const PantallaRecursos();
      default:
        return PantallaSplash(alComenzar: () => _irA(1));
    }
  }

  // ── Pantalla de práctica ──────────────────────────────────
  Widget _construirPractica() {
    return Column(children: [
      // Header con imagen de fondo estilo lista_acordes
      Stack(children: [
        Image.asset('assets/onboarding2.png',
            width: double.infinity, height: 180, fit: BoxFit.cover),
        Container(
          height: 180,
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
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _irA(1),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: blanco, size: 18),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final r = acordes[Random().nextInt(acordes.length)];
                    setState(() {
                      _acorde = r;
                      _resultado = null;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shuffle_rounded, color: blanco, size: 13),
                      SizedBox(width: 5),
                      Text('Aleatorio',
                          style: TextStyle(fontSize: 11, color: blanco)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                // Indicador conexión
                GestureDetector(
                  onTap: _verificarServidor,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _verificando
                          ? ambar
                          : _online
                              ? verde
                              : rojo,
                      boxShadow: [
                        BoxShadow(
                            color: (_verificando
                                    ? ambar
                                    : _online
                                        ? verde
                                        : rojo)
                                .withValues(alpha: 0.6),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Practicar acordes',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: blanco)),
                          SizedBox(height: 4),
                          Text('Selecciona un acorde para practicar',
                              style: TextStyle(fontSize: 13, color: medio)),
                        ]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaModoLibre())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: verde.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: verde.withValues(alpha: 0.4)),
                      ),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.graphic_eq_rounded, color: verde, size: 14),
                        SizedBox(width: 5),
                        Text('Modo libre',
                            style: TextStyle(
                                fontSize: 11,
                                color: verde,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
      // Estado de grabación (solo cuando graba o procesa)
      if (_grabando || _procesando)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: fondo,
          child: Column(children: [
            Text(
              _procesando ? 'Analizando...' : 'ESCUCHANDO...',
              style: const TextStyle(
                fontSize: 11,
                color: blanco,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (_grabando) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _progreso / 50,
                  minHeight: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: const AlwaysStoppedAnimation(verde),
                ),
              ),
            ],
          ]),
        ),
      Expanded(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(children: [
            SelectorAcordes(
              seleccionado: _acorde,
              alSeleccionar: (a) {
                setState(() {
                  _acorde = a;
                  _resultado = null;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _PantallaDetalleAcorde(
                      acorde: a,
                      online: _online,
                      onGrabar: () {
                        if (_procesando) return;
                        _grabando ? _detenerGrabacion() : _iniciarGrabacion();
                      },
                      grabando: _grabando,
                      procesando: _procesando,
                      progreso: _progreso,
                      resultado: _resultado,
                    ),
                  ),
                );
              },
            ),
            if (_acorde != null) ...[
              const SizedBox(height: 20),
              TarjetaAcorde(acorde: _acorde!),
            ],
            if (_resultado != null) ...[
              const SizedBox(height: 14),
              TarjetaResultado(resultado: _resultado!),
            ],
            const SizedBox(height: 100),
          ]),
        ),
      ),
    ]);
  }

  // ── Nav bar flotante tipo pill ────────────────────────────
  Widget _construirNavBar() {
    final enPractica = _pagina == 2;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0F).withValues(alpha: 0.75),
            border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            top: 8,
          ),
          child: Row(children: [
            Expanded(child: _itemNav(1, Icons.school_rounded, 'Aprende')),
            // Botón central mic con Skia
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!enPractica) {
                  _irA(2);
                  return;
                }
                if (_procesando) return;
                _grabando ? _detenerGrabacion() : _iniciarGrabacion();
              },
              child: ScaleTransition(
                scale:
                    _grabando ? _pulsoAnim : const AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: _MicButtonPainter(
                      activo: enPractica,
                      grabando: _grabando,
                    ),
                    child: Center(
                      child: _procesando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: ambar))
                          : Icon(
                              _grabando
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: enPractica || _grabando ? blanco : medio,
                              size: 26),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child: _itemNav(4, Icons.library_books_rounded, 'Recursos')),
          ]),
        ),
      ),
    );
  }

  Widget _itemNav(int idx, IconData icono, String etiqueta) {
    final sel = _pagina == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _irA(idx),
      child: SizedBox(
        height: 56,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: sel ? 16 : 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: sel ? verde.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedScale(
                scale: sel ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(icono, color: sel ? verde : tenue, size: 21),
              ),
              // La etiqueta solo aparece cuando está seleccionado
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: sel ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      etiqueta,
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.2,
                        color: verde,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Pantalla dedicada de detalle de acorde ────────────────

class _PantallaDetalleAcorde extends StatefulWidget {
  final String acorde;
  final bool online;
  final VoidCallback onGrabar;
  final bool grabando;
  final bool procesando;
  final int progreso;
  final Map<String, dynamic>? resultado;

  const _PantallaDetalleAcorde({
    required this.acorde,
    required this.online,
    required this.onGrabar,
    required this.grabando,
    required this.procesando,
    required this.progreso,
    required this.resultado,
  });

  @override
  State<_PantallaDetalleAcorde> createState() => _EstadoPantallaDetalleAcorde();
}

class _EstadoPantallaDetalleAcorde extends State<_PantallaDetalleAcorde>
    with TickerProviderStateMixin {
  // Animación de entrada principal (fade + slide-up)
  late AnimationController _entradaCtrl;
  late Animation<double> _entradaFade;
  late Animation<Offset> _entradaSlide;

  // Animaciones escalonadas para las tarjetas
  late AnimationController _tarjeta1Ctrl;
  late Animation<double> _tarjeta1Fade;
  late Animation<Offset> _tarjeta1Slide;

  late AnimationController _tarjeta2Ctrl;
  late Animation<double> _tarjeta2Fade;
  late Animation<Offset> _tarjeta2Slide;

  // Animación spring del botón
  late AnimationController _botonCtrl;
  late Animation<double> _botonScale;

  @override
  void initState() {
    super.initState();

    // Entrada principal: header fade+slide 600ms easeOutCubic
    _entradaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entradaFade = CurvedAnimation(
        parent: _entradaCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _entradaSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _entradaCtrl, curve: Curves.easeOutCubic));

    // Tarjeta diagrama: aparece primero (delay 200ms)
    _tarjeta1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _tarjeta1Fade =
        CurvedAnimation(parent: _tarjeta1Ctrl, curve: Curves.easeOut);
    _tarjeta1Slide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: _tarjeta1Ctrl, curve: Curves.easeOutCubic));

    // Tarjeta resultado: aparece después (delay 350ms)
    _tarjeta2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _tarjeta2Fade =
        CurvedAnimation(parent: _tarjeta2Ctrl, curve: Curves.easeOut);
    _tarjeta2Slide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: _tarjeta2Ctrl, curve: Curves.easeOutCubic));

    // Botón spring: escala 0.97 → 1.0 con easeOutBack
    _botonCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _botonScale = Tween<double>(begin: 0.97, end: 1.0).animate(
        CurvedAnimation(parent: _botonCtrl, curve: Curves.easeOutBack));

    // Lanzar animaciones escalonadas
    _entradaCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _tarjeta1Ctrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _tarjeta2Ctrl.forward();
    });
    _botonCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _entradaCtrl.dispose();
    _tarjeta1Ctrl.dispose();
    _tarjeta2Ctrl.dispose();
    _botonCtrl.dispose();
    super.dispose();
  }

  void _animarBoton() {
    _botonCtrl.reverse().then((_) {
      if (mounted) _botonCtrl.forward();
    });
    widget.onGrabar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(children: [
          // ── Header animado ──────────────────────────────
          FadeTransition(
            opacity: _entradaFade,
            child: SlideTransition(
              position: _entradaSlide,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  // Botón volver estilizado
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tarjeta2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: blanco, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.acorde,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: blanco,
                                  height: 1.1,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 2),
                          Text(nombreAcorde[widget.acorde] ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: medio,
                                  fontWeight: FontWeight.w400)),
                        ]),
                  ),
                  // Indicador conexión
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.online ? verde : rojo,
                      boxShadow: [
                        BoxShadow(
                            color: (widget.online ? verde : rojo)
                                .withValues(alpha: 0.5),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          // ── Estado grabación ────────────────────────────
          if (widget.grabando || widget.procesando)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(children: [
                Text(
                  widget.procesando ? 'Analizando...' : 'ESCUCHANDO...',
                  style: const TextStyle(
                      fontSize: 11,
                      color: blanco,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w300),
                ),
                if (widget.grabando) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: widget.progreso / 50,
                      minHeight: 2,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: const AlwaysStoppedAnimation(verde),
                    ),
                  ),
                ],
              ]),
            ),
          // ── Contenido con stagger ───────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(children: [
                // Tarjeta diagrama — aparece primero
                FadeTransition(
                  opacity: _tarjeta1Fade,
                  child: SlideTransition(
                    position: _tarjeta1Slide,
                    child: TarjetaAcorde(acorde: widget.acorde),
                  ),
                ),
                // Tarjeta resultado — aparece después
                if (widget.resultado != null) ...[
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: _tarjeta2Fade,
                    child: SlideTransition(
                      position: _tarjeta2Slide,
                      child: TarjetaResultado(resultado: widget.resultado!),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
          // ── Botón "Tocar acorde" con spring ────────────
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            child: ScaleTransition(
              scale: _botonScale,
              child: GestureDetector(
                onTap: _animarBoton,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: widget.grabando
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6B2FFF), morado],
                          ),
                    color: widget.grabando ? rojo : null,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.grabando ? rojo : morado)
                            .withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            widget.grabando
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: blanco,
                            size: 22),
                        const SizedBox(width: 10),
                        Text(
                          widget.procesando
                              ? 'Analizando...'
                              : widget.grabando
                                  ? 'Detener'
                                  : 'Tocar acorde',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: blanco,
                              letterSpacing: 0.2),
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Painter botón micrófono central ──────────────────────

class _MicButtonPainter extends CustomPainter {
  final bool activo;
  final bool grabando;
  const _MicButtonPainter({required this.activo, required this.grabando});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Glow exterior
    if (activo || grabando) {
      final color = grabando ? rojo : verde;
      final paintGlow = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 14);
      canvas.drawCircle(center, r, paintGlow);
    }

    // Fondo con gradiente
    final paintFondo = Paint();
    if (grabando) {
      paintFondo.color = rojo;
    } else if (activo) {
      paintFondo.shader = RadialGradient(
        colors: [const Color(0xFF6B2FFF), verde],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    } else {
      paintFondo.color = const Color(0xFF1E1E2E);
    }
    canvas.drawCircle(center, r, paintFondo);

    // Highlight superior
    if (activo || grabando) {
      final paintHL = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawCircle(center, r, paintHL);
    }

    // Borde
    final paintBorde = Paint()
      ..color = activo || grabando
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, paintBorde);

    // Detalle: arco decorativo tipo cuerda
    if (activo) {
      final paintArco = Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * 0.65),
        3.14 * 0.9,
        3.14 * 0.2,
        false,
        paintArco,
      );
    }
  }

  @override
  bool shouldRepaint(_MicButtonPainter old) =>
      old.activo != activo || old.grabando != grabando;
}
