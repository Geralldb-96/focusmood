part of '../../main.dart';

extension _CardWidgets on _MoodPageState {
  Widget box(Widget child, {String? color, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color == null ? surface : tone(color),
        borderRadius: BorderRadius.circular(23),
        border: color == null
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
        boxShadow: color == null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  Widget note(
    String message, {
    String color = 'peach',
    IconData icon = Icons.info_outline,
  }) {
    return box(
      Row(
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 10),
          Expanded(child: small(message)),
        ],
      ),
      color: color,
    );
  }

  Widget row(
    String label,
    String sub,
    IconData icon,
    VoidCallback action, {
    String? end,
    String color = 'mint',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tone(color),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(label, size: 13, bold: true),
                      if (sub.isNotEmpty) small(sub),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (end != null)
                  text(end, size: 11, bold: true)
                else
                  const Icon(Icons.chevron_right, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget stat(String label, String value, IconData icon, String color) {
    return Expanded(
      child: box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17),
            gap(8),
            text(value, size: 19, bold: true),
            gap(4),
            small(label),
          ],
        ),
        color: color,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget progress(double value, {Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 7,
        color: color,
        backgroundColor: dark
            ? const Color(0xff33483c)
            : const Color(0xffe5eeea),
      ),
    );
  }
}
