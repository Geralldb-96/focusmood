import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../state/habits_controller.dart';
import '../../state/progress_controller.dart';
import '../../state/session_controller.dart';
import '../widgets.dart';
import 'daily_screen.dart';
import 'shell.dart';
import 'wellness_screens.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final habits = context.watch<HabitsController>();
    final week = context.watch<ProgressController>().summary;
    final nav = context.read<ShellNav>();
    final date = toBeginningOfSentenceCase(
      DateFormat("EEEE, d 'de' MMMM", 'es').format(DateTime.now()),
    );

    Widget quick(
      IconData icon,
      String title,
      String sub,
      Color color,
      VoidCallback onTap,
    ) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(23),
          child: InkWell(
            borderRadius: BorderRadius.circular(23),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 18, color: MoodColors.deep),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: MoodColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return ScreenScaffold(
      onRefresh: () async {
        await Future.wait([
          habits.load(),
          context.read<ProgressController>().load(),
        ]);
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MoodColors.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Hola, ${user.firstName} ☀️',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Perfil',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => nav.go(ShellNav.profile),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: MoodColors.mint,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: MoodColors.deep,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        PastelCard(
          color: MoodColors.lavender,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Cómo estás hoy?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tu registro toma menos de 1 minuto',
                          style: TextStyle(
                            fontSize: 12,
                            color: MoodColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.spa_outlined,
                    size: 32,
                    color: MoodColors.purple.withValues(alpha: .9),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Registrar mi día',
                icon: Icons.add,
                onPressed: () => pushScreen(context, const DailyScreen()),
              ),
            ],
          ),
        ),
        const SectionTitle('Accesos rápidos'),
        Row(
          children: [
            quick(
              Icons.auto_awesome_outlined,
              'Recomendación IA',
              'Una técnica para ahora',
              MoodColors.mint,
              () => pushScreen(context, const DailyScreen()),
            ),
            quick(
              Icons.timer_outlined,
              'Pomodoro',
              '25 min de enfoque',
              MoodColors.blueSoft,
              () => nav.go(ShellNav.focus),
            ),
          ],
        ),
        Row(
          children: [
            quick(
              Icons.favorite_border,
              'Bienestar',
              'Pausas y ejercicios',
              MoodColors.peach,
              () => pushScreen(context, const WellnessScreen()),
            ),
            quick(
              Icons.check_circle_outline,
              'Hábitos',
              '${habits.completed} de ${habits.habits.length} completados',
              MoodColors.lavender,
              () => nav.go(ShellNav.habits),
            ),
          ],
        ),
        if (week != null && week.hasData)
          PastelCard(
            white: true,
            margin: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  color: MoodColors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu semana',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${week.habitsCompleted} hábitos cumplidos · ${week.studyMinutes} min de estudio',
                        style: const TextStyle(
                          fontSize: 11,
                          color: MoodColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                LinkText('Ver', onTap: () => nav.go(ShellNav.progress)),
              ],
            ),
          ),
      ],
    );
  }
}
