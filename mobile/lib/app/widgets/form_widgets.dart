part of '../../main.dart';

extension _FormWidgets on _MoodPageState {
  Widget chips(
    List<String> values,
    String selected,
    ValueChanged<String> change,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(value, style: const TextStyle(fontSize: 11)),
              selected: value == selected,
              onSelected: (_) => change(value),
            ),
          )
          .toList(),
    );
  }

  Widget field(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool secret = false,
    bool required = false,
    bool isEmail = false,
    int? minLength,
    bool digits = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 13, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(label, size: 12, bold: true),
          gap(6),
          TextFormField(
            key: ValueKey('field-$label'),
            controller: controller,
            obscureText: secret,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : digits
                ? TextInputType.number
                : TextInputType.text,
            autocorrect: !secret && !isEmail,
            enableSuggestions: !secret,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: icon == null ? null : Icon(icon, size: 18),
              hintText: isEmail ? 'nombre@universidad.edu' : null,
            ),
            validator: (value) {
              final normalizedValue = value?.trim() ?? '';

              if (required && normalizedValue.isEmpty) {
                return 'Completa este campo.';
              }

              if (isEmail &&
                  !RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(normalizedValue)) {
                return 'Revisa el formato del correo.';
              }

              if (minLength != null && normalizedValue.length < minLength) {
                return 'Usa al menos $minLength caracteres.';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
