import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/data/database/app_database.dart' as db_data;
import 'package:konta/data/repositories/account_repository.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late db_data.AppDatabase db;
  late AccountRepository repository;
  final uuid = const Uuid();

  setUp(() {
    db = db_data.AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Account _buildTestAccount({
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
    test('createAccount saves account and getAccountById retrieves it', () async {
      final id = uuid.v4();
      final account = _buildTestAccount(id: id);

      await repository.createAccount(account);
      final retrieved = await repository.getAccountById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, id);
      expect(retrieved.name, 'Test Account');
      expect(retrieved.type, AccountType.savings);
      expect(retrieved.initialBalance, 1200.0);
    });

    test('getAccountsByUserId returns only non-deleted accounts for specific user', () async {
      final user1 = 'user-1';
      final user2 = 'user-2';

      final acc1 = _buildTestAccount(id: uuid.v4(), name: 'Acc 1').copyWith(userId: user1);
      final acc2 = _buildTestAccount(id: uuid.v4(), name: 'Acc 2').copyWith(userId: user1);
      final accDeleted = _buildTestAccount(id: uuid.v4(), name: 'Deleted Acc', isDeleted: true).copyWith(userId: user1);
      final accOther = _buildTestAccount(id: uuid.v4(), name: 'Acc Other').copyWith(userId: user2);

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
      final account = _buildTestAccount(id: id, name: 'Original Name');
      await repository.createAccount(account);

      final updated = account.copyWith(name: 'Updated Name', initialBalance: 5000.0);
      await repository.updateAccount(updated);

      final retrieved = await repository.getAccountById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.initialBalance, 5000.0);
    });

    test('deleteAccount soft-deletes the account record', () async {
      final id = uuid.v4();
      final account = _buildTestAccount(id: id, name: 'Active Acc');
      await repository.createAccount(account);

      await repository.deleteAccount(id);

      final retrieved = await repository.getAccountById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.isDeleted, isTrue);
    });
  });
}
