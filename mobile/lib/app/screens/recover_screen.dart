part of '../../main.dart';

extension _RecoverScreenContent on _MoodPageState {
  List<Widget> buildRecoverScreen() {
    return [
      heading('Recuperar acceso', sub: 'Te enviaremos un enlace seguro.'),
      box(
        const SizedBox(
          height: 140,
          child: Center(
            child: CircleAvatar(
              radius: 38,
              child: Icon(Icons.key_outlined, size: 34),
            ),
          ),
        ),
        color: 'blue',
      ),
      Form(
        key: form,
        child: Column(
          children: [
            field(
              'Correo de tu cuenta',
              email,
              icon: Icons.mail_outline,
              required: true,
              isEmail: true,
            ),
            button('Enviar enlace', () {
              if (form.currentState!.validate()) {
                refresh(() => sent = true);
              }
            }, icon: Icons.send_outlined),
          ],
        ),
      ),
      if (sent)
        note(
          'Solicitud de demostración. El envío de correos estará disponible al conectar el servidor.',
          color: 'mint',
          icon: Icons.check_circle_outline,
        ),
    ];
  }
}
