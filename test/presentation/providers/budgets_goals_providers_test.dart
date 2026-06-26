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

class FakeBudgetRepository implements IBudgetRepository {
  int insertCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

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
  Future<List<Budget>> getBudgets() async => [];

  @override
  Stream<List<Budget>> watchBudgets() => const Stream.empty();

  @override
  Future<Budget?> getBudgetById(String id) async => null;

  @override
  Future<List<Budget>> getBudgetsByCategoryId(String categoryId) async => [];
}

class FakeSavingsGoalRepository implements ISavingsGoalRepository {
  int insertCount = 0;
  int updateCount = 0;
  int deleteCount = 0;

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
  Future<List<SavingsGoal>> getSavingsGoals() async => [];

  @override
  Stream<List<SavingsGoal>> watchSavingsGoals() => const Stream.empty();

  @override
  Future<SavingsGoal?> getSavingsGoalById(String id) async => null;
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

void main() {
  late FakeBudgetRepository fakeBudgetRepository;
  late FakeSavingsGoalRepository fakeSavingsGoalRepository;
  late FakeCategoryRepository fakeCategoryRepository;
  late ProviderContainer container;

  setUp(() {
    fakeBudgetRepository = FakeBudgetRepository();
    fakeSavingsGoalRepository = FakeSavingsGoalRepository();
    fakeCategoryRepository = FakeCategoryRepository();

    container = ProviderContainer(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(fakeBudgetRepository),
        savingsGoalRepositoryProvider
            .overrideWithValue(fakeSavingsGoalRepository),
        categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
      ],
    );
  });

  group('BudgetsNotifier', () {
    test('createBudget success', () async {
      final params = CreateBudgetParams(
        id: '1',
        accountId: 'account1',
        categoryId: 'cat1',
        targetAmount: 10000,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      final notifier = container.read(budgetsNotifierProvider.notifier);
      await notifier.createBudget(params);

      expect(fakeBudgetRepository.insertCount, 1);
    });

    test('updateBudget success', () async {
      final budget = Budget(
        id: '1',
        accountId: 'account1',
        categoryId: 'cat1',
        targetAmount: 10000,
        currentAmount: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final notifier = container.read(budgetsNotifierProvider.notifier);
      await notifier.updateBudget(budget);

      expect(fakeBudgetRepository.updateCount, 1);
    });

    test('deleteBudget success', () async {
      final notifier = container.read(budgetsNotifierProvider.notifier);
      await notifier.deleteBudget('1');

      expect(fakeBudgetRepository.deleteCount, 1);
    });
  });

  group('SavingsGoalsNotifier', () {
    test('createSavingsGoal success', () async {
      const params = CreateSavingsGoalParams(
        id: '1',
        name: 'Goal 1',
        targetAmount: 10000,
        currency: 'EUR',
        color: '#FFFFFF',
        icon: 'icon',
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);
      await notifier.createSavingsGoal(params);

      expect(fakeSavingsGoalRepository.insertCount, 1);
    });

    test('updateSavingsGoal success', () async {
      final goal = SavingsGoal(
        id: '1',
        name: 'Goal 1',
        targetAmount: 10000,
        currentAmount: 0,
        currency: 'EUR',
        color: '#FFFFFF',
        icon: 'icon',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final notifier = container.read(savingsGoalsNotifierProvider.notifier);
      await notifier.updateSavingsGoal(goal);

      expect(fakeSavingsGoalRepository.updateCount, 1);
    });

    test('deleteSavingsGoal success', () async {
      final notifier = container.read(savingsGoalsNotifierProvider.notifier);
      await notifier.deleteSavingsGoal('1');

      expect(fakeSavingsGoalRepository.deleteCount, 1);
    });
  });
}
