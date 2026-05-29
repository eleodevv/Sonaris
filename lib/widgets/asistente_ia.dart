import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constantes/colores.dart';
import '../services/ia_service.dart';

// ── Botón flotante ────────────────────────────────────────

class BotonAsistenteIA extends StatelessWidget {
  const BotonAsistenteIA({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _ChatAsistente(),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: verde,
          boxShadow: [
            BoxShadow(
                color: verde.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: fondo, size: 24),
      ),
    );
  }
}

// ── Chat ──────────────────────────────────────────────────

class _ChatAsistente extends StatefulWidget {
  const _ChatAsistente();

  @override
  State<_ChatAsistente> createState() => _EstadoChat();
}

class _EstadoChat extends State<_ChatAsistente> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _ia = IaService();
  final List<_Mensaje> _mensajes = [];
  final List<Map<String, String>> _historial = [];
  bool _cargando = false;
  bool _puedeEnviar = false;

  static const List<Map<String, dynamic>> _sugerencias = [
    {
      'icono': Icons.music_note_rounded,
      'titulo': '¿Cómo practico el acorde F?',
      'color': Color(0xFF8B5CF6),
    },
    {
      'icono': Icons.timeline_rounded,
      'titulo': '¿Qué es una progresión de acordes?',
      'color': Color(0xFFEC4899),
    },
    {
      'icono': Icons.access_time_rounded,
      'titulo': '¿Cuánto tiempo tarda aprender guitarra?',
      'color': ambar,
    },
    {
      'icono': Icons.mic_rounded,
      'titulo': '¿Cómo funciona la detección de acordes?',
      'color': Color(0xFF22C55E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextoCambia);
    // Auto-focus when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _onTextoCambia() {
    final puede = _ctrl.text.trim().isNotEmpty;
    if (puede != _puedeEnviar) setState(() => _puedeEnviar = puede);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextoCambia);
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _enviar(String texto) async {
    final mensaje = texto.trim();
    if (mensaje.isEmpty || _cargando) return;
    _ctrl.clear();
    HapticFeedback.selectionClick();
    setState(() {
      _mensajes
          .add(_Mensaje(texto: mensaje, esUsuario: true, hora: DateTime.now()));
      _cargando = true;
    });
    _scrollAbajo();

    try {
      final respuesta = await _ia.enviarMensaje(_historial, mensaje);
      if (!mounted) return;
      _historial.add({'role': 'user', 'text': mensaje});
      _historial.add({'role': 'assistant', 'text': respuesta});
      setState(() {
        _mensajes.add(
            _Mensaje(texto: respuesta, esUsuario: false, hora: DateTime.now()));
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mensajes.add(_Mensaje(
          texto:
              'No pude conectarme. Verifica tu conexión e inténtalo de nuevo.',
          esUsuario: false,
          hora: DateTime.now(),
          esError: true,
        ));
        _cargando = false;
      });
    }
    _scrollAbajo();
  }

  void _scrollAbajo() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          // Header
          _buildHeader(),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          // Mensajes o sugerencias
          Expanded(
            child: _mensajes.isEmpty
                ? _buildSugerencias()
                : ListView.builder(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: _mensajes.length + (_cargando ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _mensajes.length) {
                        return const _BurbujaCargando();
                      }
                      return _BurbujaChat(mensaje: _mensajes[i]);
                    },
                  ),
          ),
          // Input
          _buildInput(),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        // Avatar with morado gradient + glow + status dot
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6B33FF), morado],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: morado.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child:
                const Icon(Icons.auto_awesome_rounded, color: blanco, size: 22),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E),
                border: Border.all(color: tarjeta, width: 2),
              ),
            ),
          ),
        ]),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Asistente Sonaris',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: blanco,
                    letterSpacing: -0.2)),
            SizedBox(height: 2),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _DotEnLinea(),
              SizedBox(width: 6),
              Text('En línea',
                  style: TextStyle(
                      fontSize: 12, color: medio, fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
        const Spacer(),
        Material(
          color: Colors.white.withValues(alpha: 0.06),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.close_rounded, color: blanco, size: 18),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSugerencias() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        const Center(
          child: Text(
            '¿Cómo puedo ayudarte hoy?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: blanco,
                letterSpacing: -0.3),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Pregúntame sobre acordes, teoría o la app',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: medio, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 28),
        Row(children: [
          Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                  color: morado, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          const Text('Sugerencias',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: blanco,
                  letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 12),
        for (int i = 0; i < _sugerencias.length; i++)
          _TarjetaSugerencia(
            indice: i,
            icono: _sugerencias[i]['icono'] as IconData,
            titulo: _sugerencias[i]['titulo'] as String,
            color: _sugerencias[i]['color'] as Color,
            onTap: () => _enviar(_sugerencias[i]['titulo'] as String),
          ),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 14),
      decoration: BoxDecoration(
        color: tarjeta,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: _CampoTexto(
            controlador: _ctrl,
            focus: _focus,
            onSubmitted: _enviar,
          ),
        ),
        const SizedBox(width: 10),
        _BotonEnviar(
          activo: _puedeEnviar && !_cargando,
          cargando: _cargando,
          onTap: () => _enviar(_ctrl.text),
        ),
      ]),
    );
  }
}

// ── Burbuja de chat ───────────────────────────────────────

class _Mensaje {
  final String texto;
  final bool esUsuario;
  final DateTime hora;
  final bool esError;
  const _Mensaje({
    required this.texto,
    required this.esUsuario,
    required this.hora,
    this.esError = false,
  });
}

String _formatHora(DateTime t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _BurbujaChat extends StatefulWidget {
  final _Mensaje mensaje;
  const _BurbujaChat({required this.mensaje});

  @override
  State<_BurbujaChat> createState() => _EstadoBurbujaChat();
}

class _EstadoBurbujaChat extends State<_BurbujaChat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mensaje;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment:
                m.esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!m.esUsuario) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: m.esError
                          ? [rojo, rojo.withValues(alpha: 0.7)]
                          : const [Color(0xFF6B33FF), morado],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                      m.esError
                          ? Icons.error_outline_rounded
                          : Icons.auto_awesome_rounded,
                      color: blanco,
                      size: 14),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: m.esUsuario
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: m.esUsuario
                            ? morado
                            : (m.esError
                                ? rojo.withValues(alpha: 0.12)
                                : tarjeta2),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(m.esUsuario ? 18 : 4),
                          bottomRight: Radius.circular(m.esUsuario ? 4 : 18),
                        ),
                        boxShadow: m.esUsuario
                            ? [
                                BoxShadow(
                                  color: morado.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Text(m.texto,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: m.esUsuario
                                  ? blanco
                                  : (m.esError ? rojo : blanco),
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(
                          left: m.esUsuario ? 0 : 4,
                          right: m.esUsuario ? 4 : 0),
                      child: Text(
                        _formatHora(m.hora),
                        style: const TextStyle(
                            fontSize: 10.5,
                            color: tenue,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
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

class _BurbujaCargando extends StatelessWidget {
  const _BurbujaCargando();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6B33FF), morado],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:
              const Icon(Icons.auto_awesome_rounded, color: blanco, size: 14),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: tarjeta2,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            _Punto(delay: 0),
            SizedBox(width: 5),
            _Punto(delay: 180),
            SizedBox(width: 5),
            _Punto(delay: 360),
          ]),
        ),
      ]),
    );
  }
}

class _Punto extends StatefulWidget {
  final int delay;
  const _Punto({required this.delay});
  @override
  State<_Punto> createState() => _EstadoPunto();
}

class _EstadoPunto extends State<_Punto> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: ScaleTransition(
          scale: _anim,
          child: Container(
              width: 8,
              height: 8,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: morado)),
        ),
      );
}

// ── Auxiliares: status dot, sugerencia, campo, botón ─────

class _DotEnLinea extends StatefulWidget {
  const _DotEnLinea();
  @override
  State<_DotEnLinea> createState() => _EstadoDotEnLinea();
}

class _EstadoDotEnLinea extends State<_DotEnLinea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF22C55E),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E)
                    .withValues(alpha: 0.4 + 0.4 * _ctrl.value),
                blurRadius: 6 + 3 * _ctrl.value,
                spreadRadius: _ctrl.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TarjetaSugerencia extends StatefulWidget {
  final int indice;
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaSugerencia({
    required this.indice,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TarjetaSugerencia> createState() => _EstadoTarjetaSugerencia();
}

class _EstadoTarjetaSugerencia extends State<_TarjetaSugerencia>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrada;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _presionado = false;

  @override
  void initState() {
    super.initState();
    _entrada = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _entrada, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrada, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.indice * 80), () {
      if (mounted) _entrada.forward();
    });
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _presionado = true),
          onTapUp: (_) => setState(() => _presionado = false),
          onTapCancel: () => setState(() => _presionado = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _presionado ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.10),
                    tarjeta2,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: morado.withValues(alpha: 0.18), width: 1),
              ),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.18),
                  ),
                  child: Icon(widget.icono, color: widget.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.titulo,
                      style: const TextStyle(
                          fontSize: 14,
                          color: blanco,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: medio.withValues(alpha: 0.7), size: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampoTexto extends StatefulWidget {
  final TextEditingController controlador;
  final FocusNode focus;
  final ValueChanged<String> onSubmitted;
  const _CampoTexto({
    required this.controlador,
    required this.focus,
    required this.onSubmitted,
  });

  @override
  State<_CampoTexto> createState() => _EstadoCampoTexto();
}

class _EstadoCampoTexto extends State<_CampoTexto> {
  bool _enfocado = false;

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focus.hasFocus != _enfocado) {
      setState(() => _enfocado = widget.focus.hasFocus);
    }
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: tarjeta2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _enfocado
              ? morado.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.06),
          width: _enfocado ? 1.5 : 1,
        ),
        boxShadow: _enfocado
            ? [
                BoxShadow(
                  color: morado.withValues(alpha: 0.18),
                  blurRadius: 12,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controlador,
        focusNode: widget.focus,
        style: const TextStyle(
            color: blanco, fontSize: 14, fontWeight: FontWeight.w500),
        cursorColor: morado,
        maxLines: 4,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: widget.onSubmitted,
        decoration: const InputDecoration(
          hintText: 'Escribe tu pregunta...',
          hintStyle: TextStyle(
              color: tenue, fontSize: 14, fontWeight: FontWeight.w500),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

class _BotonEnviar extends StatefulWidget {
  final bool activo;
  final bool cargando;
  final VoidCallback onTap;
  const _BotonEnviar({
    required this.activo,
    required this.cargando,
    required this.onTap,
  });

  @override
  State<_BotonEnviar> createState() => _EstadoBotonEnviar();
}

class _EstadoBotonEnviar extends State<_BotonEnviar> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.activo;
    return GestureDetector(
      onTapDown: habilitado ? (_) => setState(() => _presionado = true) : null,
      onTapUp: habilitado ? (_) => setState(() => _presionado = false) : null,
      onTapCancel: () => setState(() => _presionado = false),
      onTap: habilitado
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _presionado ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: habilitado
                ? const LinearGradient(
                    colors: [Color(0xFF6B33FF), morado],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: habilitado ? null : tarjeta2,
            boxShadow: habilitado
                ? [
                    BoxShadow(
                      color: morado.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: widget.cargando
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(blanco),
                  ),
                )
              : Icon(Icons.send_rounded,
                  color: habilitado ? blanco : medio, size: 18),
        ),
      ),
    );
  }
}
