part of '../../main.dart';

extension _ProgressScreenContent on _MoodPageState {
  List<Widget> buildProgressScreen() {
    return [
      heading(
        'Tu semana',
        sub: '25 sep – 1 oct · Vista de demostración',
        backButton: false,
        action: Icons.calendar_month_outlined,
        onAction: () => notify('Resumen semanal de demostración'),
      ),
      Row(
        children: [
          stat(
            'Ánimo',
            '${s.record['mood']}.0',
            Icons.sentiment_satisfied_alt,
            'lavender',
          ),
          const SizedBox(width: 8),
          stat('Hábitos', '${s.percent}%', Icons.check_circle_outline, 'mint'),
          const SizedBox(width: 8),
          stat(
            'Estudio',
            '${s.totalMinutes} min',
            Icons.menu_book_outlined,
            'peach',
          ),
        ],
      ),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text('Ánimo diario', bold: true),
            small('Vista ilustrativa de la semana'),
            gap(16),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  7,
                  (i) => Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 18,
                        height: [35, 58, 46, 70, 62, 80, 67][i].toDouble(),
                        decoration: BoxDecoration(
                          color: i == 5
                              ? Theme.of(context).colorScheme.primary
                              : tone('mint'),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      gap(5),
                      small(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: box(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  small('Hábitos'),
                  text(
                    '${s.completed}/${s.habits.length}',
                    size: 26,
                    bold: true,
                  ),
                  gap(7),
                  progress(s.percent / 100),
                ],
              ),
              color: 'mint',
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: box(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  small('Enfoque'),
                  text('${s.sessions.length}', size: 26, bold: true),
                  small('pomodoros'),
                ],
              ),
              color: 'peach',
            ),
          ),
        ],
      ),
      note(
        'Hallazgo de la semana: prueba una pausa activa antes de estudiar y observa tu concentración.',
        color: 'lavender',
        icon: Icons.auto_awesome_outlined,
      ),
    ];
  }
}
