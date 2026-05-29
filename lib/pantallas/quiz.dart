import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../services/turso_service.dart';
import '../services/sesion_service.dart';
import '../widgets/diagrama_acorde.dart';

// ── Modelos ───────────────────────────────────────────────

enum TipoPregunta {
  nombreAcorde,
  notasAcorde,
  descripcionAcorde,
  diagramaAcorde
}

class Pregunta {
  final TipoPregunta tipo;
  final String acorde;
  final String enunciado;
  final List<String> opciones;
  const Pregunta(
      {required this.tipo,
      required this.acorde,
      required this.enunciado,
      required this.opciones});
}

class _Nivel {
  final String nombre;
  final String subtitulo;
  final Color color;
  final IconData icono;
  final int preguntas;
  final int segundos;
  final int minAciertos;
  const _Nivel(
      {required this.nombre,
      required this.subtitulo,
      required this.color,
      required this.icono,
      required this.preguntas,
      required this.segundos,
      required this.minAciertos});
}

const _niveles = [
  _Nivel(
      nombre: 'Iniciado',
      subtitulo: 'Conceptos básicos',
      color: Color(0xFF4CAF50),
      icono: Icons.star_outline_rounded,
      preguntas: 5,
      segundos: 25,
      minAciertos: 3),
  _Nivel(
      nombre: 'Aprendiz',
      subtitulo: 'Notas y acordes',
      color: Color(0xFF2196F3),
      icono: Icons.music_note_rounded,
      preguntas: 6,
      segundos: 20,
      minAciertos: 4),
  _Nivel(
      nombre: 'Intermedio',
      subtitulo: 'Teoría musical',
      color: Color(0xFFFF9800),
      icono: Icons.queue_music_rounded,
      preguntas: 8,
      segundos: 15,
      minAciertos: 5),
  _Nivel(
      nombre: 'Avanzado',
      subtitulo: 'Diagramas y técnica',
      color: Color(0xFF9C27B0),
      icono: Icons.piano_rounded,
      preguntas: 9,
      segundos: 12,
      minAciertos: 6),
  _Nivel(
      nombre: 'Maestro',
      subtitulo: 'Dominio total',
      color: Color(0xFFF44336),
      icono: Icons.workspace_premium_rounded,
      preguntas: 10,
      segundos: 10,
      minAciertos: 8),
];

// ── Generador de preguntas ────────────────────────────────

List<Pregunta> generarPreguntas({int cantidad = 8}) {
  final rng = Random();
  final lista = <Pregunta>[];
  const tipos = TipoPregunta.values;
  for (int i = 0; i < cantidad; i++) {
    final acorde = acordes[rng.nextInt(acordes.length)];
    final tipo = tipos[rng.nextInt(tipos.length)];
    final otras = acordes.where((a) => a != acorde).toList()..shuffle(rng);
    final dist = otras.take(3).toList();
    switch (tipo) {
      case TipoPregunta.nombreAcorde:
        final ops = [
          nombreAcorde[acorde]!,
          ...dist.map((a) => nombreAcorde[a]!)
        ]..shuffle(rng);
        lista.add(Pregunta(
            tipo: tipo,
            acorde: acorde,
            enunciado: '¿Cómo se llama el acorde $acorde?',
            opciones: ops));
      case TipoPregunta.notasAcorde:
        final ops = [
          notasAcorde[acorde]!.join(' - '),
          ...dist.map((a) => notasAcorde[a]!.join(' - '))
        ]..shuffle(rng);
        lista.add(Pregunta(
            tipo: tipo,
            acorde: acorde,
            enunciado: '¿Qué notas forman el acorde $acorde?',
            opciones: ops));
      case TipoPregunta.descripcionAcorde:
        final ops = [acorde, ...dist]..shuffle(rng);
        lista.add(Pregunta(
            tipo: tipo,
            acorde: acorde,
            enunciado: descripcionAcorde[acorde]!,
            opciones: ops));
      case TipoPregunta.diagramaAcorde:
        final ops = [acorde, ...dist]..shuffle(rng);
        lista.add(Pregunta(
            tipo: tipo,
            acorde: acorde,
            enunciado: '¿Qué acorde representa este diagrama?',
            opciones: ops));
    }
  }
  return lista;
}
// ── Pantalla principal con niveles ────────────────────────

class PantallaQuiz extends StatefulWidget {
  const PantallaQuiz({super.key});
  @override
  State<PantallaQuiz> createState() => _EstadoPantallaQuiz();
}

class _EstadoPantallaQuiz extends State<PantallaQuiz>
    with TickerProviderStateMixin {
  int _nivelDesbloqueado = 0;
  late final AnimationController _entradaCtrl;
  late final Animation<double> _headerAnim;
  late final Animation<double> _bubbleAnim;

  @override
  void initState() {
    super.initState();
    _entradaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerAnim = CurvedAnimation(
      parent: _entradaCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _bubbleAnim = CurvedAnimation(
      parent: _entradaCtrl,
      curve: const Interval(0.22, 0.75, curve: Curves.easeOutBack),
    );
    _cargarProgreso();
    _entradaCtrl.forward();
  }

  @override
  void dispose() {
    _entradaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProgreso() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() =>
        _nivelDesbloqueado = prefs.getInt('quiz_nivel_desbloqueado') ?? 0);
  }

  Future<void> _desbloquearNivel(int idx) async {
    if (idx > _nivelDesbloqueado) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_nivel_desbloqueado', idx);
      if (!mounted) return;
      setState(() => _nivelDesbloqueado = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completados = _nivelDesbloqueado.clamp(0, _niveles.length);
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(children: [
          // ── Header animado ────────────────────────────────
          AnimatedBuilder(
            animation: _headerAnim,
            builder: (_, child) {
              final t = _headerAnim.value;
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, -18 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: _buildHeader(completados),
          ),
          const SizedBox(height: 22),
          // ── Personaje + burbuja con spring scale + fade ──
          AnimatedBuilder(
            animation: _bubbleAnim,
            builder: (_, child) {
              final t = _bubbleAnim.value;
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.85 + 0.15 * t.clamp(0.0, 1.2),
                  alignment: Alignment.bottomLeft,
                  child: child,
                ),
              );
            },
            child: _buildPersonajeBurbuja(),
          ),
          const SizedBox(height: 22),
          // ── Lista de niveles con stagger ──────────────────
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _niveles.length,
              itemBuilder: (_, i) {
                final n = _niveles[i];
                final desbloqueado = i <= _nivelDesbloqueado;
                final completado = i < _nivelDesbloqueado;
                return _TarjetaNivel(
                  key: ValueKey('nivel_$i'),
                  nivel: n,
                  index: i,
                  desbloqueado: desbloqueado,
                  completado: completado,
                  onTap: desbloqueado
                      ? () async {
                          final paso = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _PantallaQuizNivel(nivelIdx: i),
                            ),
                          );
                          if (paso == true) await _desbloquearNivel(i + 1);
                        }
                      : null,
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(int completados) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tarjeta2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              ),
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
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Musical',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: blanco,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Supera cada nivel para avanzar',
                style: TextStyle(fontSize: 12, color: medio),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: morado.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: morado.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: morado.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bolt_rounded, color: morado, size: 12),
            const SizedBox(width: 4),
            Text(
              '$completados/${_niveles.length} niveles',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: morado,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPersonajeBurbuja() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: morado.withValues(alpha: 0.16),
              border: Border.all(
                color: morado.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: morado.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: blanco,
              size: 42,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: tarjeta.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _nivelDesbloqueado == 0
                    ? '¡Completa cada nivel para desbloquear el siguiente!'
                    : '¡Llevas ${_nivelDesbloqueado + 1} niveles desbloqueados!',
                style: const TextStyle(
                  fontSize: 13,
                  color: blanco,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de nivel con stagger + spring tap ─────────────
class _TarjetaNivel extends StatefulWidget {
  final _Nivel nivel;
  final int index;
  final bool desbloqueado;
  final bool completado;
  final VoidCallback? onTap;

  const _TarjetaNivel({
    super.key,
    required this.nivel,
    required this.index,
    required this.desbloqueado,
    required this.completado,
    required this.onTap,
  });

  @override
  State<_TarjetaNivel> createState() => _EstadoTarjetaNivel();
}

class _EstadoTarjetaNivel extends State<_TarjetaNivel>
    with TickerProviderStateMixin {
  late final AnimationController _entradaCtrl;
  late final Animation<double> _entradaAnim;
  late final AnimationController _tapCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _entradaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _entradaAnim = CurvedAnimation(
      parent: _entradaCtrl,
      curve: Curves.easeOutCubic,
    );
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 360),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _tapCtrl,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
    Future.delayed(
      Duration(milliseconds: 280 + widget.index * 100),
      () {
        if (mounted) _entradaCtrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _entradaCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    _tapCtrl.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    _tapCtrl.reverse();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    _tapCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.nivel;
    final activo = widget.desbloqueado;

    return AnimatedBuilder(
      animation: _entradaAnim,
      builder: (_, child) {
        final t = _entradaAnim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - t)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            );
          },
          child: AnimatedOpacity(
            opacity: activo ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: activo
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          tarjeta,
                          Color.alphaBlend(
                            n.color.withValues(alpha: 0.07),
                            tarjeta,
                          ),
                        ],
                      )
                    : null,
                color: activo ? null : tarjeta,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: activo
                      ? n.color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.05),
                  width: activo ? 1.5 : 1,
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: n.color.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(children: [
                // Icono circular más grande (60x60)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activo ? n.color.withValues(alpha: 0.15) : tarjeta2,
                    border: Border.all(
                      color: activo
                          ? n.color.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.06),
                      width: 1.5,
                    ),
                    boxShadow: activo
                        ? [
                            BoxShadow(
                              color: n.color.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    activo ? n.icono : Icons.lock_rounded,
                    color: activo ? n.color : tenue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text(
                            n.nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  activo ? FontWeight.w800 : FontWeight.w600,
                              color: activo ? blanco : tenue,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.completado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: verde.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: verde.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: verde.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: verde, size: 11),
                                SizedBox(width: 3),
                                Text(
                                  'Completado',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: verde,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                        n.subtitulo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: medio,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Stat row: timer + target
                      Row(children: [
                        Icon(
                          Icons.timer_outlined,
                          color:
                              activo ? n.color.withValues(alpha: 0.85) : tenue,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${n.segundos}s',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: activo
                                ? Colors.white.withValues(alpha: 0.7)
                                : tenue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.gps_fixed_rounded,
                          color:
                              activo ? n.color.withValues(alpha: 0.85) : tenue,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${n.minAciertos}/${n.preguntas}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: activo
                                ? Colors.white.withValues(alpha: 0.7)
                                : tenue,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (activo)
                  AnimatedBuilder(
                    animation: _tapCtrl,
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(3 * _tapCtrl.value, 0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: n.color.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: n.color,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
// ── Pantalla del quiz por nivel ───────────────────────────

class _PantallaQuizNivel extends StatefulWidget {
  final int nivelIdx;
  const _PantallaQuizNivel({required this.nivelIdx});
  @override
  State<_PantallaQuizNivel> createState() => _EstadoQuizNivel();
}

class _EstadoQuizNivel extends State<_PantallaQuizNivel>
    with TickerProviderStateMixin {
  late List<Pregunta> _preguntas;
  late _Nivel _nivel;
  int _indice = 0, _puntaje = 0, _vidas = 3, _segundos = 0;
  String? _seleccion;
  bool _respondida = false, _terminado = false;
  Timer? _timer;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _nivel = _niveles[widget.nivelIdx];
    _preguntas = generarPreguntas(cantidad: _nivel.preguntas);
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animCtrl.forward();
    _iniciarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _iniciarTimer() {
    _segundos = _nivel.segundos;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundos > 0) {
        setState(() => _segundos--);
      } else {
        _timer?.cancel();
        if (!_respondida) _tiempoAgotado();
      }
    });
  }

  void _tiempoAgotado() {
    HapticFeedback.heavyImpact();
    setState(() {
      _respondida = true;
      _vidas--;
    });
    if (_vidas <= 0)
      Future.delayed(const Duration(milliseconds: 800),
          () => setState(() => _terminado = true));
  }

  String _respuestaCorrecta() {
    final p = _preguntas[_indice];
    switch (p.tipo) {
      case TipoPregunta.nombreAcorde:
        return nombreAcorde[p.acorde]!;
      case TipoPregunta.notasAcorde:
        return notasAcorde[p.acorde]!.join(' - ');
      case TipoPregunta.descripcionAcorde:
      case TipoPregunta.diagramaAcorde:
        return p.acorde;
    }
  }

  void _responder(String opcion) {
    if (_respondida) return;
    _timer?.cancel();
    HapticFeedback.selectionClick();
    final correcta = opcion == _respuestaCorrecta();
    if (correcta) {
      _puntaje++;
      HapticFeedback.mediumImpact();
    } else {
      _vidas--;
    }
    setState(() {
      _seleccion = opcion;
      _respondida = true;
    });
    if (_vidas <= 0)
      Future.delayed(const Duration(milliseconds: 1200),
          () => setState(() => _terminado = true));
  }

  void _siguiente() {
    if (_indice < _preguntas.length - 1) {
      _animCtrl.reset();
      setState(() {
        _indice++;
        _seleccion = null;
        _respondida = false;
      });
      _animCtrl.forward();
      _iniciarTimer();
    } else {
      _guardarResultado();
      setState(() => _terminado = true);
    }
  }

  Future<void> _guardarResultado() async {
    final uid = context.read<SesionService>().usuarioId;
    if (uid == null) return;
    context
        .read<TursoService>()
        .registrarIntento(
            usuarioId: uid,
            acorde: 'QUIZ',
            correcto: _puntaje >= _nivel.minAciertos,
            confianza: (_puntaje / _preguntas.length) * 100)
        .catchError((_) {});
  }

  bool get _paso => _vidas > 0 && _puntaje >= _nivel.minAciertos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(child: _terminado ? _buildResultado() : _buildPregunta()),
    );
  }

  Widget _buildResultado() {
    final porcentaje = (_puntaje / _preguntas.length * 100).round();
    final color = _paso ? verde : rojo;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border:
                  Border.all(color: color.withValues(alpha: 0.4), width: 2)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
                _paso
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: color,
                size: 40),
            const SizedBox(height: 4),
            Text('$porcentaje%',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          ]),
        ),
        const SizedBox(height: 20),
        Text(_paso ? '¡Nivel superado!' : 'Inténtalo de nuevo',
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: blanco)),
        const SizedBox(height: 8),
        Text(
            '$_puntaje de ${_preguntas.length} correctas · mínimo ${_nivel.minAciertos}',
            style: const TextStyle(fontSize: 14, color: medio)),
        const SizedBox(height: 12),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                3,
                (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                        i < _vidas
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: rojo,
                        size: 22)))),
        const SizedBox(height: 40),
        if (_paso && widget.nivelIdx < _niveles.length - 1)
          GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: verde.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]),
              child: const Text('Desbloquear siguiente nivel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: blanco)),
            ),
          ),
        if (!_paso || widget.nivelIdx == _niveles.length - 1) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _preguntas = generarPreguntas(cantidad: _nivel.preguntas);
                _indice = 0;
                _puntaje = 0;
                _vidas = 3;
                _seleccion = null;
                _respondida = false;
                _terminado = false;
              });
              _animCtrl.reset();
              _animCtrl.forward();
              _iniciarTimer();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: tarjeta,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08))),
              child: const Text('Intentar de nuevo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
            ),
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context, _paso),
          child: Text('Volver a niveles',
              style: const TextStyle(color: medio, fontSize: 14)),
        ),
      ]),
    );
  }

  // ── Helper: label for question type ─────────────────────
  String _tipoBadgeLabel(TipoPregunta tipo) {
    switch (tipo) {
      case TipoPregunta.nombreAcorde:
        return 'NOMBRE';
      case TipoPregunta.notasAcorde:
        return 'NOTAS';
      case TipoPregunta.descripcionAcorde:
        return 'DESCRIPCIÓN';
      case TipoPregunta.diagramaAcorde:
        return 'DIAGRAMA';
    }
  }

  // ── Helper: icon for question type ──────────────────────
  IconData _tipoBadgeIcon(TipoPregunta tipo) {
    switch (tipo) {
      case TipoPregunta.nombreAcorde:
        return Icons.text_fields_rounded;
      case TipoPregunta.notasAcorde:
        return Icons.music_note_rounded;
      case TipoPregunta.descripcionAcorde:
        return Icons.menu_book_rounded;
      case TipoPregunta.diagramaAcorde:
        return Icons.grid_on_rounded;
    }
  }

  Widget _buildPregunta() {
    final p = _preguntas[_indice];
    final correcta = _respuestaCorrecta();
    final timerRatio = _segundos / _nivel.segundos;
    final timerColor = timerRatio > 0.5
        ? verde
        : timerRatio > 0.25
            ? ambar
            : rojo;
    final timerLow = _segundos > 0 && _segundos < 5;
    final esUltima = _indice >= _preguntas.length - 1;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(children: [
        // ── Improved Header ──────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: fondo,
            border: Border(
                bottom:
                    BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Row(children: [
            // Close button
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: tarjeta2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07))),
                child: const Icon(Icons.close_rounded, color: medio, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            // Level badge — slightly more vibrant
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _nivel.color.withValues(alpha: 0.22),
                    _nivel.color.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _nivel.color.withValues(alpha: 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: _nivel.color.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_nivel.icono, color: _nivel.color, size: 13),
                const SizedBox(width: 5),
                Text(_nivel.nombre,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: _nivel.color)),
              ]),
            ),
            const SizedBox(width: 8),
            // Question counter
            Expanded(
              child: Text(
                '${_indice + 1} / ${_preguntas.length}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: medio),
              ),
            ),
            // Circular timer with pulsing glow when low
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                final pulse = timerLow ? 0.5 + 0.5 * _pulseCtrl.value : 0.0;
                return SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: timerLow
                            ? [
                                BoxShadow(
                                  color: rojo.withValues(
                                      alpha: 0.30 + 0.30 * pulse),
                                  blurRadius: 14 + 6 * pulse,
                                  spreadRadius: 1 + 1 * pulse,
                                ),
                              ]
                            : null,
                      ),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: timerRatio.clamp(0.0, 1.0),
                          strokeWidth: 3.4,
                          backgroundColor: tarjeta2,
                          valueColor: AlwaysStoppedAnimation(timerColor),
                        ),
                      ),
                    ),
                    Text('$_segundos',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: timerColor)),
                  ]),
                );
              },
            ),
          ]),
        ),

        // ── Stats bar: lives + points ────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tarjeta.withValues(alpha: 0.6),
            border: Border(
                bottom:
                    BorderSide(color: Colors.white.withValues(alpha: 0.04))),
          ),
          child: Row(children: [
            // Hearts: each in a circular container with glow / dimmed look
            ...List.generate(3, (i) {
              final alive = i < _vidas;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: alive
                        ? rojo.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.03),
                    border: Border.all(
                      color: alive
                          ? rojo.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1.2,
                    ),
                    boxShadow: alive
                        ? [
                            BoxShadow(
                              color: rojo.withValues(alpha: 0.45),
                              blurRadius: 10,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    alive ? Icons.favorite_rounded : Icons.heart_broken_rounded,
                    color: alive ? rojo : Colors.white.withValues(alpha: 0.22),
                    size: 16,
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            // Numeric counter for remaining lives
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: rojo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rojo.withValues(alpha: 0.30)),
              ),
              child: Text(
                '$_vidas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: rojo,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const Spacer(),
            // Points badge — stronger gradient + glow + animated XP icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    morado.withValues(alpha: 0.55),
                    morado.withValues(alpha: 0.22),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: morado.withValues(alpha: 0.65)),
                boxShadow: [
                  BoxShadow(
                    color: morado.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) {
                    final s = 0.92 + 0.16 * _pulseCtrl.value;
                    return Transform.scale(scale: s, child: child);
                  },
                  child: const Icon(Icons.bolt_rounded, color: ambar, size: 15),
                ),
                const SizedBox(width: 5),
                Text('$_puntaje pts',
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: blanco)),
              ]),
            ),
          ]),
        ),

        // ── Question content + options ───────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Question type badge — pill, stronger color, icon, slight glow
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _nivel.color.withValues(alpha: 0.28),
                      _nivel.color.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(color: _nivel.color.withValues(alpha: 0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: _nivel.color.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_tipoBadgeIcon(p.tipo), color: _nivel.color, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _tipoBadgeLabel(p.tipo),
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: _nivel.color),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Diagram (if applicable)
              if (p.tipo == TipoPregunta.diagramaAcorde) ...[
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05))),
                    child: DiagramaAcordeWidget(acorde: p.acorde, alto: 130)),
                const SizedBox(height: 16),
              ],

              // Question text — scale-in animation, bigger font, letterSpacing
              ScaleTransition(
                scale: _scaleAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    p.enunciado,
                    style: const TextStyle(
                        fontSize: 24,
                        color: blanco,
                        height: 1.32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Answer options
              ...p.opciones.asMap().entries.map((e) {
                final idx = e.key;
                final op = e.value;
                final letra = ['A', 'B', 'C', 'D'][idx];
                final esCorrecta = _respondida && op == correcta;
                final esIncorrecta =
                    _respondida && _seleccion == op && op != correcta;

                return _OpcionRespuesta(
                  letra: letra,
                  texto: op,
                  esCorrecta: esCorrecta,
                  esIncorrecta: esIncorrecta,
                  respondida: _respondida,
                  onTap: () => _responder(op),
                );
              }),

              // "Siguiente" button — spring scale on press, gradient + glow
              if (_respondida) ...[
                const SizedBox(height: 8),
                _BotonSiguiente(
                  habilitado: _vidas > 0,
                  esUltima: esUltima,
                  color: _nivel.color,
                  onTap: _vidas > 0 ? _siguiente : () {},
                ),
              ],
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Answer option widget with press scale + shine ─────────
class _OpcionRespuesta extends StatefulWidget {
  final String letra;
  final String texto;
  final bool esCorrecta;
  final bool esIncorrecta;
  final bool respondida;
  final VoidCallback onTap;

  const _OpcionRespuesta({
    required this.letra,
    required this.texto,
    required this.esCorrecta,
    required this.esIncorrecta,
    required this.respondida,
    required this.onTap,
  });

  @override
  State<_OpcionRespuesta> createState() => _EstadoOpcionRespuesta();
}

class _EstadoOpcionRespuesta extends State<_OpcionRespuesta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _tapCtrl,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.respondida) return;
    _tapCtrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.respondida) return;
    _tapCtrl.reverse();
  }

  void _onTapCancel() {
    if (widget.respondida) return;
    _tapCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color bg = tarjeta;
    Color borderColor = Colors.white.withValues(alpha: 0.07);
    Color txt = blanco;
    Color letraTxt = blanco;
    List<BoxShadow> shadows = [];
    Gradient? letraGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.16),
        Colors.white.withValues(alpha: 0.06),
      ],
    );
    Color? letraSolid;

    if (widget.esCorrecta) {
      bg = verde.withValues(alpha: 0.14);
      borderColor = verde;
      txt = verde;
      letraTxt = blanco;
      letraGradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [verde, morado],
      );
      shadows = [
        BoxShadow(
          color: verde.withValues(alpha: 0.32),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (widget.esIncorrecta) {
      bg = rojo.withValues(alpha: 0.14);
      borderColor = rojo;
      txt = rojo;
      letraTxt = blanco;
      letraGradient = null;
      letraSolid = rojo;
      shadows = [
        BoxShadow(
          color: rojo.withValues(alpha: 0.30),
          blurRadius: 18,
          spreadRadius: 0.5,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (widget.respondida) {
      // Dim other options after answering
      txt = medio;
      letraTxt = medio;
      letraGradient = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.02),
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: shadows,
          ),
          child: Row(children: [
            // Letter circle — gradient/shine, vibrant when answered
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: letraSolid,
                gradient: letraSolid == null ? letraGradient : null,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                boxShadow: widget.esCorrecta
                    ? [
                        BoxShadow(
                          color: verde.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ]
                    : widget.esIncorrecta
                        ? [
                            BoxShadow(
                              color: rojo.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
              ),
              child: Center(
                child: Text(
                  widget.letra,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: letraTxt,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.texto,
                style: TextStyle(
                    fontSize: 15.5,
                    color: txt,
                    fontWeight: FontWeight.w700,
                    height: 1.25),
              ),
            ),
            if (widget.esCorrecta)
              const Icon(Icons.check_circle_rounded, color: verde, size: 22),
            if (widget.esIncorrecta)
              const Icon(Icons.cancel_rounded, color: rojo, size: 22),
          ]),
        ),
      ),
    );
  }
}

// ── "Siguiente" button with spring scale + glow ──────────
class _BotonSiguiente extends StatefulWidget {
  final bool habilitado;
  final bool esUltima;
  final Color color;
  final VoidCallback onTap;

  const _BotonSiguiente({
    required this.habilitado,
    required this.esUltima,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BotonSiguiente> createState() => _EstadoBotonSiguiente();
}

class _EstadoBotonSiguiente extends State<_BotonSiguiente>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _tapCtrl,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.habilitado) return;
    _tapCtrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.habilitado) return;
    _tapCtrl.reverse();
  }

  void _onTapCancel() {
    if (!widget.habilitado) return;
    _tapCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return GestureDetector(
      onTap: widget.habilitado ? widget.onTap : null,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.habilitado
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      c,
                      Color.alphaBlend(Colors.white.withValues(alpha: 0.18), c),
                    ],
                  )
                : null,
            color: widget.habilitado ? null : tarjeta2,
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.habilitado
                ? [
                    BoxShadow(
                      color: c.withValues(alpha: 0.50),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: c.withValues(alpha: 0.20),
                      blurRadius: 50,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              !widget.habilitado
                  ? 'Sin vidas...'
                  : widget.esUltima
                      ? 'Ver resultado'
                      : 'Siguiente',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: widget.habilitado ? blanco : medio),
            ),
            if (widget.habilitado) ...[
              const SizedBox(width: 8),
              Icon(
                widget.esUltima
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                color: blanco,
                size: 19,
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
