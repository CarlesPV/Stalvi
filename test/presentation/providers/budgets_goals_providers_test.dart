import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/domain/entities/budget.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/repositories/i_budget_repository.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/presentation/providers/budgets_goals_providers.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/domain/usecases/create_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_usecase.dart';
import 'package:stalvi/domain/usecases/update_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_progress_usecase.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class FakeBudgetRepository implements IBudgetRepository {
  int insertCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

  final Budget _stored = Budget(
    id: '1',
    accountId: 'account1',
    categoryId: 'cat1',
    targetAmount: 10000,
    currentAmount: 0,
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 2, 1),
    createdAt: DateTime(2024, 1, 1),
    modifiedAt: DateTime(2024, 1, 1),
  );

  @override
  Future<void> createBudget(Budget budget) async {
    insertCount++;
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    updateCount++;
  }

  @override
  Future<void> deleteBudget(String id) async {
    deleteCount++;
  }

  @override
  Future<List<Budget>> getBudgets() async => [_stored];

  @override
  Stream<List<Budget>> watchBudgets() => const Stream.empty();

  @override
  Future<Budget?> getBudgetById(String id) async =>
      id == _stored.id ? _stored : null;

  @override
  Future<List<Budget>> getBudgetsByCategoryId(String categoryId) async => [];
}

class FakeSavingsGoalRepository implements ISavingsGoalRepository {
  int insertCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

  final SavingsGoal _stored = SavingsGoal(
    id: '1',
    name: 'Goal 1',
    targetAmount: 10000,
    currentAmount: 0,
    currency: 'EUR',
    color: '#FFFFFF',
    icon: 'icon',
    createdAt: DateTime(2024, 1, 1),
    modifiedAt: DateTime(2024, 1, 1),
  );

  @override
  Future<void> createSavingsGoal(SavingsGoal goal) async {
    insertCount++;
  }

  @override
  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    updateCount++;
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    deleteCount++;
  }

  @override
  Future<List<SavingsGoal>> getSavingsGoals() async => [_stored];

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals() => const Stream.empty();

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async =>
      id == _stored.id ? _stored : null;
}

class FakeCategoryRepository implements ICategoryRepository {
  @override
  Future<Category?> getCategoryById(String id) async => Category(
        id: id,
        name: 'Test',
        icon: 'icon',
        color: '#000000',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

  @override
  Stream<List<Category>> watchAllCategories() => const Stream.empty();

  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<Category> createCategory(Category category) async => category;

  @override
  Future<Category> updateCategory(Category category) async => category;

  @override
  Future<void> deleteCategoryPermanently(String id) async {}

  @override
  Future<void> deleteCategory(String id) async {}
}

class MockUpdateBudgetProgressUseCase extends Mock
    implements UpdateBudgetProgressUseCase {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeBudgetRepository fakeBudgetRepository;
  late FakeSavingsGoalRepository fakeSavingsGoalRepository;
  late FakeCategoryRepository fakeCategoryRepository;
  late MockUpdateBudgetProgressUseCase mockUpdateBudgetProgressUseCase;
  late ProviderContainer container;

  setUp(() {
    fakeBudgetRepository = FakeBudgetRepository();
    fakeSavingsGoalRepository = FakeSavingsGoalRepository();
    fakeCategoryRepository = FakeCategoryRepository();
    mockUpdateBudgetProgressUseCase = MockUpdateBudgetProgressUseCase();

    when(
      () => mockUpdateBudgetProgressUseCase.execute(
        categoryId: any(named: 'categoryId'),
      ),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(fakeBudgetRepository),
        savingsGoalRepositoryProvider
            .overrideWithValue(fakeSavingsGoalRepository),
        categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
        updateBudgetProgressUseCaseProvider
            .overrideWithValue(mockUpdateBudgetProgressUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('BudgetsNotifier', () {
    test(
        'createBudget transitions through AsyncLoading and resolves to AsyncData',
        () async {
      final params = CreateBudgetParams(
        id: '1',
        accountId: 'account1',
        categoryId: 'cat1',
        targetAmount: 10000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      final notifier = container.read(budgetsNotifierProvider.notifier);

      // Start and collect state emissions
      final states = <AsyncValue<void>>[];
      final sub = container.listen(budgetsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.createBudget(params);
      sub.close();

      expect(fakeBudgetRepository.insertCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });

    test(
        'updateBudget transitions through AsyncLoading and resolves to AsyncData',
        () async {
      final params = UpdateBudgetParams(
        id: '1',
        categoryId: 'cat1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 1),
      );

      final notifier = container.read(budgetsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(budgetsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.updateBudget(params);
      sub.close();

      expect(fakeBudgetRepository.updateCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });

    test('updateBudget with invalid id resolves to AsyncError', () async {
      final params = UpdateBudgetParams(
        id: 'nonexistent',
        categoryId: 'cat1',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 3, 1),
      );

      final notifier = container.read(budgetsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(budgetsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.updateBudget(params);
      sub.close();

      expect(fakeBudgetRepository.updateCount, 0);
      expect(states.last, isA<AsyncError<void>>());
    });

    test(
        'deleteBudget transitions through AsyncLoading and resolves to AsyncData',
        () async {
      final notifier = container.read(budgetsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(budgetsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.deleteBudget('1');
      sub.close();

      expect(fakeBudgetRepository.deleteCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });
  });

  group('SavingsGoalsNotifier', () {
    test(
        'createSavingsGoal transitions through AsyncLoading and resolves to AsyncData',
        () async {
      const params = CreateSavingsGoalParams(
        id: '1',
        name: 'Goal 1',
        targetAmount: 10000,
        currency: 'EUR',
        color: '#FFFFFF',
        icon: 'icon',
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(savingsGoalsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.createSavingsGoal(params);
      sub.close();

      expect(fakeSavingsGoalRepository.insertCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });

    test(
        'updateSavingsGoal transitions through AsyncLoading and resolves to AsyncData',
        () async {
      const params = UpdateSavingsGoalParams(
        id: '1',
        name: 'Updated Goal',
        color: '#2196F3',
        icon: 'flight',
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(savingsGoalsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.updateSavingsGoal(params);
      sub.close();

      expect(fakeSavingsGoalRepository.updateCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });

    test('updateSavingsGoal with invalid id resolves to AsyncError', () async {
      const params = UpdateSavingsGoalParams(
        id: 'nonexistent',
        name: 'Updated Goal',
        color: '#2196F3',
        icon: 'flight',
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(savingsGoalsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.updateSavingsGoal(params);
      sub.close();

      expect(fakeSavingsGoalRepository.updateCount, 0);
      expect(states.last, isA<AsyncError<void>>());
    });

    test('updateSavingsGoal with empty name resolves to AsyncError', () async {
      const params = UpdateSavingsGoalParams(
        id: '1',
        name: '   ',
        color: '#2196F3',
        icon: 'flight',
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(savingsGoalsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.updateSavingsGoal(params);
      sub.close();

      expect(fakeSavingsGoalRepository.updateCount, 0);
      expect(states.last, isA<AsyncError<void>>());
    });

    test(
        'deleteSavingsGoal transitions through AsyncLoading and resolves to AsyncData',
        () async {
      final notifier = container.read(savingsGoalsNotifierProvider.notifier);

      final states = <AsyncValue<void>>[];
      final sub = container.listen(savingsGoalsNotifierProvider, (_, next) {
        states.add(next);
      });

      await notifier.deleteSavingsGoal('1');
      sub.close();

      expect(fakeSavingsGoalRepository.deleteCount, 1);
      expect(
        states.any((s) => s is AsyncLoading),
        isTrue,
        reason: 'Should have passed through AsyncLoading',
      );
      expect(states.last, isA<AsyncData<void>>());
    });
  });
}
