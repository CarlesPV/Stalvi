import 'dart:ffi';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konta/data/database/app_database.dart';
import 'package:konta/main.dart';
import 'package:konta/presentation/providers/app_startup_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  testWidgets('KontaApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => AppDatabase.forTesting(NativeDatabase.memory())),
        ],
        child: const KontaApp(),
      ),
    );
    // Verify the Konta wordmark appears on the splash screen.
    expect(find.text('Konta'), findsWidgets);

    // Let the splash screen timer (2200ms) and animations run to transition to AuthScreen,
    // avoiding pumpAndSettle timeout since AuthScreen has an infinite pulsing animation.
    await tester.pump(const Duration(seconds: 3));
  });
}


