import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/domain/usecases/delete_and_reassign_category_usecase.dart';

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockTransactionRepository extends Mock
    implements ITransactionRepository {}

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
    String? notes,
    String? originalCurrency,
    int? convertedAmount,
    double? exchangeRate,
    DateTime? createdAt,
    DateTime? modifiedAt,
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
  late DeleteAndReassignCategoryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTransactionQueryFilter());
    registerFallbackValue(FakeTransaction(id: 'dummy'));
  });

  setUp(() {
    mockCategoryRepo = MockCategoryRepository();
    mockTransactionRepo = MockTransactionRepository();
    useCase =
        DeleteAndReassignCategoryUseCase(mockCategoryRepo, mockTransactionRepo);
  });

  group('DeleteAndReassignCategoryUseCase', () {
    test('isCategoryInUse returns true when transactions exist', () async {
      when(() => mockTransactionRepo.watchFilteredTransactions(any()))
          .thenAnswer((_) => Stream.value([
                FakeTransaction(id: '1', categoryId: 'cat1'),
              ]));

      final result = await useCase.isCategoryInUse('cat1');
      expect(result, isTrue);
    });

    test('isCategoryInUse returns false when no transactions exist', () async {
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

      when(() => mockCategoryRepo.deleteCategory('oldCat'))
          .thenAnswer((_) async {});

      await useCase.execute(oldCategoryId: 'oldCat', newCategoryId: 'newCat');

      verify(() => mockTransactionRepo.updateTransaction(any(
              that: predicate<Transaction>((tx) => tx.categoryId == 'newCat'))))
          .called(2);
      verify(() => mockCategoryRepo.deleteCategory('oldCat')).called(1);
    });
  });
}
