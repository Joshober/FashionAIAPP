import 'package:dio/dio.dart';

class HealthRepository {
  HealthRepository(this._dio);

  final Dio _dio;

  Future<bool> ping() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/api/health');
      return r.data?['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
