part of '../../main.dart';

extension _DailyScreenContent on _MoodPageState {
  List<Widget> buildDailyScreen() {
    return [
      heading('Tu registro de hoy', sub: 'Paso 2 de 2 · contexto académico'),
      Row(
        children: [
          Expanded(child: progress(1)),
          const SizedBox(width: 6),
          Expanded(child: progress(1)),
        ],
      ),
      gap(15),
      ...[
        (
          key: 'mood',
          label: 'Estado de ánimo',
          low: 'Bajo',
          high: 'Muy bien',
          color: const Color(0xff9080b0),
        ),
        (
          key: 'energy',
          label: 'Energía',
          low: 'Sin energía',
          high: 'Con energía',
          color: const Color(0xfff6ac69),
        ),
        (
          key: 'focus',
          label: 'Concentración',
          low: 'Dispersa',
          high: 'Enfocada',
          color: const Color(0xff4c8198),
        ),
      ].map(
        (data) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: text(data.label, bold: true)),
                text('${s.record[data.key]}/10', color: data.color, bold: true),
              ],
            ),
            Slider(
              semanticFormatterCallback: (value) {
                return '${data.label}: ${value.round()}';
              },
              padding: const EdgeInsets.symmetric(vertical: 9),
              value: s.record[data.key]!.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: data.color,
              onChanged: (value) {
                s.setRecord(data.key, value.round());
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [small(data.low), small(data.high)],
            ),
            gap(18),
          ],
        ),
      ),
      title('Tiempo disponible'),
      chips(
        ['5 min', '15 min', '25 min', '45+ min'],
        duration,
        (value) => refresh(() => duration = value),
      ),
      title('Actividad académica'),
      chips(
        ['Examen', 'Tarea', 'Clase', 'Proyecto'],
        activity,
        (value) => refresh(() => activity = value),
      ),
      button(
        'Generar recomendación',
        () => go(
          'generating',
          args: {'duration': duration, 'activity': activity},
        ),
        icon: Icons.auto_awesome_outlined,
      ),
      small(
        'Tu información emocional se guarda en este dispositivo y puedes eliminarla.',
        align: TextAlign.center,
      ),
    ];
  }
}
