part of '../../main.dart';

extension _HomeScreenContent on _MoodPageState {
  List<Widget> buildHomeScreen() {
    return [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                small('Jueves, 1 de octubre'),
                Text(
                  'Hola, ${s.firstName} ☼',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          InkWell(onTap: () => go('profile'), child: avatar(radius: 22)),
        ],
      ),
      gap(10),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text('¿Cómo estás hoy?', size: 16, bold: true),
                      small('Tu registro toma menos de 1 minuto'),
                    ],
                  ),
                ),
                const Icon(Icons.spa_outlined, size: 28),
              ],
            ),
            button('Registrar mi día', () => go('daily'), icon: Icons.add),
          ],
        ),
        color: 'lavender',
      ),
      title('Accesos rápidos'),
      LayoutBuilder(
        builder: (context, constraints) {
          const data = [
            (
              'Recomendación IA',
              'Una técnica para ahora',
              'daily',
              'mint',
              Icons.auto_awesome_outlined,
            ),
            (
              'Pomodoro',
              '25 min de enfoque',
              'focus',
              'blue',
              Icons.timer_outlined,
            ),
            (
              'Bienestar',
              'Pausas y ejercicios',
              'wellness',
              'peach',
              Icons.favorite_border,
            ),
            (
              'Hábitos',
              'Tu ritmo, cada día',
              'habits',
              'lavender',
              Icons.check_circle_outline,
            ),
          ];

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: data
                .map(
                  (item) => SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    child: Material(
                      color: tone(item.$4),
                      borderRadius: BorderRadius.circular(19),
                      child: InkWell(
                        onTap: () => go(item.$3),
                        borderRadius: BorderRadius.circular(19),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 17,
                                backgroundColor: surface,
                                child: Icon(item.$5, size: 18),
                              ),
                              gap(10),
                              text(item.$1, bold: true, size: 13),
                              gap(5),
                              small(
                                item.$3 == 'habits'
                                    ? '${s.completed} de ${s.habits.length} completados'
                                    : item.$2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
      gap(10),
      box(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text('Racha de bienestar', bold: true),
                      small('5 días cuidando de ti'),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(
                    Icons.local_fire_department_outlined,
                    size: 15,
                  ),
                  label: small('5 días'),
                ),
              ],
            ),
            gap(8),
            progress(0.7, color: const Color(0xfff6ac69)),
          ],
        ),
      ),
      link('Ver notificaciones', () => go('notifications')),
    ];
  }
}
