import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android emulator: http://10.0.2.2:8000
  // iOS simulator:    http://localhost:8000
  // Dispositivo físico: http://TU_IP:8000
  static const String baseUrl = 'https://9hvq80jq-8000.usw3.devtunnels.ms';

  Future<Map<String, dynamic>> getAcordes() async {
    final response = await http.get(Uri.parse('$baseUrl/acordes'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al obtener acordes');
  }

  Future<Map<String, dynamic>> detectarAcorde(
    String audioPath, {
    String? acordeEsperado,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detectar'));
    // Enviar acorde en filename como fallback por si el form field no llega
    final filename = acordeEsperado != null ? '$acordeEsperado.wav' : 'audio.wav';
    request.files.add(await http.MultipartFile.fromPath('audio', audioPath,
        filename: filename));
    if (acordeEsperado != null) {
      request.fields['acorde_esperado'] = acordeEsperado;
    }
    var streamed = await request.send();
    var response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Error al detectar acorde');
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
