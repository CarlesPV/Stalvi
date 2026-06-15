import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/core/security/secure_storage_manager.dart';
import 'package:konta/infrastructure/services/biometric_auth_service.dart';
import 'package:konta/presentation/features/auth/auth_screen.dart';
import 'package:konta/presentation/providers/auth_notifier.dart';
import 'package:konta/presentation/providers/locale_provider.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/presentation/providers/repository_providers.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/account.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

void main() {
  late MockSecureStorageManager mockSecureStorage;
  late MockBiometricAuthService mockBiometricAuth;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    mockBiometricAuth = MockBiometricAuthService();

    // Default stubbing
    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
    when(() => mockSecureStorage.isBiometricsEnabled())
        .thenAnswer((_) async => false);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => false);
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => false);
  });

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

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
        home: const AuthScreen(),
      ),
    );
  }

  group('AuthScreen PIN Widget Tests', () {
    testWidgets(
        'shows 5 empty dots when 5-digit PIN is configured, no confirm button, and auto-submits on 5th digit',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
      when(() => mockSecureStorage.getPinLength()).thenAnswer((_) async => 5);
      when(() => mockSecureStorage.getPinHash())
          .thenAnswer((_) async => hashPin('12345'));

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
          transactionsStreamProvider
              .overrideWith((ref) => Stream.value(<Transaction>[])),
          accountsListProvider.overrideWith((ref) => Future.value(<Account>[])),
        ],
      );

      // Act
      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pump();

      // Assert: Verify state is unauthenticated and 5 dots are rendered
      // Dots are rendered as Containers with shape circle.
      final dotFinder = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration != null && decoration.shape == BoxShape.circle;
      });

      // There are 5 dots for PIN + 1 biometric circle header icon = 6 circle containers in the screen.
      // Wait, let's verify. The brand header has:
      // Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16) ...))
      // So the only BoxShape.circle containers are the PIN dots and any locked-out / status circle, which is not shown.
      // Therefore, the number of circle decorated containers should be exactly 5.
      expect(dotFinder, findsNWidgets(5));

      // Assert: Verify confirm button is completely absent
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);

      // Act: Type PIN digits "1", "2", "3", "4", "5"
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      // Still 4 digits, not yet validated. Check that it is not in loading/authenticated state
      expect(container.read(authNotifierProvider).isLoading, false);

      await tester.tap(find.text('5'));
      // Wait for build transitions and animations
      await tester.pump();

      // Assert: Validation should be triggered immediately (which sets status to loading then authenticated)
      // Since mockSecureStorage has the correct pin hash, it will succeed and set state to authenticated.
      await tester.pump(const Duration(milliseconds: 200));
      expect(
          container.read(authNotifierProvider).value, AuthStatus.authenticated);
    });

    testWidgets(
        'shows 6 empty dots when 6-digit PIN is configured, no confirm button, and auto-submits on 6th digit',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
      when(() => mockSecureStorage.getPinLength()).thenAnswer((_) async => 6);
      when(() => mockSecureStorage.getPinHash())
          .thenAnswer((_) async => hashPin('123456'));

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
          biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
          transactionsStreamProvider
              .overrideWith((ref) => Stream.value(<Transaction>[])),
          accountsListProvider.overrideWith((ref) => Future.value(<Account>[])),
        ],
      );

      // Act
      await tester.pumpWidget(buildTestApp(container: container));
      await tester.pump();

      // Assert: Verify 6 dots are rendered
      final dotFinder = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration as BoxDecoration?;
        return decoration != null && decoration.shape == BoxShape.circle;
      });
      expect(dotFinder, findsNWidgets(6));

      // Assert: Verify confirm button is completely absent
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);

      // Act: Type PIN digits "1", "2", "3", "4", "5", "6"
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();

      // Still 5 digits, not yet validated
      expect(container.read(authNotifierProvider).isLoading, false);

      await tester.tap(find.text('6'));
      await tester.pump();

      // Assert: Validation triggered automatically
      await tester.pump(const Duration(milliseconds: 200));
      expect(
          container.read(authNotifierProvider).value, AuthStatus.authenticated);
    });
  });
}
