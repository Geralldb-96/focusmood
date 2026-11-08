part of '../../main.dart';

extension _AboutScreenContent on _MoodPageState {
  List<Widget> buildAboutScreen() {
    return [
      heading('Acerca de Mood'),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            brand(),
            gap(16),
            text('Bienestar que acompaña', size: 22, bold: true),
            gap(10),
            small(
              'Una herramienta para cuidar tus hábitos y encontrar tu ritmo de estudio.',
            ),
            gap(12),
            small('Versión 1.2.0 · Flutter y Dart. Temas claro y oscuro.'),
            gap(12),
            small(
              'Las recomendaciones son ejemplos locales y no constituyen atención médica o psicológica.',
            ),
          ],
        ),
        color: 'soft',
      ),
    ];
  }
}
