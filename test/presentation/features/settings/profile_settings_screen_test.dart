import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';
import 'package:konta/domain/usecases/update_credentials_usecase.dart';
import 'package:konta/presentation/features/settings/profile_settings_screen.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

class FakeProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getFirstProfile() async {
    return Profile(
      id: '1',
      name: 'Test User',
      username: 'test_user',
      password: '',
      defaultCurrency: 'EUR',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUpdateCredentialsUseCase implements UpdateCredentialsUseCase {
  bool shouldFailVerify = false;

  @override
  Future<void> verifyOldPin(String oldPin) async {
    if (shouldFailVerify) {
      throw const ValidationException(message: 'old_pin_incorrect');
    }
  }

  @override
  Future<void> execute(UpdateCredentialsParams params) async {
    // success
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeProfileRepository fakeProfileRepository;
  late FakeUpdateCredentialsUseCase fakeUpdateCredentialsUseCase;

  setUp(() {
    fakeProfileRepository = FakeProfileRepository();
    fakeUpdateCredentialsUseCase = FakeUpdateCredentialsUseCase();
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        updateCredentialsUseCaseProvider
            .overrideWithValue(fakeUpdateCredentialsUseCase),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileSettingsScreen(),
      ),
    );
  }

  testWidgets('entering wrong old PIN keeps user in step 1 and shows error',
      (WidgetTester tester) async {
    fakeUpdateCredentialsUseCase.shouldFailVerify = true;

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open change PIN bottom sheet
    await tester.tap(find.text('Change PIN'));
    await tester.pumpAndSettle();

    // Verify we are at Old PIN step
    expect(find.text('Old PIN'), findsWidgets);

    // Enter wrong PIN
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify error is shown and we are still at Old PIN step
    expect(find.text('Incorrect Old PIN.'), findsWidgets);
    expect(find.text('Old PIN'), findsWidgets);
  });

  testWidgets('entering correct old PIN moves to step 2',
      (WidgetTester tester) async {
    fakeUpdateCredentialsUseCase.shouldFailVerify = false;

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open change PIN bottom sheet
    await tester.tap(find.text('Change PIN'));
    await tester.pumpAndSettle();

    // Enter correct PIN
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify we moved to New PIN step
    expect(find.text('New PIN'), findsWidgets);
  });

  testWidgets('successfully saving the new PIN', (WidgetTester tester) async {
    fakeUpdateCredentialsUseCase.shouldFailVerify = false;

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open change PIN bottom sheet
    await tester.tap(find.text('Change PIN'));
    await tester.pumpAndSettle();

    // Step 1: Old PIN
    await tester.enterText(find.byType(TextField).last, '1234');
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 2: New PIN
    await tester.enterText(find.byType(TextField).last, '5678');
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Step 3: Confirm PIN
    await tester.enterText(find.byType(TextField).last, '5678');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify success snackbar
    expect(find.text('PIN updated successfully.'), findsWidgets);
  });
}
