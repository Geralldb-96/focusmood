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
}
