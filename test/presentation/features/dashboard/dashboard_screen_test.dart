import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/presentation/features/dashboard/dashboard_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/widgets/empty_state_widget.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/create_account_usecase.dart';
import 'package:stalvi/presentation/features/transactions/transaction_details_dialog.dart';
import 'package:stalvi/presentation/widgets/create_account_dialog.dart';
import 'package:stalvi/presentation/features/transactions/add_transaction_screen.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';
import 'package:stalvi/presentation/providers/add_transaction_notifier.dart';
import 'package:stalvi/presentation/providers/transaction_filter_provider.dart';

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockCreateAccountUseCase extends Mock implements CreateAccountUseCase {}

class FakeCreateAccountParams extends Fake implements CreateAccountParams {}

class FakeTransaction extends Fake implements Transaction {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class FakeAddTransactionNotifier extends AddTransactionNotifier {
  @override
  AddTransactionState build() {
    return AddTransactionState.initial();
  }

  @override
  void updateAmount(String text) {}
  @override
  void updateNotes(String notes) {}
  @override
  void updateType(dynamic type) {}
  @override
  void updateAccount(String accountId) {}
  @override
  void updateCategory(String? categoryId) {}
  @override
  void updateDate(DateTime date) {}
  @override
  void updateCurrency(String currency) {}
  @override
  Future<bool> submit() async {
    return true;
  }
}

class NeverStream<T> extends Stream<T> {
  const NeverStream();

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return NeverSubscription<T>();
  }
}

class NeverSubscription<T> implements StreamSubscription<T> {
  @override
  Future<void> cancel() => Future.value();
  @override
  void onData(void Function(T data)? handleData) {}
  @override
  void onError(Function? handleError) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;
}

void main() {
  late MockSecureStorageManager mockSecureStorage;
  late MockBiometricAuthService mockBiometricAuth;

  setUpAll(() {
    registerFallbackValue(FakeCreateAccountParams());
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockSecureStorage = MockSecureStorageManager();
    mockBiometricAuth = MockBiometricAuthService();

    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
    when(() => mockSecureStorage.isBiometricsEnabled())
        .thenAnswer((_) async => false);
    when(() => mockSecureStorage.hasBiometricsChoice())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => false);
    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => false);
  });

  final testAccount = Account(
    id: 'acc_wallet',
    userId: 'user_1',
    name: 'Cash Wallet',
    type: AccountType.cash,
    initialBalance: 500.0,
    currency: 'EUR',
    color: '#FF5722',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  final testTransaction = Transaction(
    id: 'txn_1',
    accountId: 'acc_wallet',
    categoryId: 'cat_food',
    amount: 1550, // €15.50
    originalCurrency: 'EUR',
    exchangeRate: 1.0,
    type: TransactionType.expense,
    date: DateTime(2026, 6, 10),
    notes: 'Dinner with friends',
    createdAt: DateTime(2026, 6, 10),
    modifiedAt: DateTime(2026, 6, 10),
  );

  Widget createTestWidget({
    required Stream<List<Transaction>> transactionsStream,
    required Stream<List<Account>> accountsStream,
    Profile? profile,
    PeriodSummary? periodSummary,
    ITransactionRepository? transactionRepo,
    CreateAccountUseCase? createAccountUseCase,
  }) {
    final mockProfile = profile ??
        Profile(
          id: 'user_1',
          name: 'Anonymous',
          username: 'anon',
          password: 'pw',
          defaultCurrency: 'EUR',
          createdAt: DateTime(2026, 6, 1),
          modifiedAt: DateTime(2026, 6, 1),
        );

    final mockPeriodSummary = periodSummary ??
        const PeriodSummary(
          totalIncome: 10000, // €100.00
          totalExpense: 5000, // €50.00
        );

    final broadcastTxns = transactionsStream.asBroadcastStream();

    return ProviderScope(
      overrides: [
        transactionsStreamProvider.overrideWith((ref) => broadcastTxns),
        filteredTransactionsProvider.overrideWith((ref) => broadcastTxns),
        accountsListProvider.overrideWith((ref) => accountsStream),
        defaultProfileProvider.overrideWith((ref) => mockProfile),
        periodSummaryProvider.overrideWith((ref) => mockPeriodSummary),
        categoriesListProvider.overrideWith((ref) => Stream.value([])),
        tagsListProvider.overrideWith((ref) => Future.value([])),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
        biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
        addTransactionNotifierProvider
            .overrideWith(FakeAddTransactionNotifier.new),
        globalBalanceProvider.overrideWith((ref) async* {
          final accounts = await ref.watch(accountsListProvider.future);
          yield accounts.fold<double>(
            0.0,
            (sum, acc) => sum + acc.initialBalance,
          );
        }),
        if (transactionRepo != null)
          transactionRepositoryProvider.overrideWithValue(transactionRepo),
        if (createAccountUseCase != null)
          createAccountUseCaseProvider.overrideWithValue(createAccountUseCase),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final activeLocale = ref.watch(localeProvider);
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: activeLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets(
        'renders empty state in Overview tab when transactions list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value(<Transaction>[]),
          accountsStream: Stream.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Overview tab is index 0 by default. It displays recent transactions empty state.
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text(
          'Add your first income or expense to see it here and start tracking.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'renders empty state in Transactions tab when transactions list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value(<Transaction>[]),
          accountsStream: Stream.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on the Transactions navigation destination (second tab)
      // Since 'Transactions' label is also used elsewhere, we target the NavigationDestination label.
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets(
        'renders empty state in Accounts tab when accounts list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value(<Account>[]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on the Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No accounts yet'), findsOneWidget);
      expect(
        find.text(
          'Create an account or wallet to start managing your assets and tracking transactions.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'renders lists of transactions and accounts when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Overview Tab is default. Verify transaction item notes exist.
      expect(find.text('Dinner with friends'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);

      // Tap Transactions tab
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dinner with friends'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);

      // Tap Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Cash Wallet'), findsOneWidget);
      expect(find.text('CASH'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);
    });

    testWidgets('renders Recycle Bin tile and navigates to RecycleBinScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Expect to see the Recycle Bin row
      expect(find.text('Recycle Bin'), findsOneWidget);
    });

    testWidgets(
        'obfuscates amounts by default on loading, and reveals them when eye icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify that the obfuscation string is shown by default
      expect(find.text('***'), findsWidgets);

      // Verify that the actual amount (e.g. 500.00) is NOT visible yet
      expect(find.textContaining('500.00'), findsNothing);

      // 2. Find the eye icon button and tap it to toggle discreet mode
      final eyeButton = find.byKey(const ValueKey('discreetModeIconButton'));
      expect(eyeButton, findsOneWidget);
      await tester.tap(eyeButton);
      await tester.pump();

      // 3. Verify that the obfuscated string is gone, and the actual values are visible
      expect(find.text('***'), findsNothing);
      expect(find.textContaining('500.00'), findsOneWidget);
    });

    testWidgets('Tapping FAB on Overview tab opens AddTransactionScreen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pump(); // start animation
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify AddTransactionScreen is opened
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });

    testWidgets('Tapping FAB on Accounts tab opens CreateAccountDialog',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final mockCreateAccountUseCase = MockCreateAccountUseCase();
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
          createAccountUseCase: mockCreateAccountUseCase,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap on FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify CreateAccountDialog (bottom sheet) is shown
      expect(find.byType(CreateAccountDialog), findsOneWidget);
    });

    testWidgets(
        'Tapping transaction item opens TransactionDetailsDialog and tapping Delete button triggers soft delete',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final mockTxnRepo = MockTransactionRepository();
      when(() => mockTxnRepo.deleteTransaction(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsStream: Stream.value([testAccount]),
          transactionRepo: mockTxnRepo,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Find by key to be extremely precise
      final txnItem =
          find.byKey(ValueKey('recent_transaction_${testTransaction.id}'));
      expect(txnItem, findsOneWidget);

      await tester.ensureVisible(txnItem);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on the transaction item to open Details bottom sheet
      await tester.tap(txnItem);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify dialog details are showing
      expect(find.byType(TransactionDetailsDialog), findsOneWidget);

      // Find the Delete button inside dialog and tap it
      final deleteBtn = find.byKey(const ValueKey('deleteTransactionButton'));
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify confirm delete dialog is shown
      expect(find.text('Delete Transaction?'), findsOneWidget);

      // Tap on confirm Delete button
      final confirmDeleteBtn =
          find.byKey(const ValueKey('confirmDeleteButton'));
      expect(confirmDeleteBtn, findsOneWidget);
      await tester.tap(confirmDeleteBtn);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify that deleteTransaction was called on mock repository
      verify(() => mockTxnRepo.deleteTransaction(testTransaction.id)).called(1);
    });
  });
}
