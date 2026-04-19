import 'package:dio/dio.dart';

class MirrorRepository {
  MirrorRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> analyze(String prompt) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/mirror/analyze',
      data: {'prompt': prompt},
    );
    return Map<String, dynamic>.from(r.data!);
  }

  Future<Map<String, dynamic>> analyzeFrame(String frameDataUrl, Map<String, dynamic> context) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/mirror/analyze-frame',
      data: {'frame': frameDataUrl, 'context': context},
    );
    return Map<String, dynamic>.from(r.data!);
  }
}
