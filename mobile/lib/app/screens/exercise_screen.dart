part of '../../main.dart';

extension _ExerciseScreenContent on _MoodPageState {
  List<Widget> buildExerciseScreen() {
    final phase = [
      'Inhala',
      'Sostén',
      'Exhala',
      'Descansa',
    ][(exerciseTime ~/ 4) % 4];
    return [
      heading(
        exercise,
        sub: 'Ejercicio guiado · 3 minutos',
        action: sound ? Icons.volume_up_outlined : Icons.volume_off_outlined,
        onAction: () {
          refresh(() => sound = !sound);
          notify('Guía visual activa. Audio pendiente de integración.');
        },
      ),
      box(
        Column(
          children: [
            gap(20),
            AnimatedContainer(
              duration: breathing ? const Duration(seconds: 4) : Duration.zero,
              width: phase == 'Inhala' || phase == 'Sostén' ? 180 : 145,
              height: phase == 'Inhala' || phase == 'Sostén' ? 180 : 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone('mint'),
                border: Border.all(width: 7, color: const Color(0xff4c8198)),
              ),
              child: Center(child: text(phase, size: 22, bold: true)),
            ),
            gap(24),
            text('4 segundos', size: 17, bold: true),
            gap(20),
          ],
        ),
        color: 'blue',
      ),
      gap(9),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [small(MoodStore.time(exerciseTime)), small('03:00')],
      ),
      gap(8),
      progress(exerciseTime / 180),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text('Sigue el círculo', bold: true),
            gap(6),
            small(
              exercise.contains('Movilidad')
                  ? 'Mueve suavemente los hombros y el cuello sin forzar.'
                  : exercise.contains('visual')
                  ? 'Mira un objeto lejano y relaja tus ojos.'
                  : 'Inhala al expandirse, sostén suavemente y exhala al contraerse.',
            ),
          ],
        ),
        color: 'soft',
      ),
      Row(
        children: [
          Expanded(
            child: button(
              'Finalizar',
              () => back('wellness'),
              secondary: true,
              icon: Icons.stop_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: button(
              breathing ? 'Pausar' : 'Continuar',
              () => refresh(() => breathing = !breathing),
              icon: breathing ? Icons.pause : Icons.play_arrow_outlined,
            ),
          ),
        ],
      ),
    ];
  }
}
