part of '../../main.dart';

extension _HabitsScreenContent on _MoodPageState {
  List<Widget> buildHabitsScreen() {
    return [
      heading(
        'Hábitos',
        sub: 'Jueves · ${s.completed} de ${s.habits.length} completados',
        backButton: false,
        action: Icons.add,
        actionLabel: 'Nuevo hábito',
        onAction: () => go('habit'),
      ),
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
                      text('Buen ritmo, ${s.firstName}', bold: true),
                      small('Un pequeño paso cada día'),
                    ],
                  ),
                ),
                text('${s.percent}%', size: 23, bold: true),
              ],
            ),
            gap(8),
            progress(s.percent / 100),
          ],
        ),
        color: 'mint',
      ),
      gap(10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (index) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: index == 3
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                small(['L', 'M', 'X', 'J', 'V', 'S', 'D'][index]),
                text(
                  '${[28, 29, 30, 1, 2, 3, 4][index]}',
                  size: 11,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
      gap(12),
      ...s.habits.map(
        (habit) => box(
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => go('habit', args: habit),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: tone(
                          habit.icon == 'book' ? 'lavender' : 'mint',
                        ),
                        child: Icon(habitIcon(habit.icon), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                decoration: habit.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: habit.done ? muted : null,
                              ),
                            ),
                            small(habit.goal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => s.toggleHabit(habit),
                tooltip:
                    '${habit.done ? 'Desmarcar' : 'Completar'} ${habit.name}',
                icon: Icon(
                  habit.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: habit.done
                      ? Theme.of(context).colorScheme.primary
                      : muted,
                ),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
        ),
      ),
      button('Crear nuevo hábito', () => go('habit'), icon: Icons.add),
    ];
  }
}
