import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/repositories/i_account_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/repositories/i_trash_repository.dart';
import 'package:stalvi/domain/usecases/trash_usecases.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockTrashRepository extends Mock implements ITrashRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAccountRepository extends Mock implements IAccountRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

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
  late MockCategoryRepository mockCategoryRepo;
  late MockProfileRepository mockProfileRepo;
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
    mockCategoryRepo = MockCategoryRepository();
    mockProfileRepo = MockProfileRepository();
    trashUsecases = TrashUsecases(
      mockTrashRepo,
      mockTransactionRepo,
      mockAccountRepo,
      mockCategoryRepo,
      mockProfileRepo,
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
        when(
          () => mockTrashRepo.getTrashItems(),
        ).thenAnswer((_) async => items);

        final result = await trashUsecases.getTrashItems();

        expect(result, items);
        verify(() => mockTrashRepo.getTrashItems()).called(1);
      });
    });

    // ── restoreItem — transaction ─────────────────────────────────────────
    group('restoreItem — transaction', () {
      final dummyTxn = Transaction(
        id: 'txn_1',
        accountId: 'acc_1',
        categoryId: 'cat_1',
        type: TransactionType.expense,
        amount: 1000,
        originalCurrency: 'EUR',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final dummyAccount = Account(
        id: 'acc_1',
        userId: 'usr_1',
        name: 'Main',
        type: AccountType.bank,
        initialBalance: 0,
        currency: 'EUR',
        color: '#000000',
        icon: 'icon',
        isDefault: false,
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final dummyCategory = Category(
        id: 'cat_1',
        name: 'Food',
        icon: 'icon',
        color: 'color',
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      setUp(() {
        registerFallbackValue(dummyTxn);
      });

      test(
          'routes to transactionRepository.restoreTransaction with no updates if account and category are intact',
          () async {
        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById('txn_1'))
            .thenAnswer((_) async => dummyTxn);
        when(() => mockAccountRepo.getAccountById('acc_1'))
            .thenAnswer((_) async => dummyAccount);
        when(() => mockCategoryRepo.getCategoryById('cat_1'))
            .thenAnswer((_) async => dummyCategory);
        when(
          () => mockUpdateBudgetProgressUseCase.execute(
            transaction: any(named: 'transaction'),
          ),
        ).thenAnswer((_) async {});

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        verify(() => mockTransactionRepo.restoreTransaction('txn_1')).called(1);
        verifyNever(() => mockTransactionRepo.updateTransaction(any()));
        verifyZeroInteractions(mockTrashRepo);
      });

      test('does NOT call trashRepo.restoreItem for transactions', () async {
        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById('txn_1'))
            .thenAnswer((_) async => dummyTxn);
        when(() => mockAccountRepo.getAccountById('acc_1'))
            .thenAnswer((_) async => dummyAccount);
        when(() => mockCategoryRepo.getCategoryById('cat_1'))
            .thenAnswer((_) async => dummyCategory);
        when(
          () => mockUpdateBudgetProgressUseCase.execute(
            transaction: any(named: 'transaction'),
          ),
        ).thenAnswer((_) async {});

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        verifyNever(
          () => mockTrashRepo.restoreItem('txn_1', TrashItemType.transaction),
        );
      });

      test('falls back to default account if original account is deleted',
          () async {
        final deletedAccount = dummyAccount.copyWith(isDeleted: true);
        final defaultAccount = dummyAccount.copyWith(id: 'acc_default');
        final profile = Profile(
          id: 'usr_1',
          name: 'Test',
          username: 'test',
          password: 'pw',
          defaultCurrency: 'EUR',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        );

        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById('txn_1'))
            .thenAnswer((_) async => dummyTxn);
        when(() => mockTransactionRepo.updateTransaction(any()))
            .thenAnswer((_) async => dummyTxn);
        when(() => mockAccountRepo.getAccountById('acc_1'))
            .thenAnswer((_) async => deletedAccount);
        when(() => mockProfileRepo.getFirstProfile())
            .thenAnswer((_) async => profile);
        when(() => mockAccountRepo.getDefaultAccount('usr_1'))
            .thenAnswer((_) async => defaultAccount);
        when(() => mockCategoryRepo.getCategoryById('cat_1'))
            .thenAnswer((_) async => dummyCategory);
        when(
          () => mockUpdateBudgetProgressUseCase.execute(
            transaction: any(named: 'transaction'),
          ),
        ).thenAnswer((_) async {});

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        final updateCapture =
            verify(() => mockTransactionRepo.updateTransaction(captureAny()))
                .captured
                .first as Transaction;
        expect(updateCapture.accountId, 'acc_default');
        verify(() => mockTransactionRepo.restoreTransaction('txn_1')).called(1);
      });

      test(
          'falls back to appropriate category type if original category is deleted',
          () async {
        final expenseTxn = dummyTxn.copyWith(
          categoryId: 'cat_1',
          type: TransactionType.expense,
        );
        final deletedCategory = dummyCategory.copyWith(isDeleted: true);

        final expenseCategory = Category(
          id: 'cat_exp',
          name: 'Exp',
          associatedType: CategoryType.expense,
          icon: 'icon',
          color: 'color',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        );
        final incomeCategory = Category(
          id: 'cat_inc',
          name: 'Inc',
          associatedType: CategoryType.income,
          icon: 'icon',
          color: 'color',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        );

        when(() => mockTransactionRepo.restoreTransaction(any()))
            .thenAnswer((_) async {});
        when(() => mockTransactionRepo.getTransactionById('txn_1'))
            .thenAnswer((_) async => expenseTxn);
        when(() => mockTransactionRepo.updateTransaction(any()))
            .thenAnswer((_) async => expenseTxn);
        when(() => mockAccountRepo.getAccountById('acc_1'))
            .thenAnswer((_) async => dummyAccount);

        when(() => mockCategoryRepo.getCategoryById('cat_1'))
            .thenAnswer((_) async => deletedCategory);
        when(() => mockCategoryRepo.getAllCategories())
            .thenAnswer((_) async => [incomeCategory, expenseCategory]);
        when(
          () => mockUpdateBudgetProgressUseCase.execute(
            transaction: any(named: 'transaction'),
          ),
        ).thenAnswer((_) async {});

        await trashUsecases.restoreItem('txn_1', TrashItemType.transaction);

        final updateCapture =
            verify(() => mockTransactionRepo.updateTransaction(captureAny()))
                .captured
                .first as Transaction;
        expect(updateCapture.categoryId, 'cat_exp');
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
          when(
            () => mockTrashRepo.restoreItem(any(), type),
          ).thenAnswer((_) async {});

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
          when(
            () => mockTransactionRepo.hardDeleteTransaction('txn_1'),
          ).thenAnswer((_) async {});

          await trashUsecases.deleteItemPermanently(
            'txn_1',
            TrashItemType.transaction,
          );

          verify(
            () => mockTransactionRepo.hardDeleteTransaction('txn_1'),
          ).called(1);
          verifyZeroInteractions(mockTrashRepo);
          verifyZeroInteractions(mockAccountRepo);
        },
      );

      test(
        'does NOT call trashRepo.deleteItemPermanently for transactions',
        () async {
          when(
            () => mockTransactionRepo.hardDeleteTransaction('txn_1'),
          ).thenAnswer((_) async {});

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
        },
      );
    });

    // ── deleteItemPermanently — account (cascade) ─────────────────────────
    group('deleteItemPermanently — account', () {
      test(
        'routes to accountRepository.hardDeleteAccount (cascades transactions)',
        () async {
          when(
            () => mockAccountRepo.hardDeleteAccount('account_1'),
          ).thenAnswer((_) async {});

          await trashUsecases.deleteItemPermanently(
            'account_1',
            TrashItemType.account,
          );

          verify(
            () => mockAccountRepo.hardDeleteAccount('account_1'),
          ).called(1);
          verifyZeroInteractions(mockTrashRepo);
          verifyZeroInteractions(mockTransactionRepo);
        },
      );

      test(
        'does NOT call trashRepo.deleteItemPermanently for accounts',
        () async {
          when(
            () => mockAccountRepo.hardDeleteAccount('account_1'),
          ).thenAnswer((_) async {});

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
        },
      );
    });

    // ── deleteItemPermanently — other types ───────────────────────────────
    group('deleteItemPermanently — other types', () {
      for (final type in [
        TrashItemType.category,
        TrashItemType.budget,
        TrashItemType.savingsGoal,
      ]) {
        test(
          'routes ${type.name} to trashRepo.deleteItemPermanently',
          () async {
            when(
              () => mockTrashRepo.deleteItemPermanently('item_1', type),
            ).thenAnswer((_) async {});

            await trashUsecases.deleteItemPermanently('item_1', type);

            verify(
              () => mockTrashRepo.deleteItemPermanently('item_1', type),
            ).called(1);
            verifyZeroInteractions(mockTransactionRepo);
            verifyZeroInteractions(mockAccountRepo);
          },
        );
      }
    });
  });
}
