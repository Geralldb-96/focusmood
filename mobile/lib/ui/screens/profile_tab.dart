import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_exception.dart';
import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../state/session_controller.dart';
import '../widgets.dart';
import 'shell.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _logout(BuildContext context) async {
    final session = context.read<SessionController>();
    final nav = context.read<ShellNav>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, color: MoodColors.danger),
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tu progreso quedará guardado y podrás volver cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, cerrar sesión',
              style: TextStyle(color: MoodColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      nav.index = 0;
      await session.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    return ScreenScaffold(
      children: [
        const ScreenHeader(
          title: 'Perfil',
          subtitle: 'Tu espacio y preferencias',
        ),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: MoodColors.mint,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: MoodColors.deep,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(fontSize: 12, color: MoodColors.muted),
              ),
              if (user.career.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Chip(
                    label: Text(
                      user.career,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MoodColors.peachText,
                      ),
                    ),
                    backgroundColor: MoodColors.peach,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        RowTile(
          icon: Icons.person_outline,
          title: 'Editar perfil',
          subtitle: 'Nombre, carrera y universidad',
          onTap: () => pushScreen(context, const EditProfileScreen()),
        ),
        RowTile(
          icon: Icons.notifications_none,
          title: 'Recordatorios',
          subtitle: 'Rutinas diarias en este dispositivo',
          onTap: () => pushScreen(context, const RemindersScreen()),
        ),
        RowTile(
          icon: Icons.verified_user_outlined,
          title: 'Privacidad y datos',
          subtitle: 'Gestiona tu información',
          onTap: () => pushScreen(context, const PrivacyScreen()),
        ),
        RowTile(
          icon: Icons.help_outline,
          title: 'Ayuda y apoyo',
          subtitle: 'Recursos y orientación',
          onTap: () => pushScreen(context, const HelpScreen()),
        ),
        RowTile(
          icon: Icons.info_outline,
          title: 'Acerca de Mood',
          subtitle: 'Versión 1.0.0',
          onTap: () => pushScreen(context, const AboutScreen()),
        ),
        RowTile(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          tileColor: MoodColors.dangerBg,
          iconColor: MoodColors.danger,
          titleColor: MoodColors.danger,
          onTap: () => _logout(context),
        ),
        const MutedText(
          'Mood acompaña tu bienestar académico y no sustituye atención profesional.',
          center: true,
          size: 11,
        ),
      ],
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final _user = context.read<SessionController>().user;
  late final _name = TextEditingController(text: _user.name);
  late final _email = TextEditingController(text: _user.email);
  late final _university = TextEditingController(text: _user.university);
  late final _career = TextEditingController(text: _user.career);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _university.dispose();
    _career.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<SessionController>().updateProfile(
        name: _name.text,
        career: _career.text,
        university: _university.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      toast('Perfil actualizado');
    } on ApiException catch (e) {
      toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Editar perfil',
          subtitle: 'Actualiza tu información personal',
          onBack: () => Navigator.of(context).pop(),
        ),
        Form(
          key: _form,
          child: Column(
            children: [
              LabeledField(
                label: 'Nombre completo',
                controller: _name,
                icon: Icons.person_outline,
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              LabeledField(
                label: 'Correo',
                controller: _email,
                icon: Icons.mail_outline,
                readOnly: true,
              ),
              LabeledField(
                label: 'Universidad',
                controller: _university,
                icon: Icons.school_outlined,
              ),
              LabeledField(
                label: 'Carrera',
                controller: _career,
                icon: Icons.menu_book_outlined,
              ),
            ],
          ),
        ),
        const MutedText(
          'El correo no se puede cambiar desde la app.',
          size: 11,
        ),
        PrimaryButton(
          label: 'Guardar cambios',
          icon: Icons.check,
          loading: _busy,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// Rutinas de recordatorio. Son preferencias locales: aún no programan notificaciones del sistema.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const _routines = [
    (
      'reminder-mood',
      Icons.favorite_border,
      'Registro emocional',
      'Todos los días · 09:00',
    ),
    (
      'reminder-water',
      Icons.water_drop_outlined,
      'Tomar agua',
      'Lun–Vie · cada 2 horas',
    ),
    (
      'reminder-focus',
      Icons.timer_outlined,
      'Bloque de enfoque',
      'Lun, Mié, Vie · 17:00',
    ),
    (
      'reminder-sleep',
      Icons.bedtime_outlined,
      'Preparar el descanso',
      'Todos los días · 23:00',
    ),
  ];

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
      (p) => mounted ? setState(() => _prefs = p) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Recordatorios',
          subtitle: 'Elige cuándo quieres que Mood te acompañe',
          onBack: () => Navigator.of(context).pop(),
        ),
        const InfoBanner(
          'Mantén solo los avisos que te resulten útiles. Puedes pausarlos en cualquier momento.',
          icon: Icons.notifications_none,
        ),
        const SectionTitle('Rutina diaria'),
        for (final (key, icon, title, sub) in _routines)
          RowTile(
            icon: icon,
            title: title,
            subtitle: sub,
            trailing: Switch(
              value: _prefs?.getBool(key) ?? false,
              activeTrackColor: MoodColors.green,
              onChanged: _prefs == null
                  ? null
                  : (v) async {
                      await _prefs!.setBool(key, v);
                      setState(() {});
                    },
            ),
          ),
        const MutedText(
          'Preferencias guardadas en este dispositivo. El envío de notificaciones del sistema aún no está conectado.',
          size: 11,
        ),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Privacidad y datos',
          onBack: () => Navigator.of(context).pop(),
        ),
        const PastelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined, color: MoodColors.green),
              SizedBox(height: 10),
              Text(
                'Tú controlas tu información',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              MutedText(
                'Tus hábitos, registros y sesiones se guardan en tu cuenta de Mood y solo tú puedes verlos. Los datos de ánimo, energía y concentración se envían al servicio de IA únicamente para generar tus recomendaciones.',
              ),
            ],
          ),
        ),
        PrimaryButton(
          label: 'Borrar datos de este dispositivo',
          icon: Icons.delete_outline,
          danger: true,
          onPressed: () async {
            final session = context.read<SessionController>();
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            await session.logout();
          },
        ),
        const MutedText(
          'Cierra tu sesión y borra las preferencias guardadas en este dispositivo. Tu cuenta no se elimina.',
          size: 11,
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Ayuda y apoyo',
          onBack: () => Navigator.of(context).pop(),
        ),
        const PastelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite_border, color: MoodColors.green),
              SizedBox(height: 10),
              Text(
                'No tienes que hacerlo solo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              MutedText(
                'Si necesitas apoyo, contacta al servicio de bienestar de tu universidad o a un profesional de salud mental.',
              ),
              MutedText(
                'Si estás en peligro inmediato, comunícate con los servicios de emergencia de tu localidad.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Acerca de Mood',
          onBack: () => Navigator.of(context).pop(),
        ),
        const PastelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Brand(),
              SizedBox(height: 12),
              Text(
                'Bienestar que acompaña',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              MutedText(
                'Una herramienta para cuidar tus hábitos y encontrar tu ritmo de estudio.',
              ),
              MutedText('Versión 1.0.0'),
              MutedText(
                'Las recomendaciones son orientativas y no constituyen atención médica o psicológica.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
