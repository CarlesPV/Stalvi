import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/repositories/i_automatic_transaction_repository.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/delete_and_reassign_category_usecase.dart';

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

class MockAutomaticTransactionRepository extends Mock
    implements IAutomaticTransactionRepository {}

class FakeTransaction extends Fake implements Transaction {
  @override
  final String id;
  @override
  final String? categoryId;

  FakeTransaction({required this.id, this.categoryId});

  @override
  Transaction copyWith({
    String? id,
    int? amount,
    DateTime? date,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    String? savingsGoalId,
    String? notes,
    String? originalCurrency,
    int? convertedAmount,
    double? exchangeRate,
    String? exchangeRateSnapshot,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? transferId,
    bool clearTransferId = false,
    String? parentRecurringId,
    bool clearParentRecurringId = false,
    DateTime? expectedExecutionDate,
    bool clearExpectedExecutionDate = false,
  }) {
    return FakeTransaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class FakeTransactionQueryFilter extends Fake
    implements TransactionQueryFilter {}

void main() {
  late MockCategoryRepository mockCategoryRepo;
  late MockTransactionRepository mockTransactionRepo;
  late MockAutomaticTransactionRepository mockAutomaticTransactionRepo;
  late DeleteAndReassignCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
    registerFallbackValue(FakeTransaction(id: 'dummy'));
  });

  setUp(() {
    mockCategoryRepo = MockCategoryRepository();
    mockTransactionRepo = MockTransactionRepository();
    mockAutomaticTransactionRepo = MockAutomaticTransactionRepository();
    useCase = DeleteAndReassignCategoryUseCase(
      mockCategoryRepo,
      mockTransactionRepo,
      mockAutomaticTransactionRepo,
    );
  });

  group('DeleteAndReassignCategoryUseCase', () {
    test(
        'isCategoryInUse throws CategoryInUseByAutomaticTransactionException if in use by auto tx',
        () async {
      final autoTx = AutomaticTransaction(
        id: '1',
        name: 'Auto',
        amount: 100,
        currency: 'USD',
        type: TransactionType.expense,
        accountId: 'acc1',
        categoryId: 'cat1',
        recurrenceDays: 30,
        nextExecutionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      when(() => mockAutomaticTransactionRepo.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([autoTx]));

      expect(
        () => useCase.isCategoryInUse('cat1'),
        throwsA(isA<CategoryInUseByAutomaticTransactionException>()),
      );
    });

    test('isCategoryInUse returns true when transactions exist', () async {
      when(() => mockAutomaticTransactionRepo.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockTransactionRepo.watchFilteredTransactions(any()))
          .thenAnswer(
        (_) => Stream.value([
          FakeTransaction(id: '1', categoryId: 'cat1'),
        ]),
      );

      final result = await useCase.isCategoryInUse('cat1');
      expect(result, isTrue);
    });

    test('isCategoryInUse returns false when no transactions exist', () async {
      when(() => mockAutomaticTransactionRepo.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockTransactionRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([]));

      final result = await useCase.isCategoryInUse('cat1');
      expect(result, isFalse);
    });

    test('execute throws ArgumentError when old and new categories are same',
        () async {
      expect(
        () => useCase.execute(oldCategoryId: 'cat1', newCategoryId: 'cat1'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('execute reassigns transactions and deletes old category', () async {
      final tx1 = FakeTransaction(id: 'tx1', categoryId: 'oldCat');
      final tx2 = FakeTransaction(id: 'tx2', categoryId: 'oldCat');

      when(() => mockTransactionRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([tx1, tx2]));

      when(() => mockTransactionRepo.updateTransaction(any()))
          .thenAnswer((_) async => tx1);

      when(() => mockAutomaticTransactionRepo.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([]));

      when(() => mockCategoryRepo.deleteCategory('oldCat'))
          .thenAnswer((_) async {});

      await useCase.execute(oldCategoryId: 'oldCat', newCategoryId: 'newCat');

      verify(
        () => mockTransactionRepo.updateTransaction(
          any(
            that: predicate<Transaction>((tx) => tx.categoryId == 'newCat'),
          ),
        ),
      ).called(2);
      verify(() => mockCategoryRepo.deleteCategory('oldCat')).called(1);
    });

    test('getReplacementCategories returns correct filtered list', () async {
      final now = DateTime.now();
      final catIncome = Category(
        id: 'inc1',
        name: 'Income',
        associatedType: CategoryType.income,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catExpense = Category(
        id: 'exp1',
        name: 'Expense',
        associatedType: CategoryType.expense,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catCustom = Category(
        id: 'cus1',
        name: 'Custom',
        associatedType: null,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );
      final catCustom2 = Category(
        id: 'cus2',
        name: 'Custom2',
        associatedType: null,
        icon: 'icon',
        color: 'color',
        createdAt: now,
        modifiedAt: now,
      );

      when(() => mockCategoryRepo.watchAllCategories()).thenAnswer(
        (_) => Stream.value([catIncome, catExpense, catCustom, catCustom2]),
      );

      // Deleting income category should return other income cats + custom cats
      final replacementsIncome =
          await useCase.getReplacementCategories(catIncome);
      expect(replacementsIncome.map((c) => c.id).toList(), ['cus1', 'cus2']);

      // Deleting custom category should return ALL other categories
      final replacementsCustom =
          await useCase.getReplacementCategories(catCustom);
      expect(
        replacementsCustom.map((c) => c.id).toList(),
        ['inc1', 'exp1', 'cus2'],
      );
    });
  });
}
