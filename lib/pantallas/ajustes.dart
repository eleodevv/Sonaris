import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';
import '../services/turso_service.dart';
import '../services/perfil_service.dart';
import 'bienvenida.dart';

class PantallaAjustes extends StatefulWidget {
  final VoidCallback? alAbrirApiMonitor;
  const PantallaAjustes({super.key, this.alAbrirApiMonitor});

  @override
  State<PantallaAjustes> createState() => _EstadoAjustes();
}

class _EstadoAjustes extends State<PantallaAjustes> {
  bool _notificaciones = true;
  bool _sonidos = true;
  bool _entrada = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _entrada = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionService>();
    final iniciales = (sesion.nombre ?? 'U')
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(children: [
          // Header mejorado
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 20, 20),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tarjeta2,
                        tarjeta.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: blanco, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ajustes',
                        style: TextStyle(
                            fontSize: 24,
                            color: blanco,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                    SizedBox(height: 2),
                    Text('Personaliza tu experiencia',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF999999),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1)),
                  ],
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                // Avatar y nombre mejorado
                Center(
                  child: Column(children: [
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: _entrada ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: AnimatedScale(
                        scale: _entrada ? 1.0 : 0.6,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.elasticOut,
                        child: GestureDetector(
                          onTap: () => _seleccionarFoto(context),
                          child: Stack(clipBehavior: Clip.none, children: [
                            _AvatarWidget(iniciales: iniciales),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6B3DFF),
                                      morado,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: fondo, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: morado.withValues(alpha: 0.6),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    size: 16, color: blanco),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedOpacity(
                      opacity: _entrada ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      child: AnimatedSlide(
                        offset: _entrada ? Offset.zero : const Offset(0, 0.3),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: Column(children: [
                          Text(sesion.nombre ?? '',
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: blanco,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Text(sesion.email ?? '',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFFA8A8A8),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ]),
                ),

                // Sección Perfil
                const _Seccion('PERFIL'),
                _ItemTap(
                  index: 0,
                  icono: Icons.person_outline_rounded,
                  titulo: 'Editar nombre',
                  subtitulo: sesion.nombre ?? '',
                  color: morado,
                  onTap: () => _editarNombre(context, sesion),
                ),

                const SizedBox(height: 20),

                // Sección Preferencias
                const _Seccion('PREFERENCIAS'),
                _ItemSwitch(
                  index: 1,
                  icono: Icons.notifications_outlined,
                  titulo: 'Notificaciones',
                  valor: _notificaciones,
                  onChanged: (v) => setState(() => _notificaciones = v),
                ),
                _ItemSwitch(
                  index: 2,
                  icono: Icons.volume_up_outlined,
                  titulo: 'Sonidos de la app',
                  valor: _sonidos,
                  onChanged: (v) => setState(() => _sonidos = v),
                ),

                const SizedBox(height: 20),

                // Sección Cuenta
                const _Seccion('CUENTA'),
                _ItemTap(
                  index: 3,
                  icono: Icons.lock_outline_rounded,
                  titulo: 'Cambiar contraseña',
                  color: ambar,
                  onTap: () => _cambiarPassword(context, sesion),
                ),
                _ItemTap(
                  index: 4,
                  icono: Icons.logout_rounded,
                  titulo: 'Cerrar sesión',
                  color: rojo,
                  onTap: () => _cerrarSesion(context, sesion),
                ),

                const SizedBox(height: 20),

                // Sección Info
                const _Seccion('INFORMACIÓN'),
                const _ItemInfo(
                  index: 5,
                  icono: Icons.info_outline_rounded,
                  titulo: 'Versión',
                  valor: '1.0.0',
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _seleccionarFoto(BuildContext context) {
    final perfil = context.read<PerfilService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: tarjeta,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foto de perfil',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await perfil.seleccionarDeGaleria();
                      if (mounted && perfil.ultimoError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(perfil.ultimoError!,
                                style: const TextStyle(color: blanco)),
                            backgroundColor: rojo,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: tarjeta2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: verde.withValues(alpha: 0.2), width: 1)),
                      child: const Column(children: [
                        Icon(Icons.photo_library_rounded,
                            color: verde, size: 28),
                        SizedBox(height: 8),
                        Text('Galería',
                            style: TextStyle(
                                fontSize: 13,
                                color: blanco,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await perfil.tomarFoto();
                      if (mounted && perfil.ultimoError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(perfil.ultimoError!,
                                style: const TextStyle(color: blanco)),
                            backgroundColor: rojo,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: tarjeta2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: verde.withValues(alpha: 0.2), width: 1)),
                      child: const Column(children: [
                        Icon(Icons.camera_alt_rounded, color: verde, size: 28),
                        SizedBox(height: 8),
                        Text('Cámara',
                            style: TextStyle(
                                fontSize: 13,
                                color: blanco,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
              ]),
            ]),
      ),
    );
  }

  void _editarNombre(BuildContext context, SesionService sesion) {
    final ctrl = TextEditingController(text: sesion.nombre);
    showModalBottomSheet(
      context: context,
      backgroundColor: tarjeta,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editar nombre',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: blanco),
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  hintStyle: const TextStyle(color: tenue),
                  filled: true,
                  fillColor: tarjeta2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final nuevoNombre = ctrl.text.trim();
                  if (nuevoNombre.isEmpty) return;
                  final uid = sesion.usuarioId;
                  if (uid != null) {
                    await context
                        .read<TursoService>()
                        .actualizarNombre(uid, nuevoNombre);
                    sesion.actualizarNombre(nuevoNombre);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: verde, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Guardar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fondo)),
                ),
              ),
            ]),
      ),
    );
  }

  void _cambiarPassword(BuildContext context, SesionService sesion) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: tarjeta,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nueva contraseña',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: blanco)),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                autofocus: true,
                obscureText: true,
                style: const TextStyle(color: blanco),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: tenue),
                  filled: true,
                  fillColor: tarjeta2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final nueva = ctrl.text.trim();
                  if (nueva.length < 6) return;
                  final uid = sesion.usuarioId;
                  if (uid != null) {
                    await context
                        .read<TursoService>()
                        .actualizarPassword(uid, nueva);
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Contraseña actualizada',
                            style: TextStyle(color: blanco)),
                        backgroundColor: tarjeta2,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      color: verde, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Guardar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fondo)),
                ),
              ),
            ]),
      ),
    );
  }

  void _cerrarSesion(BuildContext context, SesionService sesion) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tarjeta,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión', style: TextStyle(color: blanco)),
        content: const Text('¿Seguro que quieres cerrar sesión?',
            style: TextStyle(color: medio)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: medio)),
          ),
          TextButton(
            onPressed: () async {
              await sesion.cerrarSesion();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaBienvenida()),
                  (_) => false);
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: rojo)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  const _Seccion(this.titulo);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 14, top: 4),
        child: Row(children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [morado, Color(0xFF6B3DFF)],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: morado.withValues(alpha: 0.55),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(titulo,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB0B0B0),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}

class _ItemTap extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Color? color;
  final VoidCallback onTap;
  final int index;

  const _ItemTap({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.color,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<_ItemTap> createState() => _ItemTapState();
}

class _ItemTapState extends State<_ItemTap>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 + widget.index * 60), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? blanco;
    final isDestructive = widget.color == rojo;

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDestructive
                      ? [
                          tarjeta,
                          rojo.withValues(alpha: 0.06),
                        ]
                      : [
                          tarjeta,
                          tarjeta2.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDestructive
                      ? rojo.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: _pressed ? 0.18 : 0.1),
                    blurRadius: _pressed ? 14 : 8,
                    offset: const Offset(0, 2),
                  ),
                  if (isDestructive)
                    BoxShadow(
                      color: rojo.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        c.withValues(alpha: 0.18),
                        c.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.18),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(widget.icono, color: c, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.titulo,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: c)),
                      if (widget.subtitulo != null) ...[
                        const SizedBox(height: 4),
                        Text(widget.subtitulo!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w400)),
                      ],
                    ])),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: c.withValues(alpha: 0.4), size: 14),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemSwitch extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final bool valor;
  final ValueChanged<bool> onChanged;
  final int index;

  const _ItemSwitch({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.onChanged,
    this.index = 0,
  });

  @override
  State<_ItemSwitch> createState() => _ItemSwitchState();
}

class _ItemSwitchState extends State<_ItemSwitch> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 + widget.index * 60), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.valor;
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tarjeta,
                tarjeta2.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: on
                  ? morado.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              if (on)
                BoxShadow(
                  color: morado.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: on
                      ? [
                          morado.withValues(alpha: 0.22),
                          morado.withValues(alpha: 0.10),
                        ]
                      : [
                          blanco.withValues(alpha: 0.10),
                          blanco.withValues(alpha: 0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (on)
                    BoxShadow(
                      color: morado.withValues(alpha: 0.32),
                      blurRadius: 10,
                    ),
                ],
              ),
              child: Icon(widget.icono, color: on ? morado : blanco, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(widget.titulo,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: blanco))),
            Switch(
              value: widget.valor,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                widget.onChanged(v);
              },
              activeThumbColor: blanco,
              activeTrackColor: morado,
              inactiveThumbColor: medio,
              inactiveTrackColor: tarjeta2,
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? morado : tenue,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ItemInfo extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final int index;

  const _ItemInfo({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.index = 0,
  });

  @override
  State<_ItemInfo> createState() => _ItemInfoState();
}

class _ItemInfoState extends State<_ItemInfo> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 120 + widget.index * 60), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tarjeta,
                  tarjeta2.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF888888).withValues(alpha: 0.18),
                    const Color(0xFF666666).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(widget.icono, color: const Color(0xFFB0B0B0), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(widget.titulo,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: blanco))),
            Text(widget.valor,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String iniciales;
  const _AvatarWidget({required this.iniciales});

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilService>();

    Widget imagen;
    if (perfil.fotoPath != null) {
      imagen = ClipOval(
        child: Image.file(
          File(perfil.fotoPath!),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    } else if (perfil.avatarAsset != null) {
      imagen = ClipOval(
        child: Image.asset(
          perfil.avatarAsset!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    } else {
      imagen = Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              morado.withValues(alpha: 0.28),
              morado.withValues(alpha: 0.10),
            ],
          ),
        ),
        child: Center(
          child: Text(iniciales,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: blanco)),
        ),
      );
    }

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: morado.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: morado.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: morado.withValues(alpha: 0.20),
            blurRadius: 50,
            spreadRadius: 6,
          ),
        ],
      ),
      child: imagen,
    );
  }
}
