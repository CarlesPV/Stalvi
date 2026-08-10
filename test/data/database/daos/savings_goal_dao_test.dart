import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/savings_goal_dao.dart';

void main() {
  late AppDatabase database;
  late SavingsGoalDao dao;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SavingsGoalDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'createSavingsGoal and getSavingsGoals ignores soft-deleted items',
    () async {
      final now = DateTime.now();
      await dao.createSavingsGoal(
        SavingsGoalsCompanion.insert(
          id: 's1',
          name: 'Goal',
          targetAmount: 10000,
          color: '#000',
          icon: 'icon',
          createdAt: now,
          modifiedAt: now,
        ),
      );

      final goals = await dao.getSavingsGoals();
      expect(goals.length, 1);
      expect(goals.first.id, 's1');

      await dao.softDelete('s1');

      final afterDelete = await dao.getSavingsGoals();
      expect(afterDelete.isEmpty, isTrue);
    },
  );

  test('getSavingsGoalById ignores soft-deleted items', () async {
    final now = DateTime.now();
    await dao.createSavingsGoal(
      SavingsGoalsCompanion.insert(
        id: 's2',
        name: 'Goal2',
        targetAmount: 10000,
        color: '#000',
        icon: 'icon',
        createdAt: now,
        modifiedAt: now,
      ),
    );

    final s = await dao.getSavingsGoalById('s2');
    expect(s, isNotNull);

    await dao.softDelete('s2');

    final after = await dao.getSavingsGoalById('s2');
    expect(after, isNull);
  });
}
