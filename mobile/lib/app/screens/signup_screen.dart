part of '../../main.dart';

extension _SignupScreenContent on _MoodPageState {
  List<Widget> buildSignupScreen(String currentScreen) {
    final signup = currentScreen == 'signup';

    return [
      brand(),
      gap(12),
      heading(
        signup ? 'Crea tu espacio' : 'Qué gusto verte',
        sub: signup
            ? 'Unos datos para personalizar tu experiencia.'
            : 'Retoma tus hábitos y sesiones de estudio.',
        backButton: false,
      ),
      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (signup)
              field('Nombre', name, icon: Icons.person_outline, required: true),
            field(
              signup ? 'Correo universitario' : 'Correo',
              email,
              icon: Icons.mail_outline,
              required: true,
              isEmail: true,
            ),
            field(
              'Contraseña',
              password,
              icon: Icons.lock_outline,
              required: true,
              secret: true,
              minLength: 8,
            ),
            if (signup) ...[
              gap(5),
              small('8 caracteres, una mayúscula y un número'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: accepted,
                onChanged: (value) {
                  refresh(() => accepted = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: small(
                  'Acepto los términos, privacidad y el uso responsable de recomendaciones.',
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => go('recover'),
                  child: text('¿Olvidaste tu contraseña?', size: 12),
                ),
              ),
            button(signup ? 'Crear cuenta' : 'Iniciar sesión', () {
              if (!form.currentState!.validate()) return;

              if (signup &&
                  (!accepted ||
                      !RegExp(r'[A-Z]').hasMatch(password.text) ||
                      !RegExp(r'[0-9]').hasMatch(password.text))) {
                notify(
                  'Acepta los términos y usa una contraseña con mayúscula y número.',
                );
                return;
              }

              if (signup) {
                s.saveProfile({
                  ...s.profile,
                  'name': name.text.trim(),
                  'email': email.text.trim(),
                });
              }

              password.clear();

              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);

              notify('Bienvenido a tu espacio de demostración');
            }, icon: Icons.person_add_outlined),
          ],
        ),
      ),
      gap(10),
      small(
        signup ? 'o continúa con tu cuenta institucional' : 'o',
        align: TextAlign.center,
      ),
      button(
        'Continuar con Google',
        () {
          notify('Google requiere conectar un servicio de autenticación.');
        },
        secondary: true,
        icon: Icons.public,
      ),
      link(
        signup
            ? '¿Ya tienes cuenta?  Inicia sesión'
            : '¿Aún no tienes cuenta?  Regístrate',
        () => go(signup ? 'login' : 'signup', replace: true),
      ),
      small(
        'Demo local · No uses tu contraseña real.',
        align: TextAlign.center,
      ),
    ];
  }
}
