import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_trash_repository.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTrashRepository extends Mock implements ITrashRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockUpdateBudgetProgressUseCase extends Mock
    implements UpdateBudgetProgressUseCase {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late TrashUsecases trashUsecases;
  late MockTrashRepository mockTrashRepo;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockUpdateBudgetProgressUseCase mockUpdateBudgetProgressUseCase;

  setUpAll(() {
    // Register fallback values for enum types used with any() in mocktail.
    registerFallbackValue(TrashItemType.transaction);
  });

  setUp(() {
    mockTrashRepo = MockTrashRepository();
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockUpdateBudgetProgressUseCase = MockUpdateBudgetProgressUseCase();
    trashUsecases = TrashUsecases(
      mockTrashRepo,
      mockTransactionRepo,
      mockAccountRepo,
      mockUpdateBudgetProgressUseCase,
    );
  });

  group('TrashUsecases', () {
    // ── getTrashItems ──────────────────────────────────────────────────────
    group('getTrashItems', () {
      test('delegates to ITrashRepository', () async {
        final items = [
          TrashItem(
            id: 'txn_1',
            name: 'Transaction (10.00)',
            type: TrashItemType.transaction,
            daysRemaining: 15,
            deletedAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];
        when(() => mockTrashRepo.getTrashItems())
            .thenAnswer((_) async => items);

        final result = await trashUsecases.getTrashItems();

        expect(result, items);
        verify(() => mockTrashRepo.getTrashItems()).called(1);
      });
    });

    // ── restoreItem — transaction ─────────────────────────────────────────
    group('restoreItem — transaction', () {
      test('routes to transactionRepository.restoreTransaction', () async {
        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById(any()))
            .thenAnswer((_) async => null);

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        verify(() => mockTransactionRepo.restoreTransaction('txn_1')).called(1);
        verifyZeroInteractions(mockTrashRepo);
        verifyZeroInteractions(mockAccountRepo);
      });

      test('does NOT call trashRepo.restoreItem for transactions', () async {
        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById(any()))
            .thenAnswer((_) async => null);

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        verifyNever(
          () => mockTrashRepo.restoreItem('txn_1', TrashItemType.transaction),
        );
      });
    });

    // ── restoreItem — non-transaction types ───────────────────────────────
    group('restoreItem — other types', () {
      for (final type in [
        TrashItemType.category,
        TrashItemType.account,
        TrashItemType.budget,
      ]) {
        test('routes ${type.name} to trashRepo.restoreItem', () async {
          when(() => mockTrashRepo.restoreItem(any(), type))
              .thenAnswer((_) async {});

          await trashUsecases.restoreItem('item_1', type);

          verify(() => mockTrashRepo.restoreItem('item_1', type)).called(1);
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        });
      }
    });

    // ── deleteItemPermanently — transaction ───────────────────────────────
    group('deleteItemPermanently — transaction', () {
      test(
          'routes to transactionRepository.hardDeleteTransaction (includes mirror)',
          () async {
        when(() => mockTransactionRepo.hardDeleteTransaction('txn_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'txn_1',
          TrashItemType.transaction,
        );

        verify(() => mockTransactionRepo.hardDeleteTransaction('txn_1'))
            .called(1);
        verifyZeroInteractions(mockTrashRepo);
        verifyZeroInteractions(mockAccountRepo);
      });

      test('does NOT call trashRepo.deleteItemPermanently for transactions',
          () async {
        when(() => mockTransactionRepo.hardDeleteTransaction('txn_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'txn_1',
          TrashItemType.transaction,
        );

        verifyNever(
          () => mockTrashRepo.deleteItemPermanently(
            'txn_1',
            TrashItemType.transaction,
          ),
        );
      });
    });

    // ── deleteItemPermanently — account (cascade) ─────────────────────────
    group('deleteItemPermanently — account', () {
      test(
          'routes to accountRepository.hardDeleteAccount (cascades transactions)',
          () async {
        when(() => mockAccountRepo.hardDeleteAccount('account_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'account_1',
          TrashItemType.account,
        );

        verify(() => mockAccountRepo.hardDeleteAccount('account_1')).called(1);
        verifyZeroInteractions(mockTrashRepo);
        verifyZeroInteractions(mockTransactionRepo);
      });

      test('does NOT call trashRepo.deleteItemPermanently for accounts',
          () async {
        when(() => mockAccountRepo.hardDeleteAccount('account_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'account_1',
          TrashItemType.account,
        );

        verifyNever(
          () => mockTrashRepo.deleteItemPermanently(
            'account_1',
            TrashItemType.account,
          ),
        );
      });
    });

    // ── deleteItemPermanently — other types ───────────────────────────────
    group('deleteItemPermanently — other types', () {
      for (final type in [
        TrashItemType.category,
        TrashItemType.budget,
        TrashItemType.savingsGoal,
      ]) {
        test('routes ${type.name} to trashRepo.deleteItemPermanently',
            () async {
          when(() => mockTrashRepo.deleteItemPermanently('item_1', type))
              .thenAnswer((_) async {});

          await trashUsecases.deleteItemPermanently('item_1', type);

          verify(() => mockTrashRepo.deleteItemPermanently('item_1', type))
              .called(1);
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        });
      }
    });
  });
}
