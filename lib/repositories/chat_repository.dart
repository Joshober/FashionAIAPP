import 'dart:convert';

import 'package:dio/dio.dart';

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<({String reply, Map<String, dynamic>? outfitGeneration})> chat(String message) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat',
      data: {
        // Web parity payload
        'messages': [
          {'role': 'user', 'content': message},
        ],
        // Backward compatibility for older backend variants.
        'message': message,
      },
    );
    final d = r.data ?? const <String, dynamic>{};
    final og = d['outfitGeneration'];
    final nested = d['message'];
    final nestedContent = nested is Map ? nested['content']?.toString() : null;
    return (
      reply: d['reply']?.toString() ?? nestedContent ?? '',
      outfitGeneration: og is Map ? Map<String, dynamic>.from(og) : null,
    );
  }

  Future<String> transcribeWavBase64(String wavBase64) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat/transcribe',
      data: {
        // Web parity payload
        'audioBase64': wavBase64,
        'format': 'wav',
        // Backward compatibility key.
        'audio': wavBase64,
      },
    );
    return r.data?['text']?.toString() ?? '';
  }

  Future<List<int>> tts(String text) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/chat/tts',
      data: {'text': text},
    );
    final audio = r.data?['audioBase64']?.toString() ?? r.data?['audio']?.toString() ?? '';
    if (audio.isEmpty) return [];
    return base64Decode(audio);
  }
}
