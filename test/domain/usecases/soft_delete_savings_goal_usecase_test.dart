import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/soft_delete_savings_goal_usecase.dart';

class MockSavingsGoalRepository extends Mock
    implements ISavingsGoalRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockSavingsGoalRepository mockSavingsGoalRepo;
  late MockTransactionRepository mockTransactionRepo;
  late SoftDeleteSavingsGoalUseCase usecase;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockSavingsGoalRepo = MockSavingsGoalRepository();
    mockTransactionRepo = MockTransactionRepository();
    usecase = SoftDeleteSavingsGoalUseCase(
      mockSavingsGoalRepo,
      mockTransactionRepo,
    );
  });

  final testGoal = SavingsGoal(
    id: 'g1',
    name: 'Vacation',
    targetAmount: 5000,
    currentAmount: 1000,
    currency: 'EUR',
    color: '#000',
    icon: 'savings',
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  test('soft deletes goal and creates refund transactions', () async {
    when(
      () => mockSavingsGoalRepo.getSavingsGoalById('g1'),
    ).thenAnswer((_) async => testGoal);
    when(
      () => mockSavingsGoalRepo.deleteSavingsGoal('g1'),
    ).thenAnswer((_) async {});

    final tx1 = Transaction(
      id: 'tx1',
      amount: 1000,
      date: DateTime.now(),
      type: TransactionType.transfer,
      accountId: 'acc1',
      savingsGoalId: 'g1',
      originalCurrency: 'USD',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    when(
      () => mockTransactionRepo.watchAllTransactions(),
    ).thenAnswer((_) => Stream.value([tx1]));

    when(
      () => mockTransactionRepo.createTransaction(any()),
    ).thenAnswer((_) async => FakeTransaction());

    await usecase.execute('g1');

    verify(() => mockSavingsGoalRepo.deleteSavingsGoal('g1')).called(1);

    verify(
      () => mockTransactionRepo.createTransaction(
        any(
          that: predicate<Transaction>(
            (t) =>
                t.type == TransactionType.income &&
                t.amount == 1000 &&
                t.accountId == 'acc1',
          ),
        ),
      ),
    ).called(1);
  });
}
