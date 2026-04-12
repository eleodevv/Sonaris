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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: medio, size: 18),
              ),
              const Expanded(
                child: Text('Ajustes',
                    style: TextStyle(
                        fontSize: 16,
                        color: blanco,
                        fontWeight: FontWeight.w300)),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                // Avatar y nombre
                Center(
                  child: Column(children: [
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _seleccionarFoto(context),
                      child: Stack(children: [
                        _AvatarWidget(iniciales: iniciales),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: verde,
                              shape: BoxShape.circle,
                              border: Border.all(color: fondo, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                size: 13, color: fondo),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Text(sesion.nombre ?? '',
                        style: const TextStyle(
                            fontSize: 18,
                            color: blanco,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(sesion.email ?? '',
                        style: const TextStyle(fontSize: 13, color: medio)),
                    const SizedBox(height: 24),
                  ]),
                ),

                // Sección Perfil
                _Seccion('PERFIL'),
                _ItemTap(
                  icono: Icons.person_outline_rounded,
                  titulo: 'Editar nombre',
                  subtitulo: sesion.nombre ?? '',
                  onTap: () => _editarNombre(context, sesion),
                ),

                const SizedBox(height: 20),

                // Sección Preferencias
                _Seccion('PREFERENCIAS'),
                _ItemSwitch(
                  icono: Icons.notifications_outlined,
                  titulo: 'Notificaciones',
                  valor: _notificaciones,
                  onChanged: (v) => setState(() => _notificaciones = v),
                ),
                _ItemSwitch(
                  icono: Icons.volume_up_outlined,
                  titulo: 'Sonidos de la app',
                  valor: _sonidos,
                  onChanged: (v) => setState(() => _sonidos = v),
                ),

                const SizedBox(height: 20),

                // Sección Cuenta
                _Seccion('CUENTA'),
                _ItemTap(
                  icono: Icons.lock_outline_rounded,
                  titulo: 'Cambiar contraseña',
                  onTap: () => _cambiarPassword(context, sesion),
                ),
                _ItemTap(
                  icono: Icons.logout_rounded,
                  titulo: 'Cerrar sesión',
                  color: rojo,
                  onTap: () => _cerrarSesion(context, sesion),
                ),

                const SizedBox(height: 20),

                // Sección Info
                _Seccion('INFORMACIÓN'),
                _ItemTap(
                  icono: Icons.monitor_heart_rounded,
                  titulo: 'Monitor de API',
                  subtitulo: 'Estado y latencia del servidor',
                  onTap: () {
                    Navigator.pop(context);
                    widget.alAbrirApiMonitor?.call();
                  },
                ),
                const _ItemInfo(
                  icono: Icons.info_outline_rounded,
                  titulo: 'Versión',
                  valor: '1.0.0',
                ),
                const _ItemInfo(
                  icono: Icons.music_note_rounded,
                  titulo: 'Modelo IA',
                  valor: 'MLP v1 · 6 acordes',
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
              const SizedBox(height: 20),
              // Avatares predefinidos
              const Text('Avatares',
                  style:
                      TextStyle(fontSize: 11, color: tenue, letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: PerfilService.avatares.map((asset) {
                  return GestureDetector(
                    onTap: () {
                      perfil.seleccionarAvatar(asset);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: perfil.avatarAsset == asset
                              ? verde
                              : Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                          child: Image.asset(asset,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Opciones galería/cámara
              const Text('O elige una foto',
                  style:
                      TextStyle(fontSize: 11, color: tenue, letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await perfil.seleccionarDeGaleria();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: tarjeta2,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Column(children: [
                        Icon(Icons.photo_library_rounded,
                            color: medio, size: 22),
                        SizedBox(height: 6),
                        Text('Galería',
                            style: TextStyle(fontSize: 12, color: medio)),
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
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: tarjeta2,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Column(children: [
                        Icon(Icons.camera_alt_rounded, color: medio, size: 22),
                        SizedBox(height: 6),
                        Text('Cámara',
                            style: TextStyle(fontSize: 12, color: medio)),
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
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(titulo,
            style:
                const TextStyle(fontSize: 10, color: tenue, letterSpacing: 2)),
      );
}

class _ItemTap extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Color? color;
  final VoidCallback onTap;

  const _ItemTap({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? blanco;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icono, color: c, size: 18),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(titulo, style: TextStyle(fontSize: 14, color: c)),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitulo!,
                      style: const TextStyle(fontSize: 12, color: medio)),
                ],
              ])),
          Icon(Icons.arrow_forward_ios_rounded, color: tenue, size: 12),
        ]),
      ),
    );
  }
}

class _ItemSwitch extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _ItemSwitch({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: tarjeta, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icono, color: blanco, size: 18),
        const SizedBox(width: 14),
        Expanded(
            child: Text(titulo,
                style: const TextStyle(fontSize: 14, color: blanco))),
        Switch(
          value: valor,
          onChanged: onChanged,
          activeColor: verde,
          inactiveThumbColor: tenue,
          inactiveTrackColor: tarjeta2,
        ),
      ]),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _ItemInfo({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: tarjeta, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Icon(icono, color: medio, size: 18),
        const SizedBox(width: 14),
        Expanded(
            child: Text(titulo,
                style: const TextStyle(fontSize: 14, color: blanco))),
        Text(valor, style: const TextStyle(fontSize: 13, color: medio)),
      ]),
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
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else if (perfil.avatarAsset != null) {
      imagen = ClipOval(
        child: Image.asset(
          perfil.avatarAsset!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    } else {
      imagen = Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: verde.withValues(alpha: 0.15),
          border: Border.all(color: verde.withValues(alpha: 0.3), width: 2),
        ),
        child: Center(
          child: Text(iniciales,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w600, color: verde)),
        ),
      );
    }

    return SizedBox(width: 80, height: 80, child: imagen);
  }
}
