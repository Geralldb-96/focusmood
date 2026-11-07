import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../state/session_controller.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Align(alignment: Alignment.centerLeft, child: Brand()),
        ),
        const SizedBox(height: 22),
        const _Illustration(),
        const SizedBox(height: 22),
        const Text(
          'Tu bienestar\nacadémico, a tu ritmo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
            height: 1.15,
          ),
        ),
        const MutedText(
          'Registra cómo te sientes, mejora tus hábitos y recibe recomendaciones útiles para estudiar con equilibrio.',
        ),
        const InfoBanner(
          'Mood no sustituye orientación médica o psicológica profesional.',
          icon: Icons.verified_user_outlined,
        ),
        PrimaryButton(
          label: 'Comenzar',
          icon: Icons.arrow_forward,
          onPressed: () => pushScreen(context, const AuthScreen(signUp: true)),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '¿Ya tienes cuenta?',
              style: TextStyle(fontSize: 12, color: MoodColors.muted),
            ),
            LinkText(
              'Inicia sesión',
              onTap: () => pushScreen(context, const AuthScreen(signUp: false)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 210,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 210,
          height: 210,
          decoration: const BoxDecoration(
            color: MoodColors.mint,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            color: MoodColors.lavender,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: MoodColors.peach,
            shape: BoxShape.circle,
          ),
        ),
        const Icon(Icons.spa_outlined, size: 40, color: MoodColors.green),
        const Positioned(
          top: 24,
          right: 52,
          child: Icon(
            Icons.favorite_border,
            size: 22,
            color: MoodColors.purple,
          ),
        ),
        const Positioned(
          bottom: 30,
          left: 56,
          child: Icon(
            Icons.auto_awesome_outlined,
            size: 22,
            color: MoodColors.orange,
          ),
        ),
      ],
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.signUp});

  final bool signUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = false;
  bool _showTermsError = false;
  late bool _signUp = widget.signUp;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _requiredEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'El correo no tiene un formato válido';
    }
    return null;
  }

  String? _passwordRule(String? v) {
    final value = v ?? '';
    if (!_signUp) return value.isEmpty ? 'La contraseña es obligatoria' : null;
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,64}$').hasMatch(value)) {
      return 'Mínimo 8 caracteres, con letra y número';
    }
    return null;
  }

  Future<void> _submit() async {
    final ok = _form.currentState!.validate();
    setState(() => _showTermsError = _signUp && !_accepted);
    if (!ok || (_signUp && !_accepted)) return;
    final session = context.read<SessionController>();
    final done = _signUp
        ? await session.register(_name.text, _email.text, _password.text)
        : await session.login(_email.text, _password.text);
    if (done && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      toast(
        _signUp
            ? '¡Cuenta creada! Bienvenido a Mood'
            : 'Qué bueno verte de nuevo',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return ScreenScaffold(
      children: [
        Row(
          children: [
            RoundIconButton(
              icon: Icons.arrow_back,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            const Brand(),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          _signUp ? 'Crea tu espacio' : 'Qué gusto verte',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
          ),
        ),
        MutedText(
          _signUp
              ? 'Unos datos para personalizar tu experiencia.'
              : 'Retoma tus hábitos y sesiones de estudio.',
        ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_signUp)
                LabeledField(
                  label: 'Nombre',
                  controller: _name,
                  icon: Icons.person_outline,
                  hint: 'Andrea',
                  autofillHints: const [AutofillHints.name],
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'El nombre es obligatorio'
                      : null,
                ),
              LabeledField(
                label: _signUp ? 'Correo universitario' : 'Correo',
                controller: _email,
                icon: Icons.mail_outline,
                hint: 'nombre@universidad.edu',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: _requiredEmail,
              ),
              LabeledField(
                label: 'Contraseña',
                controller: _password,
                icon: Icons.lock_outline,
                hint: '••••••••••',
                obscure: true,
                autofillHints: _signUp
                    ? const [AutofillHints.newPassword]
                    : const [AutofillHints.password],
                validator: _passwordRule,
              ),
              if (_signUp) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '8 a 64 caracteres, con al menos una letra y un número',
                    style: TextStyle(fontSize: 11, color: MoodColors.muted),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.transparent,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v ?? false),
                  title: const Text(
                    'Acepto los términos, privacidad y el uso responsable de recomendaciones.',
                    style: TextStyle(fontSize: 12, color: MoodColors.muted),
                  ),
                  subtitle: _showTermsError && !_accepted
                      ? const Text(
                          'Debes aceptar las condiciones para continuar',
                          style: TextStyle(
                            fontSize: 11,
                            color: MoodColors.danger,
                          ),
                        )
                      : null,
                ),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: LinkText(
                    '¿Olvidaste tu contraseña?',
                    onTap: () => pushScreen(context, const RecoverScreen()),
                  ),
                ),
            ],
          ),
        ),
        if (session.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Semantics(
              liveRegion: true,
              child: Text(
                session.error!,
                style: const TextStyle(fontSize: 12, color: MoodColors.danger),
              ),
            ),
          ),
        const SizedBox(height: 6),
        PrimaryButton(
          label: _signUp ? 'Crear cuenta' : 'Iniciar sesión',
          icon: Icons.person_outline,
          loading: session.busy,
          onPressed: _submit,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _signUp ? '¿Ya tienes cuenta?' : '¿Aún no tienes cuenta?',
              style: const TextStyle(fontSize: 12, color: MoodColors.muted),
            ),
            LinkText(
              _signUp ? 'Inicia sesión' : 'Regístrate',
              onTap: () => setState(() => _signUp = !_signUp),
            ),
          ],
        ),
      ],
    );
  }
}

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<SessionController>().forgotPassword(_email.text);
      if (mounted) setState(() => _sent = true);
    } on ApiException catch (e) {
      setState(() => _sent = false);
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
          title: 'Recuperar acceso',
          subtitle: 'Te enviaremos un enlace seguro.',
          onBack: () => Navigator.of(context).pop(),
        ),
        const Center(
          child: Icon(Icons.key_outlined, size: 54, color: MoodColors.green),
        ),
        Form(
          key: _form,
          child: LabeledField(
            label: 'Correo de tu cuenta',
            controller: _email,
            icon: Icons.mail_outline,
            hint: 'nombre@campus.edu',
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                ? null
                : 'Ingresa un correo válido',
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Enviar enlace',
          icon: Icons.send_outlined,
          loading: _busy,
          onPressed: _send,
        ),
        if (_sent)
          const InfoBanner(
            'Solicitud registrada. Si el servidor tiene el envío de correo configurado, recibirás las instrucciones.',
            icon: Icons.check_circle_outline,
            color: MoodColors.mint,
            foreground: MoodColors.deep,
          ),
      ],
    );
  }
}
