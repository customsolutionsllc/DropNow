import 'package:flutter_test/flutter_test.dart';
import 'package:drop_now/app/app.dart';
import 'package:drop_now/core/services/services.dart';

void main() {
  testWidgets('App shell renders', (WidgetTester tester) async {
    final prefsService = PreferencesService();
    await prefsService.init();
    final notificationService = NotificationService();
    final commandService = CommandGenerationService();
    final schedulingService = SchedulingService(
      prefsService: prefsService,
      commandService: commandService,
      notificationService: notificationService,
    );
    final storageService = ExecutionStorageService();
    await storageService.init(prefsService.prefs);
    final statsService = StatsService(storageService);

    await tester.pumpWidget(
      DropNowApp(
        prefsService: prefsService,
        commandService: commandService,
        schedulingService: schedulingService,
        notificationService: notificationService,
        storageService: storageService,
        statsService: statsService,
        authService: AuthService(),
      ),
    );
    expect(find.text('DropNow'), findsOneWidget);
  });
}
