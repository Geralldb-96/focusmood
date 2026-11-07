import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/recommendation_controller.dart';
import '../widgets.dart';
import 'recommendation_screens.dart';

/// Registro diario + tiempo disponible + actividad (FCM-05, FCM-06).
class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  double _mood = 7, _energy = 6, _focus = 4;
  int _minutes = 15;
  String _activity = 'Examen';

  static const _durations = [5, 15, 25, 45];
  static const _activities = [
    ('Examen', Icons.edit_note),
    ('Tarea', Icons.menu_book_outlined),
    ('Clase', Icons.school_outlined),
    ('Proyecto', Icons.groups_outlined),
  ];

  Widget _slider(
    String label,
    String min,
    String max,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${value.round()}/10',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: color,
            inactiveColor: color.withValues(alpha: .25),
            label: '${value.round()}',
            semanticFormatterCallback: (v) => '${v.round()} de 10',
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min,
                style: const TextStyle(fontSize: 11, color: MoodColors.muted),
              ),
              Text(
                max,
                style: const TextStyle(fontSize: 11, color: MoodColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Tu registro de hoy',
          subtitle: 'Cuéntanos cómo estás para recomendarte algo útil',
          onBack: () => Navigator.of(context).pop(),
        ),
        _slider(
          'Estado de ánimo',
          'Bajo',
          'Muy bien',
          _mood,
          MoodColors.purple,
          (v) => setState(() => _mood = v),
        ),
        _slider(
          'Energía',
          'Sin energía',
          'Con energía',
          _energy,
          MoodColors.orange,
          (v) => setState(() => _energy = v),
        ),
        _slider(
          'Concentración',
          'Dispersa',
          'Enfocada',
          _focus,
          MoodColors.blue,
          (v) => setState(() => _focus = v),
        ),
        const Text(
          'Tiempo disponible',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        ChipWrap(
          children: [
            for (final m in _durations)
              MoodChip(
                label: m == 45 ? '45+ min' : '$m min',
                selected: m == _minutes,
                onTap: () => setState(() => _minutes = m),
              ),
          ],
        ),
        const Text(
          'Actividad académica',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        ChipWrap(
          children: [
            for (final (name, icon) in _activities)
              MoodChip(
                label: name,
                icon: icon,
                selected: name == _activity,
                onTap: () => setState(() => _activity = name),
              ),
          ],
        ),
        PrimaryButton(
          label: 'Generar recomendación',
          icon: Icons.auto_awesome_outlined,
          onPressed: () => pushScreen(
            context,
            GeneratingScreen(
              input: DailyInput(
                mood: _mood.round(),
                energy: _energy.round(),
                focus: _focus.round(),
              ),
              minutes: _minutes,
              activity: _activity,
            ),
          ),
        ),
        const MutedText(
          'Tu registro se guarda de forma segura en tu cuenta.',
          center: true,
          size: 11,
        ),
      ],
    );
  }
}

/// Pantalla de espera mientras el backend consulta a la IA (puede tardar hasta ~10 s).
class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({
    super.key,
    required this.input,
    required this.minutes,
    required this.activity,
  });

  final DailyInput input;
  final int minutes;
  final String activity;

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final controller = context.read<RecommendationController>();
    final navigator = Navigator.of(context);
    try {
      final rec = await controller.generate(
        widget.input,
        widget.minutes,
        widget.activity,
      );
      if (rec == null || !mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const RecommendationScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      toast(e.message);
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<RecommendationController>().cancelGeneration();
      },
      child: ScreenScaffold(
        children: [
          ScreenHeader(
            title: 'Preparando tu recomendación',
            onBack: () => Navigator.of(context).pop(),
          ),
          PastelCard(
            color: MoodColors.mint,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(26),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: MoodColors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adaptando una técnica para ti',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                MutedText(
                  'Consideramos tu energía, concentración, tiempo y ${widget.activity.toLowerCase()} de hoy.',
                  center: true,
                ),
              ],
            ),
          ),
          const InfoBanner(
            'Mientras esperas, prepara agua y silencia las notificaciones.',
          ),
          const MutedText(
            'Esto suele tardar menos de 10 segundos',
            center: true,
            size: 11,
          ),
          Center(
            child: LinkText(
              'Cancelar',
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
