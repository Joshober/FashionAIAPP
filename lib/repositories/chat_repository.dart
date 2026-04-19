import 'dart:convert';

import 'package:dio/dio.dart';

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<({String reply, Map<String, dynamic>? outfitGeneration})> chat(String message) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat',
      data: {'message': message},
    );
    final d = r.data!;
    final og = d['outfitGeneration'];
    return (
      reply: d['reply']?.toString() ?? '',
      outfitGeneration: og is Map ? Map<String, dynamic>.from(og) : null,
    );
  }

  Future<String> transcribeWavBase64(String wavBase64) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat/transcribe',
      data: {'audio': wavBase64},
    );
    return r.data?['text']?.toString() ?? '';
  }

  Future<List<int>> tts(String text) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat/tts',
      data: {'text': text},
    );
    final audio = r.data?['audio']?.toString() ?? '';
    if (audio.isEmpty) return [];
    return base64Decode(audio);
  }
}
