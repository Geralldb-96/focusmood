import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../state/study_controller.dart';
import '../widgets.dart';

class FocusTab extends StatelessWidget {
  const FocusTab({super.key});

  Future<void> _customMinutes(BuildContext context, StudyController c) async {
    final controller = TextEditingController(text: '${c.minutes}');
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu tiempo de enfoque'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minutos (1-180)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('Guardar duración'),
          ),
        ],
      ),
    );
    if (value != null) c.setMinutes(value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudyController>();
    final mm = (c.remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (c.remaining % 60).toString().padLeft(2, '0');
    final progress = 1 - c.remaining / (c.minutes * 60);
    final state = c.running
        ? 'Enfoque en curso'
        : (c.started ? 'Sesión pausada' : 'Listo para enfocarte');

    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: c.running
              ? 'Enfoque activo'
              : (c.started ? 'Pausa tu ritmo' : 'Pomodoro'),
          subtitle: 'Bloques de enfoque con pausas',
        ),
        const SizedBox(height: 6),
        Center(
          child: Semantics(
            label: '$mm:$ss. $state',
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: c.started ? progress : 0,
                  active: c.running,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$mm:$ss',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MoodColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (!c.started) ...[
          Center(
            child: Wrap(
              spacing: 7,
              children: [
                for (final m in [15, 25, 45])
                  MoodChip(
                    label: '$m min',
                    selected: c.minutes == m,
                    onTap: () => c.setMinutes(m),
                  ),
                MoodChip(
                  label: 'Personalizar',
                  selected: false,
                  onTap: () => _customMinutes(context, c),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Iniciar enfoque',
            icon: Icons.play_arrow_outlined,
            onPressed: c.start,
          ),
        ] else ...[
          c.running
              ? const InfoBanner(
                  'Modo sin distracciones. Encuentra un lugar tranquilo.',
                  icon: Icons.nightlight_outlined,
                  color: MoodColors.soft,
                  foreground: MoodColors.deep,
                )
              : const InfoBanner(
                  'Respira, estira los hombros y retoma cuando estés listo.',
                ),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Finalizar',
                  icon: Icons.stop_outlined,
                  secondary: true,
                  onPressed: c.finishEarly,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: c.running ? 'Pausar' : 'Continuar',
                  icon: c.running ? Icons.pause : Icons.play_arrow_outlined,
                  onPressed: c.running ? c.pause : c.resume,
                ),
              ),
            ],
          ),
        ],
        Center(
          child: LinkText(
            'Ver sesiones realizadas',
            onTap: () => pushScreen(context, const SessionsScreen()),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = MoodColors.soft;
    canvas.drawCircle(center, radius, track);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14
      ..color = active ? MoodColors.green : MoodColors.orange;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.active != active;
}

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StudyController>();
    return ScreenScaffold(
      onRefresh: c.load,
      children: [
        ScreenHeader(
          title: 'Sesiones',
          subtitle: 'Tu enfoque reciente',
          onBack: () => Navigator.of(context).pop(),
        ),
        Row(
          children: [
            StatCard(
              icon: Icons.schedule,
              value: '${c.totalMinutes} min',
              label: 'Tiempo total',
              color: MoodColors.mint,
            ),
            StatCard(
              icon: Icons.timer_outlined,
              value: '${c.sessions.length}',
              label: 'Sesiones',
              color: MoodColors.peach,
            ),
          ],
        ),
        const SectionTitle('Actividad reciente'),
        if (c.sessions.isEmpty)
          const PastelCard(
            child: Text(
              'Aún no hay sesiones. Tu primer bloque de enfoque aparecerá aquí.',
              style: TextStyle(fontSize: 13, color: MoodColors.muted),
            ),
          )
        else
          for (final s in c.sessions)
            RowTile(
              icon: Icons.timer_outlined,
              title: s.activity,
              subtitle: DateFormat(
                "d MMM yyyy, HH:mm",
                'es',
              ).format(s.startedAt),
              trailing: Text(
                '${s.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      ],
    );
  }
}
