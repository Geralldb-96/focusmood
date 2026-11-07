import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/messenger.dart';
import '../../core/theme.dart';
import '../../state/study_controller.dart';
import 'focus_tab.dart';
import 'habits_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'progress_tab.dart';

/// Pestaña activa del shell; permite que otras pantallas cambien de pestaña (p. ej. "Iniciar técnica").
class ShellNav extends ChangeNotifier {
  int index = 0;

  static const home = 0, habits = 1, focus = 2, progress = 3, profile = 4;

  void go(int i) {
    if (i == index) return;
    index = i;
    notifyListeners();
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  StreamSubscription<String>? _notices;

  @override
  void initState() {
    super.initState();
    _notices = context.read<StudyController>().notices.listen(toast);
  }

  @override
  void dispose() {
    _notices?.cancel();
    super.dispose();
  }

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Inicio'),
    (Icons.check_circle_outline, Icons.check_circle, 'Hábitos'),
    (Icons.timer_outlined, Icons.timer, 'Enfoque'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'Progreso'),
    (Icons.person_outline, Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<ShellNav>();
    return Scaffold(
      body: IndexedStack(
        index: nav.index,
        children: const [
          HomeTab(),
          HabitsTab(),
          FocusTab(),
          ProgressTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE7EEEA))),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: MoodColors.mint,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => TextStyle(
                fontSize: 11,
                fontWeight: s.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: s.contains(WidgetState.selected)
                    ? MoodColors.deep
                    : MoodColors.muted,
              ),
            ),
          ),
          child: NavigationBar(
            height: 66,
            elevation: 0,
            selectedIndex: nav.index,
            onDestinationSelected: nav.go,
            destinations: [
              for (final (icon, selected, label) in _items)
                NavigationDestination(
                  icon: Icon(icon, color: MoodColors.muted),
                  selectedIcon: Icon(selected, color: MoodColors.deep),
                  label: label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
