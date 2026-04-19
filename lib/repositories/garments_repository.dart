import 'package:dio/dio.dart';

class GarmentsRepository {
  GarmentsRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> list() async {
    final r = await _dio.get<List<dynamic>>('/api/prendas');
    return (r.data ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>('/api/prendas/$id');
    return Map<String, dynamic>.from(r.data!);
  }

  Future<Map<String, dynamic>> upload(List<int> bytes, String filename) async {
    final form = FormData.fromMap({
      'imagen': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final r = await _dio.post<Map<String, dynamic>>('/api/prendas/upload', data: form);
    return Map<String, dynamic>.from(r.data!);
  }

  Future<Map<String, dynamic>> autoSave(Map<String, dynamic> body) async {
    final r = await _dio.post<Map<String, dynamic>>('/api/prendas/auto', data: body);
    return Map<String, dynamic>.from(r.data!);
  }

  Future<Map<String, dynamic>> updateOccasion(String id, List<String> ocasion) async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/api/prendas/$id/ocasion',
      data: {'ocasion': ocasion},
    );
    return Map<String, dynamic>.from(r.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/api/prendas/$id');
  }

  Future<Map<String, dynamic>> classifyVitBase64(String dataUrlOrB64) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/classify/vit-base64',
      data: {'imagen': dataUrlOrB64},
    );
    return Map<String, dynamic>.from(r.data!);
  }
}
