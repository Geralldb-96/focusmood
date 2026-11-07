import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/wellness_controller.dart';
import '../widgets.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  String _category = 'Para ti';

  static const _categories = {
    'Para ti': null,
    'Respirar': 'RESPIRAR',
    'Moverte': 'MOVERTE',
    'Descansar': 'DESCANSAR',
  };

  IconData _icon(String category) => switch (category) {
    'RESPIRAR' => Icons.air,
    'MOVERTE' => Icons.directions_walk,
    _ => Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final all = context.watch<WellnessController>().activities;
    final filter = _categories[_category];
    final list = all
        .where((a) => filter == null || a.category == filter)
        .toList();
    final featured = all.isEmpty ? null : all.first;
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Bienestar',
          subtitle: 'Pequeñas pausas, efectos reales',
          onBack: () => Navigator.of(context).pop(),
        ),
        ChipWrap(
          children: [
            for (final t in _categories.keys)
              MoodChip(
                label: t,
                selected: t == _category,
                onTap: () => setState(() => _category = t),
              ),
          ],
        ),
        if (featured != null)
          PastelCard(
            color: MoodColors.peach,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendado ahora',
                  style: TextStyle(fontSize: 11, color: MoodColors.peachText),
                ),
                const SizedBox(height: 6),
                Text(
                  featured.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: MoodColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ideal antes de tu próximo bloque de estudio.',
                  style: TextStyle(fontSize: 12, color: MoodColors.peachText),
                ),
                const SizedBox(height: 6),
                PrimaryButton(
                  label: 'Comenzar · ${featured.minutes} min',
                  icon: Icons.play_arrow_outlined,
                  onPressed: () =>
                      pushScreen(context, ExerciseScreen(activity: featured)),
                ),
              ],
            ),
          ),
        const SectionTitle('Ejercicios guiados'),
        if (all.isEmpty)
          const MutedText(
            'No se pudieron cargar las actividades. Desliza para reintentar desde Inicio.',
            center: true,
          ),
        for (final a in list)
          RowTile(
            icon: _icon(a.category),
            title: a.name,
            subtitle: a.description.split('. ').first,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEEE6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '${a.minutes} min',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: MoodColors.deep,
                ),
              ),
            ),
            onTap: () => pushScreen(context, ExerciseScreen(activity: a)),
          ),
      ],
    );
  }
}

/// Ejercicio guiado con círculo de respiración y registro al terminar (FCM-14).
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key, required this.activity});

  final WellnessActivity activity;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  static const _phases = ['Inhala', 'Sostén', 'Exhala', 'Descansa'];

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  Timer? _timer;
  int _elapsed = 0;
  bool _running = true;
  bool _logged = false;

  int get _total => widget.activity.minutes * 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _breath.repeat(reverse: true);
  }

  void _tick() {
    if (!_running) return;
    setState(() => _elapsed++);
    if (_elapsed >= _total) {
      _running = false;
      _breath.stop();
      _log(completed: true);
      toast('Ejercicio completado');
    }
  }

  Future<void> _log({required bool completed}) async {
    if (_logged) return;
    _logged = true;
    try {
      await context.read<WellnessController>().log(
        widget.activity,
        completed: completed,
      );
    } catch (_) {
      // el registro es secundario: no interrumpe el ejercicio
    }
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _breath.repeat(reverse: true);
    } else {
      _breath.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final done = _elapsed >= _total;
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: widget.activity.name,
          subtitle: 'Ejercicio guiado · ${widget.activity.minutes} minutos',
          onBack: () => Navigator.of(context).pop(),
        ),
        PastelCard(
          color: MoodColors.blueSoft,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _breath,
                    builder: (_, _) {
                      final size =
                          110 + 70 * Curves.easeInOut.transform(_breath.value);
                      return Container(
                        width: size,
                        height: size,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: .8),
                          border: Border.all(color: MoodColors.blue, width: 3),
                        ),
                        child: Text(
                          done ? '¡Listo!' : _phases[(_elapsed ~/ 4) % 4],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MoodColors.blue,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Text(
                '4 segundos',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(_elapsed),
                style: const TextStyle(fontSize: 11, color: MoodColors.muted),
              ),
              Text(
                _fmt(_total),
                style: const TextStyle(fontSize: 11, color: MoodColors.muted),
              ),
            ],
          ),
        ),
        ProgressTrack(_elapsed / _total, color: MoodColors.blue),
        const SizedBox(height: 12),
        PastelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sigue el círculo',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              MutedText(widget.activity.description),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Finalizar',
                icon: Icons.stop_outlined,
                secondary: true,
                onPressed: () {
                  if (!done && _elapsed > 0) _log(completed: false);
                  Navigator.of(context).pop();
                  toast('Pausa de bienestar finalizada');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: _running ? 'Pausar' : 'Continuar',
                icon: _running ? Icons.pause : Icons.play_arrow_outlined,
                onPressed: done ? null : _toggle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
