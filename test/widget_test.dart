import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/main.dart';
import 'package:habitflow/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1179, 2556); // iPhone 15 Pro
    view.devicePixelRatio = 3;
  });

  testWidgets('every tab renders without layout errors', (tester) async {
    await tester.pumpWidget(HabitflowApp(state: AppState()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Welcome'), findsOneWidget);

    for (final (icon, title) in [
      (Icons.assignment_outlined, 'Habits'),
      (Icons.leaderboard_outlined, 'Statistic'),
      (Icons.person_outline_rounded, 'Profile'),
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
    }
  });

  testWidgets('toggling a habit updates the done count', (tester) async {
    final state = AppState();
    await tester.pumpWidget(HabitflowApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();

    final before = state.doneCount;
    await tester.tap(find.text('Read 20 pages'));
    await tester.pumpAndSettle();
    expect(state.doneCount, before + 1);
  });

  test('settings survive an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    AppState(prefs: prefs)
      ..setThemeMode(ThemeMode.dark)
      ..setSound(false)
      ..setReminder(const TimeOfDay(hour: 21, minute: 30))
      ..toggleCaution('Knees');

    final restarted = AppState(prefs: prefs);
    expect(restarted.themeMode, ThemeMode.dark);
    expect(restarted.sound, isFalse);
    expect(restarted.reminder, const TimeOfDay(hour: 21, minute: 30));
    expect(restarted.cautionAreas, containsAll(['Lower back', 'Knees']));
  });
}
