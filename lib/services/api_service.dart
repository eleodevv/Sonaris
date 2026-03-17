import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://sonarisapi.onrender.com';

  Future<Map<String, dynamic>> getAcordes() async {
    final response = await http.get(Uri.parse('$baseUrl/acordes'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al obtener acordes');
  }

  /// Clasifica el acorde usando Naive Bayes — no necesita saber el acorde de antemano.
  /// Devuelve: { acorde_predicho, confianza, top5, metodo }
  Future<Map<String, dynamic>> clasificarAcorde(String audioPath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/clasificar'));
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath,
        filename: 'audio.wav'));
    var streamed = await request.send().timeout(const Duration(seconds: 30));
    var response = await http.Response.fromStream(streamed)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al clasificar acorde (${response.statusCode})');
  }

  /// Mantiene /verificar como fallback DSP si Bayes no está disponible
  Future<Map<String, dynamic>> verificarAcorde(
      String audioPath, String acordeEsperado) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/verificar'));
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath,
        filename: '$acordeEsperado.wav'));
    request.fields['acorde_esperado'] = acordeEsperado;
    var streamed = await request.send().timeout(const Duration(seconds: 25));
    var response = await http.Response.fromStream(streamed)
        .timeout(const Duration(seconds: 25));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al verificar acorde (${response.statusCode})');
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
