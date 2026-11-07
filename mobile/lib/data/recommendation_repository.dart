import '../core/api_client.dart';
import '../core/api_exception.dart';
import 'models.dart';

abstract interface class RecommendationRepository {
  Future<Recommendation> generate(
    DailyInput input,
    int availableMinutes,
    String activity,
  );
  Future<List<Recommendation>> history();
  Future<Recommendation> rate(int id, int score);
}

class ApiRecommendationRepository implements RecommendationRepository {
  ApiRecommendationRepository(this._api);

  final ApiClient _api;

  /// Guarda (o actualiza) el registro de hoy y solicita la recomendación sobre él.
  @override
  Future<Recommendation> generate(
    DailyInput input,
    int availableMinutes,
    String activity,
  ) async {
    final log = await _saveDaily(input);
    final res = await _api.post(
      '/recommendations',
      body: {
        'dailyLogId': log['id'],
        'availableMinutes': availableMinutes,
        'academicActivity': activity,
      },
    );
    return Recommendation.fromJson(res as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _saveDaily(DailyInput input) async {
    try {
      return await _api.post('/daily-logs', body: input.toJson())
          as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (!e.isConflict) rethrow;
      final today = await _api.get('/daily-logs/today') as Map<String, dynamic>;
      return await _api.put('/daily-logs/${today['id']}', body: input.toJson())
          as Map<String, dynamic>;
    }
  }

  @override
  Future<List<Recommendation>> history() async => [
    for (final j in await _api.get('/recommendations') as List)
      Recommendation.fromJson(j as Map<String, dynamic>),
  ];

  @override
  Future<Recommendation> rate(int id, int score) async =>
      Recommendation.fromJson(
        await _api.put('/recommendations/$id/rating', body: {'score': score})
            as Map<String, dynamic>,
      );
}
