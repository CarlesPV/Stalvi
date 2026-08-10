import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';

@GenerateNiceMocks([MockSpec<IAutomaticTransactionRepository>()])
import 'delete_automatic_transaction_usecase_test.mocks.dart';

void main() {
  late DeleteAutomaticTransactionUseCase useCase;
  late MockIAutomaticTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockIAutomaticTransactionRepository();
    useCase = DeleteAutomaticTransactionUseCase(mockRepository);
  });

  test(
    'should set isDeleted to true, isActive to false, and deletedAt to current time',
    () async {
      final now = DateTime.now();
      final txn = AutomaticTransaction(
        id: 'test-id',
        name: 'Test',
        amount: 1000,
        currency: 'EUR',
        type: TransactionType.expense,
        accountId: 'account-1',
        recurrenceDays: 30,
        nextExecutionDate: now,
        createdAt: now,
      );

      when(
        mockRepository.getAutomaticTransactionById('test-id'),
      ).thenAnswer((_) async => txn);

      await useCase.execute('test-id');

      verify(
        mockRepository.updateAutomaticTransaction(
          argThat(
            predicate<AutomaticTransaction>(
              (updatedTxn) =>
                  updatedTxn.isDeleted == true &&
                  updatedTxn.isActive == false &&
                  updatedTxn.deletedAt != null,
            ),
          ),
        ),
      ).called(1);
    },
  );
}
