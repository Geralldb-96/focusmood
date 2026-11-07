import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/wellness_repository.dart';
import 'refreshable.dart';

/// Actividades de bienestar (FCM-14).
class WellnessController extends ChangeNotifier implements Refreshable {
  WellnessController(this._repo, {this._onChanged});

  final WellnessRepository _repo;
  final Future<void> Function()? _onChanged;

  List<WellnessActivity> activities = const [];

  @override
  Future<void> load() async {
    activities = await _repo.activities();
    notifyListeners();
  }

  Future<void> log(WellnessActivity activity, {required bool completed}) async {
    await _repo.log(activity.id, completed: completed);
    await _onChanged?.call();
  }

  @override
  void clear() {
    activities = const [];
    notifyListeners();
  }
}
