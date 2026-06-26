import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';

class MockBudgetRepository extends Mock implements IBudgetRepository {}

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockUpdateBudgetProgressUseCase extends Mock
    implements UpdateBudgetProgressUseCase {}

class FakeBudget extends Fake implements Budget {}

void main() {
  late CreateBudgetUseCase usecase;
  late MockBudgetRepository mockBudgetRepo;
  late MockCategoryRepository mockCategoryRepo;
  late MockUpdateBudgetProgressUseCase mockUpdateBudgetProgressUseCase;

  final now = DateTime.now();

  setUpAll(() {
    registerFallbackValue(FakeBudget());
  });

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockCategoryRepo = MockCategoryRepository();
    mockUpdateBudgetProgressUseCase = MockUpdateBudgetProgressUseCase();
    usecase = CreateBudgetUseCase(
      mockBudgetRepo,
      mockCategoryRepo,
      mockUpdateBudgetProgressUseCase,
    );
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
    accountId: 'account_1',
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
      when(
        () => mockUpdateBudgetProgressUseCase.execute(
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockBudgetRepo.getBudgetsByCategoryId(any()))
          .thenAnswer((_) async => []);

      final result = await usecase.execute(validParams);

      expect(result.id, validParams.id);
      expect(result.targetAmount, validParams.targetAmount);
      verify(() => mockBudgetRepo.createBudget(any())).called(1);
    });

    test('should throw validation error when target amount is 0', () async {
      final params = CreateBudgetParams(
        id: 'budget_1',
        accountId: 'account_1',
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
        accountId: 'account_1',
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
