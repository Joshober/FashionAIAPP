import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';

bool auth0Configured() {
  final d = envOrDefine('AUTH0_DOMAIN').trim();
  final c = envOrDefine('AUTH0_CLIENT_ID').trim();
  return d.isNotEmpty && c.isNotEmpty;
}

String _normalizeDomain(String raw) {
  var s = raw.trim();
  s = s.replaceFirst(RegExp(r'^https?://'), '');
  if (s.endsWith('/')) s = s.substring(0, s.length - 1);
  return s;
}

class Auth0Service {
  Auth0Service(this._ref);

  final Ref _ref;

  String get _domain => _normalizeDomain(envOrDefine('AUTH0_DOMAIN'));
  String get _clientId => envOrDefine('AUTH0_CLIENT_ID').trim();
  String get _audience => envOrDefine('AUTH0_AUDIENCE').trim();

  String _redirectUri() {
    final explicit = envOrDefine('AUTH0_REDIRECT_URI').trim();
    if (explicit.isNotEmpty) return explicit;
    if (kIsWeb) return '${Uri.base.origin}/auth-callback';
    return 'fashionai.app.auth0://auth-callback';
  }

  String _callbackScheme() => Uri.parse(_redirectUri()).scheme;

  static String _pkceChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  static String _randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> login() async {
    final verifier = _randomString(64);
    final challenge = _pkceChallenge(verifier);
    final state = _randomString(24);
    final redirectUri = _redirectUri();

    final authUri = Uri.https(_domain, '/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': redirectUri,
      'scope': 'openid profile email',
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
      'state': state,
      if (_audience.isNotEmpty) 'audience': _audience,
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: _callbackScheme(),
    );

    final returned = Uri.parse(result);
    if (returned.queryParameters['state'] != state) {
      throw StateError('OAuth state mismatch');
    }
    final code = returned.queryParameters['code'];
    if (code == null || code.isEmpty) {
      final err = returned.queryParameters['error_description'] ?? returned.queryParameters['error'];
      throw StateError(err ?? 'No authorization code');
    }

    final res = await Dio().post<Map<String, dynamic>>(
      Uri.https(_domain, '/oauth/token').toString(),
      data: <String, dynamic>{
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': verifier,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final token = res.data?['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('Token response missing access_token');
    }
    await _ref.read(authTokenProvider.notifier).setToken(token);
  }

  Future<void> logout() async {
    await _ref.read(authTokenProvider.notifier).setToken(null);
  }
}

final auth0ServiceProvider = Provider<Auth0Service?>((ref) {
  if (!auth0Configured()) return null;
  return Auth0Service(ref);
});
