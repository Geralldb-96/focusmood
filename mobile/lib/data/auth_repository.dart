import 'dart:convert';

import '../core/api_client.dart';
import 'models.dart';

abstract interface class AuthRepository {
  Future<void> register(String name, String email, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<bool> hasSession();
  Future<UserProfile> profile();
  Future<UserProfile> updateProfile({
    required String name,
    String? career,
    required String university,
  });
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api);

  final ApiClient _api;

  Future<void> _store(dynamic res) => _api.saveTokens(
    (res as Map)['token'] as String,
    res['refreshToken'] as String,
  );

  @override
  Future<void> register(String name, String email, String password) async =>
      _store(
        await _api.post(
          '/auth/register',
          auth: false,
          body: {
            'name': name,
            'email': email,
            'password': password,
            'confirmPassword': password,
            'acceptTerms': true,
          },
        ),
      );

  @override
  Future<void> login(String email, String password) async => _store(
    await _api.post(
      '/auth/login',
      auth: false,
      body: {'email': email, 'password': password},
    ),
  );

  @override
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // el token local se descarta igualmente
    }
    await _api.clearTokens();
  }

  @override
  Future<void> forgotPassword(String email) =>
      _api.post('/auth/forgot-password', auth: false, body: {'email': email});

  @override
  Future<bool> hasSession() => _api.hasSession();

  @override
  Future<UserProfile> profile() async =>
      UserProfile.fromJson(await _api.get('/profile') as Map<String, dynamic>);

  @override
  Future<UserProfile> updateProfile({
    required String name,
    String? career,
    required String university,
  }) async {
    final res = await _api.put(
      '/profile',
      body: {
        'name': name,
        'career': (career == null || career.isEmpty) ? null : career,
        'preferences': jsonEncode({'university': university}),
      },
    );
    return UserProfile.fromJson(res as Map<String, dynamic>);
  }
}
