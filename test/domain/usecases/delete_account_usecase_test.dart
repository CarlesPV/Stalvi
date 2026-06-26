import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/usecases/delete_account_usecase.dart';

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class FakeBudget extends Fake implements Budget {}

void main() {
  late MockAccountRepository mockAccountRepo;
  late MockBudgetRepository mockBudgetRepo;
  late DeleteAccountUseCase usecase;

  setUpAll(() {
    registerFallbackValue(FakeBudget());
  });

  setUp(() {
    mockAccountRepo = MockAccountRepository();
    mockBudgetRepo = MockBudgetRepository();
    usecase = DeleteAccountUseCase(mockAccountRepo, mockBudgetRepo);
  });

  final testAccount = Account(
    id: 'acc1',
    name: 'Test Account',
    type: AccountType.cash,
    currency: 'USD',
    color: '#000',
    icon: 'wallet',
    initialBalance: 0,
    isDefault: false,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
    userId: 'user1',
  );

  final defaultAccount = Account(
    id: 'acc2',
    name: 'Default Account',
    type: AccountType.bank,
    currency: 'USD',
    color: '#000',
    icon: 'wallet',
    initialBalance: 0,
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
    userId: 'user1',
  );

  test('reassigns budgets to default account and deletes account', () async {
    when(() => mockAccountRepo.getAccountById('acc1'))
        .thenAnswer((_) async => testAccount);
    when(() => mockAccountRepo.getDefaultAccount('user1'))
        .thenAnswer((_) async => defaultAccount);

    final budget = Budget(
      id: 'b1',
      accountId: 'acc1',
      categoryId: 'cat1',
      targetAmount: 1000,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    when(() => mockBudgetRepo.getBudgets()).thenAnswer((_) async => [budget]);
    when(() => mockBudgetRepo.updateBudget(any())).thenAnswer((_) async {});
    when(() => mockAccountRepo.deleteAccount('acc1')).thenAnswer((_) async {});

    await usecase.execute('acc1');

    verify(
      () => mockBudgetRepo.updateBudget(
        any(that: predicate<Budget>((b) => b.accountId == 'acc2')),
      ),
    ).called(1);

    verify(() => mockAccountRepo.deleteAccount('acc1')).called(1);
  });

  test('throws if trying to delete default account', () async {
    when(() => mockAccountRepo.getAccountById('acc2'))
        .thenAnswer((_) async => defaultAccount);
    when(() => mockAccountRepo.getDefaultAccount('user1'))
        .thenAnswer((_) async => defaultAccount);

    expect(
      () => usecase.execute('acc2'),
      throwsA(isA<ValidationException>()),
    );
  });
}
