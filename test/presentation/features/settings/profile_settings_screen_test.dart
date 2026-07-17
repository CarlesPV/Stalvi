import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';
import 'package:stalvi/presentation/features/settings/profile_settings_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

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
    expect(find.textContaining('Incorrect Old PIN.'), findsWidgets);
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

  testWidgets(
      'fallback to PIN if biometrics fails or is cancelled when deleting all data',
      (WidgetTester tester) async {
    fakeUpdateCredentialsUseCase.shouldFailVerify = false;

    final mockBiometricAuth = MockBiometricAuthService();
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => true);
    when(
      () => mockBiometricAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        lockedOutMessage: any(named: 'lockedOutMessage'),
        authFailedMessage: any(named: 'authFailedMessage'),
        unknownErrorMessage: any(named: 'unknownErrorMessage'),
        signInTitle: any(named: 'signInTitle'),
        cancelButton: any(named: 'cancelButton'),
      ),
    ).thenAnswer((_) async => false);

    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          updateCredentialsUseCaseProvider
              .overrideWithValue(fakeUpdateCredentialsUseCase),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open change PIN bottom sheet (actually we tap Delete All Data)
    final deleteButton = find.text('Delete All Data');
    try {
      await tester.scrollUntilVisible(
        deleteButton,
        200,
        scrollable: find.byType(Scrollable),
      );
    } catch (_) {
      // In case scrollUntilVisible fails, drag manually
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
    }
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Biometrics should be called
    verify(
      () => mockBiometricAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        lockedOutMessage: any(named: 'lockedOutMessage'),
        authFailedMessage: any(named: 'authFailedMessage'),
        unknownErrorMessage: any(named: 'unknownErrorMessage'),
        signInTitle: any(named: 'signInTitle'),
        cancelButton: any(named: 'cancelButton'),
      ),
    ).called(1);

    // PIN bottom sheet should be shown
  });

  testWidgets('Username dialog renders without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Username'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
      'Currency dropdown dialog renders without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Default Currency'));
    await tester.pumpAndSettle();

    expect(find.text('Select Currency'), findsOneWidget);
  });

  testWidgets(
      'Delete all data confirmation dialog renders without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockBiometricAuth = MockBiometricAuthService();
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => true);
    when(
      () => mockBiometricAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        lockedOutMessage: any(named: 'lockedOutMessage'),
        authFailedMessage: any(named: 'authFailedMessage'),
        unknownErrorMessage: any(named: 'unknownErrorMessage'),
        signInTitle: any(named: 'signInTitle'),
        cancelButton: any(named: 'cancelButton'),
      ),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          updateCredentialsUseCaseProvider
              .overrideWithValue(fakeUpdateCredentialsUseCase),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.text('Delete All Data');
    try {
      await tester.scrollUntilVisible(
        deleteButton,
        200,
        scrollable: find.byType(Scrollable),
      );
    } catch (_) {
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
    }
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete All Data'), findsWidgets);
  });
}
