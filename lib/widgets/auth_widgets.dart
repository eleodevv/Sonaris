import 'dart:ui';
import 'package:flutter/material.dart';
import '../constantes/colores.dart';

/// Botón de retroceso para las pantallas de auth
class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: blanco, size: 20),
      ),
    );
  }
}

/// Animación de fade + slide para secciones de auth
class AuthFade extends StatelessWidget {
  final AnimationController controller;
  final Interval intervalo;
  final Widget child;
  const AuthFade({
    super.key,
    required this.controller,
    required this.intervalo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: intervalo);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(fade);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// Campo de texto con etiqueta superior
class AuthCampo extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool obscure;
  final TextInputType teclado;
  final Widget? sufijo;

  const AuthCampo({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icono,
    this.obscure = false,
    this.teclado = TextInputType.text,
    this.sufijo,
  });

  @override
  State<AuthCampo> createState() => _AuthCampoState();
}

class _AuthCampoState extends State<AuthCampo> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _focused ? morado : medio,
              letterSpacing: 0.2,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _focused ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focused
                      ? morado.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Focus(
                onFocusChange: (f) => setState(() => _focused = f),
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.obscure,
                  keyboardType: widget.teclado,
                  cursorColor: morado,
                  style: const TextStyle(
                      color: blanco, fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: tenue, fontSize: 15),
                    prefixIcon: Icon(widget.icono,
                        color: _focused ? morado : medio, size: 20),
                    suffixIcon: widget.sufijo != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: widget.sufijo)
                        : null,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón principal con gradiente e icono circular
class AuthBoton extends StatefulWidget {
  final String texto;
  final bool cargando;
  final VoidCallback onTap;
  const AuthBoton({
    super.key,
    required this.texto,
    required this.cargando,
    required this.onTap,
  });

  @override
  State<AuthBoton> createState() => _AuthBotonState();
}

class _AuthBotonState extends State<AuthBoton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.cargando ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.cargando ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.cargando ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: morado,
            borderRadius: BorderRadius.circular(18),
          ),
          child: widget.cargando
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: blanco),
                  ),
                )
              : Center(
                  child: Text(widget.texto,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: blanco,
                          letterSpacing: 0.2)),
                ),
        ),
      ),
    );
  }
}

/// Banner de error
class AuthError extends StatelessWidget {
  final String mensaje;
  const AuthError({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: rojo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rojo.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: rojo, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Text(mensaje,
              style: const TextStyle(
                  color: rojo, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
