import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/focus/domain/focus_session.dart';
import 'features/habits/domain/habit.dart';

import 'legacy_storage.dart'
    if (dart.library.js_interop) 'legacy_storage_web.dart';
export 'features/focus/domain/focus_session.dart';
export 'features/habits/domain/habit.dart';

class MoodStore extends ChangeNotifier {
  MoodStore(this.prefs, {DateTime Function()? now}) : now = now ?? DateTime.now;
  final DateTime Function() now;
  final SharedPreferences prefs;
  Map<String, String> profile = {
    'name': 'Tomás Cabrejo',
    'email': 'angelt-cabrejos@campus.edu',
    'university': 'Universidad Libre',
    'career': 'Ingeniería de Sistemas · 7° Semestre',
  };
  List<Habit> habits = [
    Habit(
      id: 1,
      name: 'Tomar agua',
      goal: '6 de 8 vasos',
      icon: 'water',
      done: true,
    ),
    Habit(
      id: 2,
      name: 'Leer 20 minutos',
      goal: 'Racha de 4 días',
      icon: 'book',
      done: true,
    ),
    Habit(id: 3, name: 'Pausa activa', goal: 'Cada tarde'),
    Habit(
      id: 4,
      name: 'Dormir antes de las 23:30',
      goal: 'Recordatorio 23:00',
      icon: 'sleep',
    ),
  ];
  List<FocusSession> sessions = [];
  Map<String, int> record = {'mood': 7, 'energy': 6, 'focus': 4};
  List<bool> reminders = [true, true, true, false];
  bool dark = true, saved = false, read = false, personal = true;
  String feedback = '', storageError = '';
  int minutes = 25, seconds = 1500;
  bool running = false, started = false;
  Timer? _ticker;
  DateTime? _deadline;
  int get completed => habits.where((h) => h.done).length;
  int get percent =>
      habits.isEmpty ? 0 : (completed / habits.length * 100).round();
  int get totalMinutes => sessions.fold(0, (sum, s) => sum + s.minutes);
  String get firstName => profile['name']!.split(' ').first;
  String get initials => profile['name']!
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();
  static String time(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  dynamic _load(String key) {
    try {
      final raw = prefs.getString('mood-$key') ?? readLegacy('mood-$key');
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  void load() {
    try {
      final p = _load('user');
      if (p is Map) profile = {...profile, ...Map<String, String>.from(p)};
    } catch (_) {}
    try {
      final h = _load('habits');
      if (h is List) {
        habits = h
            .map((j) => Habit.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
      }
    } catch (_) {}
    try {
      final s = _load('sessions');
      if (s is List) {
        sessions = s
            .map(
              (j) => FocusSession.fromJson(Map<String, dynamic>.from(j as Map)),
            )
            .toList();
      }
    } catch (_) {}
    try {
      final r = _load('record');
      if (r is Map) record = Map<String, int>.from(r);
    } catch (_) {}
    final rem = _load('reminders');
    if (rem is List && rem.length == 4 && rem.every((v) => v is bool)) {
      reminders = rem.cast<bool>();
    }
    dark = _load('dark') as bool? ?? true;
    saved = _load('bookmark') as bool? ?? false;
    read = _load('notifications') as bool? ?? false;
    personal = _load('personalization') as bool? ?? true;
    feedback = _load('feedback') as String? ?? '';
  }

  Future<void> save(String key, Object value) async {
    try {
      if (!await prefs.setString('mood-$key', jsonEncode(value))) {
        storageError = 'No se pudieron guardar los datos.';
      }
    } catch (_) {
      storageError = 'No se pudieron guardar los datos.';
    }
    notifyListeners();
  }

  void toggleTheme() {
    dark = !dark;
    unawaited(save('dark', dark));
    notifyListeners();
  }

  void saveProfile(Map<String, String> value) {
    profile = value;
    unawaited(save('user', profile));
    notifyListeners();
  }

  void saveHabits() {
    unawaited(save('habits', habits.map((h) => h.toJson()).toList()));
    notifyListeners();
  }

  void toggleHabit(Habit h) {
    h.done = !h.done;
    saveHabits();
  }

  void setRecord(String key, int value) {
    record[key] = value;
    unawaited(save('record', record));
    notifyListeners();
  }

  void configureTimer(int value) {
    if (value < 1 || value > 180) return;
    _ticker?.cancel();
    minutes = value;
    seconds = value * 60;
    running = false;
    started = false;
    notifyListeners();
  }

  void startTimer() {
    if (running) return;
    if (seconds == 0) seconds = minutes * 60;
    started = true;
    running = true;
    _deadline = now().add(Duration(seconds: seconds));
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
    notifyListeners();
  }

  void tick() {
    if (!running || _deadline == null) return;
    seconds = (_deadline!.difference(now()).inMilliseconds / 1000).ceil().clamp(
      0,
      minutes * 60,
    );
    if (seconds == 0) {
      _ticker?.cancel();
      running = false;
      started = false;
      _addSession(minutes);
    }
    notifyListeners();
  }

  void pauseTimer() {
    tick();
    _ticker?.cancel();
    running = false;
    notifyListeners();
  }

  void finishTimer() {
    tick();
    if (started) {
      final elapsed = (minutes * 60 - seconds) ~/ 60;
      if (elapsed > 0) _addSession(elapsed);
    }
    _ticker?.cancel();
    running = false;
    started = false;
    seconds = minutes * 60;
    notifyListeners();
  }

  void _addSession(int value) {
    sessions.insert(
      0,
      FocusSession(
        value,
        DateTime.now()
            .toIso8601String()
            .substring(0, 16)
            .replaceAll('T', ' · '),
      ),
    );
    unawaited(save('sessions', sessions.map((s) => s.toJson()).toList()));
  }

  String export() => const JsonEncoder.withIndent('  ').convert({
    'user': profile,
    'habits': habits.map((h) => h.toJson()).toList(),
    'record': record,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  });
  Future<void> clear() async {
    _ticker?.cancel();
    running = false;
    started = false;
    seconds = minutes * 60;
    clearLegacy();
    for (final key in prefs.getKeys().where((k) => k.startsWith('mood-'))) {
      await prefs.remove(key);
    }
    profile = {
      'name': 'Tomás Cabrejo',
      'email': 'angelt-cabrejos@campus.edu',
      'university': '',
      'career': '',
    };
    habits = [];
    sessions = [];
    record = {'mood': 7, 'energy': 6, 'focus': 4};
    reminders = [true, true, true, false];
    saved = false;
    read = false;
    personal = true;
    feedback = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
