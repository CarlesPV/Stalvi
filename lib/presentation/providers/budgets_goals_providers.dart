import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/domain/usecases/create_budget_usecase.dart';
import 'package:stalvi/domain/usecases/create_savings_goal_usecase.dart';
import 'package:stalvi/domain/usecases/update_budget_usecase.dart';
import 'package:stalvi/domain/usecases/update_savings_goal_usecase.dart';

class BudgetsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

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

  Future<void> updateBudget(UpdateBudgetParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      final useCase = UpdateBudgetUseCase(repo);
      await useCase.execute(params);
    });
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.deleteBudget(id);
    });
  }
}

class SavingsGoalsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createSavingsGoal(CreateSavingsGoalParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      final useCase = CreateSavingsGoalUseCase(repo);
      await useCase.execute(params);
    });
  }

  Future<void> updateSavingsGoal(UpdateSavingsGoalParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      final useCase = UpdateSavingsGoalUseCase(repo);
      await useCase.execute(params);
    });
  }

  Future<void> deleteSavingsGoal(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(savingsGoalRepositoryProvider);
      await repo.deleteSavingsGoal(id);
    });
  }
}

final budgetsNotifierProvider = AsyncNotifierProvider<BudgetsNotifier, void>(
  BudgetsNotifier.new,
);

final savingsGoalsNotifierProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, void>(
  SavingsGoalsNotifier.new,
);
