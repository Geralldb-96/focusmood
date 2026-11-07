import '../core/api_client.dart';
import 'models.dart';

abstract interface class WellnessRepository {
  Future<List<WellnessActivity>> activities();
  Future<void> log(int activityId, {required bool completed});
}

class ApiWellnessRepository implements WellnessRepository {
  ApiWellnessRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<WellnessActivity>> activities() async => [
    for (final j in await _api.get('/wellness/activities') as List)
      WellnessActivity.fromJson(j as Map<String, dynamic>),
  ];

  @override
  Future<void> log(int activityId, {required bool completed}) => _api.post(
    '/wellness/logs',
    body: {'activityId': activityId, 'completed': completed},
  );
}
