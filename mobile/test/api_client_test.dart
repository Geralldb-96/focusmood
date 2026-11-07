import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mood_app/core/api_client.dart';
import 'package:mood_app/core/api_exception.dart';
import 'package:mood_app/core/token_store.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  late MemoryTokenStore store;

  setUp(() => store = MemoryTokenStore());

  ApiClient clientFor(MockClientHandler handler) =>
      ApiClient(httpClient: MockClient(handler), tokenStore: store, baseUrl: 'http://api.test');

  test('envía el JWT en las solicitudes autenticadas', () async {
    String? header;
    final api = clientFor((req) async {
      header = req.headers['Authorization'];
      return _json({'ok': true});
    });
    await api.saveTokens('access-1', 'refresh-1');
    await api.get('/habits');
    expect(header, 'Bearer access-1');
  });

  test('ante un 401 renueva el token una sola vez y reintenta', () async {
    var refreshCalls = 0;
    final seen = <String>[];
    final api = clientFor((req) async {
      if (req.url.path.endsWith('/auth/refresh')) {
        refreshCalls++;
        expect(jsonDecode(req.body), {'refreshToken': 'refresh-1'});
        return _json({'token': 'access-2', 'refreshToken': 'refresh-2'});
      }
      seen.add(req.headers['Authorization']!);
      return req.headers['Authorization'] == 'Bearer access-2' ? _json([]) : _json({'detail': 'expiró'}, 401);
    });
    await api.saveTokens('access-1', 'refresh-1');

    // Dos solicitudes simultáneas: deben compartir una única renovación.
    await Future.wait([api.get('/habits'), api.get('/study-sessions')]);

    expect(refreshCalls, 1);
    expect(seen.where((h) => h == 'Bearer access-2'), hasLength(2));
    expect((await store.read())!.refresh, 'refresh-2');
  });

  test('si el refresh falla, borra la sesión y avisa que expiró', () async {
    var expired = false;
    final api = clientFor((req) async => _json({'detail': 'La sesión no es válida'}, 401))..onSessionExpired = () => expired = true;
    await api.saveTokens('access-1', 'refresh-1');

    await expectLater(api.get('/habits'), throwsA(isA<ApiException>()));
    expect(expired, isTrue);
    expect(await store.read(), isNull);
    expect(await api.hasSession(), isFalse);
  });

  test('traduce errores de validación al primer mensaje del campo', () async {
    final api = clientFor((req) async => _json({'detail': 'Hay datos que debes corregir.', 'errors': {'password': 'Contraseña débil'}}, 400));
    await expectLater(
      api.post('/auth/register', auth: false, body: {}),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Contraseña débil').having((e) => e.status, 'status', 400)),
    );
  });

  test('un fallo de red produce un mensaje claro y status 0', () async {
    final api = clientFor((req) async => throw http.ClientException('sin red'));
    await expectLater(
      api.post('/auth/login', auth: false, body: {}),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 0).having((e) => e.message, 'message', contains('No se pudo conectar'))),
    );
  });

  test('un 401 de login (auth: false) no intenta renovar la sesión', () async {
    var refreshCalls = 0;
    final api = clientFor((req) async {
      if (req.url.path.endsWith('/auth/refresh')) refreshCalls++;
      return _json({'detail': 'Correo o contraseña incorrectos.'}, 401);
    });
    await expectLater(api.post('/auth/login', auth: false, body: {}), throwsA(isA<ApiException>()));
    expect(refreshCalls, 0);
  });
}
