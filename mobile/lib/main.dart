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

  Widget brand() => Row(
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

  Widget note(
    String message, {
    String color = 'peach',
    IconData icon = Icons.info_outline,
  }) => box(
    Row(
      children: [
        Icon(icon, size: 21),
        const SizedBox(width: 10),
        Expanded(child: small(message)),
      ],
    ),
    color: color,
  );
  Widget chips(
    List<String> values,
    String selected,
    ValueChanged<String> change,
  ) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: values
        .map(
          (v) => ChoiceChip(
            label: Text(v, style: const TextStyle(fontSize: 11)),
            selected: v == selected,
            onSelected: (_) => change(v),
          ),
        )
        .toList(),
  );
  Widget field(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool secret = false,
    bool required = false,
    bool isEmail = false,
    int? minLength,
    bool digits = false,
  }) => Padding(
    padding: const EdgeInsets.only(top: 13, bottom: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(label, size: 12, bold: true),
        gap(6),
        TextFormField(
          key: ValueKey('field-$label'),
          controller: controller,
          obscureText: secret,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : digits
              ? TextInputType.number
              : TextInputType.text,
          autocorrect: !secret && !isEmail,
          enableSuggestions: !secret,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: icon == null ? null : Icon(icon, size: 18),
            hintText: isEmail ? 'nombre@universidad.edu' : null,
          ),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (required && v.isEmpty) return 'Completa este campo.';
            if (isEmail && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
              return 'Revisa el formato del correo.';
            }
            if (minLength != null && v.length < minLength) {
              return 'Usa al menos $minLength caracteres.';
            }
            return null;
          },
        ),
      ],
    ),
  );
  Widget row(
    String label,
    String sub,
    IconData icon,
    VoidCallback action, {
    String? end,
    String color = 'mint',
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Material(
      color: surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tone(color),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(label, size: 13, bold: true),
                    if (sub.isNotEmpty) small(sub),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (end != null)
                text(end, size: 11, bold: true)
              else
                const Icon(Icons.chevron_right, size: 17),
            ],
          ),
        ),
      ),
    ),
  );
  Widget stat(String label, String value, IconData icon, String color) =>
      Expanded(
        child: box(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17),
              gap(8),
              text(value, size: 19, bold: true),
              gap(4),
              small(label),
            ],
          ),
          color: color,
          padding: const EdgeInsets.all(12),
        ),
      );
  Widget progress(double value, {Color? color}) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: 7,
      color: color,
      backgroundColor: dark ? const Color(0xff33483c) : const Color(0xffe5eeea),
    ),
  );
  Widget avatar({double radius = 38}) => CircleAvatar(
    radius: radius,
    backgroundColor: tone('mint'),
    child: text(s.initials, size: radius * .65, bold: true),
  );
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
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: Theme.of(ctx).textTheme.titleLarge),
              gap(8),
              small(detail),
              gap(10),
              button(label, () {
                Navigator.pop(ctx);
                action();
              }, danger: true),
              button('Cancelar', () => Navigator.pop(ctx), secondary: true),
            ],
          ),
        ),
      ),
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
