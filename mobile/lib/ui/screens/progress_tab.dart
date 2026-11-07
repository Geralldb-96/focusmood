import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/progress_controller.dart';
import '../widgets.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ProgressController>();
    final w = c.summary;
    return ScreenScaffold(
      onRefresh: c.load,
      children: [
        ScreenHeader(
          title: 'Tu semana',
          subtitle: w == null ? 'Esta semana' : '${w.weekStart} – ${w.weekEnd}',
        ),
        if (w == null && c.loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (w == null && !c.loading)
          const MutedText(
            'No se pudo cargar tu progreso. Desliza hacia abajo para reintentar.',
            center: true,
          ),
        if (w != null) ...[
          if (!w.hasData)
            InfoBanner(w.message ?? 'Todavía no hay registros esta semana.'),
          Row(
            children: [
              StatCard(
                icon: Icons.favorite_border,
                value: w.averageMood?.toString() ?? '—',
                label: 'Ánimo (1-5)',
                color: MoodColors.lavender,
              ),
              StatCard(
                icon: Icons.check_circle_outline,
                value: '${(w.habitRate ?? 0).round()}%',
                label: 'Hábitos',
                color: MoodColors.mint,
              ),
              StatCard(
                icon: Icons.menu_book_outlined,
                value: '${w.studyMinutes} min',
                label: 'Estudio',
                color: MoodColors.peach,
                foreground: MoodColors.peachText,
              ),
            ],
          ),
          PastelCard(
            white: true,
            margin: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ánimo diario',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Registros de la semana',
                  style: TextStyle(fontSize: 11, color: MoodColors.muted),
                ),
                const SizedBox(height: 14),
                _MoodChart(week: w),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: PastelCard(
                  color: MoodColors.mint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hábitos',
                        style: TextStyle(fontSize: 11, color: MoodColors.muted),
                      ),
                      Text(
                        '${w.habitsCompleted}/${w.habitsExpected}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProgressTrack((w.habitRate ?? 0) / 100),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PastelCard(
                  color: MoodColors.peach,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enfoque',
                        style: TextStyle(
                          fontSize: 11,
                          color: MoodColors.peachText,
                        ),
                      ),
                      Text(
                        '${w.studySessions}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: MoodColors.peachText,
                        ),
                      ),
                      const Text(
                        'sesiones',
                        style: TextStyle(
                          fontSize: 11,
                          color: MoodColors.peachText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          PastelCard(
            color: MoodColors.lavender,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 25),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.recsRated > 0
                            ? 'Utilidad de las recomendaciones'
                            : 'Un consejo',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        w.recsRated > 0
                            ? '${w.recsHelpful} de ${w.recsRated} recomendaciones valoradas te resultaron útiles.'
                            : 'Prueba una pausa activa antes de estudiar y observa cómo cambia tu concentración.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: MoodColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart({required this.week});

  final WeeklySummary week;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(week.weekStart);
    String iso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(
                builder: (_) {
                  final key = iso(start.add(Duration(days: i)));
                  final point = week.moodPoints
                      .where((p) => p.date == key)
                      .firstOrNull;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Semantics(
                        label: point == null
                            ? 'Sin registro'
                            : 'Ánimo ${point.score} de 5',
                        child: Container(
                          width: 22,
                          height: point == null ? 4 : point.score * 17.0 + 6,
                          decoration: BoxDecoration(
                            color: point == null
                                ? const Color(0xFFDCEEE6)
                                : (point.score >= 4
                                      ? MoodColors.green
                                      : MoodColors.purple.withValues(
                                          alpha: .65,
                                        )),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LMXJVSD'[i],
                        style: const TextStyle(
                          fontSize: 11,
                          color: MoodColors.muted,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
