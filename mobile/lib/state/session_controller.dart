import 'package:flutter/foundation.dart';

import '../core/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/models.dart';
import 'refreshable.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Sesión del usuario: autenticación y perfil (FCM-01..04, FCM-17).
class SessionController extends ChangeNotifier {
  SessionController(this._auth, this._data);

  final AuthRepository _auth;
  final List<Refreshable> _data;

  AuthStatus status = AuthStatus.unknown;
  UserProfile user = UserProfile.empty;
  bool busy = false;
  String? error;

  Future<void> bootstrap() async {
    if (await _auth.hasSession()) {
      try {
        await _enter();
        return;
      } catch (_) {
        // sin red o sesión inválida: se pide iniciar sesión
      }
    }
    status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<bool> login(String email, String password) =>
      _authenticate(() => _auth.login(email.trim(), password));

  Future<bool> register(String name, String email, String password) =>
      _authenticate(() => _auth.register(name.trim(), email.trim(), password));

  Future<bool> _authenticate(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      await _enter();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _enter() async {
    user = await _auth.profile();
    status = AuthStatus.signedIn;
    notifyListeners();
    await Future.wait(_data.map((d) => d.load().catchError((Object _) {})));
  }

  Future<void> forgotPassword(String email) =>
      _auth.forgotPassword(email.trim());

  Future<void> updateProfile({
    required String name,
    required String career,
    required String university,
  }) async {
    user = await _auth.updateProfile(
      name: name.trim(),
      career: career.trim(),
      university: university.trim(),
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _signedOut();
  }

  /// La sesión no se pudo renovar (o se borraron los datos del dispositivo).
  void expire() => _signedOut();

  void _signedOut() {
    for (final d in _data) {
      d.clear();
    }
    user = UserProfile.empty;
    error = null;
    status = AuthStatus.signedOut;
    notifyListeners();
  }
}
