import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/presentation/features/auth/biometric_opt_in_screen.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/core/theme/app_theme.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

void main() {
  late MockSecureStorageManager mockSecureStorage;
  late MockBiometricAuthService mockBiometricAuth;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    mockBiometricAuth = MockBiometricAuthService();

    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
    when(() => mockSecureStorage.isBiometricsEnabled())
        .thenAnswer((_) async => false);
    when(() => mockSecureStorage.hasBiometricsChoice())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => false);
  });

  Widget buildTestApp({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BiometricOptInScreen(),
      ),
    );
  }

  group('BiometricOptInScreen Tests', () {
    testWidgets(
        'renders all visual elements: title, subtitle, enable and skip buttons',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        ],
      );

      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pump();

      // Verify texts are rendered
      expect(find.text('Enable Biometric Login'), findsOneWidget);
      expect(
        find.text(
          'Use Fingerprint or FaceID to quickly and securely access your Stalvi account in the future.',
        ),
        findsOneWidget,
      );
      expect(find.text('Enable Biometrics'), findsOneWidget);
      expect(find.text('Skip for Now'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
    });

    testWidgets(
        'clicking Enable Biometrics triggers authentication setup and enables it',
        (WidgetTester tester) async {
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
      when(() => mockBiometricAuth.enableBiometrics())
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        ],
      );

      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pump();

      await tester.tap(find.text('Enable Biometrics'));
      await tester.pump();

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
      verify(() => mockBiometricAuth.enableBiometrics()).called(1);
    });

    testWidgets('clicking Skip for Now disables biometrics and completes flow',
        (WidgetTester tester) async {
      when(() => mockBiometricAuth.disableBiometrics())
          .thenAnswer((_) async => {});

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        ],
      );

      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pump();

      await tester.tap(find.text('Skip for Now'));
      await tester.pump();

      verify(() => mockBiometricAuth.disableBiometrics()).called(1);
    });
  });
}
