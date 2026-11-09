part of '../../main.dart';

extension _TypographyWidgets on _MoodPageState {
  Text text(
    String value, {
    double? size,
    bool bold = false,
    Color? color,
    TextAlign? align,
  }) {
    return Text(
      value,
      textAlign: align,
      style: TextStyle(
        fontSize: size,
        fontWeight: bold ? FontWeight.w700 : null,
        color: color,
      ),
    );
  }

  Widget small(String value, {TextAlign? align}) {
    return Text(
      value,
      textAlign: align,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget gap([double size = 16]) {
    return SizedBox(height: size);
  }

  Widget title(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget heading(
    String value, {
    String? sub,
    bool backButton = true,
    IconData? action,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          if (backButton) ...[
            IconButton.filledTonal(
              onPressed: () => back(),
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Volver',
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                if (sub != null) small(sub),
              ],
            ),
          ),
          if (action != null)
            IconButton.filledTonal(
              onPressed: onAction,
              icon: Icon(action, size: 20),
              tooltip: actionLabel ?? 'Opciones',
            ),
        ],
      ),
    );
  }
}
