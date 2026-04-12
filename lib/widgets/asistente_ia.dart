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
  final _ia = IaService();
  final List<_Mensaje> _mensajes = [];
  final List<Map<String, String>> _historial = [];
  bool _cargando = false;

  static const _sugerencias = [
    '🎸  ¿Cómo practico el acorde F?',
    '🎵  ¿Qué es una progresión de acordes?',
    '🤔  ¿Cuánto tiempo tarda aprender guitarra?',
    '📱  ¿Cómo funciona la detección de acordes?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty || _cargando) return;
    _ctrl.clear();
    HapticFeedback.selectionClick();
    setState(() {
      _mensajes.add(_Mensaje(texto: texto, esUsuario: true));
      _cargando = true;
    });
    _scrollAbajo();

    try {
      final respuesta = await _ia.enviarMensaje(_historial, texto);
      _historial.add({'role': 'user', 'text': texto});
      _historial.add({'role': 'model', 'text': respuesta});
      setState(() {
        _mensajes.add(_Mensaje(texto: respuesta, esUsuario: false));
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajes.add(_Mensaje(texto: 'Error: $e', esUsuario: false));
        _cargando = false;
      });
    }
    _scrollAbajo();
  }

  void _scrollAbajo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: verde.withValues(alpha: 0.15)),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: verde, size: 16)),
              const SizedBox(width: 10),
              const Text('Asistente Sonaris',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.close_rounded, color: medio, size: 22)),
            ]),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF222222), height: 1),
          // Mensajes o sugerencias
          Expanded(
            child: _mensajes.isEmpty
                ? _buildSugerencias()
                : ListView.builder(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _mensajes.length + (_cargando ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _mensajes.length) return _BurbujaCargando();
                      return _BurbujaChat(mensaje: _mensajes[i]);
                    },
                  ),
          ),
          // Input
          Container(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF222222)))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: blanco, fontSize: 14),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _enviar,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu pregunta...',
                    hintStyle: const TextStyle(color: tenue, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _enviar(_ctrl.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: _cargando ? tenue : verde),
                  child: Icon(
                      _cargando
                          ? Icons.hourglass_empty_rounded
                          : Icons.send_rounded,
                      color: fondo,
                      size: 18),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSugerencias() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        const Text('¿Cómo puedo ayudarte?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: blanco)),
        const SizedBox(height: 16),
        ..._sugerencias.map((s) => GestureDetector(
              onTap: () => _enviar(s.substring(3).trim()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Text(s,
                    style: const TextStyle(fontSize: 14, color: blanco)),
              ),
            )),
      ],
    );
  }
}

// ── Burbuja de chat ───────────────────────────────────────

class _Mensaje {
  final String texto;
  final bool esUsuario;
  const _Mensaje({required this.texto, required this.esUsuario});
}

class _BurbujaChat extends StatelessWidget {
  final _Mensaje mensaje;
  const _BurbujaChat({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          mensaje.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: mensaje.esUsuario
              ? verde.withValues(alpha: 0.15)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mensaje.esUsuario ? 18 : 4),
            bottomRight: Radius.circular(mensaje.esUsuario ? 4 : 18),
          ),
          border: Border.all(
              color: mensaje.esUsuario
                  ? verde.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Text(mensaje.texto,
            style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: mensaje.esUsuario ? verde : blanco)),
      ),
    );
  }
}

class _BurbujaCargando extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Punto(delay: 0),
          const SizedBox(width: 4),
          _Punto(delay: 200),
          const SizedBox(width: 4),
          _Punto(delay: 400),
        ]),
      ),
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
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
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
        child: Container(
            width: 7,
            height: 7,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: medio)),
      );
}
