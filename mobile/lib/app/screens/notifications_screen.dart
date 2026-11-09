part of '../../main.dart';

extension _NotificationsScreenContent on _MoodPageState {
  List<Widget> buildNotificationsScreen() {
    return [
      heading(
        'Notificaciones',
        sub: s.read ? 'Todo tranquilo por aquí' : '3 nuevas desde ayer',
        action: s.read ? Icons.tune : Icons.done_all,
        actionLabel: 'Marcar todas como leídas',
        onAction: () {
          if (s.read) {
            go('reminders');
          } else {
            s.read = true;
            unawaited(s.save('notifications', true));
          }
        },
      ),
      if (s.read) ...[
        gap(100),
        Center(
          child: CircleAvatar(
            radius: 65,
            backgroundColor: tone('mint'),
            child: const Icon(Icons.notifications_off_outlined, size: 36),
          ),
        ),
        gap(24),
        Text(
          'No tienes avisos\npendientes',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gap(9),
        small(
          'Cuando haya algo útil para tus hábitos o sesiones, aparecerá aquí.',
          align: TextAlign.center,
        ),
        gap(12),
        button(
          'Configurar recordatorios',
          () => go('reminders'),
          secondary: true,
          icon: Icons.notification_add_outlined,
        ),
      ] else ...[
        title('HOY'),
        row(
          '¿Cómo te sientes hoy?',
          'Tu registro diario está listo. Te tomará menos de un minuto.',
          Icons.sentiment_satisfied_alt,
          () => go('daily'),
        ),
        row(
          'Un bloque breve puede ayudarte',
          'Tienes 25 minutos libres antes de tu próxima clase.',
          Icons.timer_outlined,
          () => go('focus'),
          color: 'peach',
        ),
        row(
          'Pausa para hidratarte',
          'Un pequeño paso cuenta.',
          Icons.water_drop_outlined,
          () => go('habits'),
        ),
        title('AYER'),
        row(
          'Resumen semanal disponible',
          'Tu ánimo y constancia mejoran semana a semana.',
          Icons.auto_awesome_outlined,
          () => go('progress'),
          color: 'lavender',
        ),
      ],
    ];
  }
}
