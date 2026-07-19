import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
// ignore: depend_onreferenced_packages
import 'package:uuid/uuid.dart';
import 'package:stalvi/data/database/app_database.dart' as db_data;
import 'package:stalvi/data/repositories/account_repository.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';

void main() {
  late db_data.AppDatabase db;
  late AccountRepository repository;
  const uuid = Uuid();

  setUp(() {
    db = db_data.AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Account buildTestAccount({
    required String id,
    String name = 'Test Account',
    bool isDefault = false,
    bool isDeleted = false,
  }) {
    return Account(
      id: id,
      userId: 'test-user-id',
      name: name,
      type: AccountType.savings,
      initialBalance: 1200.0,
      currency: 'USD',
      color: '#00FF00',
      icon: 'savings',
      isDefault: isDefault,
      isDeleted: isDeleted,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  group('AccountRepository Tests', () {
    test('createAccount saves account and getAccountById retrieves it',
        () async {
      final id = uuid.v4();
      final account = buildTestAccount(id: id);

      await repository.createAccount(account);
      final retrieved = await repository.getAccountById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.name, 'Test Account');
      expect(retrieved.type, AccountType.savings);
      expect(retrieved.initialBalance, 1200.0);
    });

    test(
        'getAccountsByUserId returns only non-deleted accounts for specific user',
        () async {
      const user1 = 'user-1';
      const user2 = 'user-2';

      final acc1 = buildTestAccount(id: uuid.v4(), name: 'Acc 1')
          .copyWith(userId: user1);
      final acc2 = buildTestAccount(id: uuid.v4(), name: 'Acc 2')
          .copyWith(userId: user1);
      final accDeleted =
          buildTestAccount(id: uuid.v4(), name: 'Deleted Acc', isDeleted: true)
              .copyWith(userId: user1);
      final accOther = buildTestAccount(id: uuid.v4(), name: 'Acc Other')
          .copyWith(userId: user2);

      await repository.createAccount(acc1);
      await repository.createAccount(acc2);
      await repository.createAccount(accDeleted);
      await repository.createAccount(accOther);

      final list = await repository.getAccountsByUserId(user1);

      expect(list.length, 2);
      final names = list.map((a) => a.name).toList();
      expect(names, containsAll(['Acc 1', 'Acc 2']));
      expect(names, isNot(contains('Deleted Acc')));
      expect(names, isNot(contains('Acc Other')));
    });

    test('updateAccount correctly modifies database fields', () async {
      final id = uuid.v4();
      final account = buildTestAccount(id: id, name: 'Original Name');
      await repository.createAccount(account);

      final updated =
          account.copyWith(name: 'Updated Name', initialBalance: 5000.0);
      await repository.updateAccount(updated);

      final retrieved = await repository.getAccountById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.initialBalance, 5000.0);
    });

    test('deleteAccount soft-deletes the account record', () async {
      final id = uuid.v4();
      final account = buildTestAccount(id: id, name: 'Active Acc');
      final anotherId = uuid.v4();
      final anotherAccount =
          buildTestAccount(id: anotherId, name: 'Another Acc');

      await repository.createAccount(account);
      await repository.createAccount(anotherAccount);

      await repository.deleteAccount(id);

      final retrieved = await repository.getAccountById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.isDeleted, isTrue);
    });
  });
}
