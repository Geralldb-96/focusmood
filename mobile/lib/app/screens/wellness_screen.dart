part of '../../main.dart';

extension _WellnessScreenContent on _MoodPageState {
  List<Widget> buildWellnessScreen() {
    final exercises = [
      (
        'Respiración cuadrada',
        'Reduce tensión y recupera claridad',
        '4 min',
        'Respirar',
        Icons.air,
      ),
      (
        'Movilidad de cuello y hombros',
        'Libera tensión de la postura',
        '6 min',
        'Moverte',
        Icons.accessibility_new,
      ),
      (
        'Descanso visual 20–20–20',
        'Cuida tus ojos frente a la pantalla',
        '2 min',
        'Descansar',
        Icons.visibility_outlined,
      ),
      (
        'Escaneo corporal breve',
        'Observa sin juzgar cómo te sientes',
        '5 min',
        'Descansar',
        Icons.psychology_outlined,
      ),
    ];
    return [
      heading('Bienestar', sub: 'Pequeñas pausas, efectos reales'),
      chips(
        ['Para ti', 'Respirar', 'Moverte', 'Descansar'],
        category,
        (v) => refresh(() => category = v),
      ),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            small('Recomendado ahora'),
            gap(9),
            text('Respira y reinicia', size: 19, bold: true),
            small('Ideal antes de tu próximo bloque de estudio.'),
            button(
              'Comenzar · 3 min',
              () => go('exercise', args: {'exercise': 'Respira y reinicia'}),
              icon: Icons.play_arrow_outlined,
            ),
          ],
        ),
        color: 'peach',
      ),
      title('Ejercicios guiados'),
      ...exercises
          .where((e) => category == 'Para ti' || e.$4 == category)
          .map(
            (e) => row(
              e.$1,
              e.$2,
              e.$5,
              () => go('exercise', args: {'exercise': e.$1}),
              end: e.$3,
            ),
          ),
    ];
  }
}
