import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_token.dart';
import 'dio_client.dart';

final authSessionProvider = Provider<AuthSession>((ref) => AuthSession(ref));

class AuthSession {
  AuthSession(this._ref);

  final Ref _ref;

  Future<void> signOut() => _ref.read(authTokenProvider.notifier).setToken(null);

  Future<void> signIn(String email, String password) async {
    await _postAuth('/api/auth/signin', email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _postAuth('/api/auth/signup', email, password);
  }

  Future<void> _postAuth(String path, String email, String password) async {
    final dio = _ref.read(dioProvider);
    final res = await dio.post<Map<String, dynamic>>(
      path,
      data: {'email': email.trim(), 'password': password},
    );
    final token = res.data?['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Server did not return access_token',
      );
    }
    await _ref.read(authTokenProvider.notifier).setToken(token);
  }
}
