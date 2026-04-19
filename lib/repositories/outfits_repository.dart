import 'package:dio/dio.dart';

class OutfitsRepository {
  OutfitsRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> recommend(Map<String, String> query) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/outfits/recommend',
      queryParameters: query,
    );
    final recs = r.data?['recommendations'];
    if (recs is! List) return [];
    return recs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> save(Map<String, dynamic> body) async {
    final r = await _dio.post<Map<String, dynamic>>('/api/outfits/save', data: body);
    return Map<String, dynamic>.from(r.data!);
  }

  Future<List<Map<String, dynamic>>> list() async {
    final r = await _dio.get<List<dynamic>>('/api/outfits');
    return (r.data ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>('/api/outfits/$id');
    return Map<String, dynamic>.from(r.data!);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/api/outfits/$id');
  }
}
