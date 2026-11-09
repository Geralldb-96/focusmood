part of '../../main.dart';

extension _RecommendationScreenContent on _MoodPageState {
  List<Widget> buildRecommendationScreen() {
    return [
      heading(
        'Tu recomendación',
        sub: 'Basada en tu registro de hoy',
        action: s.saved ? Icons.bookmark : Icons.bookmark_border,
        actionLabel: 'Guardar recomendación',
        onAction: () {
          s.saved = !s.saved;
          unawaited(s.save('bookmark', s.saved));
        },
      ),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: small('✧ Técnica de enfoque')),
                Chip(label: small(duration)),
              ],
            ),
            text('Arranque suave 5–10', size: 22, bold: true),
            gap(8),
            small(
              'Reduce la fricción de empezar: una microtarea clara y un bloque breve de enfoque.',
            ),
          ],
        ),
        color: 'lavender',
      ),
      title('Cómo hacerlo'),
      ...[
        'Elige una sola pregunta del ${activity.toLowerCase()} para repasar.',
        'Dedica 5 minutos a leer y subrayar ideas clave.',
        'Usa 10 minutos para responder sin consultar apuntes.',
      ].asMap().entries.map(
        (entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: tone('mint'),
                child: text('${entry.key + 1}', size: 11, bold: true),
              ),
              const SizedBox(width: 9),
              Expanded(child: text(entry.value, size: 12)),
            ],
          ),
        ),
      ),
      button('Iniciar técnica · 15 min', () {
        s.configureTimer(15);
        s.startTimer();
        go('focus');
      }, icon: Icons.play_arrow_outlined),
      gap(10),
      small('¿Esta recomendación te resultó útil?', align: TextAlign.center),
      Row(
        children: [
          Expanded(
            child: button(
              s.feedback == 'yes' ? '¡Gracias!' : 'Me sirvió',
              () => rate('yes'),
              secondary: true,
              icon: Icons.thumb_up_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: button(
              'No me sirvió',
              () => rate('no'),
              secondary: true,
              icon: Icons.thumb_down_outlined,
            ),
          ),
        ],
      ),
      link('Ver historial de recomendaciones', () => go('history')),
      small(
        'Sugerencia de demostración, sin IA conectada. No sustituye apoyo profesional.',
        align: TextAlign.center,
      ),
    ];
  }
}
