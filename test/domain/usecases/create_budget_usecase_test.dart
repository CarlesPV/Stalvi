import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/budget.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/domain/repositories/i_budget_repository.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';
import 'package:konta/domain/usecases/create_budget_usecase.dart';

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class FakeBudget extends Fake implements Budget {}

void main() {
  late CreateBudgetUseCase usecase;
  late MockBudgetRepository mockBudgetRepo;
  late MockCategoryRepository mockCategoryRepo;

  final now = DateTime.now();

  setUpAll(() {
    registerFallbackValue(FakeBudget());
  });

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockCategoryRepo = MockCategoryRepository();
    usecase = CreateBudgetUseCase(mockBudgetRepo, mockCategoryRepo);
  });

  final validCategory = Category(
    id: 'cat_1',
    name: 'Food',
    associatedType: CategoryType.expense,
    icon: 'food',
    color: 'red',
    createdAt: now,
    modifiedAt: now,
  );

  final validParams = CreateBudgetParams(
    id: 'budget_1',
    categoryId: 'cat_1',
    targetAmount: 50000,
    startDate: now,
    endDate: now.add(const Duration(days: 30)),
  );

  group('CreateBudgetUseCase', () {
    test('should successfully create budget', () async {
      when(() => mockCategoryRepo.getCategoryById(any()))
          .thenAnswer((_) async => validCategory);
      when(() => mockBudgetRepo.createBudget(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as Budget);

      final result = await usecase.execute(validParams);

      expect(result.id, validParams.id);
      expect(result.targetAmount, validParams.targetAmount);
      verify(() => mockBudgetRepo.createBudget(any())).called(1);
    });

    test('should throw validation error when target amount is 0', () async {
      final params = CreateBudgetParams(
        id: 'budget_1',
        categoryId: 'cat_1',
        targetAmount: 0,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      final call = usecase.execute(params);
      await expectLater(
        () => call,
        throwsA(
          isA<ValidationException>()
              .having((e) => e.code, 'code', 'INVALID_AMOUNT'),
        ),
      );
    });

    test('should throw validation error when end date is before start date',
        () async {
      final params = CreateBudgetParams(
        id: 'budget_1',
        categoryId: 'cat_1',
        targetAmount: 50000,
        startDate: now,
        endDate: now.subtract(const Duration(days: 1)),
      );

      final call = usecase.execute(params);
      await expectLater(
        () => call,
        throwsA(
          isA<ValidationException>()
              .having((e) => e.code, 'code', 'INVALID_DATES'),
        ),
      );
    });

    test('should throw not found error when category does not exist', () async {
      when(() => mockCategoryRepo.getCategoryById(any()))
          .thenAnswer((_) async => null);

      final call = usecase.execute(validParams);
      await expectLater(() => call, throwsA(isA<NotFoundException>()));
    });
  });
}
