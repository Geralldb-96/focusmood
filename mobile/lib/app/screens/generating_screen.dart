part of '../../main.dart';

extension _GeneratingScreenContent on _MoodPageState {
  List<Widget> buildGeneratingScreen() {
    return [
      heading('Preparando tu recomendación'),
      box(
        Column(
          children: [
            gap(20),
            SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: CircularProgressIndicator(
                      strokeWidth: 18,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: surface,
                    ),
                  ),
                  const Icon(Icons.auto_awesome_outlined, size: 40),
                ],
              ),
            ),
            gap(35),
            text(
              'Adaptando una técnica para ti',
              size: 17,
              bold: true,
              align: TextAlign.center,
            ),
            gap(7),
            small(
              'Consideramos tu energía, concentración, tiempo y actividad de hoy.',
              align: TextAlign.center,
            ),
            gap(24),
          ],
        ),
        color: 'mint',
      ),
      note('Mientras esperas, prepara agua y silencia las notificaciones.'),
      small('Esto suele tardar menos de 10 segundos', align: TextAlign.center),
      link('Cancelar', () => back('daily')),
    ];
  }
}
