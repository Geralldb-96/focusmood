part of '../../main.dart';

extension _ProfileScreenContent on _MoodPageState {
  List<Widget> buildProfileScreen() {
    return [
      heading(
        'Perfil',
        sub: 'Tu espacio y preferencias',
        backButton: false,
        action: Icons.tune,
        onAction: () => go('edit-profile'),
      ),
      Center(child: avatar()),
      gap(10),
      text(s.profile['name']!, size: 17, bold: true, align: TextAlign.center),
      small(s.profile['email']!, align: TextAlign.center),
      gap(12),
      Center(child: Chip(label: small('♨ Racha de 5 días'))),
      gap(10),
      row(
        'Editar perfil',
        'Nombre, carrera y preferencias',
        Icons.person_outline,
        () => go('edit-profile'),
      ),
      row(
        'Recordatorios',
        '4 configurados',
        Icons.notifications_outlined,
        () => go('reminders'),
      ),
      row(
        'Privacidad y datos',
        'Gestiona tu información',
        Icons.shield_outlined,
        () => go('privacy'),
      ),
      row(
        'Ayuda y apoyo',
        'Recursos y orientación',
        Icons.help_outline,
        () => go('help'),
      ),
      SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        secondary: Icon(
          dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        ),
        title: text('Modo oscuro', bold: true),
        subtitle: small('Tu preferencia se guarda en este dispositivo'),
        value: s.dark,
        onChanged: (_) => s.toggleTheme(),
      ),
      row(
        'Acerca de Mood',
        'Versión 1.2.0 · Flutter',
        Icons.info_outline,
        () => go('about'),
      ),
      row(
        'Cerrar sesión',
        '',
        Icons.logout,
        () => confirm(
          '¿Cerrar sesión?',
          'Tu progreso quedará guardado y podrás volver cuando quieras.',
          () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (_) => false,
            );
          },
          label: 'Sí, cerrar sesión',
        ),
        color: 'peach',
      ),
      gap(12),
      small(
        'Mood acompaña tu bienestar académico y no sustituye atención profesional.',
        align: TextAlign.center,
      ),
    ];
  }
}
