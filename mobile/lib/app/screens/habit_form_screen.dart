part of '../../main.dart';

extension _HabitFormScreenContent on _MoodPageState {
  List<Widget> buildHabitFormScreen() {
    return [
      heading(
        editing == null ? 'Nuevo hábito' : 'Editar hábito',
        sub: editing == null
            ? 'Hazlo pequeño, claro y alcanzable'
            : 'Ajusta tu meta sin perder el progreso',
      ),
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field(
              'Nombre del hábito',
              name,
              required: true,
              icon: Icons.check_circle_outline,
            ),
            title('Icono y color'),
            Wrap(
              spacing: 9,
              children: ['walk', 'book', 'water', 'sleep', 'heart']
                  .map(
                    (v) => IconButton.filledTonal(
                      onPressed: () => refresh(() => icon = v),
                      isSelected: icon == v,
                      tooltip: v,
                      icon: Icon(habitIcon(v)),
                      selectedIcon: Icon(
                        habitIcon(v),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            title('Frecuencia'),
            Wrap(
              spacing: 6,
              children: List.generate(
                7,
                (i) => FilterChip(
                  label: Text(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                  selected: days.contains(i),
                  onSelected: (v) => refresh(() {
                    if (v) {
                      days.add(i);
                    } else {
                      days.remove(i);
                    }
                  }),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: field('Meta', goal, required: true)),
                const SizedBox(width: 9),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text('Momento', size: 12, bold: true),
                        gap(6),
                        DropdownButtonFormField<String>(
                          initialValue: moment,
                          isExpanded: true,
                          items: ['Mañana', 'Tarde', 'Noche']
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: text(v, size: 13),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => moment = v!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: text('Recordatorio', bold: true),
              subtitle: small('A las 17:30'),
              value: reminder,
              onChanged: (v) => refresh(() => reminder = v),
            ),
            button(
              editing == null ? 'Crear hábito' : 'Guardar cambios',
              saveHabit,
              icon: Icons.check,
            ),
          ],
        ),
      ),
      if (editing != null)
        button(
          'Eliminar hábito',
          () => confirm(
            '¿Eliminar hábito?',
            'Se eliminará de tu lista de hábitos.',
            () {
              s.habits.removeWhere((h) => h.id == editing!.id);
              s.saveHabits();
              back('habits');
            },
            label: 'Eliminar hábito',
          ),
          danger: true,
          icon: Icons.delete_outline,
        ),
    ];
  }
}
