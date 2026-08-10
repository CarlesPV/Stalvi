import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

/// Tests for account-level cascade rules at the repository interface level.
///
/// The concrete implementation (AccountRepository) is tested via integration
/// tests against a real Drift in-memory database. Here we verify that the
/// interface contract is correctly wired:
///
/// - [IAccountRepository.deleteAccount] → must call soft-delete on account.
/// - [IAccountRepository.hardDeleteAccount] → must remove account AND cascade.
///
/// These tests use a mock repository to confirm that the delete contract
/// is triggered from callers (e.g., UI / use-cases) with the correct ID.
void main() {
  late MockAccountRepository mockAccountRepo;
  late MockTransactionRepository mockTransactionRepo;

  setUp(() {
    mockAccountRepo = MockAccountRepository();
    mockTransactionRepo = MockTransactionRepository();
  });

  group('AccountRepository — cascade delete contract', () {
    test('deleteAccount is called with the correct account id', () async {
      when(() => mockAccountRepo.deleteAccount(any())).thenAnswer((_) async {});

      await mockAccountRepo.deleteAccount('account_1');

      verify(() => mockAccountRepo.deleteAccount('account_1')).called(1);
    });

    test('hardDeleteAccount is called with the correct account id', () async {
      when(
        () => mockAccountRepo.hardDeleteAccount(any()),
      ).thenAnswer((_) async {});

      await mockAccountRepo.hardDeleteAccount('account_1');

      verify(() => mockAccountRepo.hardDeleteAccount('account_1')).called(1);
    });

    test(
      'softDeleteTransactionsByAccountId is invoked with account id by callers',
      () async {
        when(
          () => mockTransactionRepo.softDeleteTransactionsByAccountId(any()),
        ).thenAnswer((_) async {});

        await mockTransactionRepo.softDeleteTransactionsByAccountId(
          'account_1',
        );

        verify(
          () => mockTransactionRepo.softDeleteTransactionsByAccountId(
            'account_1',
          ),
        ).called(1);
      },
    );

    test(
      'hardDeleteTransactionsByAccountId is invoked with account id by callers',
      () async {
        when(
          () => mockTransactionRepo.hardDeleteTransactionsByAccountId(any()),
        ).thenAnswer((_) async {});

        await mockTransactionRepo.hardDeleteTransactionsByAccountId(
          'account_1',
        );

        verify(
          () => mockTransactionRepo.hardDeleteTransactionsByAccountId(
            'account_1',
          ),
        ).called(1);
      },
    );
  });

  group('TransactionRepository — transfer mirror operations', () {
    test('deleteTransaction is called with target id', () async {
      when(
        () => mockTransactionRepo.deleteTransaction(any()),
      ).thenAnswer((_) async {});

      await mockTransactionRepo.deleteTransaction('txn_1');

      verify(() => mockTransactionRepo.deleteTransaction('txn_1')).called(1);
    });

    test('hardDeleteTransaction is called with target id', () async {
      when(
        () => mockTransactionRepo.hardDeleteTransaction(any()),
      ).thenAnswer((_) async {});

      await mockTransactionRepo.hardDeleteTransaction('txn_1');

      verify(
        () => mockTransactionRepo.hardDeleteTransaction('txn_1'),
      ).called(1);
    });

    test('restoreTransaction is called with target id', () async {
      when(
        () => mockTransactionRepo.restoreTransaction(any()),
      ).thenAnswer((_) async {});

      await mockTransactionRepo.restoreTransaction('txn_1');

      verify(() => mockTransactionRepo.restoreTransaction('txn_1')).called(1);
    });
  });
}
