import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/main.dart';
import 'package:stalvi/presentation/providers/app_startup_provider.dart';

void main() {
  testWidgets('StalviApp renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith(
            (ref) async => AppDatabase.forTesting(NativeDatabase.memory()),
          ),
        ],
        child: const StalviApp(),
      ),
    );
    // Verify the Stalvi wordmark appears on the splash screen.
    expect(find.text('Stalvi'), findsWidgets);

    // Let the splash screen timer (2200ms) and animations run to transition to AuthScreen,
    // avoiding pumpAndSettle timeout since AuthScreen has an infinite pulsing animation.
    await tester.pump(const Duration(seconds: 3));
  });
}
