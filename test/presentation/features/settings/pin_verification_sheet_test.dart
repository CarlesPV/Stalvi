import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/presentation/features/settings/pin_verification_sheet.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late MockSecureStorageManager mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    when(() => mockSecureStorage.getPinLength()).thenAnswer((_) async => 4);
    when(() => mockSecureStorage.hasPin()).thenAnswer((_) async => true);
    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
    when(() => mockSecureStorage.isBiometricsEnabled())
        .thenAnswer((_) async => false);
    when(() => mockSecureStorage.getLockoutTimestamp())
        .thenAnswer((_) async => null);
  });

  Widget buildTestApp({
    required Widget child,
    required ProviderContainer container,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('PinVerificationSheet Tests', () {
    testWidgets(
        'triggers HapticFeedback.lightImpact on digit tap and backspace tap',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final List<String> hapticFeedbackCalls = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticFeedbackCalls.add(methodCall.arguments as String);
          }
          return null;
        },
      );

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestApp(
          container: container,
          child: PinVerificationSheet(
            onVerified: () {},
            onCancelled: () {},
          ),
        ),
      );
      await tester.pump();

      // Tap digit 1
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(hapticFeedbackCalls, contains('HapticFeedbackType.lightImpact'));
      await tester.pumpAndSettle();
      hapticFeedbackCalls.clear();

      // Tap backspace
      final backspaceIcon = find.byIcon(Icons.backspace_outlined);
      expect(backspaceIcon, findsOneWidget);
      await tester.tap(backspaceIcon);
      await tester.pump();

      expect(hapticFeedbackCalls, contains('HapticFeedbackType.lightImpact'));
      await tester.pumpAndSettle();
    });
    testWidgets('shows error text in semantic tree on failed pin',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockSecureStorage.getPinHash())
          .thenAnswer((_) async => 'fake_hash');

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestApp(
          container: container,
          child: PinVerificationSheet(
            onVerified: () {},
            onCancelled: () {},
          ),
        ),
      );
      await tester.pump();

      // Enter incorrect PIN: 1, 1, 1, 1
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('1'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('5 attempts remaining'), findsOneWidget);
    });
  });
}
