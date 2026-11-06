import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusmood/main.dart';
import 'package:focusmood/mood_store.dart';
import 'package:focusmood/theme.dart';

void main() {
  Future<MoodStore> store() async {
    SharedPreferences.setMockInitialValues({});
    return MoodStore(await SharedPreferences.getInstance())..load();
  }

  testWidgets('bienvenida cambia de tema y guarda la preferencia', (
    tester,
  ) async {
    final s = await store();
    await tester.pumpWidget(MoodApp(store: s));
    await tester.pumpAndSettle();
    expect(find.text('Tu bienestar\nacadémico, a tu ritmo'), findsOneWidget);
    expect(s.dark, isTrue);
    await tester.tap(find.byTooltip('Modo claro'));
    await tester.pumpAndSettle();
    expect(s.dark, isFalse);
    expect(s.prefs.getString('mood-dark'), 'false');
    await tester.scrollUntilVisible(
      find.text('Comenzar'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu espacio'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    s.dispose();
  });
  testWidgets('crear, completar y editar hábitos conserva los datos', (
    tester,
  ) async {
    final s = await store();
    await tester.pumpWidget(
      MaterialApp(
        theme: moodTheme(false),
        home: MoodPage(store: s, screen: 'habits'),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => MoodPage(
            store: s,
            screen: settings.name!.substring(1),
            argument: settings.arguments,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Crear nuevo hábito'), 200);
    await tester.tap(find.text('Crear nuevo hábito'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('field-Nombre del hábito')),
      'Caminar después de clase',
    );
    await tester.scrollUntilVisible(
      find.text('Crear hábito'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Crear hábito'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear hábito'));
    await tester.pumpAndSettle();
    expect(s.habits.last.name, 'Caminar después de clase');
    final h = s.habits.last;
    s.toggleHabit(h);
    await tester.pumpAndSettle();
    expect(h.done, isTrue);
    final restored = MoodStore(s.prefs)..load();
    expect(restored.habits.last.name, h.name);
    expect(restored.habits.last.done, isTrue);
    await tester.pumpWidget(const SizedBox());
    s.dispose();
    restored.dispose();
  });
  for (final width in [320.0, 390.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'pantallas sin errores de layout a $width en tema ${dark ? 'oscuro' : 'claro'}',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final s = await store();
          s.dark = dark;
          for (final screen in [
            'welcome',
            'login',
            'signup',
            'recover',
            'home',
            'daily',
            'recommendation',
            'history',
            'habits',
            'habit',
            'focus',
            'sessions',
            'wellness',
            'exercise',
            'progress',
            'profile',
            'edit-profile',
            'reminders',
            'notifications',
            'privacy',
            'help',
            'about',
            'system',
          ]) {
            await tester.pumpWidget(
              MaterialApp(
                theme: moodTheme(dark),
                home: MoodPage(
                  key: ValueKey('$screen-$dark-$width'),
                  store: s,
                  screen: screen,
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 400));
            expect(tester.takeException(), isNull, reason: 'Pantalla $screen');
          }
          await tester.pumpWidget(const SizedBox());
          s.dispose();
        },
      );
    }
  }
}
