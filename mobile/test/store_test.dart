import 'dart:convert';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusmood/mood_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });
  test('recupera el esquema de datos de las versiones anteriores', () async {
    await prefs.setString(
      'mood-user',
      jsonEncode({
        'name': 'Andrea López',
        'email': 'a@campus.edu',
        'university': 'Libre',
        'career': 'Sistemas',
      }),
    );
    await prefs.setString(
      'mood-habits',
      jsonEncode([
        {
          'id': 9,
          'name': 'Leer',
          'goal': '20 minutos',
          'icon': 'book',
          'done': true,
        },
      ]),
    );
    final s = MoodStore(prefs)..load();
    expect(s.firstName, 'Andrea');
    expect(s.habits.single.done, isTrue);
    expect(s.dark, isTrue);
    s.dispose();
  });
  test('completa una sesión una sola vez y permite reiniciar', () {
    fakeAsync((time) {
      final s = MoodStore(prefs, now: time.getClock(DateTime(2026)).now);
      s.configureTimer(1);
      s.startTimer();
      s.pauseTimer();
      expect(s.started, isTrue);
      time.elapse(const Duration(seconds: 10));
      expect(s.seconds, 60);
      s.startTimer();
      time.elapse(const Duration(seconds: 20));
      expect(s.seconds, 40);
      s.pauseTimer();
      time.elapse(const Duration(seconds: 10));
      expect(s.seconds, 40);
      s.startTimer();
      time.elapse(const Duration(seconds: 40));
      expect(s.sessions.single.minutes, 1);
      expect(s.running, isFalse);
      s.finishTimer();
      expect(s.sessions.length, 1);
      expect(s.seconds, 60);
      s.dispose();
    });
  });
  test('borrar datos no guarda una sesión pendiente', () async {
    final s = MoodStore(prefs)..load();
    s.startTimer();
    await s.clear();
    expect(s.sessions, isEmpty);
    expect(s.habits, isEmpty);
    expect(s.running, isFalse);
    expect(prefs.getKeys().where((k) => k.startsWith('mood-')), isEmpty);
    s.dispose();
  });
}
