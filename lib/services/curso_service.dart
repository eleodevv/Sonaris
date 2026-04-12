import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CursoService extends ChangeNotifier {
  final Set<String> _completadas = {};
  int _xpTotal = 0;

  int get xpTotal => _xpTotal;

  CursoService() {
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('lecciones_completadas') ?? [];
    _xpTotal = prefs.getInt('xp_total') ?? 0;
    _completadas.addAll(lista);
    notifyListeners();
  }

  bool estaCompletada(String leccionId) => _completadas.contains(leccionId);

  Future<void> completarLeccion(String leccionId, int xp) async {
    if (_completadas.contains(leccionId)) return;
    _completadas.add(leccionId);
    _xpTotal += xp;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('lecciones_completadas', _completadas.toList());
    await prefs.setInt('xp_total', _xpTotal);
    notifyListeners();
  }

  int progresoCapitulo(String capId, int totalLecciones) {
    final completadas = _completadas.where((id) => id.startsWith(capId)).length;
    return completadas;
  }

  double porcentajeCapitulo(String capId, int totalLecciones) {
    if (totalLecciones == 0) return 0;
    return progresoCapitulo(capId, totalLecciones) / totalLecciones;
  }
}
