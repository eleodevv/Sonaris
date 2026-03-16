import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../services/api_service.dart';
import '../services/audio_service.dart';

// Acordes por nivel (mismo que el algoritmo DSP)
const Map<String, List<String>> acordesBasicos = {
  'A': ['A', 'C#', 'E'], 'Am': ['A', 'C', 'E'], 'C': ['C', 'E', 'G'],
  'D': ['D', 'F#', 'A'], 'Dm': ['D', 'F', 'A'], 'E': ['E', 'G#', 'B'],
  'Em': ['E', 'G', 'B'], 'G': ['G', 'B', 'D'],
  'C7': ['C', 'E', 'G', 'A#'], 'G7': ['G', 'B', 'D', 'F'],
};

const Map<String, List<String>> acordesMedios = {
  'F': ['F', 'A', 'C'], 'Bm': ['B', 'D', 'F#'],
  'A7': ['A', 'C#', 'E', 'G'], 'E7': ['E', 'G#', 'B', 'D'],
  'Am7': ['A', 'C', 'E', 'G'], 'Cmaj7': ['C', 'E', 'G', 'B'],
  'Dsus4': ['D', 'G', 'A'], 'Asus4': ['A', 'D', 'E'],
};

const Map<String, List<String>> acordesAvanzados = {
  'Gm': ['G', 'A#', 'D'],
  'F#m': ['F#', 'A', 'C#'],
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();

  String _nivel = 'basico';
  String? _acordeSeleccionado;
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordingProgress = 0;
  Timer? _timer;
  Map<String, dynamic>? _resultado;
  bool _serverOnline = false;

  Map<String, List<String>> get _acordesActuales {
    if (_nivel == 'medio') return acordesMedios;
    if (_nivel == 'avanzado') return acordesAvanzados;
    return acordesBasicos;
  }

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkServer() async {
    final online = await context.read<ApiService>().checkHealth();
    setState(() => _serverOnline = online);
  }

  void _cambiarNivel(String nivel) {
    setState(() {
      _nivel = nivel;
      _acordeSeleccionado = null;
      _resultado = null;
    });
  }

  void _seleccionarAleatorio() {
    final keys = _acordesActuales.keys.toList();
    setState(() {
      _acordeSeleccionado = keys[Random().nextInt(keys.length)];
      _resultado = null;
    });
  }

  Future<void> _startRecording() async {
    if (_acordeSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un acorde primero')),
      );
      return;
    }
    final ok = await _audioService.startRecording();
    if (!ok) return;

    setState(() {
      _isRecording = true;
      _recordingProgress = 0;
      _resultado = null;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _recordingProgress++);
      if (_recordingProgress >= 30) {
        t.cancel();
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
      _recordingProgress = 0;
    });
    if (path != null) await _procesarAudio(path);
  }

  Future<void> _procesarAudio(String path) async {
    setState(() => _isProcessing = true);
    try {
      final result = await context.read<ApiService>().detectarAcorde(
            path,
            acordeEsperado: _acordeSeleccionado,
          );
      setState(() => _resultado = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎸 Sonaris'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              _serverOnline ? Icons.cloud_done : Icons.cloud_off,
              color: _serverOnline ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNivelSelector(),
            const SizedBox(height: 16),
            _buildAcordeSelector(),
            const SizedBox(height: 16),
            _buildInfoAcorde(),
            const SizedBox(height: 24),
            _buildRecordButton(),
            if (_isRecording || _isProcessing) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _isRecording ? _recordingProgress / 30 : null,
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _isProcessing ? 'Analizando...' : 'Grabando...',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildResultado(),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nivel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _nivelChip('🟢 Básico', 'basico')),
                const SizedBox(width: 8),
                Expanded(child: _nivelChip('🟡 Medio', 'medio')),
                const SizedBox(width: 8),
                Expanded(child: _nivelChip('🔴 Avanzado', 'avanzado')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nivelChip(String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _nivel == value,
      onSelected: (_) => _cambiarNivel(value),
    );
  }

  Widget _buildAcordeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acorde', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _acordeSeleccionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: 'Elige un acorde',
                    ),
                    items: _acordesActuales.keys.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Text(a, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _acordeSeleccionado = v;
                      _resultado = null;
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _seleccionarAleatorio,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Aleatorio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAcorde() {
    if (_acordeSeleccionado == null) return const SizedBox.shrink();
    final notas = _acordesActuales[_acordeSeleccionado!] ?? [];
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _acordeSeleccionado!,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text('Notas: ${notas.join(' - ')}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : (_isRecording ? _stopRecording : _startRecording),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
      label: Text(_isRecording ? 'GRABANDO...' : '🎤 GRABAR (3 seg)'),
    );
  }

  Widget _buildResultado() {
    if (_resultado == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              _acordeSeleccionado == null
                  ? 'Selecciona un acorde para comenzar'
                  : 'Presiona GRABAR y toca el acorde',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final esCorrecto = _resultado!['es_correcto'] ?? false;
    final acordeDetectado = _resultado!['acorde_detectado'] ?? '?';
    final confianza = (_resultado!['confianza'] ?? 0.0).toDouble();
    final notas = List<String>.from(_resultado!['notas_detectadas'] ?? []);

    return Card(
      color: esCorrecto ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              esCorrecto ? Icons.check_circle : Icons.cancel,
              size: 72,
              color: esCorrecto ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              esCorrecto ? '¡CORRECTO!' : 'Intenta de nuevo',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: esCorrecto ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text('Detectado: $acordeDetectado', style: const TextStyle(fontSize: 18)),
            Text('Confianza: ${confianza.toStringAsFixed(1)}%'),
            if (notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notas: ${notas.join(', ')}', style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}
