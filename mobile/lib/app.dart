import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api_client.dart';
import 'core/config.dart';
import 'core/messenger.dart';
import 'core/theme.dart';
import 'core/token_store.dart';
import 'data/auth_repository.dart';
import 'data/habit_repository.dart';
import 'data/progress_repository.dart';
import 'data/recommendation_repository.dart';
import 'data/study_repository.dart';
import 'data/wellness_repository.dart';
import 'state/habits_controller.dart';
import 'state/progress_controller.dart';
import 'state/recommendation_controller.dart';
import 'state/session_controller.dart';
import 'state/study_controller.dart';
import 'state/wellness_controller.dart';
import 'ui/screens/auth_screens.dart';
import 'ui/screens/shell.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class MoodApp extends StatefulWidget {
  const MoodApp({
    super.key,
    required this.prefs,
    this.httpClient,
    this.tokenStore,
    this.baseUrl,
  });

  final SharedPreferences prefs;
  final http.Client? httpClient;
  final TokenStore? tokenStore;
  final String? baseUrl;

  @override
  State<MoodApp> createState() => _MoodAppState();
}

class _MoodAppState extends State<MoodApp> {
  late final ApiClient _api;
  late final ProgressController _progress;
  late final HabitsController _habits;
  late final RecommendationController _recommendations;
  late final StudyController _study;
  late final WellnessController _wellness;
  late final SessionController _session;
  final _nav = ShellNav();

  @override
  void initState() {
    super.initState();
    // Composición de dependencias: los controladores reciben interfaces de repositorio.
    _api = ApiClient(
      httpClient: widget.httpClient ?? http.Client(),
      tokenStore: widget.tokenStore ?? SecureTokenStore(),
      baseUrl: widget.baseUrl ?? AppConfig.apiBase,
    );
    _progress = ProgressController(ApiProgressRepository(_api));
    _habits = HabitsController(
      ApiHabitRepository(_api),
      widget.prefs,
      onChanged: _progress.refreshQuietly,
    );
    _recommendations = RecommendationController(
      ApiRecommendationRepository(_api),
      onChanged: _progress.refreshQuietly,
    );
    _study = StudyController(
      ApiStudyRepository(_api),
      onChanged: _progress.refreshQuietly,
    );
    _wellness = WellnessController(
      ApiWellnessRepository(_api),
      onChanged: _progress.refreshQuietly,
    );
    _session = SessionController(ApiAuthRepository(_api), [
      _progress,
      _habits,
      _recommendations,
      _study,
      _wellness,
    ]);
    _api.onSessionExpired = _session.expire;
    _session.bootstrap();
  }

  @override
  void dispose() {
    for (final c in [
      _session,
      _progress,
      _habits,
      _recommendations,
      _study,
      _wellness,
      _nav,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _session),
        ChangeNotifierProvider.value(value: _progress),
        ChangeNotifierProvider.value(value: _habits),
        ChangeNotifierProvider.value(value: _recommendations),
        ChangeNotifierProvider.value(value: _study),
        ChangeNotifierProvider.value(value: _wellness),
        ChangeNotifierProvider.value(value: _nav),
      ],
      child: MaterialApp(
        title: 'Mood',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: messengerKey,
        theme: buildTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => _PhoneFrame(child: child!),
        home: const _AuthGate(),
      ),
    );
  }
}

/// En pantallas anchas (web/escritorio) muestra la app con proporciones de teléfono.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width <= 600) return child;
    return ColoredBox(
      color: const Color(0xFFEDF2EF),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  AuthStatus? _last;

  @override
  Widget build(BuildContext context) {
    final status = context.select<SessionController, AuthStatus>(
      (s) => s.status,
    );
    if (_last == AuthStatus.signedIn && status == AuthStatus.signedOut) {
      // Sesión cerrada o expirada: se descartan las pantallas internas que quedaran abiertas.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _navigatorKey.currentState?.popUntil((r) => r.isFirst),
      );
    }
    _last = status;
    return switch (status) {
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.signedOut => const WelcomeScreen(),
      AuthStatus.signedIn => const Shell(),
    };
  }
}
