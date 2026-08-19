import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/delete_account_usecase.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/widgets/edit_account_dialog.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late MockTransactionRepository mockTransactionRepo;
  late MockDeleteAccountUseCase mockDeleteAccountUseCase;
  late MockSecureStorageManager mockSecureStorage;

  final testAccount = Account(
    id: 'acc_1',
    userId: 'user_1',
    name: 'My Wallet',
    type: AccountType.cash,
    initialBalance: 100.0,
    currency: 'EUR',
    color: '#000000',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockDeleteAccountUseCase = MockDeleteAccountUseCase();
    mockSecureStorage = MockSecureStorageManager();
    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(mockTransactionRepo),
        deleteAccountUseCaseProvider
            .overrideWithValue(mockDeleteAccountUseCase),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  EditAccountDialog.show(context, testAccount);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('EditAccountDialog - Delete Tests', () {
    testWidgets(
        'shows warning about cascading delete if account has transactions',
        (WidgetTester tester) async {
      when(() => mockTransactionRepo.hasAnyTransactions(testAccount.id))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestableWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This account has associated transactions. Deleting it will also delete all its transactions.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.text('Cancel'), findsWidgets);
      expect(find.text('Delete'), findsWidgets);
    });

    testWidgets('shows standard warning if account has no transactions',
        (WidgetTester tester) async {
      when(() => mockTransactionRepo.hasAnyTransactions(testAccount.id))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestableWidget());
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Are you sure you want to delete all data? This cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsNothing);
    });
  });
}
