import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late MockSecureStorageManager mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => null);
    when(() => mockSecureStorage.setUserLocale(any())).thenAnswer((_) async {});
  });

  Widget buildTestApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, child) {
          final activeLocale = ref.watch(localeProvider);
          return MaterialApp(
            locale: activeLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TestLocaleScreen(),
          );
        },
      ),
    );
  }

  testWidgets('switches locale and displays correct localized terms',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(mockSecureStorage),
      ],
    );

    // Initial load: defaults to English (or system)
    await tester.pumpWidget(buildTestApp(container));
    await tester.pumpAndSettle();

    // Verify initial state defaults to English
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);

    // Switch to Spanish
    await container.read(localeProvider.notifier).setLocale(const Locale('es'));
    await tester.pumpAndSettle();

    // Verify Spanish translations are displayed
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Transacciones'), findsOneWidget);
    expect(find.text('Añadir transacción'), findsOneWidget);
    expect(find.text('Ingresos'), findsOneWidget);

    // Switch to Catalan
    await container.read(localeProvider.notifier).setLocale(const Locale('ca'));
    await tester.pumpAndSettle();

    // Verify Catalan translations are displayed
    expect(find.text('Ajustos'), findsOneWidget);
    expect(find.text('Transaccions'), findsOneWidget);
    expect(find.text('Afegir transacció'), findsOneWidget);
    expect(find.text('Ingressos'), findsOneWidget);
  });
}

class TestLocaleScreen extends StatelessWidget {
  const TestLocaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          Text(l10n.settings),
          Text(l10n.transactions),
          Text(l10n.addTransaction),
          Text(l10n.income),
        ],
      ),
    );
  }
}
