import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';
import '../pantallas/home.dart';
import 'registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});
  @override
  State<PantallaLogin> createState() => _EstadoLogin();
}

class _EstadoLogin extends State<PantallaLogin>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPassword = false;
  bool _cargando = false;
  String? _error;

  late AnimationController _ctrl;
  late Animation<double> _logoAnim;
  late Animation<double> _formAnim;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    // Logo aparece primero
    _logoAnim = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    // Formulario aparece después con spring
    _formAnim = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic));
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    HapticFeedback.lightImpact();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    final err = await context.read<SesionService>().login(email, pass);
    if (!mounted) return;
    setState(() => _cargando = false);
    if (err != null) {
      HapticFeedback.mediumImpact();
      setState(() => _error = err);
    } else {
      HapticFeedback.heavyImpact();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaHome()),
          (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(fit: StackFit.expand, children: [
        // ── Fondo con imagen borrosa ─────────────────────
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Image.asset('assets/fondo.png', fit: BoxFit.cover),
        ),
        // Capa oscura más suave arriba, más densa abajo
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x88000000),
                Color(0xBB000000),
                Color(0xEE000000),
                Colors.black,
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),
        // Glow morado arriba derecha
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                verde.withValues(alpha: 0.35),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Glow azul abajo izquierda
        Positioned(
          bottom: 200,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF3A0DB8).withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // ── Contenido ────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: h -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Column(children: [
                // Botón back
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: blanco, size: 15),
                      ),
                    ),
                  ),
                ),

                // ── Logo + título (aparece primero) ──────
                Expanded(
                  flex: 2,
                  child: FadeTransition(
                    opacity: _logoAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo con glow
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: verde.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 2),
                            ],
                          ),
                          child: Image.asset('assets/logo_sonaris.png',
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 20),
                        const Text('Sonaris',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: blanco,
                              letterSpacing: -0.5,
                            )),
                        const SizedBox(height: 6),
                        Text('Tu viaje con la guitarra',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
                ),

                // ── Formulario (aparece después) ─────────
                FadeTransition(
                  opacity: _formAnim,
                  child: SlideTransition(
                    position: _formSlide,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(32)),
                            border: Border(
                              top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1)),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            left: 28,
                            right: 28,
                            top: 32,
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Handle
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: blanco,
                                    letterSpacing: -0.5,
                                  )),
                              const SizedBox(height: 4),
                              Text('Hola de nuevo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  )),
                              const SizedBox(height: 28),
                              // Campos
                              _CampoApple(
                                controller: _emailCtrl,
                                hint: 'Correo electrónico',
                                icono: Icons.mail_outline_rounded,
                                teclado: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _CampoApple(
                                controller: _passCtrl,
                                hint: 'Contraseña',
                                icono: Icons.lock_outline_rounded,
                                obscure: !_verPassword,
                                sufijo: GestureDetector(
                                  onTap: () => setState(
                                      () => _verPassword = !_verPassword),
                                  child: Icon(
                                      _verPassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      size: 18),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text('¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                    )),
                              ),
                              // Error
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                _ErrorBanner(mensaje: _error!),
                              ],
                              const SizedBox(height: 24),
                              // Botón
                              GestureDetector(
                                onTap: _cargando ? null : _login,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 17),
                                  decoration: BoxDecoration(
                                    color: _cargando
                                        ? verde.withValues(alpha: 0.6)
                                        : verde,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                          color: verde.withValues(alpha: 0.35),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6))
                                    ],
                                  ),
                                  child: _cargando
                                      ? const Center(
                                          child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: blanco)))
                                      : const Text('Continuar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: blanco)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Link registro
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('¿No tienes cuenta? ',
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            fontSize: 14)),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const PantallaRegistro())),
                                      child: const Text('Regístrate',
                                          style: TextStyle(
                                              color: blanco,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Widgets compartidos ───────────────────────────────────

class _CampoApple extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool obscure;
  final TextInputType teclado;
  final Widget? sufijo;

  const _CampoApple({
    required this.controller,
    required this.hint,
    required this.icono,
    this.obscure = false,
    this.teclado = TextInputType.text,
    this.sufijo,
  });

  @override
  State<_CampoApple> createState() => _EstadoCampoApple();
}

class _EstadoCampoApple extends State<_CampoApple> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _focused
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? verde.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                    color: verde.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 1)
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.teclado,
          style: const TextStyle(
              color: blanco, fontSize: 16, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25), fontSize: 16),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(widget.icono,
                  color: _focused
                      ? verde.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.2),
                  size: 18),
            ),
            suffixIcon: widget.sufijo != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: widget.sufijo)
                : null,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String mensaje;
  const _ErrorBanner({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: rojo.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rojo.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded,
                color: rojo.withValues(alpha: 0.8), size: 16),
            const SizedBox(width: 8),
            Expanded(
                child: Text(mensaje,
                    style: TextStyle(
                        color: rojo.withValues(alpha: 0.9), fontSize: 13))),
          ]),
        ),
      ),
    );
  }
}
