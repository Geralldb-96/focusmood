import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_store.dart';
import 'theme.dart';

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

  Text text(
    String value, {
    double? size,
    bool bold = false,
    Color? color,
    TextAlign? align,
  }) => Text(
    value,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : null,
      color: color,
    ),
  );
  Widget small(String value, {TextAlign? align}) => Text(
    value,
    textAlign: align,
    style: Theme.of(context).textTheme.bodySmall,
  );
  Widget gap([double size = 16]) => SizedBox(height: size);
  Widget title(String value) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 12),
    child: Text(value, style: Theme.of(context).textTheme.titleMedium),
  );
  Widget heading(
    String value, {
    String? sub,
    bool backButton = true,
    IconData? action,
    VoidCallback? onAction,
    String? actionLabel,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        if (backButton) ...[
          IconButton.filledTonal(
            onPressed: () => back(),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Volver',
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              if (sub != null) small(sub),
            ],
          ),
        ),
        if (action != null)
          IconButton.filledTonal(
            onPressed: onAction,
            icon: Icon(action, size: 20),
            tooltip: actionLabel ?? 'Opciones',
          ),
      ],
    ),
  );
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
  Widget button(
    String label,
    VoidCallback? onTap, {
    IconData? icon,
    bool secondary = false,
    bool danger = false,
  }) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: secondary
          ? OutlinedButton(onPressed: onTap, child: child)
          : FilledButton(
              onPressed: onTap,
              style: danger
                  ? FilledButton.styleFrom(
                      backgroundColor: dark
                          ? const Color(0xff4b282a)
                          : const Color(0xfffbe8e7),
                      foregroundColor: dark
                          ? const Color(0xffffb4b4)
                          : const Color(0xffbf4549),
                    )
                  : null,
              child: child,
            ),
    );
  }

  Widget link(String label, VoidCallback action) => Center(
    child: TextButton(
      onPressed: action,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
  Widget box(Widget child, {String? color, EdgeInsets? padding}) => Container(
    margin: const EdgeInsets.symmetric(vertical: 7),
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color == null ? surface : tone(color),
      borderRadius: BorderRadius.circular(23),
      border: color == null
          ? Border.all(color: Theme.of(context).dividerColor)
          : null,
      boxShadow: color == null
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    ),
    child: child,
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
        return [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              brand(),
              IconButton(
                onPressed: s.toggleTheme,
                icon: Icon(
                  dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                tooltip: dark ? 'Modo claro' : 'Modo oscuro',
              ),
            ],
          ),
          gap(22),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 30,
                  bottom: 20,
                  child: Container(
                    width: 135,
                    height: 145,
                    decoration: BoxDecoration(
                      color: tone('peach'),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: tone('lavender'),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -.3,
                  child: Container(
                    width: 245,
                    height: 175,
                    decoration: BoxDecoration(
                      color: tone('mint'),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  left: 25,
                  bottom: 20,
                  child: CircleAvatar(
                    backgroundColor: surface,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color(0xffba5054),
                      size: 21,
                    ),
                  ),
                ),
                Positioned(
                  right: 28,
                  top: 18,
                  child: CircleAvatar(
                    backgroundColor: surface,
                    child: const Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xffc88948),
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
          gap(14),
          Text(
            'Tu bienestar\nacadémico, a tu ritmo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          gap(10),
          text(
            'Registra cómo te sientes, mejora tus hábitos y recibe recomendaciones útiles para estudiar con equilibrio.',
            align: TextAlign.center,
            color: muted,
          ),
          gap(12),
          note(
            'Mood no sustituye orientación médica o psicológica profesional.',
            icon: Icons.shield_outlined,
          ),
          button('Comenzar', () => go('signup'), icon: Icons.arrow_forward),
          link('¿Ya tienes cuenta?  Inicia sesión', () => go('login')),
        ];
      case 'signup':
      case 'login':
        final signup = screen == 'signup';
        return [
          brand(),
          gap(12),
          heading(
            signup ? 'Crea tu espacio' : 'Qué gusto verte',
            sub: signup
                ? 'Unos datos para personalizar tu experiencia.'
                : 'Retoma tus hábitos y sesiones de estudio.',
            backButton: false,
          ),
          Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (signup)
                  field(
                    'Nombre',
                    name,
                    icon: Icons.person_outline,
                    required: true,
                  ),
                field(
                  signup ? 'Correo universitario' : 'Correo',
                  email,
                  icon: Icons.mail_outline,
                  required: true,
                  isEmail: true,
                ),
                field(
                  'Contraseña',
                  password,
                  icon: Icons.lock_outline,
                  required: true,
                  secret: true,
                  minLength: 8,
                ),
                if (signup) ...[
                  gap(5),
                  small('8 caracteres, una mayúscula y un número'),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: accepted,
                    onChanged: (v) => setState(() => accepted = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: small(
                      'Acepto los términos, privacidad y el uso responsable de recomendaciones.',
                    ),
                  ),
                ] else
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => go('recover'),
                      child: text('¿Olvidaste tu contraseña?', size: 12),
                    ),
                  ),
                button(signup ? 'Crear cuenta' : 'Iniciar sesión', () {
                  if (!form.currentState!.validate()) return;
                  if (signup &&
                      (!accepted ||
                          !RegExp(r'[A-Z]').hasMatch(password.text) ||
                          !RegExp(r'[0-9]').hasMatch(password.text))) {
                    notify(
                      'Acepta los términos y usa una contraseña con mayúscula y número.',
                    );
                    return;
                  }
                  if (signup) {
                    s.saveProfile({
                      ...s.profile,
                      'name': name.text.trim(),
                      'email': email.text.trim(),
                    });
                  }
                  password.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (_) => false,
                  );
                  notify('Bienvenido a tu espacio de demostración');
                }, icon: Icons.person_add_outlined),
              ],
            ),
          ),
          gap(10),
          small(
            signup ? 'o continúa con tu cuenta institucional' : 'o',
            align: TextAlign.center,
          ),
          button(
            'Continuar con Google',
            () => notify(
              'Google requiere conectar un servicio de autenticación.',
            ),
            secondary: true,
            icon: Icons.public,
          ),
          link(
            signup
                ? '¿Ya tienes cuenta?  Inicia sesión'
                : '¿Aún no tienes cuenta?  Regístrate',
            () => go(signup ? 'login' : 'signup', replace: true),
          ),
          small(
            'Demo local · No uses tu contraseña real.',
            align: TextAlign.center,
          ),
        ];
      case 'recover':
        return [
          heading('Recuperar acceso', sub: 'Te enviaremos un enlace seguro.'),
          box(
            const SizedBox(
              height: 140,
              child: Center(
                child: CircleAvatar(
                  radius: 38,
                  child: Icon(Icons.key_outlined, size: 34),
                ),
              ),
            ),
            color: 'blue',
          ),
          Form(
            key: form,
            child: Column(
              children: [
                field(
                  'Correo de tu cuenta',
                  email,
                  icon: Icons.mail_outline,
                  required: true,
                  isEmail: true,
                ),
                button('Enviar enlace', () {
                  if (form.currentState!.validate()) {
                    setState(() => sent = true);
                  }
                }, icon: Icons.send_outlined),
              ],
            ),
          ),
          if (sent)
            note(
              'Solicitud de demostración. El envío de correos estará disponible al conectar el servidor.',
              color: 'mint',
              icon: Icons.check_circle_outline,
            ),
        ];
      case 'home':
        return [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    small('Jueves, 1 de octubre'),
                    Text(
                      'Hola, ${s.firstName} ☼',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              InkWell(onTap: () => go('profile'), child: avatar(radius: 22)),
            ],
          ),
          gap(10),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text('¿Cómo estás hoy?', size: 16, bold: true),
                          small('Tu registro toma menos de 1 minuto'),
                        ],
                      ),
                    ),
                    const Icon(Icons.spa_outlined, size: 28),
                  ],
                ),
                button('Registrar mi día', () => go('daily'), icon: Icons.add),
              ],
            ),
            color: 'lavender',
          ),
          title('Accesos rápidos'),
          LayoutBuilder(
            builder: (context, c) {
              const data = [
                (
                  'Recomendación IA',
                  'Una técnica para ahora',
                  'daily',
                  'mint',
                  Icons.auto_awesome_outlined,
                ),
                (
                  'Pomodoro',
                  '25 min de enfoque',
                  'focus',
                  'blue',
                  Icons.timer_outlined,
                ),
                (
                  'Bienestar',
                  'Pausas y ejercicios',
                  'wellness',
                  'peach',
                  Icons.favorite_border,
                ),
                (
                  'Hábitos',
                  'Tu ritmo, cada día',
                  'habits',
                  'lavender',
                  Icons.check_circle_outline,
                ),
              ];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: data
                    .map(
                      (d) => SizedBox(
                        width: (c.maxWidth - 10) / 2,
                        child: Material(
                          color: tone(d.$4),
                          borderRadius: BorderRadius.circular(19),
                          child: InkWell(
                            onTap: () => go(d.$3),
                            borderRadius: BorderRadius.circular(19),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: surface,
                                    child: Icon(d.$5, size: 18),
                                  ),
                                  gap(10),
                                  text(d.$1, bold: true, size: 13),
                                  gap(5),
                                  small(
                                    d.$3 == 'habits'
                                        ? '${s.completed} de ${s.habits.length} completados'
                                        : d.$2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          gap(10),
          box(
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text('Racha de bienestar', bold: true),
                          small('5 días cuidando de ti'),
                        ],
                      ),
                    ),
                    Chip(
                      avatar: const Icon(
                        Icons.local_fire_department_outlined,
                        size: 15,
                      ),
                      label: small('5 días'),
                    ),
                  ],
                ),
                gap(8),
                progress(.7, color: const Color(0xfff6ac69)),
              ],
            ),
          ),
          link('Ver notificaciones', () => go('notifications')),
        ];
      case 'daily':
        return [
          heading(
            'Tu registro de hoy',
            sub: 'Paso 2 de 2 · contexto académico',
          ),
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
            (d) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: text(d.label, bold: true)),
                    text('${s.record[d.key]}/10', color: d.color, bold: true),
                  ],
                ),
                Slider(
                  semanticFormatterCallback: (v) => '${d.label}: ${v.round()}',
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  value: s.record[d.key]!.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: d.color,
                  onChanged: (v) => s.setRecord(d.key, v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [small(d.low), small(d.high)],
                ),
                gap(18),
              ],
            ),
          ),
          title('Tiempo disponible'),
          chips(
            ['5 min', '15 min', '25 min', '45+ min'],
            duration,
            (v) => setState(() => duration = v),
          ),
          title('Actividad académica'),
          chips(
            ['Examen', 'Tarea', 'Clase', 'Proyecto'],
            activity,
            (v) => setState(() => activity = v),
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
      case 'generating':
        return [
          heading('Preparando tu recomendación'),
          box(
            Column(
              children: [
                gap(20),
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 130,
                        width: 130,
                        child: CircularProgressIndicator(
                          strokeWidth: 18,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor: surface,
                        ),
                      ),
                      const Icon(Icons.auto_awesome_outlined, size: 40),
                    ],
                  ),
                ),
                gap(35),
                text(
                  'Adaptando una técnica para ti',
                  size: 17,
                  bold: true,
                  align: TextAlign.center,
                ),
                gap(7),
                small(
                  'Consideramos tu energía, concentración, tiempo y actividad de hoy.',
                  align: TextAlign.center,
                ),
                gap(24),
              ],
            ),
            color: 'mint',
          ),
          note('Mientras esperas, prepara agua y silencia las notificaciones.'),
          small(
            'Esto suele tardar menos de 10 segundos',
            align: TextAlign.center,
          ),
          link('Cancelar', () => back('daily')),
        ];
      case 'recommendation':
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
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: tone('mint'),
                    child: text('${e.key + 1}', size: 11, bold: true),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: text(e.value, size: 12)),
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
          small(
            '¿Esta recomendación te resultó útil?',
            align: TextAlign.center,
          ),
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
      case 'history':
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
            (v) => setState(() => filter = v),
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
                progress(.75),
              ],
            ),
            color: 'soft',
          ),
          ...rows
              .asMap()
              .entries
              .where(
                (e) =>
                    filter == 'Todas' ||
                    filter == 'Guardadas' && s.saved && e.key == 0 ||
                    filter == 'Útiles' && (e.key > 0 || s.feedback == 'yes'),
              )
              .map(
                (e) => row(
                  e.value.$1,
                  e.value.$2,
                  Icons.thumb_up_outlined,
                  () => go('recommendation'),
                ),
              ),
          if (filter == 'Guardadas' && !s.saved)
            note('Aún no guardaste recomendaciones.', color: 'soft'),
        ];
      case 'habits':
        return [
          heading(
            'Hábitos',
            sub: 'Jueves · ${s.completed} de ${s.habits.length} completados',
            backButton: false,
            action: Icons.add,
            actionLabel: 'Nuevo hábito',
            onAction: () => go('habit'),
          ),
          box(
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text('Buen ritmo, ${s.firstName}', bold: true),
                          small('Un pequeño paso cada día'),
                        ],
                      ),
                    ),
                    text('${s.percent}%', size: 23, bold: true),
                  ],
                ),
                gap(8),
                progress(s.percent / 100),
              ],
            ),
            color: 'mint',
          ),
          gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: i == 3
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    small(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                    text(
                      '${[28, 29, 30, 1, 2, 3, 4][i]}',
                      size: 11,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          gap(12),
          ...s.habits.map(
            (h) => box(
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => go('habit', args: h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: tone(
                              h.icon == 'book' ? 'lavender' : 'mint',
                            ),
                            child: Icon(habitIcon(h.icon), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    decoration: h.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: h.done ? muted : null,
                                  ),
                                ),
                                small(h.goal),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => s.toggleHabit(h),
                    tooltip: '${h.done ? 'Desmarcar' : 'Completar'} ${h.name}',
                    icon: Icon(
                      h.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: h.done
                          ? Theme.of(context).colorScheme.primary
                          : muted,
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
            ),
          ),
          button('Crear nuevo hábito', () => go('habit'), icon: Icons.add),
        ];
      case 'habit':
        return [
          heading(
            editing == null ? 'Nuevo hábito' : 'Editar hábito',
            sub: editing == null
                ? 'Hazlo pequeño, claro y alcanzable'
                : 'Ajusta tu meta sin perder el progreso',
          ),
          Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                field(
                  'Nombre del hábito',
                  name,
                  required: true,
                  icon: Icons.check_circle_outline,
                ),
                title('Icono y color'),
                Wrap(
                  spacing: 9,
                  children: ['walk', 'book', 'water', 'sleep', 'heart']
                      .map(
                        (v) => IconButton.filledTonal(
                          onPressed: () => setState(() => icon = v),
                          isSelected: icon == v,
                          tooltip: v,
                          icon: Icon(habitIcon(v)),
                          selectedIcon: Icon(
                            habitIcon(v),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                      .toList(),
                ),
                title('Frecuencia'),
                Wrap(
                  spacing: 6,
                  children: List.generate(
                    7,
                    (i) => FilterChip(
                      label: Text(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                      selected: days.contains(i),
                      onSelected: (v) => setState(() {
                        if (v) {
                          days.add(i);
                        } else {
                          days.remove(i);
                        }
                      }),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: field('Meta', goal, required: true)),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            text('Momento', size: 12, bold: true),
                            gap(6),
                            DropdownButtonFormField<String>(
                              initialValue: moment,
                              isExpanded: true,
                              items: ['Mañana', 'Tarde', 'Noche']
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: text(v, size: 13),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => moment = v!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: text('Recordatorio', bold: true),
                  subtitle: small('A las 17:30'),
                  value: reminder,
                  onChanged: (v) => setState(() => reminder = v),
                ),
                button(
                  editing == null ? 'Crear hábito' : 'Guardar cambios',
                  saveHabit,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
          if (editing != null)
            button(
              'Eliminar hábito',
              () => confirm(
                '¿Eliminar hábito?',
                'Se eliminará de tu lista de hábitos.',
                () {
                  s.habits.removeWhere((h) => h.id == editing!.id);
                  s.saveHabits();
                  back('habits');
                },
                label: 'Eliminar hábito',
              ),
              danger: true,
              icon: Icons.delete_outline,
            ),
        ];
      case 'focus':
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
      case 'sessions':
        return [
          heading('Sesiones', sub: 'Tu enfoque guardado en este dispositivo'),
          Row(
            children: [
              stat(
                'Tiempo total',
                '${s.totalMinutes} min',
                Icons.schedule,
                'mint',
              ),
              const SizedBox(width: 8),
              stat(
                'Pomodoros',
                '${s.sessions.length}',
                Icons.timer_outlined,
                'peach',
              ),
              const SizedBox(width: 8),
              stat(
                'Mejor racha',
                '${s.sessions.isEmpty ? 0 : 1}',
                Icons.local_fire_department_outlined,
                'lavender',
              ),
            ],
          ),
          title('Actividad reciente'),
          if (s.sessions.isEmpty)
            note(
              'Aún no hay sesiones. Tu primer bloque de enfoque aparecerá aquí.',
              color: 'soft',
            ),
          ...s.sessions.map(
            (session) => row(
              session.name,
              session.date,
              Icons.timer_outlined,
              () => go('focus'),
              end: '${session.minutes} min',
              color: 'blue',
            ),
          ),
        ];
      case 'wellness':
        final exercises = [
          (
            'Respiración cuadrada',
            'Reduce tensión y recupera claridad',
            '4 min',
            'Respirar',
            Icons.air,
          ),
          (
            'Movilidad de cuello y hombros',
            'Libera tensión de la postura',
            '6 min',
            'Moverte',
            Icons.accessibility_new,
          ),
          (
            'Descanso visual 20–20–20',
            'Cuida tus ojos frente a la pantalla',
            '2 min',
            'Descansar',
            Icons.visibility_outlined,
          ),
          (
            'Escaneo corporal breve',
            'Observa sin juzgar cómo te sientes',
            '5 min',
            'Descansar',
            Icons.psychology_outlined,
          ),
        ];
        return [
          heading('Bienestar', sub: 'Pequeñas pausas, efectos reales'),
          chips(
            ['Para ti', 'Respirar', 'Moverte', 'Descansar'],
            category,
            (v) => setState(() => category = v),
          ),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                small('Recomendado ahora'),
                gap(9),
                text('Respira y reinicia', size: 19, bold: true),
                small('Ideal antes de tu próximo bloque de estudio.'),
                button(
                  'Comenzar · 3 min',
                  () =>
                      go('exercise', args: {'exercise': 'Respira y reinicia'}),
                  icon: Icons.play_arrow_outlined,
                ),
              ],
            ),
            color: 'peach',
          ),
          title('Ejercicios guiados'),
          ...exercises
              .where((e) => category == 'Para ti' || e.$4 == category)
              .map(
                (e) => row(
                  e.$1,
                  e.$2,
                  e.$5,
                  () => go('exercise', args: {'exercise': e.$1}),
                  end: e.$3,
                ),
              ),
        ];
      case 'exercise':
        final phase = [
          'Inhala',
          'Sostén',
          'Exhala',
          'Descansa',
        ][(exerciseTime ~/ 4) % 4];
        return [
          heading(
            exercise,
            sub: 'Ejercicio guiado · 3 minutos',
            action: sound
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
            onAction: () {
              setState(() => sound = !sound);
              notify('Guía visual activa. Audio pendiente de integración.');
            },
          ),
          box(
            Column(
              children: [
                gap(20),
                AnimatedContainer(
                  duration: breathing
                      ? const Duration(seconds: 4)
                      : Duration.zero,
                  width: phase == 'Inhala' || phase == 'Sostén' ? 180 : 145,
                  height: phase == 'Inhala' || phase == 'Sostén' ? 180 : 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone('mint'),
                    border: Border.all(
                      width: 7,
                      color: const Color(0xff4c8198),
                    ),
                  ),
                  child: Center(child: text(phase, size: 22, bold: true)),
                ),
                gap(24),
                text('4 segundos', size: 17, bold: true),
                gap(20),
              ],
            ),
            color: 'blue',
          ),
          gap(9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [small(MoodStore.time(exerciseTime)), small('03:00')],
          ),
          gap(8),
          progress(exerciseTime / 180),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text('Sigue el círculo', bold: true),
                gap(6),
                small(
                  exercise.contains('Movilidad')
                      ? 'Mueve suavemente los hombros y el cuello sin forzar.'
                      : exercise.contains('visual')
                      ? 'Mira un objeto lejano y relaja tus ojos.'
                      : 'Inhala al expandirse, sostén suavemente y exhala al contraerse.',
                ),
              ],
            ),
            color: 'soft',
          ),
          Row(
            children: [
              Expanded(
                child: button(
                  'Finalizar',
                  () => back('wellness'),
                  secondary: true,
                  icon: Icons.stop_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: button(
                  breathing ? 'Pausar' : 'Continuar',
                  () => setState(() => breathing = !breathing),
                  icon: breathing ? Icons.pause : Icons.play_arrow_outlined,
                ),
              ),
            ],
          ),
        ];
      case 'progress':
        return [
          heading(
            'Tu semana',
            sub: '25 sep – 1 oct · Vista de demostración',
            backButton: false,
            action: Icons.calendar_month_outlined,
            onAction: () => notify('Resumen semanal de demostración'),
          ),
          Row(
            children: [
              stat(
                'Ánimo',
                '${s.record['mood']}.0',
                Icons.sentiment_satisfied_alt,
                'lavender',
              ),
              const SizedBox(width: 8),
              stat(
                'Hábitos',
                '${s.percent}%',
                Icons.check_circle_outline,
                'mint',
              ),
              const SizedBox(width: 8),
              stat(
                'Estudio',
                '${s.totalMinutes} min',
                Icons.menu_book_outlined,
                'peach',
              ),
            ],
          ),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text('Ánimo diario', bold: true),
                small('Vista ilustrativa de la semana'),
                gap(16),
                SizedBox(
                  height: 110,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      7,
                      (i) => Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 18,
                            height: [35, 58, 46, 70, 62, 80, 67][i].toDouble(),
                            decoration: BoxDecoration(
                              color: i == 5
                                  ? Theme.of(context).colorScheme.primary
                                  : tone('mint'),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          gap(5),
                          small(['L', 'M', 'X', 'J', 'V', 'S', 'D'][i]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: box(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      small('Hábitos'),
                      text(
                        '${s.completed}/${s.habits.length}',
                        size: 26,
                        bold: true,
                      ),
                      gap(7),
                      progress(s.percent / 100),
                    ],
                  ),
                  color: 'mint',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: box(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      small('Enfoque'),
                      text('${s.sessions.length}', size: 26, bold: true),
                      small('pomodoros'),
                    ],
                  ),
                  color: 'peach',
                ),
              ),
            ],
          ),
          note(
            'Hallazgo de la semana: prueba una pausa activa antes de estudiar y observa tu concentración.',
            color: 'lavender',
            icon: Icons.auto_awesome_outlined,
          ),
        ];
      case 'profile':
        return [
          heading(
            'Perfil',
            sub: 'Tu espacio y preferencias',
            backButton: false,
            action: Icons.tune,
            onAction: () => go('edit-profile'),
          ),
          Center(child: avatar()),
          gap(10),
          text(
            s.profile['name']!,
            size: 17,
            bold: true,
            align: TextAlign.center,
          ),
          small(s.profile['email']!, align: TextAlign.center),
          gap(12),
          Center(child: Chip(label: small('♨ Racha de 5 días'))),
          gap(10),
          row(
            'Editar perfil',
            'Nombre, carrera y preferencias',
            Icons.person_outline,
            () => go('edit-profile'),
          ),
          row(
            'Recordatorios',
            '4 configurados',
            Icons.notifications_outlined,
            () => go('reminders'),
          ),
          row(
            'Privacidad y datos',
            'Gestiona tu información',
            Icons.shield_outlined,
            () => go('privacy'),
          ),
          row(
            'Ayuda y apoyo',
            'Recursos y orientación',
            Icons.help_outline,
            () => go('help'),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            secondary: Icon(
              dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            title: text('Modo oscuro', bold: true),
            subtitle: small('Tu preferencia se guarda en este dispositivo'),
            value: s.dark,
            onChanged: (_) => s.toggleTheme(),
          ),
          row(
            'Acerca de Mood',
            'Versión 1.2.0 · Flutter',
            Icons.info_outline,
            () => go('about'),
          ),
          row(
            'Cerrar sesión',
            '',
            Icons.logout,
            () => confirm(
              '¿Cerrar sesión?',
              'Tu progreso quedará guardado y podrás volver cuando quieras.',
              () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (_) => false,
                );
              },
              label: 'Sí, cerrar sesión',
            ),
            color: 'peach',
          ),
          gap(12),
          small(
            'Mood acompaña tu bienestar académico y no sustituye atención profesional.',
            align: TextAlign.center,
          ),
        ];
      case 'edit-profile':
        return [
          heading('Editar perfil', sub: 'Actualiza tu información personal'),
          Center(child: avatar()),
          gap(8),
          small(
            'Tu avatar usa las iniciales de tu nombre',
            align: TextAlign.center,
          ),
          Form(
            key: form,
            child: Column(
              children: [
                field(
                  'Nombre completo',
                  name,
                  required: true,
                  icon: Icons.person_outline,
                ),
                field(
                  'Correo',
                  email,
                  required: true,
                  isEmail: true,
                  icon: Icons.mail_outline,
                ),
                field(
                  'Universidad',
                  university,
                  icon: Icons.account_balance_outlined,
                ),
                field('Carrera', career, icon: Icons.school_outlined),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: text('Personalización con IA', bold: true),
                  subtitle: small('Usar mis registros para recomendar'),
                  value: s.personal,
                  onChanged: (v) {
                    s.personal = v;
                    unawaited(s.save('personalization', v));
                  },
                ),
                button('Guardar cambios', () {
                  if (form.currentState!.validate()) {
                    s.saveProfile({
                      'name': name.text.trim(),
                      'email': email.text.trim(),
                      'university': university.text,
                      'career': career.text,
                    });
                    back('profile');
                    notify('Perfil actualizado');
                  }
                }, icon: Icons.check),
              ],
            ),
          ),
        ];
      case 'reminders':
        final items = [
          (
            'Registro emocional',
            'Todos los días · 09:00',
            Icons.sentiment_satisfied_alt,
          ),
          ('Tomar agua', 'Lun–Vie · cada 2 horas', Icons.water_drop_outlined),
          ('Bloque de enfoque', 'Lun, Mié, Vie · 17:00', Icons.timer_outlined),
          (
            'Preparar el descanso',
            'Todos los días · 23:00',
            Icons.bedtime_outlined,
          ),
        ];
        return [
          heading(
            'Recordatorios',
            sub: 'Elige cuándo quieres que Mood te acompañe',
            action: Icons.add,
            onAction: () =>
                notify('Activa o desactiva las rutinas de la lista.'),
          ),
          note(
            'Mantén solo los avisos que te resulten útiles. Puedes pausarlos en cualquier momento.',
            icon: Icons.notifications_outlined,
          ),
          title('Rutina diaria'),
          ...items.asMap().entries.map(
            (e) => box(
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tone('mint'),
                    child: Icon(e.value.$3, size: 18),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(e.value.$1, bold: true),
                        small(e.value.$2),
                      ],
                    ),
                  ),
                  Switch(
                    value: s.reminders[e.key],
                    onChanged: (v) {
                      s.reminders[e.key] = v;
                      unawaited(s.save('reminders', s.reminders));
                    },
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
          small(
            'Preferencias locales. Los avisos automáticos requieren una integración de notificaciones.',
          ),
        ];
      case 'notifications':
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
      case 'privacy':
        return [
          heading('Privacidad y datos'),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined),
                gap(9),
                text('Tú controlas tu información', size: 19, bold: true),
                gap(9),
                small(
                  'Esta demostración guarda tus hábitos, registros y perfil únicamente en el almacenamiento local del dispositivo. No se envían a un servidor.',
                ),
              ],
            ),
            color: 'soft',
          ),
          button(
            'Exportar mis datos',
            () async {
              await Clipboard.setData(ClipboardData(text: s.export()));
              if (mounted) {
                notify('Datos copiados al portapapeles en formato JSON.');
              }
            },
            secondary: true,
            icon: Icons.copy_outlined,
          ),
          button(
            'Eliminar mis datos locales',
            () => confirm(
              '¿Eliminar tus datos?',
              'Se borrará la información de Mood guardada en este dispositivo.',
              () async {
                await s.clear();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/welcome',
                    (_) => false,
                  );
                }
              },
              label: 'Eliminar datos',
            ),
            danger: true,
          ),
        ];
      case 'help':
        return [
          heading('Ayuda y apoyo'),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite_border),
                gap(12),
                text('No tienes que hacerlo solo', size: 20, bold: true),
                gap(9),
                small(
                  'Si necesitas apoyo, contacta al servicio de bienestar de tu universidad o a un profesional de salud mental.',
                ),
                gap(12),
                small(
                  'Si estás en peligro inmediato, comunícate con los servicios de emergencia de tu localidad.',
                ),
                button('Explorar pausas de bienestar', () => go('wellness')),
              ],
            ),
            color: 'soft',
          ),
        ];
      case 'about':
        return [
          heading('Acerca de Mood'),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand(),
                gap(16),
                text('Bienestar que acompaña', size: 22, bold: true),
                gap(10),
                small(
                  'Una herramienta para cuidar tus hábitos y encontrar tu ritmo de estudio.',
                ),
                gap(12),
                small('Versión 1.2.0 · Flutter y Dart. Temas claro y oscuro.'),
                gap(12),
                small(
                  'Las recomendaciones son ejemplos locales y no constituyen atención médica o psicológica.',
                ),
              ],
            ),
            color: 'soft',
          ),
        ];
      case 'system':
        return [
          heading('Sistema Mood', sub: 'Base visual compacta · v1.0'),
          title('PALETA SERENA'),
          Row(
            children:
                [
                      moodGreen,
                      const Color(0xfff6ac69),
                      const Color(0xff9080b0),
                      const Color(0xff4c8198),
                      const Color(0xff2b805f),
                      const Color(0xffba5054),
                    ]
                    .map(
                      (c) => Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          box(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text('Bienestar que acompaña', size: 24, bold: true),
                gap(8),
                small('Jerarquía limpia · lectura móvil accesible.'),
              ],
            ),
            color: 'soft',
          ),
          button(
            'Acción principal',
            () => go('home'),
            icon: Icons.arrow_forward,
          ),
          button(
            dark ? 'Modo claro' : 'Modo oscuro',
            s.toggleTheme,
            secondary: true,
          ),
        ];
      default:
        return [
          heading('Mood'),
          button('Ir al inicio', () => go('home', replace: true)),
        ];
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
