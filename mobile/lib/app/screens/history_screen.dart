part of '../../main.dart';

extension _HistoryScreenContent on _MoodPageState {
  List<Widget> buildHistoryScreen() {
    final rows = [
      ('Arranque suave 5–10', 'Hoy, 10:32 · 15 min · Examen'),
      ('Respiración cuadrada', 'Ayer, 18:05 · 5 min · Cierre del día'),
      ('Mapa de conceptos rápido', '29 sep, 09:14 · 25 min · Proyecto'),
      ('Pausa activa de escritorio', '27 sep, 16:42 · 8 min · Tarea'),
    ];

    return [
      heading('Historial', sub: 'Tus recomendaciones personalizadas'),
      chips(
        ['Todas', 'Útiles', 'Guardadas'],
        filter,
        (value) => refresh(() => filter = value),
      ),
      box(
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: small('Este mes · demo')),
                Expanded(
                  child: text(
                    '8 recomendaciones · 75% útiles',
                    size: 11,
                    bold: true,
                  ),
                ),
              ],
            ),
            gap(8),
            progress(0.75),
          ],
        ),
        color: 'soft',
      ),
      ...rows
          .asMap()
          .entries
          .where(
            (entry) =>
                filter == 'Todas' ||
                filter == 'Guardadas' && s.saved && entry.key == 0 ||
                filter == 'Útiles' && (entry.key > 0 || s.feedback == 'yes'),
          )
          .map(
            (entry) => row(
              entry.value.$1,
              entry.value.$2,
              Icons.thumb_up_outlined,
              () => go('recommendation'),
            ),
          ),
      if (filter == 'Guardadas' && !s.saved)
        note('Aún no guardaste recomendaciones.', color: 'soft'),
    ];
  }
}
