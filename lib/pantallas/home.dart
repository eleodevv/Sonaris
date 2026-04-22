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
  List<Map<String, dynamic>> _historialPings = [];
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
    if (mounted)
      setState(() {
        _online = ok;
        _verificando = false;
      });
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
      // Encabezado
      Container(
        color: fondo,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          bottom: 12,
        ),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _irA(1),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: medio, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Practicar',
                  style: TextStyle(
                      fontSize: 16,
                      color: blanco,
                      fontWeight: FontWeight.w300))),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: tarjeta2, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shuffle_rounded, color: medio, size: 13),
                SizedBox(width: 5),
                Text('Aleatorio', style: TextStyle(fontSize: 11, color: medio)),
              ]),
            ),
          ),
        ]),
      ),
      // Estado de grabación (solo cuando graba o procesa)
      if (_grabando || _procesando)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: fondo,
          child: Column(children: [
            Text(
              _procesando ? 'Analizando...' : 'ESCUCHANDO...',
              style: TextStyle(
                fontSize: 11,
                color: _procesando ? ambar : verde,
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
                  backgroundColor: Colors.white.withOpacity(0.05),
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
              alSeleccionar: (a) => setState(() {
                _acorde = a;
                _resultado = null;
              }),
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
            // Botón central mic
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _grabando
                        ? rojo
                        : enPractica
                            ? verde
                            : const Color(0xFF2A2A3A),
                    boxShadow: [
                      BoxShadow(
                          color: (_grabando
                                  ? rojo
                                  : enPractica
                                      ? verde
                                      : Colors.transparent)
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1),
                    ],
                  ),
                  child: _procesando
                      ? const Padding(
                          padding: EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: ambar))
                      : Icon(_grabando ? Icons.stop_rounded : Icons.mic_rounded,
                          color: enPractica || _grabando ? fondo : medio,
                          size: 24),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? verde.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border:
              sel ? Border.all(color: verde.withOpacity(0.25), width: 1) : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icono, color: sel ? verde : tenue, size: 20),
          const SizedBox(height: 3),
          Text(etiqueta,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.3,
                color: sel ? verde : tenue,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              )),
        ]),
      ),
    );
  }
}
