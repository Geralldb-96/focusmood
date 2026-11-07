import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/recommendation_controller.dart';
import '../../state/study_controller.dart';
import '../widgets.dart';
import 'shell.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _saved = false; // marcador local, solo visual

  Future<void> _rate(RecommendationController c, int score) async {
    try {
      await c.rate(score);
      toast(
        score >= 4 ? 'Gracias por tu opinión' : 'Buscaremos otras técnicas',
      );
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RecommendationController>();
    final rec = c.current;
    if (rec == null) return const Scaffold(body: SizedBox());
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Tu recomendación',
          subtitle: 'Basada en tu registro de hoy',
          onBack: () => Navigator.of(context).pop(),
          trailing: RoundIconButton(
            icon: _saved ? Icons.bookmark : Icons.bookmark_border,
            tooltip: _saved ? 'Quitar de guardadas' : 'Guardar recomendación',
            onPressed: () {
              setState(() => _saved = !_saved);
              toast(
                _saved ? 'Recomendación guardada' : 'Recomendación retirada',
              );
            },
          ),
        ),
        PastelCard(
          color: MoodColors.lavender,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 14,
                    color: MoodColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec.isWellness
                          ? 'Actividad de bienestar'
                          : 'Técnica de estudio',
                      style: const TextStyle(
                        fontSize: 12,
                        color: MoodColors.muted,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: MoodColors.mint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: MoodColors.deep,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${rec.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MoodColors.deep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                rec.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
              MutedText(rec.technique),
            ],
          ),
        ),
        const SectionTitle('Cómo hacerlo'),
        for (final (i, step) in rec.steps.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: MoodColors.mint,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MoodColors.deep,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Iniciar · ${rec.durationMinutes} min',
          icon: Icons.play_arrow_outlined,
          onPressed: () {
            context.read<StudyController>().start(
              withMinutes: rec.durationMinutes,
            );
            Navigator.of(context).popUntil((r) => r.isFirst);
            context.read<ShellNav>().go(ShellNav.focus);
          },
        ),
        const MutedText(
          '¿Esta recomendación te resultó útil?',
          center: true,
          size: 11,
        ),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: rec.helpful == true ? '¡Gracias!' : 'Me sirvió',
                icon: Icons.thumb_up_outlined,
                secondary: true,
                onPressed: () => _rate(c, 5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: rec.helpful == false ? 'Anotado' : 'No me sirvió',
                icon: Icons.thumb_down_outlined,
                secondary: true,
                onPressed: () => _rate(c, 1),
              ),
            ),
          ],
        ),
        Center(
          child: LinkText(
            'Ver historial de recomendaciones',
            onTap: () => pushScreen(context, const HistoryScreen()),
          ),
        ),
        MutedText(
          '${rec.fromFallback ? 'Recomendación general: la IA no está disponible ahora. ' : 'Generada con IA. '}${rec.disclaimer}',
          center: true,
          size: 11,
        ),
      ],
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Todas';

  @override
  Widget build(BuildContext context) {
    final c = context.watch<RecommendationController>();
    final rated = c.history.where((r) => r.score != null).toList();
    final helpfulRatio = rated.isEmpty
        ? 0.0
        : rated.where((r) => r.helpful == true).length / rated.length;
    final shown = c.history
        .where((r) => _filter == 'Todas' || r.helpful == true)
        .toList();
    return ScreenScaffold(
      children: [
        ScreenHeader(
          title: 'Historial',
          subtitle: 'Tus recomendaciones personalizadas',
          onBack: () => Navigator.of(context).pop(),
        ),
        ChipWrap(
          children: [
            for (final t in ['Todas', 'Útiles'])
              MoodChip(
                label: t,
                selected: t == _filter,
                onTap: () => setState(() => _filter = t),
              ),
          ],
        ),
        PastelCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 11, color: MoodColors.muted),
                  ),
                  Text(
                    '${c.history.length} ${c.history.length == 1 ? 'recomendación' : 'recomendaciones'}${rated.isEmpty ? '' : ' · ${(helpfulRatio * 100).round()}% útiles'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ProgressTrack(helpfulRatio),
            ],
          ),
        ),
        for (final Recommendation r in shown)
          RowTile(
            icon: r.helpful == false
                ? Icons.thumb_down_outlined
                : Icons.thumb_up_outlined,
            title: r.title,
            subtitle:
                '${DateFormat("d MMM, HH:mm", 'es').format(r.generatedAt)} · ${r.durationMinutes} min · ${r.activity}',
            onTap: () {
              c.select(r);
              pushScreen(context, const RecommendationScreen());
            },
          ),
        if (c.history.isEmpty)
          const MutedText(
            'Aún no tienes recomendaciones. Registra tu día para recibir la primera.',
            center: true,
          )
        else if (shown.isEmpty)
          const MutedText(
            'Todavía no hay recomendaciones marcadas como útiles.',
            center: true,
          ),
      ],
    );
  }
}
