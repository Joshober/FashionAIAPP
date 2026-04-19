import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _kMirrorCtx = 'mirror_context_json';

class MirrorContext {
  const MirrorContext({
    this.occasion = '',
    this.weather = '',
    this.time = '',
    this.style = '',
    this.notes = '',
    this.location = '',
  });

  final String occasion;
  final String weather;
  final String time;
  final String style;
  final String notes;
  final String location;

  Map<String, dynamic> toJson() => {
        'occasion': occasion,
        'weather': weather,
        'time': time,
        'style': style,
        'notes': notes,
        'location': location,
      };

  factory MirrorContext.fromJson(Map<String, dynamic> j) {
    String s(String k) => j[k]?.toString() ?? '';
    return MirrorContext(
      occasion: s('occasion'),
      weather: s('weather'),
      time: s('time'),
      style: s('style'),
      notes: s('notes'),
      location: s('location'),
    );
  }
}

Future<MirrorContext> loadMirrorContext() async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString(_kMirrorCtx);
  if (raw == null || raw.isEmpty) return const MirrorContext();
  try {
    final m = jsonDecode(raw);
    if (m is Map) return MirrorContext.fromJson(Map<String, dynamic>.from(m));
  } catch (_) {
    /* ignore */
  }
  return const MirrorContext();
}

Future<void> saveMirrorContext(MirrorContext ctx) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_kMirrorCtx, jsonEncode(ctx.toJson()));
}

const kVoiceReplyKey = 'chat_voice_reply';

Future<bool> loadVoiceReplyEnabled() async {
  final sp = await SharedPreferences.getInstance();
  return sp.getBool(kVoiceReplyKey) ?? false;
}

Future<void> saveVoiceReplyEnabled(bool v) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setBool(kVoiceReplyKey, v);
}

const kGeneratedOutfitsKey = 'generated_outfits_json';

Future<List<Map<String, dynamic>>> loadGeneratedOutfitsCache() async {
  final sp = await SharedPreferences.getInstance();
  final raw = sp.getString(kGeneratedOutfitsKey);
  if (raw == null || raw.isEmpty) return [];
  try {
    final d = jsonDecode(raw);
    if (d is List) {
      return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  } catch (_) {
    /* ignore */
  }
  return [];
}

Future<void> saveGeneratedOutfitsCache(List<Map<String, dynamic>> items) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(kGeneratedOutfitsKey, jsonEncode(items));
}
