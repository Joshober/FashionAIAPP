import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Production API (Render). Override with `assets/env/*.env` or `--dart-define=API_BASE_URL=...` for local dev.
const String kDefaultApiBaseUrl = 'https://fashionai-api-6w7k.onrender.com';

String envOrDefine(String key, {String defaultValue = ''}) {
  final v = dotenv.env[key];
  if (v != null && v.isNotEmpty) return v;
  return defaultValue;
}

/// `--dart-define=API_BASE_URL=...` overrides `.env` (e.g. Render `Dockerfile.web`).
String apiBaseUrl() {
  const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromDefine.isNotEmpty) return fromDefine;
  return envOrDefine('API_BASE_URL', defaultValue: kDefaultApiBaseUrl);
}
