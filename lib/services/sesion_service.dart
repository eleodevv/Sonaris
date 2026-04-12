import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'turso_service.dart';

class SesionService extends ChangeNotifier {
  int? _usuarioId;
  String? _nombre;
  String? _email;
  bool _cargando = true;

  int? get usuarioId => _usuarioId;
  String? get nombre => _nombre;
  String? get email => _email;
  bool get logueado => _usuarioId != null;
  bool get cargando => _cargando;

  final TursoService _turso;

  SesionService(this._turso) {
    _cargarSesion();
  }

  // Carga la sesión guardada al iniciar la app
  Future<void> _cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('sesion_id');
    final nombre = prefs.getString('sesion_nombre');
    final email = prefs.getString('sesion_email');
    if (id != null) {
      _usuarioId = id;
      _nombre = nombre;
      _email = email;
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> _guardarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sesion_id', _usuarioId!);
    await prefs.setString('sesion_nombre', _nombre ?? '');
    await prefs.setString('sesion_email', _email ?? '');
  }

  Future<void> _borrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sesion_id');
    await prefs.remove('sesion_nombre');
    await prefs.remove('sesion_email');
  }

  Future<String?> registrar(
      String nombre, String email, String password) async {
    try {
      final existe = await _turso.buscarUsuarioPorEmail(email);
      if (existe != null) return 'El correo ya está registrado.';
      final id = await _turso.crearUsuarioConPassword(nombre, email, password);
      if (id == null) return 'Error al crear la cuenta.';
      _usuarioId = id;
      _nombre = nombre;
      _email = email;
      await _guardarSesion();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final usuario = await _turso.loginUsuario(email, password);
      if (usuario == null) return 'Correo o contraseña incorrectos.';
      _usuarioId = int.tryParse(usuario['id'].toString());
      _nombre = usuario['nombre'] as String?;
      _email = usuario['email'] as String?;
      await _guardarSesion();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> cerrarSesion() async {
    _usuarioId = null;
    _nombre = null;
    _email = null;
    await _borrarSesion();
    notifyListeners();
  }

  void actualizarNombre(String nombre) {
    _nombre = nombre;
    _guardarSesion();
    notifyListeners();
  }
}
