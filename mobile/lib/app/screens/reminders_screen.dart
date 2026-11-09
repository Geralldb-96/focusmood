part of '../../main.dart';

extension _RemindersScreenContent on _MoodPageState {
  List<Widget> buildRemindersScreen() {
    final items = [
      (
        'Registro emocional',
        'Todos los días · 09:00',
        Icons.sentiment_satisfied_alt,
      ),
      ('Tomar agua', 'Lun–Vie · cada 2 horas', Icons.water_drop_outlined),
      ('Bloque de enfoque', 'Lun, Mié, Vie · 17:00', Icons.timer_outlined),
      (
        'Preparar el descanso',
        'Todos los días · 23:00',
        Icons.bedtime_outlined,
      ),
    ];

    return [
      heading(
        'Recordatorios',
        sub: 'Elige cuándo quieres que Mood te acompañe',
        action: Icons.add,
        onAction: () {
          notify('Activa o desactiva las rutinas de la lista.');
        },
      ),
      note(
        'Mantén solo los avisos que te resulten útiles. Puedes pausarlos en cualquier momento.',
        icon: Icons.notifications_outlined,
      ),
      title('Rutina diaria'),
      ...items.asMap().entries.map(
        (entry) => box(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: tone('mint'),
                child: Icon(entry.value.$3, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(entry.value.$1, bold: true),
                    small(entry.value.$2),
                  ],
                ),
              ),
              Switch(
                value: s.reminders[entry.key],
                onChanged: (value) {
                  s.reminders[entry.key] = value;
                  unawaited(s.save('reminders', s.reminders));
                },
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
      small(
        'Preferencias locales. Los avisos automáticos requieren una integración de notificaciones.',
      ),
    ];
  }
}
