import 'package:dio/dio.dart';

class MirrorRepository {
  MirrorRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> analyze(String prompt) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/mirror/analyze',
      data: {
        // Web parity key
        'userPrompt': prompt,
        // Backward compatibility key
        'prompt': prompt,
      },
    );
    return Map<String, dynamic>.from(r.data!);
  }

  Future<Map<String, dynamic>> analyzeFrame(
    String frameDataUrl,
    Map<String, dynamic> context, {
    String userNotes = '',
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/mirror/analyze-frame',
      data: {
        // Web parity keys
        'imageDataUrl': frameDataUrl,
        'context': context,
        'userNotes': userNotes,
        // Backward compatibility key
        'frame': frameDataUrl,
      },
    );
    return Map<String, dynamic>.from(r.data!);
  }
}
