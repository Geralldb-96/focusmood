import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mood_app/app.dart';
import 'package:mood_app/core/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

Future<void> _pump(WidgetTester tester, MockClientHandler handler) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MoodApp(
    prefs: await SharedPreferences.getInstance(),
    httpClient: MockClient(handler),
    tokenStore: MemoryTokenStore(),
    baseUrl: 'http://api.test',
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('sin sesión muestra la bienvenida y permite ir a registrarse', (tester) async {
    await _pump(tester, (_) async => _json({}, 500));
    expect(find.text('Comenzar'), findsOneWidget);
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu espacio'), findsOneWidget);
  });

  testWidgets('valida el formulario de registro sin llamar al servidor', (tester) async {
    var calls = 0;
    await _pump(tester, (_) async {
      calls++;
      return _json({}, 500);
    });
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta').last);
    await tester.pumpAndSettle();
    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('Debes aceptar las condiciones para continuar'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('un inicio de sesión incorrecto muestra el mensaje del servidor', (tester) async {
    await _pump(tester, (req) async {
      if (req.url.path.endsWith('/auth/login')) return _json({'detail': 'Correo o contraseña incorrectos.'}, 401);
      return _json({}, 500);
    });
    await tester.tap(find.text('Inicia sesión'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'a@campus.edu');
    await tester.enterText(find.byType(TextFormField).at(1), 'Equivocada1');
    await tester.tap(find.text('Iniciar sesión').last);
    await tester.pumpAndSettle();
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('un inicio de sesión correcto lleva al inicio con los datos del usuario', (tester) async {
    await _pump(tester, (req) async {
      final path = req.url.path;
      if (path.endsWith('/auth/login')) return _json({'token': 't', 'refreshToken': 'r', 'user': {'id': 1}});
      if (path.endsWith('/profile')) return _json({'name': 'Andrea Prueba', 'email': 'a@campus.edu'});
      if (path.endsWith('/habits') || path.endsWith('/study-sessions') || path.endsWith('/recommendations') || path.endsWith('/wellness/activities')) {
        return _json([]);
      }
      if (path.endsWith('/progress/weekly')) {
        return _json({
          'weekStart': '2026-11-02',
          'weekEnd': '2026-11-08',
          'hasData': false,
          'message': 'Sin registros',
          'mood': {'entries': 0, 'points': []},
          'habits': {'completed': 0, 'expected': 0},
          'study': {'sessions': 0, 'totalMinutes': 0},
          'recommendations': {'rated': 0, 'helpful': 0},
        });
      }
      return _json({}, 404);
    });
    await tester.tap(find.text('Inicia sesión'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'a@campus.edu');
    await tester.enterText(find.byType(TextFormField).at(1), 'Clave1234');
    await tester.tap(find.text('Iniciar sesión').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Hola, Andrea'), findsOneWidget);
    expect(find.text('Registrar mi día'), findsOneWidget);
  });
}
