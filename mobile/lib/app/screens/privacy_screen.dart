part of '../../main.dart';

extension _PrivacyScreenContent on _MoodPageState {
  List<Widget> buildPrivacyScreen() {
    return [
      heading('Privacidad y datos'),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined),
            gap(9),
            text('Tú controlas tu información', size: 19, bold: true),
            gap(9),
            small(
              'Esta demostración guarda tus hábitos, registros y perfil únicamente en el almacenamiento local del dispositivo. No se envían a un servidor.',
            ),
          ],
        ),
        color: 'soft',
      ),
      button(
        'Exportar mis datos',
        () async {
          await Clipboard.setData(ClipboardData(text: s.export()));
          if (mounted) {
            notify('Datos copiados al portapapeles en formato JSON.');
          }
        },
        secondary: true,
        icon: Icons.copy_outlined,
      ),
      button(
        'Eliminar mis datos locales',
        () => confirm(
          '¿Eliminar tus datos?',
          'Se borrará la información de Mood guardada en este dispositivo.',
          () async {
            await s.clear();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (_) => false,
              );
            }
          },
          label: 'Eliminar datos',
        ),
        danger: true,
      ),
    ];
  }
}
