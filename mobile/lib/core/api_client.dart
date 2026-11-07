import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'token_store.dart';

/// Cliente REST: agrega el JWT, renueva la sesión con el refresh token ante un 401
/// (una sola renovación a la vez) y traduce los errores del backend (ProblemDetail).
class ApiClient {
  ApiClient({
    required http.Client httpClient,
    required TokenStore tokenStore,
    required String baseUrl,
  }) : _http = httpClient,
       _store = tokenStore,
       _base = '$baseUrl/api/v1';

  final http.Client _http;
  final TokenStore _store;
  final String _base;

  AuthTokens? _tokens;
  bool _loaded = false;
  Future<void>? _refreshing;

  /// Se invoca cuando la sesión ya no se puede renovar.
  void Function()? onSessionExpired;

  Future<bool> hasSession() async {
    await _ensureLoaded();
    return _tokens != null;
  }

  Future<void> saveTokens(String access, String refresh) async {
    _tokens = AuthTokens(access: access, refresh: refresh);
    _loaded = true;
    await _store.write(_tokens);
  }

  Future<void> clearTokens() async {
    _tokens = null;
    _loaded = true;
    await _store.write(null);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _request('POST', path, body: body ?? const {}, auth: auth);
  Future<dynamic> put(String path, {Object? body}) =>
      _request('PUT', path, body: body ?? const {});
  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _tokens = await _store.read();
    _loaded = true;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    if (!auth) return _send(method, path, body: body, query: query);
    await _ensureLoaded();
    if (_tokens == null) {
      throw ApiException(
        'Tu sesión expiró. Inicia sesión de nuevo.',
        status: 401,
      );
    }
    if (_tokens!.access.isEmpty) await _refresh();
    try {
      return await _send(
        method,
        path,
        body: body,
        query: query,
        token: _tokens!.access,
      );
    } on ApiException catch (e) {
      if (!e.isUnauthorized) rethrow;
      await _refresh();
      return _send(
        method,
        path,
        body: body,
        query: query,
        token: _tokens!.access,
      );
    }
  }

  Future<void> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _doRefresh() async {
    final refresh = _tokens?.refresh;
    if (refresh == null) {
      throw ApiException(
        'Tu sesión expiró. Inicia sesión de nuevo.',
        status: 401,
      );
    }
    try {
      final res = await _send(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refresh},
      ) as Map<String, dynamic>;
      await saveTokens(res['token'] as String, res['refreshToken'] as String);
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 400) {
        await clearTokens();
        onSessionExpired?.call();
      }
      rethrow;
    }
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    String? token,
  }) async {
    final uri = Uri.parse('$_base$path').replace(queryParameters: query);
    final request = http.Request(method, uri);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(const Duration(seconds: 25)),
      );
    } on Exception {
      throw ApiException(
        'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
    final text = utf8.decode(response.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } on FormatException {
        data = null;
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    String message = 'Ocurrió un error inesperado.';
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        message = errors.values.first.toString();
      } else if (data['detail'] is String) {
        message = data['detail'] as String;
      }
    }
    throw ApiException(message, status: response.statusCode);
  }
}
