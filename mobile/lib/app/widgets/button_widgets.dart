part of '../../main.dart';

extension _ButtonWidgets on _MoodPageState {
  Widget button(
    String label,
    VoidCallback? onTap, {
    IconData? icon,
    bool secondary = false,
    bool danger = false,
  }) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: secondary
          ? OutlinedButton(onPressed: onTap, child: child)
          : FilledButton(
              onPressed: onTap,
              style: danger
                  ? FilledButton.styleFrom(
                      backgroundColor: dark
                          ? const Color(0xff4b282a)
                          : const Color(0xfffbe8e7),
                      foregroundColor: dark
                          ? const Color(0xffffb4b4)
                          : const Color(0xffbf4549),
                    )
                  : null,
              child: child,
            ),
    );
  }

  Widget link(String label, VoidCallback action) {
    return Center(
      child: TextButton(
        onPressed: action,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
