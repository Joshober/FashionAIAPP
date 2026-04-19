import 'package:flutter_dotenv/flutter_dotenv.dart';

String envOrDefine(String key, {String defaultValue = ''}) {
  final v = dotenv.env[key];
  if (v != null && v.isNotEmpty) return v;
  return defaultValue;
}

String apiBaseUrl() => envOrDefine('API_BASE_URL', defaultValue: 'http://127.0.0.1:4000');

String auth0Domain() => envOrDefine('AUTH0_DOMAIN');
String auth0ClientId() => envOrDefine('AUTH0_CLIENT_ID');
String auth0Audience() => envOrDefine('AUTH0_AUDIENCE');
String auth0Scheme() => envOrDefine('AUTH0_SCHEME', defaultValue: 'fashionai');

bool auth0Configured() =>
    auth0Domain().isNotEmpty && auth0ClientId().isNotEmpty;
