import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_store.dart';
import 'theme.dart';
part 'app/screens/about_screen.dart';
part 'app/screens/help_screen.dart';
part 'app/screens/system_screen.dart';
part 'app/screens/privacy_screen.dart';
part 'app/screens/welcome_screen.dart';
part 'app/screens/signup_screen.dart';
part 'app/screens/login_screen.dart';
part 'app/screens/recover_screen.dart';
part 'app/screens/home_screen.dart';
part 'app/screens/daily_screen.dart';
part 'app/screens/generating_screen.dart';
part 'app/screens/recommendation_screen.dart';
part 'app/screens/history_screen.dart';
part 'app/screens/habits_screen.dart';
part 'app/screens/habit_form_screen.dart';
part 'app/screens/pomodoro_screen.dart';
part 'app/screens/sessions_screen.dart';
part 'app/screens/wellness_screen.dart';
part 'app/screens/exercise_screen.dart';
part 'app/screens/progress_screen.dart';
part 'app/screens/profile_screen.dart';
part 'app/screens/edit_profile_screen.dart';
part 'app/screens/reminders_screen.dart';
part 'app/screens/notifications_screen.dart';
part 'app/widgets/typography_widgets.dart';
part 'app/widgets/button_widgets.dart';
part 'app/widgets/card_widgets.dart';
part 'app/widgets/form_widgets.dart';
part 'app/widgets/common_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MoodStore(await SharedPreferences.getInstance())..load();
  runApp(MoodApp(store: store));
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key, required this.store});
  final MoodStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'Mood · Bienestar académico',
      debugShowCheckedModeBanner: false,
      theme: moodTheme(false),
      darkTheme: moodTheme(true),
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/welcome',
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => MoodPage(
          store: store,
          screen: settings.name?.substring(1) ?? 'welcome',
          argument: settings.arguments,
        ),
      ),
    ),
  );
}

class MoodPage extends StatefulWidget {
  const MoodPage({
    super.key,
    required this.store,
    required this.screen,
    this.argument,
  });
  final MoodStore store;
  final String screen;
  final Object? argument;
  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> with WidgetsBindingObserver {
  MoodStore get s => widget.store;
  String get screen => widget.screen;
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      university = TextEditingController(),
      career = TextEditingController(),
      goal = TextEditingController(),
      custom = TextEditingController();
  Habit? editing;
  String icon = 'walk',
      moment = 'Tarde',
      duration = '15 min',
      activity = 'Examen',
      filter = 'Todas',
      category = 'Para ti',
      exercise = 'Respira y reinicia';
  List<int> days = [0, 1, 2, 3, 4];
  bool reminder = true,
      accepted = false,
      sent = false,
      breathing = true,
      sound = true;
  int exerciseTime = 0;
  Timer? generation, exerciseTicker;
  bool get dark => Theme.of(context).brightness == Brightness.dark;
  Color get muted => Theme.of(context).textTheme.bodySmall!.color!;
  Color get surface => dark ? const Color(0xff1c2d25) : Colors.white;
  Color tone(String kind) => switch (kind) {
    'mint' => dark ? const Color(0xff234436) : const Color(0xffdff2e9),
    'peach' => dark ? const Color(0xff483525) : const Color(0xfffff0e0),
    'blue' => dark ? const Color(0xff243c49) : const Color(0xffe3f0f5),
    'lavender' => dark ? const Color(0xff383047) : const Color(0xffeee9f5),
    _ => dark ? const Color(0xff1d3026) : const Color(0xffedf5f1),
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    name.text = s.profile['name']!;
    email.text = s.profile['email']!;
    university.text = s.profile['university']!;
    career.text = s.profile['career']!;
    if (screen == 'signup') {
      name.clear();
      email.clear();
    }
    if (screen == 'login') email.clear();
    if (screen == 'habit') {
      editing = widget.argument as Habit?;
      name.text = editing?.name ?? '';
      goal.text = editing?.goal ?? '15 minutos';
      icon = editing?.icon ?? 'walk';
      days = [...?editing?.days];
      if (editing == null) days = [0, 1, 2, 3, 4];
      reminder = editing?.reminder ?? true;
      moment = editing?.moment ?? 'Tarde';
    }
    if (widget.argument is Map<String, String>) {
      final args = widget.argument as Map<String, String>;
      duration = args['duration'] ?? duration;
      activity = args['activity'] ?? activity;
      exercise = args['exercise'] ?? exercise;
    }
    if (screen == 'generating') {
      generation = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) {
          go(
            'recommendation',
            replace: true,
            args: {'duration': duration, 'activity': activity},
          );
        }
      });
    }
    if (screen == 'exercise') {
      exerciseTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && breathing) {
          setState(() {
            exerciseTime = (exerciseTime + 1).clamp(0, 180);
            if (exerciseTime == 180) breathing = false;
          });
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) s.tick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    generation?.cancel();
    exerciseTicker?.cancel();
    for (final c in [name, email, password, university, career, goal, custom]) {
      c.dispose();
    }
    super.dispose();
  }

  void go(String page, {bool replace = false, Object? args}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, '/$page', arguments: args);
    } else {
      Navigator.pushNamed(context, '/$page', arguments: args);
    }
  }

  void back([String fallback = 'home']) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      go(fallback, replace: true);
    }
  }

  void notify(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: s,
    builder: (context, _) {
      final nav = [
        'home',
        'habits',
        'focus',
        'progress',
        'profile',
        'sessions',
        'history',
      ].contains(screen);
      final selected = switch (screen) {
        'habits' => 1,
        'focus' || 'sessions' => 2,
        'progress' => 3,
        'profile' => 4,
        _ => 0,
      };
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(23, 20, 23, 28),
                children: [
                  ...content(),
                  if (s.storageError.isNotEmpty) note(s.storageError),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: nav
            ? NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (i) => go(
                  ['home', 'habits', 'focus', 'progress', 'profile'][i],
                  replace: true,
                ),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Hábitos',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timer_outlined),
                    label: 'Enfoque',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    label: 'Progreso',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Perfil',
                  ),
                ],
              )
            : null,
      );
    },
  );
  List<Widget> content() {
    switch (screen) {
      case 'welcome':
        return buildWelcomeScreen();

      case 'signup':
        return buildSignupScreen(screen);

      case 'login':
        return buildLoginScreen(screen);

      case 'recover':
        return buildRecoverScreen();

      case 'home':
        return buildHomeScreen();
      case 'daily':
        return buildDailyScreen();

      case 'generating':
        return buildGeneratingScreen();

      case 'recommendation':
        return buildRecommendationScreen();

      case 'history':
        return buildHistoryScreen();

      case 'habits':
        return buildHabitsScreen();
      case 'habit':
        return buildHabitFormScreen();
      case 'focus':
        return buildPomodoroScreen();
      case 'sessions':
        return buildSessionsScreen();
      case 'wellness':
        return buildWellnessScreen();
      case 'exercise':
        return buildExerciseScreen();
      case 'progress':
        return buildProgressScreen();
      case 'profile':
        return buildProfileScreen();
      case 'edit-profile':
        return buildEditProfileScreen();
      case 'reminders':
        return buildRemindersScreen();
      case 'notifications':
        return buildNotificationsScreen();

      case 'privacy':
        return buildPrivacyScreen();
      case 'help':
        return buildHelpScreen();
      case 'about':
        return buildAboutScreen();

      case 'system':
        return buildSystemScreen();
      default:
        return [
          heading('Mood'),
          button('Ir al inicio', () => go('home', replace: true)),
        ];
    }
  }

  void refresh(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void rate(String value) {
    s.feedback = value;
    unawaited(s.save('feedback', value));
    notify('Gracias por tu opinión');
  }

  void saveHabit() {
    if (!form.currentState!.validate()) return;
    final habit = Habit(
      id: editing?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: name.text.trim(),
      goal: goal.text,
      icon: icon,
      done: editing?.done ?? false,
      days: [...days],
      reminder: reminder,
      moment: moment,
    );
    if (editing == null) {
      s.habits.add(habit);
    } else {
      final index = s.habits.indexWhere((h) => h.id == editing!.id);
      if (index >= 0) s.habits[index] = habit;
    }
    s.saveHabits();
    back('habits');
    notify('Hábito guardado');
  }

  Future<void> configureTimer() async {
    custom.text = '${s.minutes}';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu tiempo de enfoque'),
        content: TextField(
          controller: custom,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minutos (1–180)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
            onPressed: () {
              final value = int.tryParse(custom.text);
              if (value == null || value < 1 || value > 180) {
                notify('Elige una duración entre 1 y 180 minutos.');
                return;
              }
              s.configureTimer(value);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
