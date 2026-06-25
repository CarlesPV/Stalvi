import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/export_monthly_pdf_use_case.dart';
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
      exportService: exportService,
      l10n: l10n,
    );
  });

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

    when(() => l10n.destination_account).thenReturn('Destination Account');
    when(() => profileRepository.getFirstProfile())
        .thenAnswer((_) async => profile);
    when(() => accountRepository.getAccountsByUserId('user1'))
        .thenAnswer((_) async => [account1, account2]);
    when(() => categoryRepository.getAllCategories())
        .thenAnswer((_) async => []);
    when(
      () => getPeriodSummaryUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
      ),
    ).thenAnswer(
        (_) async => const PeriodSummary(totalIncome: 0, totalExpense: 0));

    when(
      () => getTopCategoriesUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => []);

    when(() => transactionRepository.watchAllTransactions())
        .thenAnswer((_) => Stream.value([tx1, tx2]));
    when(() =>
        exchangeRateRepository.getLatestRates(
            baseCurrency: any(named: 'baseCurrency'))).thenAnswer(
        (_) async => ExchangeRate(baseCurrency: 'EUR', date: now, rates: {}));

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
      ),
    ).thenAnswer((_) async => const ExportResult(
        bytes: [], filename: 'test.pdf', mimeType: 'application/pdf'));

    await usecase(targetCurrency: 'EUR', month: now);

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
      ),
    );

    expect(result.captured[0], 'GBP');
    expect(result.captured[1], {
      'tx1': 'Bank (Destination Account: Wallet)',
      'tx2': 'Bank (Destination Account: Wallet)',
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
      exportService: exportService,
      l10n: esL10n,
    );

    when(() => profileRepository.getFirstProfile())
        .thenAnswer((_) async => profile);
    when(() => accountRepository.getAccountsByUserId('user1'))
        .thenAnswer((_) async => [account1, account2]);
    when(() => categoryRepository.getAllCategories())
        .thenAnswer((_) async => []);
    when(
      () => getPeriodSummaryUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
      ),
    ).thenAnswer(
        (_) async => const PeriodSummary(totalIncome: 0, totalExpense: 0));

    when(
      () => getTopCategoriesUseCase.execute(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        targetCurrency: any(named: 'targetCurrency'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => []);

    when(() => transactionRepository.watchAllTransactions())
        .thenAnswer((_) => Stream.value([tx1, tx2]));
    when(() =>
        exchangeRateRepository.getLatestRates(
            baseCurrency: any(named: 'baseCurrency'))).thenAnswer(
        (_) async => ExchangeRate(baseCurrency: 'EUR', date: now, rates: {}));

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
      ),
    ).thenAnswer((_) async => const ExportResult(
        bytes: [], filename: 'test.pdf', mimeType: 'application/pdf'));

    await esUsecase(targetCurrency: 'EUR', month: now);

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
      ),
    );

    expect(result.captured[0], esL10n);
    expect(result.captured[1], {
      'tx1': 'Bank (Cuenta de destino: Wallet)',
      'tx2': 'Bank (Cuenta de destino: Wallet)',
    });
  });
}
