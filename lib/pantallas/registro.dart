import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';
import '../pantallas/home.dart';
import 'login.dart';

const _verdeSalvia = Color(0xFF7BAF8E);

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});
  @override
  State<PantallaRegistro> createState() => _EstadoRegistro();
}

class _EstadoRegistro extends State<PantallaRegistro>
    with SingleTickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPassword = false;
  bool _cargando = false;
  String? _error;

  late AnimationController _ctrl;
  late Animation<double> _fadeTop;
  late Animation<double> _fadeCard;
  late Animation<Offset> _slideCard;

  static const _fotos = [
    'assets/grid/grid4.png',
    'assets/grid/grid5.png',
    'assets/grid/grid6.png',
    'assets/grid/grid7.png',
    'assets/grid/grid8.png',
    'assets/grid/grid9.png',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeTop = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _fadeCard = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
    _slideCard = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    final nombre = _nombreCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    if (pass.length < 6) {
      setState(
          () => _error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    final err =
        await context.read<SesionService>().registrar(nombre, email, pass);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: true,
      body: Column(children: [
        // ── Parte superior: grid + título ──
        FadeTransition(
          opacity: _fadeTop,
          child: Stack(children: [
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: 140,
                child: Row(children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Column(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(_fotos[i],
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(_fotos[i + 3],
                                  fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                        ),
                      ]),
                    ),
                ]),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x55000000),
                      Color(0xDD0A0A0A),
                      Color(0xFF0A0A0A)
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded,
                    color: blanco, size: 24),
              ),
            ),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: blanco,
                    height: 1.15,
                    letterSpacing: -0.5,
                  )),
              SizedBox(height: 6),
              Text('Regístrate para empezar tu viaje musical',
                  style: TextStyle(fontSize: 14, color: medio)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Tarjeta blanca centrada ──
        Expanded(
          child: FadeTransition(
            opacity: _fadeCard,
            child: SlideTransition(
              position: _slideCard,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 20
                          : 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CampoClaro(
                            label: 'Nombre completo',
                            controller: _nombreCtrl,
                            hint: 'Tu nombre',
                            icono: Icons.person_outline_rounded,
                            teclado: TextInputType.name),
                        const SizedBox(height: 18),
                        _CampoClaro(
                            label: 'Correo electrónico',
                            controller: _emailCtrl,
                            hint: 'tucorreo@email.com',
                            icono: Icons.mail_outline_rounded,
                            teclado: TextInputType.emailAddress),
                        const SizedBox(height: 18),
                        _CampoClaro(
                          label: 'Contraseña',
                          controller: _passCtrl,
                          hint: 'Mínimo 6 caracteres',
                          icono: Icons.lock_outline_rounded,
                          obscure: !_verPassword,
                          sufijo: GestureDetector(
                            onTap: () =>
                                setState(() => _verPassword = !_verPassword),
                            child: Icon(
                                _verPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: const Color(0xFF999999),
                                size: 20),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: rojo.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: rojo, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_error!,
                                      style: const TextStyle(
                                          color: rojo, fontSize: 13))),
                            ]),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _BotonVerde(
                            texto: 'Crear cuenta',
                            cargando: _cargando,
                            onTap: _registrar),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿Ya tienes cuenta? ',
                                    style: TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PantallaLogin())),
                                  child: Text('Inicia sesión',
                                      style: TextStyle(
                                          color: _verdeSalvia,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Campo estilo claro ────────────────────────────────────
class _CampoClaro extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icono;
  final bool obscure;
  final TextInputType teclado;
  final Widget? sufijo;
  const _CampoClaro(
      {required this.label,
      required this.controller,
      required this.hint,
      required this.icono,
      this.obscure = false,
      this.teclado = TextInputType.text,
      this.sufijo});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555)))),
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0E0))),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: teclado,
          cursorColor: _verdeSalvia,
          style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
            prefixIcon: Icon(icono, color: const Color(0xFF999999), size: 20),
            suffixIcon: sufijo != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8), child: sufijo)
                : null,
            filled: false,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
          ),
        ),
      ),
    ]);
  }
}

// ── Botón verde salvia ────────────────────────────────────
class _BotonVerde extends StatefulWidget {
  final String texto;
  final bool cargando;
  final VoidCallback onTap;
  const _BotonVerde(
      {required this.texto, required this.cargando, required this.onTap});
  @override
  State<_BotonVerde> createState() => _BotonVerdeState();
}

class _BotonVerdeState extends State<_BotonVerde> {
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
          height: 56,
          decoration: BoxDecoration(
              color: _verdeSalvia, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: widget.cargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white))
                : Text(widget.texto,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
