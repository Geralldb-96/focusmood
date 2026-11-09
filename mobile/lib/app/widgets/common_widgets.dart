part of '../../main.dart';

extension _CommonWidgets on _MoodPageState {
  Widget brand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: moodGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.spa_outlined, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 10),
        text('Mood', size: 22, bold: true),
      ],
    );
  }

  Widget avatar({double radius = 38}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: tone('mint'),
      child: text(s.initials, size: radius * 0.65, bold: true),
    );
  }

  Future<void> confirm(
    String message,
    String detail,
    VoidCallback action, {
    String label = 'Confirmar',
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                gap(8),
                small(detail),
                gap(10),
                button(label, () {
                  Navigator.pop(sheetContext);
                  action();
                }, danger: true),
                button(
                  'Cancelar',
                  () => Navigator.pop(sheetContext),
                  secondary: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
