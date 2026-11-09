part of '../../main.dart';

extension _EditProfileScreenContent on _MoodPageState {
  List<Widget> buildEditProfileScreen() {
    return [
      heading('Editar perfil', sub: 'Actualiza tu información personal'),
      Center(child: avatar()),
      gap(8),
      small(
        'Tu avatar usa las iniciales de tu nombre',
        align: TextAlign.center,
      ),
      Form(
        key: form,
        child: Column(
          children: [
            field(
              'Nombre completo',
              name,
              required: true,
              icon: Icons.person_outline,
            ),
            field(
              'Correo',
              email,
              required: true,
              isEmail: true,
              icon: Icons.mail_outline,
            ),
            field(
              'Universidad',
              university,
              icon: Icons.account_balance_outlined,
            ),
            field('Carrera', career, icon: Icons.school_outlined),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: text('Personalización con IA', bold: true),
              subtitle: small('Usar mis registros para recomendar'),
              value: s.personal,
              onChanged: (v) {
                s.personal = v;
                unawaited(s.save('personalization', v));
              },
            ),
            button('Guardar cambios', () {
              if (form.currentState!.validate()) {
                s.saveProfile({
                  'name': name.text.trim(),
                  'email': email.text.trim(),
                  'university': university.text,
                  'career': career.text,
                });
                back('profile');
                notify('Perfil actualizado');
              }
            }, icon: Icons.check),
          ],
        ),
      ),
    ];
  }
}
