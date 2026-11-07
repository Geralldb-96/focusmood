import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/progress_repository.dart';
import 'refreshable.dart';

class ProgressController extends ChangeNotifier implements Refreshable {
  ProgressController(this._repo);

  final ProgressRepository _repo;

  WeeklySummary? summary;
  bool loading = false;

  @override
  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      summary = await _repo.weekly();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Recarga silenciosa tras cambios en otros módulos.
  Future<void> refreshQuietly() => load().catchError((Object _) {});

  @override
  void clear() {
    summary = null;
    notifyListeners();
  }
}
