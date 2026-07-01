import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/data/database/daos/trash_dao.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/data/database/daos/savings_goal_dao.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTrashDao extends Mock implements TrashDao {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockSavingsGoalDao extends Mock implements SavingsGoalDao {}

class MockUpdateBudgetProgressUseCase extends Mock
    implements UpdateBudgetProgressUseCase {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late TrashUsecases trashUsecases;
  late MockTrashDao mockTrashDao;
  late MockTransactionRepository mockTransactionRepo;
  late MockAccountRepository mockAccountRepo;
  late MockSavingsGoalDao mockSavingsGoalDao;
  late MockUpdateBudgetProgressUseCase mockUpdateBudgetProgressUseCase;

  setUpAll(() {
    // Register fallback values for enum types used with any() in mocktail.
    registerFallbackValue(TrashItemType.transaction);
  });

  setUp(() {
    mockTrashDao = MockTrashDao();
    mockTransactionRepo = MockTransactionRepository();
    mockAccountRepo = MockAccountRepository();
    mockSavingsGoalDao = MockSavingsGoalDao();
    mockUpdateBudgetProgressUseCase = MockUpdateBudgetProgressUseCase();
    trashUsecases = TrashUsecases(
      mockTrashDao,
      mockTransactionRepo,
      mockAccountRepo,
      mockUpdateBudgetProgressUseCase,
      mockSavingsGoalDao,
    );
  });

  group('TrashUsecases', () {
    // ── getTrashItems ──────────────────────────────────────────────────────
    group('getTrashItems', () {
      test('delegates to TrashDao', () async {
        final items = [
          TrashItem(
            id: 'txn_1',
            name: 'Transaction (10.00)',
            type: TrashItemType.transaction,
            daysRemaining: 15,
            deletedAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];
        when(() => mockTrashDao.getTrashItems()).thenAnswer((_) async => items);

        final result = await trashUsecases.getTrashItems();

        expect(result, items);
        verify(() => mockTrashDao.getTrashItems()).called(1);
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
        verifyZeroInteractions(mockTrashDao);
        verifyZeroInteractions(mockAccountRepo);
      });

      test('does NOT call trashDao.restoreItem for transactions', () async {
        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById(any()))
            .thenAnswer((_) async => null);

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        verifyNever(
          () => mockTrashDao.restoreItem('txn_1', TrashItemType.transaction),
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
        test('routes ${type.name} to trashDao.restoreItem', () async {
          when(() => mockTrashDao.restoreItem(any(), type))
              .thenAnswer((_) async {});

          await trashUsecases.restoreItem('item_1', type);

          verify(() => mockTrashDao.restoreItem('item_1', type)).called(1);
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
        verifyZeroInteractions(mockTrashDao);
        verifyZeroInteractions(mockAccountRepo);
      });

      test('does NOT call trashDao.deleteItemPermanently for transactions',
          () async {
        when(() => mockTransactionRepo.hardDeleteTransaction('txn_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'txn_1',
          TrashItemType.transaction,
        );

        verifyNever(
          () => mockTrashDao.deleteItemPermanently(
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
        verifyZeroInteractions(mockTrashDao);
        verifyZeroInteractions(mockTransactionRepo);
      });

      test('does NOT call trashDao.deleteItemPermanently for accounts',
          () async {
        when(() => mockAccountRepo.hardDeleteAccount('account_1'))
            .thenAnswer((_) async {});

        await trashUsecases.deleteItemPermanently(
          'account_1',
          TrashItemType.account,
        );

        verifyNever(
          () => mockTrashDao.deleteItemPermanently(
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
        test('routes ${type.name} to trashDao.deleteItemPermanently', () async {
          when(() => mockTrashDao.deleteItemPermanently('item_1', type))
              .thenAnswer((_) async {});

          await trashUsecases.deleteItemPermanently('item_1', type);

          verify(() => mockTrashDao.deleteItemPermanently('item_1', type))
              .called(1);
          verifyZeroInteractions(mockTransactionRepo);
          verifyZeroInteractions(mockAccountRepo);
        });
      }
    });
  });
}
