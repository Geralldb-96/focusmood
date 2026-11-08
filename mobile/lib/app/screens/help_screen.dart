part of '../../main.dart';

extension _HelpScreenContent on _MoodPageState {
  List<Widget> buildHelpScreen() {
    return [
      heading('Ayuda y apoyo'),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.favorite_border),
            gap(12),
            text('No tienes que hacerlo solo', size: 20, bold: true),
            gap(9),
            small(
              'Si necesitas apoyo, contacta al servicio de bienestar de tu universidad o a un profesional de salud mental.',
            ),
            gap(12),
            small(
              'Si estás en peligro inmediato, comunícate con los servicios de emergencia de tu localidad.',
            ),
            button('Explorar pausas de bienestar', () => go('wellness')),
          ],
        ),
        color: 'soft',
      ),
    ];
  }
}
