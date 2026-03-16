import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> startRecording() async {
    // El paquete 'record' maneja los permisos internamente en iOS/Android
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 22050,
        numChannels: 1,
      ),
      path: path,
    );
    return true;
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  void dispose() => _recorder.dispose();
}
