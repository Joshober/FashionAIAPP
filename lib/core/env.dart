import 'package:flutter_dotenv/flutter_dotenv.dart';

String envOrDefine(String key, {String defaultValue = ''}) {
  final v = dotenv.env[key];
  if (v != null && v.isNotEmpty) return v;
  return defaultValue;
}

/// Resolved API base URL: `--dart-define=API_BASE_URL=...` overrides `.env`.
String apiBaseUrl() {
  const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromDefine.isNotEmpty) return fromDefine;
  return envOrDefine('API_BASE_URL', defaultValue: 'http://127.0.0.1:4000');
}
