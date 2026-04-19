import 'package:dio/dio.dart';

class PreferencesRepository {
  PreferencesRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getPreferences() async {
    final r = await _dio.get<Map<String, dynamic>>('/api/me/preferences');
    final p = r.data?['preferences'];
    if (p is Map) return Map<String, dynamic>.from(p);
    return {};
  }

  Future<Map<String, dynamic>> putPreferences(Map<String, dynamic> preferences) async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/api/me/preferences',
      data: {'preferences': preferences},
    );
    final p = r.data?['preferences'];
    if (p is Map) return Map<String, dynamic>.from(p);
    return {};
  }
}
