import '../core/api_client.dart';
import 'models.dart';

abstract interface class ProgressRepository {
  Future<WeeklySummary> weekly();
}

class ApiProgressRepository implements ProgressRepository {
  ApiProgressRepository(this._api);

  final ApiClient _api;

  @override
  Future<WeeklySummary> weekly() async => WeeklySummary.fromJson(
    await _api.get('/progress/weekly') as Map<String, dynamic>,
  );
}
