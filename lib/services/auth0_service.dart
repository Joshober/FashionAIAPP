import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';
final auth0ServiceProvider = Provider<Auth0Service?>((ref) {
  if (!auth0Configured()) return null;
  return Auth0Service(ref);
});

class Auth0Service {
  Auth0Service(this._ref)
      : _auth0 = Auth0(auth0Domain(), auth0ClientId());

  final Ref _ref;
  final Auth0 _auth0;

  Future<void> login() async {
    final credentials = await _auth0.webAuthentication(scheme: auth0Scheme()).login(
      audience: auth0Audience().isEmpty ? null : auth0Audience(),
    );
    final at = credentials.accessToken;
    await _ref.read(authTokenProvider.notifier).setToken(at.isEmpty ? null : at);
  }

  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: auth0Scheme()).logout();
    } catch (_) {
      /* ignore */
    }
    await _ref.read(authTokenProvider.notifier).setToken(null);
  }
}
