import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/habit_repository.dart';
import '../data/models.dart';
import 'refreshable.dart';

/// Hábitos (FCM-10, FCM-11). El icono elegido es solo visual y se guarda en el dispositivo.
class HabitsController extends ChangeNotifier implements Refreshable {
  HabitsController(this._repo, this._prefs, {this._onChanged});

  final HabitRepository _repo;
  final SharedPreferences _prefs;
  final Future<void> Function()? _onChanged;

  static const _iconKey = 'habit-icon-';

  List<Habit> habits = const [];
  bool loading = false;

  int get completed => habits.where((h) => h.completedToday).length;
  double get ratio => habits.isEmpty ? 0 : completed / habits.length;

  String iconOf(int id) => _prefs.getString('$_iconKey$id') ?? 'heart';

  @override
  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      habits = await _repo.list();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> save({
    Habit? editing,
    required HabitDraft draft,
    required String icon,
  }) async {
    final saved = editing == null
        ? await _repo.create(draft)
        : await _repo.update(editing.id, draft);
    await _prefs.setString('$_iconKey${saved.id}', icon);
    await load();
    await _onChanged?.call();
  }

  Future<void> toggle(Habit habit) async {
    try {
      if (habit.completedToday) {
        await _repo.undo(habit.id, DateTime.now());
      } else {
        await _repo.complete(habit.id);
      }
    } finally {
      await load();
      await _onChanged?.call();
    }
  }

  Future<void> remove(Habit habit) async {
    await _repo.delete(habit.id);
    await _prefs.remove('$_iconKey${habit.id}');
    await load();
    await _onChanged?.call();
  }

  @override
  void clear() {
    habits = const [];
    notifyListeners();
  }
}
