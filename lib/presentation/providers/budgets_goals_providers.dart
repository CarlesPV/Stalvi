import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/domain/usecases/create_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_usecase.dart';
import 'package:stalvi/domain/usecases/update_savings_goal_usecase.dart';

/// A [Notifier] that manages budget mutation operations (creation, update, deletion).
///
/// Exposes async methods to interact with the underlying data repository and triggers
/// state changes accordingly.
class BudgetsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Executes the [CreateBudgetUseCase] to save a new budget.
  Future<void> createBudget(CreateBudgetParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final updateProgressUseCase =
          ref.read(updateBudgetProgressUseCaseProvider);
      final useCase =
          CreateBudgetUseCase(repo, categoryRepo, updateProgressUseCase);
      await useCase.execute(params);
    });
  }

  /// Executes the [UpdateBudgetUseCase] to modify an existing budget.
  Future<void> updateBudget(UpdateBudgetParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      final useCase = UpdateBudgetUseCase(repo);
      await useCase.execute(params);
    });
  }

  /// Deletes a budget by its unique identifier [id].
  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteBudget(id);
    });
  }
}

/// A [Notifier] that manages savings goals mutation operations (creation, update, deletion).
///
/// Exposes async methods to interact with the underlying data repository and triggers
/// state changes accordingly.
class SavingsGoalsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Executes the [CreateSavingsGoalUseCase] to save a new savings goal.
  Future<void> createSavingsGoal(CreateSavingsGoalParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      final useCase = CreateSavingsGoalUseCase(repo);
      await useCase.execute(params);
    });
  }

  /// Executes the [UpdateSavingsGoalUseCase] to modify an existing savings goal.
  Future<void> updateSavingsGoal(UpdateSavingsGoalParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      final useCase = UpdateSavingsGoalUseCase(repo);
      await useCase.execute(params);
    });
  }

  /// Deletes a savings goal by its unique identifier [id].
  Future<void> deleteSavingsGoal(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      await repo.deleteSavingsGoal(id);
    });
  }
}

/// Global provider for the [BudgetsNotifier] state.
final budgetsNotifierProvider = AsyncNotifierProvider<BudgetsNotifier, void>(
  BudgetsNotifier.new,
);

/// Global provider for the [SavingsGoalsNotifier] state.
final savingsGoalsNotifierProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, void>(
  SavingsGoalsNotifier.new,
);
