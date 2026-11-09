part of '../../main.dart';

extension _PomodoroScreenContent on _MoodPageState {
  List<Widget> buildPomodoroScreen() {
    return [
      heading(
        s.running
            ? 'Enfoque activo'
            : s.started
            ? 'Pausa tu ritmo'
            : 'Pomodoro',
        sub: 'Sesión 1 de 4 · Repaso de estadística',
        backButton: false,
        action: Icons.tune,
        actionLabel: 'Configurar temporizador',
        onAction: configureTimer,
      ),
      gap(6),
      Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: s.seconds / (s.minutes * 60),
                  strokeWidth: 8,
                  backgroundColor: tone('soft'),
                  color: s.running
                      ? Theme.of(context).colorScheme.primary
                      : s.started
                      ? const Color(0xffac7028)
                      : const Color(0xff4c8198),
                ),
              ),
              Container(
                width: 208,
                height: 208,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    text(MoodStore.time(s.seconds), size: 48, bold: true),
                    gap(4),
                    text(
                      s.running
                          ? 'Enfoque en curso'
                          : s.started
                          ? 'Sesión pausada'
                          : 'Listo para enfocarte',
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      gap(18),
      Center(child: text('●  ●  ●  ●', color: muted, size: 12)),
      gap(12),
      if (!s.started && !s.running) ...[
        chips(
          ['15 min', '25 min', '45 min'],
          '${s.minutes} min',
          (v) => s.configureTimer(int.parse(v.split(' ').first)),
        ),
        link('Personalizar duración', configureTimer),
        button(
          'Iniciar enfoque',
          s.startTimer,
          icon: Icons.play_arrow_outlined,
        ),
      ] else ...[
        if (s.running)
          note(
            'Modo sin distracciones · Encuentra un lugar tranquilo.',
            color: 'soft',
            icon: Icons.notifications_off_outlined,
          )
        else
          note(
            'Respira, estira los hombros y retoma cuando estés listo.',
            icon: Icons.coffee_outlined,
          ),
        Row(
          children: [
            Expanded(
              child: button(
                'Finalizar',
                s.finishTimer,
                secondary: true,
                icon: Icons.stop_outlined,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: button(
                s.running ? 'Pausar' : 'Continuar',
                s.running ? s.pauseTimer : s.startTimer,
                icon: s.running ? Icons.pause : Icons.play_arrow_outlined,
              ),
            ),
          ],
        ),
      ],
      link('Ver sesiones realizadas', () => go('sessions')),
    ];
  }
}
