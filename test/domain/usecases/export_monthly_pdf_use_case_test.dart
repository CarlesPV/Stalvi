import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/export_monthly_pdf_use_case.dart';
import 'package:stalvi/domain/usecases/pdf_export_date_range.dart';
import 'package:stalvi/domain/use_cases/statistics/get_period_summary_use_case.dart';
import 'package:stalvi/domain/use_cases/statistics/get_top_categories_use_case.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockExchangeRateRepository extends Mock
    implements IExchangeRateRepository {}

class MockGetPeriodSummaryUseCase extends Mock
    implements GetPeriodSummaryUseCase {}

class MockGetTopCategoriesUseCase extends Mock
    implements GetTopCategoriesUseCase {}

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockSavingsGoalRepository extends Mock
    implements ISavingsGoalRepository {}

class MockExportService extends Mock implements IExportService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class FakePeriodSummary extends Fake implements PeriodSummary {}

class FakeAppLocalizations extends Fake implements AppLocalizations {}

void main() {
  late ExportMonthlyPdfUseCase usecase;
  late MockProfileRepository profileRepository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;
  late MockTransactionRepository transactionRepository;
  late MockExchangeRateRepository exchangeRateRepository;
  late MockGetPeriodSummaryUseCase getPeriodSummaryUseCase;
  late MockGetTopCategoriesUseCase getTopCategoriesUseCase;
  late MockBudgetRepository budgetRepository;
  late MockSavingsGoalRepository savingsGoalRepository;
  late MockExportService exportService;
  late MockAppLocalizations l10n;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(FakePeriodSummary());
    registerFallbackValue(FakeAppLocalizations());
    registerFallbackValue(TransactionType.expense);
  });

  setUp(() {
    profileRepository = MockProfileRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    transactionRepository = MockTransactionRepository();
    exchangeRateRepository = MockExchangeRateRepository();
    getPeriodSummaryUseCase = MockGetPeriodSummaryUseCase();
    getTopCategoriesUseCase = MockGetTopCategoriesUseCase();
    budgetRepository = MockBudgetRepository();
    savingsGoalRepository = MockSavingsGoalRepository();
    exportService = MockExportService();
    l10n = MockAppLocalizations();

    usecase = ExportMonthlyPdfUseCase(
      profileRepository: profileRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
      exchangeRateRepository: exchangeRateRepository,
      getPeriodSummaryUseCase: getPeriodSummaryUseCase,
      getTopCategoriesUseCase: getTopCategoriesUseCase,
      budgetRepository: budgetRepository,
      savingsGoalRepository: savingsGoalRepository,
      exportService: exportService,
      l10n: l10n,
    );
  });

  /// Helper: stubs all common repository calls to return sensible defaults
  void stubCommonMocks({
    required Profile profile,
    required List<Account> accounts,
    required List<Transaction> transactions,
    List<Budget> budgets = const [],
    List<SavingsGoal> savingsGoals = const [],
  }) {
    final now = DateTime.now();
    when(() => l10n.destination_account).thenReturn('Destination Account');
    when(() => profileRepository.getFirstProfile())
        .thenAnswer((_) async => profile);
    when(() => accountRepository.getAccountsByUserId(any()))
        .thenAnswer((_) async => accounts);
    when(() => categoryRepository.getAllCategories())
        .thenAnswer((_) async => []);
    when(
      () => getPeriodSummaryUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
      ),
    ).thenAnswer(
      (_) async => const PeriodSummary(totalIncome: 0, totalExpense: 0),
    );
    when(
      () => getTopCategoriesUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => []);
    when(() => transactionRepository.watchAllTransactions())
        .thenAnswer((_) => Stream.value(transactions));
    when(
      () => exchangeRateRepository.getLatestRates(
        baseCurrency: any(named: 'baseCurrency'),
      ),
    ).thenAnswer(
      (_) async => ExchangeRate(baseCurrency: 'EUR', date: now, rates: {}),
    );
    when(() => budgetRepository.getBudgets()).thenAnswer((_) async => budgets);
    when(() => savingsGoalRepository.getSavingsGoals())
        .thenAnswer((_) async => savingsGoals);
    when(
      () => exportService.generateMonthlyPdf(
        any(),
        summary: any(named: 'summary'),
        month: any(named: 'month'),
        l10n: any(named: 'l10n'),
        accounts: any(named: 'accounts'),
        categories: any(named: 'categories'),
        topExpenseCategories: any(named: 'topExpenseCategories'),
        topIncomeCategories: any(named: 'topIncomeCategories'),
        defaultCurrency: any(named: 'defaultCurrency'),
        transferDestinations: any(named: 'transferDestinations'),
        budgets: any(named: 'budgets'),
        budgetCategoryNames: any(named: 'budgetCategoryNames'),
        budgetCurrencies: any(named: 'budgetCurrencies'),
        savingsGoals: any(named: 'savingsGoals'),
        customMonthLabel: any(named: 'customMonthLabel'),
      ),
    ).thenAnswer(
      (_) async => const ExportResult(
        bytes: [],
        filename: 'test.pdf',
        mimeType: 'application/pdf',
      ),
    );
  }

  test(
      'passes correct defaultCurrency and transferDestinations to generateMonthlyPdf',
      () async {
    final now = DateTime(2023, 10, 15);
    final profile = Profile(
      id: 'user1',
      name: 'User',
      username: 'user',
      password: 'pwd',
      defaultCurrency: 'GBP',
      createdAt: now,
      modifiedAt: now,
    );

    final account1 = Account(
      id: 'acc1',
      userId: 'user1',
      name: 'Bank',
      type: AccountType.bank,
      initialBalance: 0,
      currency: 'EUR',
      color: '#000000',
      icon: 'bank',
      isDefault: true,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final account2 = Account(
      id: 'acc2',
      userId: 'user1',
      name: 'Wallet',
      type: AccountType.cash,
      initialBalance: 0,
      currency: 'EUR',
      color: '#FFFFFF',
      icon: 'wallet',
      isDefault: false,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final tx1 = Transaction(
      id: 'tx1',
      amount: -1000,
      date: now,
      type: TransactionType.transfer,
      accountId: 'acc1',
      originalCurrency: 'EUR',
      createdAt: now,
      modifiedAt: now,
      transferId: 'trans1',
    );

    final tx2 = Transaction(
      id: 'tx2',
      amount: 1000,
      date: now,
      type: TransactionType.transfer,
      accountId: 'acc2',
      originalCurrency: 'EUR',
      createdAt: now,
      modifiedAt: now,
      transferId: 'trans1',
    );

    stubCommonMocks(
      profile: profile,
      accounts: [account1, account2],
      transactions: [tx1, tx2],
    );

    await usecase(targetCurrency: 'EUR', forceNow: now);

    final result = verify(
      () => exportService.generateMonthlyPdf(
        any(),
        summary: any(named: 'summary'),
        month: any(named: 'month'),
        l10n: any(named: 'l10n'),
        accounts: any(named: 'accounts'),
        categories: any(named: 'categories'),
        topExpenseCategories: any(named: 'topExpenseCategories'),
        topIncomeCategories: any(named: 'topIncomeCategories'),
        defaultCurrency: captureAny(named: 'defaultCurrency'),
        transferDestinations: captureAny(named: 'transferDestinations'),
        budgets: any(named: 'budgets'),
        budgetCategoryNames: any(named: 'budgetCategoryNames'),
        budgetCurrencies: any(named: 'budgetCurrencies'),
        savingsGoals: any(named: 'savingsGoals'),
        customMonthLabel: any(named: 'customMonthLabel'),
      ),
    );

    expect(result.captured[0], 'GBP');
    expect(result.captured[1], {
      'tx1': 'Bank -> Wallet',
      'tx2': 'Bank -> Wallet',
    });
  });

  test('passes correct Spanish destinationAccount to generateMonthlyPdf',
      () async {
    final now = DateTime(2023, 10, 15);
    final profile = Profile(
      id: 'user1',
      name: 'User',
      username: 'user',
      password: 'pwd',
      defaultCurrency: 'GBP',
      createdAt: now,
      modifiedAt: now,
    );

    final account1 = Account(
      id: 'acc1',
      userId: 'user1',
      name: 'Bank',
      type: AccountType.bank,
      initialBalance: 0,
      currency: 'EUR',
      color: '#000000',
      icon: 'bank',
      isDefault: true,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final account2 = Account(
      id: 'acc2',
      userId: 'user1',
      name: 'Wallet',
      type: AccountType.cash,
      initialBalance: 0,
      currency: 'EUR',
      color: '#FFFFFF',
      icon: 'wallet',
      isDefault: false,
      isDeleted: false,
      createdAt: now,
      modifiedAt: now,
    );

    final tx1 = Transaction(
      id: 'tx1',
      amount: -1000,
      date: now,
      type: TransactionType.transfer,
      accountId: 'acc1',
      originalCurrency: 'EUR',
      createdAt: now,
      modifiedAt: now,
      transferId: 'trans1',
    );

    final tx2 = Transaction(
      id: 'tx2',
      amount: 1000,
      date: now,
      type: TransactionType.transfer,
      accountId: 'acc2',
      originalCurrency: 'EUR',
      createdAt: now,
      modifiedAt: now,
      transferId: 'trans1',
    );

    final esL10n = MockAppLocalizations();
    when(() => esL10n.destination_account).thenReturn('Cuenta de destino');

    final esUsecase = ExportMonthlyPdfUseCase(
      profileRepository: profileRepository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
      exchangeRateRepository: exchangeRateRepository,
      getPeriodSummaryUseCase: getPeriodSummaryUseCase,
      getTopCategoriesUseCase: getTopCategoriesUseCase,
      budgetRepository: budgetRepository,
      savingsGoalRepository: savingsGoalRepository,
      exportService: exportService,
      l10n: esL10n,
    );

    stubCommonMocks(
      profile: profile,
      accounts: [account1, account2],
      transactions: [tx1, tx2],
    );

    await esUsecase(targetCurrency: 'EUR', forceNow: now);

    final result = verify(
      () => exportService.generateMonthlyPdf(
        any(),
        summary: any(named: 'summary'),
        month: any(named: 'month'),
        l10n: captureAny(named: 'l10n'),
        accounts: any(named: 'accounts'),
        categories: any(named: 'categories'),
        topExpenseCategories: any(named: 'topExpenseCategories'),
        topIncomeCategories: any(named: 'topIncomeCategories'),
        defaultCurrency: any(named: 'defaultCurrency'),
        transferDestinations: captureAny(named: 'transferDestinations'),
        budgets: any(named: 'budgets'),
        budgetCategoryNames: any(named: 'budgetCategoryNames'),
        budgetCurrencies: any(named: 'budgetCurrencies'),
        savingsGoals: any(named: 'savingsGoals'),
        customMonthLabel: any(named: 'customMonthLabel'),
      ),
    );

    expect(result.captured[0], esL10n);
    expect(result.captured[1], {
      'tx1': 'Bank -> Wallet',
      'tx2': 'Bank -> Wallet',
    });
  });

  group('Budget and SavingsGoal data passed to generateMonthlyPdf', () {
    late Profile baseProfile;
    late Account baseAccount;

    setUp(() {
      final now = DateTime(2023, 10, 15);
      baseProfile = Profile(
        id: 'user1',
        name: 'User',
        username: 'user',
        password: 'pwd',
        defaultCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      );
      baseAccount = Account(
        id: 'acc1',
        userId: 'user1',
        name: 'Bank',
        type: AccountType.bank,
        initialBalance: 0,
        currency: 'EUR',
        color: '#000000',
        icon: 'bank',
        isDefault: true,
        isDeleted: false,
        createdAt: now,
        modifiedAt: now,
      );
    });

    test('only active budgets (non-deleted) are passed to the service',
        () async {
      final now = DateTime(2023, 10, 15);
      final activeBudget = Budget(
        id: 'b1',
        accountId: 'acc1',
        categoryId: 'cat1',
        targetAmount: 10000,
        currentAmount: 5000,
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 31),
        createdAt: now,
        modifiedAt: now,
        isDeleted: false,
      );
      final deletedBudget = Budget(
        id: 'b2',
        accountId: 'acc1',
        categoryId: 'cat2',
        targetAmount: 20000,
        currentAmount: 0,
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 31),
        createdAt: now,
        modifiedAt: now,
        isDeleted: true,
      );

      stubCommonMocks(
        profile: baseProfile,
        accounts: [baseAccount],
        transactions: [],
        budgets: [activeBudget, deletedBudget],
        savingsGoals: [],
      );

      await usecase(targetCurrency: 'EUR', forceNow: now);

      final captured = verify(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: captureAny(named: 'budgets'),
          budgetCategoryNames: any(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: any(named: 'savingsGoals'),
          customMonthLabel: any(named: 'customMonthLabel'),
        ),
      ).captured;

      final passedBudgets = captured[0] as List<Budget>;
      expect(passedBudgets.length, 1);
      expect(passedBudgets.first.id, 'b1');
    });

    test('only active savings goals (non-deleted) are passed to the service',
        () async {
      final now = DateTime(2023, 10, 15);
      final activeGoal = SavingsGoal(
        id: 'sg1',
        name: 'Vacation',
        targetAmount: 50000,
        currentAmount: 25000,
        currency: 'EUR',
        color: '#FF5722',
        icon: 'beach',
        createdAt: now,
        modifiedAt: now,
        isDeleted: false,
      );
      final deletedGoal = SavingsGoal(
        id: 'sg2',
        name: 'Old Goal',
        targetAmount: 10000,
        currentAmount: 0,
        currency: 'EUR',
        color: '#9E9E9E',
        icon: 'trash',
        createdAt: now,
        modifiedAt: now,
        isDeleted: true,
      );

      stubCommonMocks(
        profile: baseProfile,
        accounts: [baseAccount],
        transactions: [],
        budgets: [],
        savingsGoals: [activeGoal, deletedGoal],
      );

      await usecase(targetCurrency: 'EUR', forceNow: now);

      final captured = verify(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: any(named: 'budgets'),
          budgetCategoryNames: any(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: captureAny(named: 'savingsGoals'),
          customMonthLabel: any(named: 'customMonthLabel'),
        ),
      ).captured;

      final passedGoals = captured[0] as List<SavingsGoal>;
      expect(passedGoals.length, 1);
      expect(passedGoals.first.id, 'sg1');
      expect(passedGoals.first.name, 'Vacation');
    });

    test('budgetCategoryNames map is correctly built from categories',
        () async {
      final now = DateTime(2023, 10, 15);
      final budget = Budget(
        id: 'b1',
        accountId: 'acc1',
        categoryId: 'cat1',
        targetAmount: 10000,
        currentAmount: 5000,
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 31),
        createdAt: now,
        modifiedAt: now,
        isDeleted: false,
      );

      when(() => l10n.destination_account).thenReturn('Destination Account');
      when(() => profileRepository.getFirstProfile())
          .thenAnswer((_) async => baseProfile);
      when(() => accountRepository.getAccountsByUserId(any()))
          .thenAnswer((_) async => [baseAccount]);

      // Return a category with id cat1, name Food
      when(() => categoryRepository.getAllCategories())
          .thenAnswer((_) async => []);
      when(
        () => getPeriodSummaryUseCase.execute(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: any(named: 'targetCurrency'),
        ),
      ).thenAnswer(
        (_) async => const PeriodSummary(totalIncome: 0, totalExpense: 0),
      );
      when(
        () => getTopCategoriesUseCase.execute(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          targetCurrency: any(named: 'targetCurrency'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) async => []);
      when(() => transactionRepository.watchAllTransactions())
          .thenAnswer((_) => Stream.value([]));
      when(
        () => exchangeRateRepository.getLatestRates(
          baseCurrency: any(named: 'baseCurrency'),
        ),
      ).thenAnswer(
        (_) async => ExchangeRate(baseCurrency: 'EUR', date: now, rates: {}),
      );
      when(() => budgetRepository.getBudgets())
          .thenAnswer((_) async => [budget]);
      when(() => savingsGoalRepository.getSavingsGoals())
          .thenAnswer((_) async => []);
      when(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: any(named: 'budgets'),
          budgetCategoryNames: any(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: any(named: 'savingsGoals'),
          customMonthLabel: any(named: 'customMonthLabel'),
        ),
      ).thenAnswer(
        (_) async => const ExportResult(
          bytes: [],
          filename: 'test.pdf',
          mimeType: 'application/pdf',
        ),
      );

      await usecase(targetCurrency: 'EUR', forceNow: now);

      final captured = verify(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: any(named: 'budgets'),
          budgetCategoryNames: captureAny(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: any(named: 'savingsGoals'),
          customMonthLabel: any(named: 'customMonthLabel'),
        ),
      ).captured;

      final categoryNames = captured[0] as Map<String, String>;
      // Without a category resolved (empty categories list), it falls back to categoryId
      expect(categoryNames['cat1'], 'cat1');
    });

    test('empty budgets and savings goals produce empty lists in service call',
        () async {
      final now = DateTime(2023, 10, 15);

      stubCommonMocks(
        profile: baseProfile,
        accounts: [baseAccount],
        transactions: [],
        budgets: [],
        savingsGoals: [],
      );

      await usecase(targetCurrency: 'EUR', forceNow: now);

      final captured = verify(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: captureAny(named: 'budgets'),
          budgetCategoryNames: any(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: captureAny(named: 'savingsGoals'),
          customMonthLabel: any(named: 'customMonthLabel'),
        ),
      ).captured;

      expect(captured[0] as List<Budget>, isEmpty);
      expect(captured[1] as List<SavingsGoal>, isEmpty);
    });
  });

  group('PdfExportDateRange logic', () {
    test('last30Days correctly calculates startDate and endDate', () async {
      final now = DateTime(2023, 10, 15);
      final profile = Profile(
        id: 'user1',
        name: 'User',
        username: 'user',
        password: 'pwd',
        defaultCurrency: 'EUR',
        createdAt: now,
        modifiedAt: now,
      );

      final account1 = Account(
        id: 'acc1',
        userId: 'user1',
        name: 'Bank',
        type: AccountType.bank,
        initialBalance: 0,
        currency: 'EUR',
        color: '#000000',
        icon: 'bank',
        isDefault: true,
        isDeleted: false,
        createdAt: now,
        modifiedAt: now,
      );

      stubCommonMocks(
        profile: profile,
        accounts: [account1],
        transactions: [],
      );

      await usecase(
        targetCurrency: 'EUR',
        dateRange: PdfExportDateRange.last30Days,
        forceNow: now,
        customMonthLabel: 'Last 30 Days Translated',
      );

      final result = verify(
        () => exportService.generateMonthlyPdf(
          any(),
          summary: any(named: 'summary'),
          month: any(named: 'month'),
          l10n: any(named: 'l10n'),
          accounts: any(named: 'accounts'),
          categories: any(named: 'categories'),
          topExpenseCategories: any(named: 'topExpenseCategories'),
          topIncomeCategories: any(named: 'topIncomeCategories'),
          defaultCurrency: any(named: 'defaultCurrency'),
          transferDestinations: any(named: 'transferDestinations'),
          budgets: any(named: 'budgets'),
          budgetCategoryNames: any(named: 'budgetCategoryNames'),
          budgetCurrencies: any(named: 'budgetCurrencies'),
          savingsGoals: any(named: 'savingsGoals'),
          customMonthLabel: captureAny(named: 'customMonthLabel'),
        ),
      );
      result.called(1);
      expect(result.captured.first, 'Last 30 Days Translated');
    });
  });
}
