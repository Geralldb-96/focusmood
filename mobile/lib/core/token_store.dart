import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Almacén de tokens abstracto (DIP): el cliente HTTP no sabe dónde se guardan.
abstract interface class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens? tokens);
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    try {
      final access = await _storage.read(key: 'access');
      final refresh = await _storage.read(key: 'refresh');
      if (refresh == null) return null;
      return AuthTokens(access: access ?? '', refresh: refresh);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(AuthTokens? tokens) async {
    try {
      if (tokens == null) {
        await _storage.delete(key: 'access');
        await _storage.delete(key: 'refresh');
      } else {
        await _storage.write(key: 'access', value: tokens.access);
        await _storage.write(key: 'refresh', value: tokens.refresh);
      }
    } catch (_) {
      // Almacenamiento no disponible: la sesión vivirá solo en memoria.
    }
  }
}

/// Almacén en memoria (pruebas).
class MemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens? tokens) async => _tokens = tokens;
}
