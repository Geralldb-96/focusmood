import '../core/api_client.dart';
import 'models.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> list();
  Future<Habit> create(HabitDraft draft);
  Future<Habit> update(int id, HabitDraft draft);
  Future<void> delete(int id);
  Future<void> complete(int id);
  Future<void> undo(int id, DateTime date);
}

class ApiHabitRepository implements HabitRepository {
  ApiHabitRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Habit>> list() async => [
    for (final j in await _api.get('/habits') as List)
      Habit.fromJson(j as Map<String, dynamic>),
  ];

  @override
  Future<Habit> create(HabitDraft draft) async => Habit.fromJson(
    await _api.post('/habits', body: draft.toJson()) as Map<String, dynamic>,
  );

  @override
  Future<Habit> update(int id, HabitDraft draft) async => Habit.fromJson(
    await _api.put('/habits/$id', body: draft.toJson()) as Map<String, dynamic>,
  );

  @override
  Future<void> delete(int id) => _api.delete('/habits/$id');

  @override
  Future<void> complete(int id) => _api.post('/habits/$id/completions');

  @override
  Future<void> undo(int id, DateTime date) {
    final d =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _api.delete('/habits/$id/completions/$d');
  }
}
