import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/recommendation_repository.dart';
import 'refreshable.dart';

/// Recomendaciones con IA (FCM-06..09).
class RecommendationController extends ChangeNotifier implements Refreshable {
  RecommendationController(this._repo, {this._onChanged});

  final RecommendationRepository _repo;
  final Future<void> Function()? _onChanged;

  List<Recommendation> history = const [];
  Recommendation? current;
  int _generation = 0;

  @override
  Future<void> load() async {
    history = await _repo.history();
    notifyListeners();
  }

  /// Devuelve la recomendación, o null si el usuario canceló mientras esperaba.
  Future<Recommendation?> generate(
    DailyInput input,
    int minutes,
    String activity,
  ) async {
    final id = ++_generation;
    final rec = await _repo.generate(input, minutes, activity);
    if (id != _generation) return null;
    current = rec;
    await load();
    await _onChanged?.call();
    return rec;
  }

  void cancelGeneration() => _generation++;

  void select(Recommendation rec) {
    current = rec;
    notifyListeners();
  }

  Future<void> rate(int score) async {
    final rec = current;
    if (rec == null) return;
    final updated = await _repo.rate(rec.id, score);
    current = updated;
    history = [for (final r in history) r.id == updated.id ? updated : r];
    notifyListeners();
    await _onChanged?.call();
  }

  @override
  void clear() {
    history = const [];
    current = null;
    _generation++;
    notifyListeners();
  }
}
