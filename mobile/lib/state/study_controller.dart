import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/study_repository.dart';
import 'refreshable.dart';

/// Temporizador Pomodoro y sesiones de estudio (FCM-12, FCM-13).
/// El tiempo corre en el dispositivo; al terminar se registra la sesión en el backend.
class StudyController extends ChangeNotifier implements Refreshable {
  StudyController(this._repo, {this._onChanged, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final StudyRepository _repo;
  final Future<void> Function()? _onChanged;
  final DateTime Function() _now;

  final _notices = StreamController<String>.broadcast();
  Stream<String> get notices => _notices.stream;

  List<StudySession> sessions = const [];
  int minutes = 25;
  int remaining = 25 * 60;
  bool running = false;
  bool started = false;

  DateTime? _startedAt;
  int _elapsedSeconds = 0;
  Timer? _ticker;

  int get totalMinutes => sessions.fold(0, (a, s) => a + s.durationMinutes);

  @override
  Future<void> load() async {
    sessions = await _repo.sessions();
    notifyListeners();
  }

  void setMinutes(int m) {
    if (started) return;
    minutes = m.clamp(1, 180);
    remaining = minutes * 60;
    notifyListeners();
  }

  void start({int? withMinutes}) {
    if (withMinutes != null) {
      started = false;
      minutes = withMinutes.clamp(1, 180);
      remaining = minutes * 60;
    }
    started = true;
    _startedAt ??= _now();
    _resume();
  }

  void pause() {
    _ticker?.cancel();
    running = false;
    notifyListeners();
  }

  void resume() => _resume();

  void _resume() {
    running = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    notifyListeners();
  }

  @visibleForTesting
  void tick() {
    if (!running) return;
    remaining--;
    _elapsedSeconds++;
    if (remaining <= 0) {
      remaining = 0;
      _finish(completed: true);
    } else {
      notifyListeners();
    }
  }

  /// Termina antes de tiempo; si ya pasó al menos un minuto queda registrada como interrumpida.
  Future<void> finishEarly() => _finish(completed: false);

  Future<void> _finish({required bool completed}) async {
    _ticker?.cancel();
    final startedAt = _startedAt;
    final elapsedMin = completed ? minutes : (_elapsedSeconds / 60).round();
    _reset();
    if (startedAt != null && elapsedMin > 0) {
      try {
        await _repo.record(
          startedAt: startedAt,
          endedAt: _now(),
          activity: 'Sesión de enfoque',
          durationMinutes: elapsedMin,
          focusMinutes: minutes,
          completed: completed,
        );
        await load();
        await _onChanged?.call();
        _notices.add(
          completed
              ? '¡Sesión completada! Tómate una pausa.'
              : 'Sesión finalizada',
        );
      } catch (e) {
        _notices.add('No se pudo guardar la sesión: $e');
      }
    } else {
      _notices.add('Sesión finalizada');
    }
  }

  void _reset() {
    running = false;
    started = false;
    _startedAt = null;
    _elapsedSeconds = 0;
    remaining = minutes * 60;
    notifyListeners();
  }

  @override
  void clear() {
    _ticker?.cancel();
    sessions = const [];
    _reset();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notices.close();
    super.dispose();
  }
}
