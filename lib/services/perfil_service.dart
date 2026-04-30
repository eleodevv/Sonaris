import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService extends ChangeNotifier {
  String? _fotoPath; // ruta local si eligió galería/cámara
  String? _avatarAsset; // asset si eligió avatar predefinido
  String? _ultimoError;

  String? get fotoPath => _fotoPath;
  String? get avatarAsset => _avatarAsset;
  String? get ultimoError => _ultimoError;
  bool get tieneFoto => _fotoPath != null || _avatarAsset != null;

  final _picker = ImagePicker();
  static const String _keyFotoPath = 'perfil_foto_path';
  static const String _keyAvatarAsset = 'perfil_avatar_asset';

  static const List<String> avatares = [
    'assets/avatares/avatar1.png',
    'assets/avatares/avatar2.png',
    'assets/avatares/avatar3.png',
    'assets/avatares/avatar4.png',
  ];

  PerfilService() {
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fotoPath = prefs.getString(_keyFotoPath);
      _avatarAsset = prefs.getString(_keyAvatarAsset);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar datos de perfil: $e');
    }
  }

  Future<void> _guardarDatos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_fotoPath != null) {
        await prefs.setString(_keyFotoPath, _fotoPath!);
        await prefs.remove(_keyAvatarAsset);
      } else if (_avatarAsset != null) {
        await prefs.setString(_keyAvatarAsset, _avatarAsset!);
        await prefs.remove(_keyFotoPath);
      } else {
        await prefs.remove(_keyFotoPath);
        await prefs.remove(_keyAvatarAsset);
      }
    } catch (e) {
      debugPrint('Error al guardar datos de perfil: $e');
    }
  }

  void seleccionarAvatar(String asset) {
    _avatarAsset = asset;
    _fotoPath = null;
    _ultimoError = null;
    notifyListeners();
    _guardarDatos();
  }

  Future<void> seleccionarDeGaleria() async {
    try {
      _ultimoError = null;
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
      );
      if (picked == null) {
        _ultimoError = 'No se seleccionó ninguna imagen';
        notifyListeners();
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/avatar_perfil.jpg');
      await File(picked.path).copy(dest.path);
      _fotoPath = dest.path;
      _avatarAsset = null;
      _ultimoError = null;
      notifyListeners();
      await _guardarDatos();
    } catch (e) {
      _ultimoError = 'Error al acceder a la galería: $e';
      notifyListeners();
    }
  }

  Future<void> tomarFoto() async {
    try {
      _ultimoError = null;
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 400,
      );
      if (picked == null) {
        _ultimoError = 'No se capturó ninguna foto';
        notifyListeners();
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final dest = File('${dir.path}/avatar_perfil.jpg');
      await File(picked.path).copy(dest.path);
      _fotoPath = dest.path;
      _avatarAsset = null;
      _ultimoError = null;
      notifyListeners();
      await _guardarDatos();
    } catch (e) {
      _ultimoError = 'Error al acceder a la cámara: $e';
      notifyListeners();
    }
  }

  void limpiar() {
    _fotoPath = null;
    _avatarAsset = null;
    _ultimoError = null;
    _guardarDatos();
    notifyListeners();
  }
}
