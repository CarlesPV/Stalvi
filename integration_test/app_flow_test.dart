import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:stalvi/main.dart';
import 'package:stalvi/presentation/providers/auth_notifier.dart';

/// A mock for AuthNotifier that bypasses biometric authentication
/// by starting the app in an authenticated state.
class MockAuthNotifier extends AuthNotifier {
  @override
  Future<AuthStatus> build() async {
    // Start the app in an authenticated state to bypass the splash/auth screen.
    return AuthStatus.authenticated;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Flow: Bypass Auth, Add Transaction, Return to Dashboard', (
    WidgetTester tester,
  ) async {
    // 1. Initialize the app with mocked authentication
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier()),
        ],
        child: const StalviApp(),
      ),
    );

    // Wait for splash screen / app initialization to settle
    await tester.pumpAndSettle();

    // 2. Verify we are on the Dashboard
    expect(find.text('Stalvi'), findsWidgets); // App bar title
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // 3. Tap the Floating Action Button to open "Add Transaction"
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 4. Verify we are on the Add Transaction screen
    expect(find.text('Add Transaction'), findsWidgets);

    // 5. Fill in transaction amount
    // The amount field is the first TextField
    final amountField = find.byType(TextField).first;
    await tester.enterText(amountField, '50.00');
    await tester.pumpAndSettle();

    // (Optional) Fill notes just to make sure
    final notesField = find.byType(TextField).last;
    await tester.enterText(notesField, 'E2E Test Transaction');
    await tester.pumpAndSettle();

    // 6. Select an account
    // Tap the account selector tile
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    // Bottom sheet is open, tap the first account in the list
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // 7. Select a category
    // Tap the category selector tile
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();

    // Bottom sheet is open. The first is 'Uncategorized', tap the second one (index 1)
    await tester.tap(find.byType(ListTile).at(1));
    await tester.pumpAndSettle();

    // 8. Save the transaction
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // 9. Verify that the user is returned to the Dashboard
    // and a success SnackBar or Recent Transactions appears
    expect(find.text('Transaction created successfully!'), findsOneWidget);
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
    ); // Back to Dashboard
  });
}
