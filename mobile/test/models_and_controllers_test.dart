import 'package:flutter_test/flutter_test.dart';
import 'package:mood_app/data/models.dart';
import 'package:mood_app/data/study_repository.dart';
import 'package:mood_app/state/study_controller.dart';

class _FakeStudyRepo implements StudyRepository {
  final recorded = <Map<String, Object>>[];

  @override
  Future<List<StudySession>> sessions() async => const [];

  @override
  Future<void> record({
    required DateTime startedAt,
    required DateTime endedAt,
    required String activity,
    required int durationMinutes,
    required int focusMinutes,
    required bool completed,
  }) async {
    recorded.add({'minutes': durationMinutes, 'completed': completed, 'focus': focusMinutes});
  }
}

void main() {
  group('DailyInput', () {
    test('convierte sliders 0-10 a la escala 1-5 del backend', () {
      expect(DailyInput.level(0), 1);
      expect(DailyInput.level(1), 1);
      expect(DailyInput.level(2), 1);
      expect(DailyInput.level(3), 2);
      expect(DailyInput.level(10), 5);
    });

    test('mapea el ánimo a un estado discreto', () {
      expect(const DailyInput(mood: 0, energy: 6, focus: 4).toJson()['mood'], 'ESTRESADO');
      expect(const DailyInput(mood: 7, energy: 6, focus: 4).toJson(), {'mood': 'CALMADO', 'energyLevel': 3, 'concentrationLevel': 2});
      expect(const DailyInput(mood: 10, energy: 10, focus: 10).toJson()['mood'], 'FELIZ');
    });
  });

  group('Recommendation', () {
    test('separa las instrucciones en pasos', () {
      final rec = Recommendation.fromJson({
        'id': 1,
        'category': 'STUDY_TECHNIQUE',
        'title': 'Pomodoro',
        'technique': 'Pomodoro',
        'durationMinutes': 25,
        'instructions': 'Silencia el celular. Trabaja 25 minutos! Descansa 5.',
        'source': 'reglas-locales',
        'generatedAt': '2026-11-05T12:00:00Z',
        'context': {'academicActivity': 'Examen'},
        'rating': {'score': 5},
        'disclaimer': 'x',
      });
      expect(rec.steps, ['Silencia el celular.', 'Trabaja 25 minutos!', 'Descansa 5.']);
      expect(rec.fromFallback, isTrue);
      expect(rec.helpful, isTrue);
    });
  });

  group('UserProfile', () {
    test('iniciales, nombre y universidad desde preferencias', () {
      final p = UserProfile.fromJson({'name': 'Andrea Prueba Díaz', 'email': 'a@b.co', 'preferences': '{"university":"Libre"}'});
      expect(p.initials, 'AP');
      expect(p.firstName, 'Andrea');
      expect(p.university, 'Libre');
    });

    test('tolera preferencias inválidas', () {
      expect(UserProfile.fromJson({'name': 'A', 'email': 'a@b.co', 'preferences': 'no-json'}).university, '');
    });
  });

  group('StudyController', () {
    test('completa la sesión al llegar a cero y la registra', () async {
      final repo = _FakeStudyRepo();
      final c = StudyController(repo)..setMinutes(1);
      c.start();
      for (var i = 0; i < 60; i++) {
        c.tick();
      }
      await Future<void>.delayed(Duration.zero);
      expect(repo.recorded, [
        {'minutes': 1, 'completed': true, 'focus': 1}
      ]);
      expect(c.started, isFalse);
      expect(c.running, isFalse);
      expect(c.remaining, 60);
      c.dispose();
    });

    test('al finalizar antes de tiempo registra los minutos reales como interrumpida', () async {
      final repo = _FakeStudyRepo();
      final c = StudyController(repo)..setMinutes(25);
      c.start();
      for (var i = 0; i < 180; i++) {
        c.tick();
      }
      await c.finishEarly();
      expect(repo.recorded.single, {'minutes': 3, 'completed': false, 'focus': 25});
      c.dispose();
    });

    test('no registra sesiones de menos de 30 segundos', () async {
      final repo = _FakeStudyRepo();
      final c = StudyController(repo);
      c.start();
      for (var i = 0; i < 10; i++) {
        c.tick();
      }
      await c.finishEarly();
      expect(repo.recorded, isEmpty);
      c.dispose();
    });

    test('la pausa detiene el conteo', () {
      final c = StudyController(_FakeStudyRepo());
      c.start();
      c.tick();
      c.pause();
      c.tick();
      expect(c.remaining, 25 * 60 - 1);
      c.dispose();
    });
  });
}
