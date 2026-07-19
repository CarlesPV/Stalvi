import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/savings_goal_repository.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
// ignore: depend_onreferenced_packages

void main() {
  late AppDatabase db;
  late SavingsGoalRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SavingsGoalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SavingsGoalRepository / AppDatabase', () {
    final testGoal = SavingsGoal(
      id: 'goal-1',
      name: 'New Car',
      targetAmount: 1500000, // 15,000.00
      currentAmount: 200000, // 2,000.00
      targetDate: DateTime(2025, 12, 31),
      currency: 'EUR',
      color: 'blue',
      icon: 'car',
      createdAt: DateTime(2023, 1, 1),
      modifiedAt: DateTime(2023, 1, 1),
      isDeleted: false,
    );

    test('can create and retrieve a savings goal', () async {
      await repository.createSavingsGoal(testGoal);

      final fetched = await repository.getSavingsGoalById('goal-1');
      expect(fetched, isNotNull);
      expect(fetched?.id, testGoal.id);
      expect(fetched?.name, testGoal.name);
      expect(fetched?.targetAmount, testGoal.targetAmount);
    });

    test('soft delete hides goal from getSavingsGoals', () async {
      await repository.createSavingsGoal(testGoal);
      await repository.deleteSavingsGoal(testGoal.id);

      final goals = await repository.getSavingsGoals();
      expect(goals.isEmpty, isTrue);

      final fetched = await repository.getSavingsGoalById(testGoal.id);
      expect(fetched, isNull);
    });

    test('update goal modifies values', () async {
      await repository.createSavingsGoal(testGoal);

      final updatedGoal = testGoal.copyWith(currentAmount: 300000);
      await repository.updateSavingsGoal(updatedGoal);

      final fetched = await repository.getSavingsGoalById(testGoal.id);
      expect(fetched?.currentAmount, 300000);
    });
  });
}
