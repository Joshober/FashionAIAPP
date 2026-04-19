import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccess = 'access_token';

class AuthTokenNotifier extends StateNotifier<String?> {
  AuthTokenNotifier() : super(null);

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> restore() async {
    state = await _storage.read(key: _kAccess);
  }

  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _kAccess);
      state = null;
    } else {
      await _storage.write(key: _kAccess, value: token);
      state = token;
    }
  }
}

final authTokenProvider =
    StateNotifierProvider<AuthTokenNotifier, String?>((ref) => AuthTokenNotifier());
