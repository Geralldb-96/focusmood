import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/habits_controller.dart';
import '../widgets.dart';

const habitIcons = <String, IconData>{
  'water': Icons.water_drop_outlined,
  'book': Icons.menu_book_outlined,
  'walk': Icons.directions_walk,
  'sleep': Icons.bedtime_outlined,
  'heart': Icons.favorite_border,
};

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<HabitsController>();
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weekday = toBeginningOfSentenceCase(
      DateFormat('EEEE', 'es').format(today),
    );

    Future<void> toggle(Habit h) async {
      try {
        await c.toggle(h);
      } on ApiException catch (e) {
        toast(e.message);
      }
    }

    return ScreenScaffold(
      onRefresh: c.load,
      children: [
        ScreenHeader(
          title: 'Hábitos',
          subtitle:
              '$weekday · ${c.completed} de ${c.habits.length} completados',
          trailing: RoundIconButton(
            icon: Icons.add,
            tooltip: 'Nuevo hábito',
            onPressed: () => pushScreen(context, const HabitFormScreen()),
          ),
        ),
        PastelCard(
          color: MoodColors.mint,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Un pequeño paso cada día',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'La constancia suma más que la perfección',
                          style: TextStyle(
                            fontSize: 11,
                            color: MoodColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(c.ratio * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: MoodColors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressTrack(c.ratio),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final d = monday.add(Duration(days: i));
                      final isToday =
                          d.day == today.day && d.month == today.month;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday ? MoodColors.deep : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: MoodColors.line),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'LMXJVSD'[i],
                              style: TextStyle(
                                fontSize: 11,
                                color: isToday
                                    ? Colors.white70
                                    : MoodColors.muted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isToday ? Colors.white : MoodColors.text,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (c.habits.isEmpty && !c.loading)
          const MutedText(
            'Aún no tienes hábitos. Crea el primero y hazlo pequeño, claro y alcanzable.',
            center: true,
          ),
        for (final h in c.habits)
          RowTile(
            icon: habitIcons[c.iconOf(h.id)] ?? Icons.favorite_border,
            title: h.name,
            subtitle: h.description.isEmpty ? null : h.description,
            tileColor: h.completedToday ? MoodColors.mint : MoodColors.soft,
            onTap: () => pushScreen(context, HabitFormScreen(editing: h)),
            trailing: Semantics(
              button: true,
              label:
                  '${h.completedToday ? 'Desmarcar' : 'Completar'} ${h.name}',
              excludeSemantics: true,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => toggle(h),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: h.completedToday
                        ? MoodColors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: h.completedToday
                          ? MoodColors.green
                          : MoodColors.line,
                      width: 1.6,
                    ),
                  ),
                  child: h.completedToday
                      ? const Icon(Icons.check, size: 17, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: 'Crear nuevo hábito',
          icon: Icons.add,
          onPressed: () => pushScreen(context, const HabitFormScreen()),
        ),
      ],
    );
  }
}

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, this.editing});

  final Habit? editing;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.editing?.name ?? '');
  late final _goal = TextEditingController(
    text: widget.editing?.description ?? '15 minutos',
  );
  late final Set<int> _days = switch (widget.editing?.frequency) {
    'WEEKLY' => {0},
    'WEEKDAYS' => {0, 1, 2, 3, 4},
    'DAILY' => {0, 1, 2, 3, 4, 5, 6},
    _ => {0, 1, 2, 3, 4},
  };
  late String _icon = 'walk';
  late String _schedule = widget.editing?.schedule ?? 'AFTERNOON';
  bool _busy = false;

  static const _schedules = {
    'MORNING': 'Mañana',
    'AFTERNOON': 'Tarde',
    'NIGHT': 'Noche',
  };

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) _icon = context.read<HabitsController>().iconOf(e.id);
  }

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    super.dispose();
  }

  String get _frequency {
    if (_days.length == 7) return 'DAILY';
    if (_days.length == 1) return 'WEEKLY';
    if (_days.length == 5 && _days.every((d) => d < 5)) return 'WEEKDAYS';
    return 'DAILY';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_days.isEmpty) {
      toast('Elige al menos un día');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<HabitsController>().save(
        editing: widget.editing,
        draft: HabitDraft(
          name: _name.text.trim(),
          description: _goal.text.trim(),
          frequency: _frequency,
          schedule: _schedule,
        ),
        icon: _icon,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      toast('Hábito guardado');
    } on ApiException catch (e) {
      toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar hábito?'),
        content: const Text(
          'Se eliminará de tu lista de hábitos junto con su historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar hábito',
              style: TextStyle(color: MoodColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<HabitsController>().remove(widget.editing!);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: editing ? 'Editar hábito' : 'Nuevo hábito',
          subtitle: editing
              ? 'Ajusta tu meta sin perder el progreso'
              : 'Hazlo pequeño, claro y alcanzable',
          onBack: () => Navigator.of(context).pop(),
        ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledField(
                label: 'Nombre del hábito',
                controller: _name,
                icon: Icons.check_circle_outline,
                hint: 'Caminar después de clase',
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'El nombre del hábito es obligatorio'
                    : null,
              ),
              const SectionTitle('Icono'),
              Wrap(
                spacing: 10,
                children: [
                  for (final e in habitIcons.entries)
                    Semantics(
                      button: true,
                      selected: _icon == e.key,
                      label: 'Icono ${e.key}',
                      excludeSemantics: true,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _icon = e.key),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _icon == e.key
                                ? MoodColors.deep
                                : MoodColors.soft,
                          ),
                          child: Icon(
                            e.value,
                            color: _icon == e.key
                                ? Colors.white
                                : MoodColors.green,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SectionTitle('Frecuencia'),
              Wrap(
                spacing: 7,
                children: [
                  for (var i = 0; i < 7; i++)
                    MoodChip(
                      label: 'LMXJVSD'[i],
                      selected: _days.contains(i),
                      onTap: () => setState(
                        () =>
                            _days.contains(i) ? _days.remove(i) : _days.add(i),
                      ),
                    ),
                ],
              ),
              LabeledField(
                label: 'Meta',
                controller: _goal,
                icon: Icons.flag_outlined,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Indica una meta' : null,
              ),
              const SizedBox(height: 14),
              const Text(
                'Momento',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                initialValue: _schedule,
                items: [
                  for (final e in _schedules.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => setState(() => _schedule = v ?? _schedule),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: editing ? 'Guardar cambios' : 'Crear hábito',
          icon: Icons.check,
          loading: _busy,
          onPressed: _save,
        ),
        if (editing)
          PrimaryButton(
            label: 'Eliminar hábito',
            icon: Icons.delete_outline,
            danger: true,
            onPressed: _delete,
          ),
      ],
    );
  }
}
