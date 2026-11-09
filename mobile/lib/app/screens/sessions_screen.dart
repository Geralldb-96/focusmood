part of '../../main.dart';

extension _SessionsScreenContent on _MoodPageState {
  List<Widget> buildSessionsScreen() {
    return [
      heading('Sesiones', sub: 'Tu enfoque guardado en este dispositivo'),
      Row(
        children: [
          stat('Tiempo total', '${s.totalMinutes} min', Icons.schedule, 'mint'),
          const SizedBox(width: 8),
          stat(
            'Pomodoros',
            '${s.sessions.length}',
            Icons.timer_outlined,
            'peach',
          ),
          const SizedBox(width: 8),
          stat(
            'Mejor racha',
            '${s.sessions.isEmpty ? 0 : 1}',
            Icons.local_fire_department_outlined,
            'lavender',
          ),
        ],
      ),
      title('Actividad reciente'),
      if (s.sessions.isEmpty)
        note(
          'Aún no hay sesiones. Tu primer bloque de enfoque aparecerá aquí.',
          color: 'soft',
        ),
      ...s.sessions.map(
        (session) => row(
          session.name,
          session.date,
          Icons.timer_outlined,
          () => go('focus'),
          end: '${session.minutes} min',
          color: 'blue',
        ),
      ),
    ];
  }
}
