import '../core/api_client.dart';
import 'models.dart';

abstract interface class StudyRepository {
  Future<List<StudySession>> sessions();
  Future<void> record({
    required DateTime startedAt,
    required DateTime endedAt,
    required String activity,
    required int durationMinutes,
    required int focusMinutes,
    required bool completed,
  });
}

class ApiStudyRepository implements StudyRepository {
  ApiStudyRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<StudySession>> sessions() async => [
    for (final j in await _api.get('/study-sessions') as List)
      StudySession.fromJson(j as Map<String, dynamic>),
  ];

  @override
  Future<void> record({
    required DateTime startedAt,
    required DateTime endedAt,
    required String activity,
    required int durationMinutes,
    required int focusMinutes,
    required bool completed,
  }) {
    final status = completed ? 'COMPLETED' : 'INTERRUPTED';
    return _api.post(
      '/study-sessions',
      body: {
        'startedAt': startedAt.toUtc().toIso8601String(),
        'endedAt': endedAt.toUtc().toIso8601String(),
        'activity': activity,
        'durationMinutes': durationMinutes,
        'status': status,
        'cycles': [
          {
            'focusMinutes': focusMinutes.clamp(1, 180),
            'breakMinutes': 5,
            'completedCycles': completed ? 1 : 0,
            'status': status,
          },
        ],
      },
    );
  }
}
