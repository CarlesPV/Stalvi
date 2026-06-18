import 'dart:io';
import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/domain/usecases/wipe_all_data_usecase.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/category_table.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempDir;
  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir;
  }
}

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late WipeAllDataUseCase useCase;
  late MockSecureStorageManager mockSecureStorageManager;
  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wipe_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    mockSecureStorageManager = MockSecureStorageManager();
    when(() => mockSecureStorageManager.deleteAll()).thenAnswer((_) async {});

    final dbFile = File('${tempDir.path}/stalvi.db');
    db = AppDatabase.forTesting(NativeDatabase(dbFile));

    useCase = WipeAllDataUseCase(mockSecureStorageManager, db);
  });

  tearDown(() async {
    try {
      await db.close();
    } catch (_) {}
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'WipeAllDataUseCase clears all tables, secure storage, and deletes database files',
      () async {
    // Arrange: Ensure database is initialized and seeds exist
    final profilesList = await db.select(db.profiles).get();
    final accountsList = await db.select(db.accounts).get();
    final categoriesList = await db.select(db.categories).get();

    expect(profilesList.isNotEmpty, isTrue);
    expect(accountsList.isNotEmpty, isTrue);
    expect(categoriesList.isNotEmpty, isTrue);

    // Create journal, wal, and shm simulation files
    final dbJournalFile = File('${tempDir.path}/stalvi.db-journal');
    final dbWalFile = File('${tempDir.path}/stalvi.db-wal');
    final dbShmFile = File('${tempDir.path}/stalvi.db-shm');

    await dbJournalFile.writeAsString('journal');
    await dbWalFile.writeAsString('wal');
    await dbShmFile.writeAsString('shm');

    final dbFile = File('${tempDir.path}/stalvi.db');
    expect(await dbFile.exists(), isTrue);
    expect(await dbJournalFile.exists(), isTrue);
    expect(await dbWalFile.exists(), isTrue);
    expect(await dbShmFile.exists(), isTrue);

    // Act
    await useCase.execute();

    // Assert: Secure storage clear was called
    verify(() => mockSecureStorageManager.deleteAll()).called(1);

    // Assert: Database files deleted
    expect(await dbFile.exists(), isFalse);
    expect(await dbJournalFile.exists(), isFalse);
    expect(await dbWalFile.exists(), isFalse);
    expect(await dbShmFile.exists(), isFalse);
  });

  test(
      'WipeAllDataUseCase clears all tables completely (including soft-deleted/Trash items)',
      () async {
    // Arrange: Seed the database with some dummy entries, including soft-deleted ones (Trash)
    final now = DateTime.now();

    // 1. Insert a Profile
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: 'user_test_wipe',
            name: 'Test Wipe',
            username: 'testwipe',
            password: '',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 2. Insert Accounts (one active, one soft-deleted/Trash)
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_active',
            userId: 'user_test_wipe',
            name: 'Active Account',
            type: AccountType.cash,
            initialBalance: 10.0,
            currency: 'EUR',
            color: '#FFFFFF',
            icon: 'icon',
            createdAt: now,
            modifiedAt: now,
          ),
        );
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: 'acc_deleted',
            userId: 'user_test_wipe',
            name: 'Deleted Account',
            type: AccountType.cash,
            initialBalance: 0.0,
            currency: 'EUR',
            color: '#000000',
            icon: 'icon',
            isDeleted: const Value(true), // soft-deleted/Trash
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 3. Insert Categories (one active, one soft-deleted/Trash)
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat_active',
            name: 'Active Cat',
            associatedType: const Value(CategoryAssociatedType.expense),
            icon: 'icon',
            color: '#FFFFFF',
            createdAt: now,
            modifiedAt: now,
          ),
        );
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'cat_deleted',
            name: 'Deleted Cat',
            associatedType: const Value(CategoryAssociatedType.expense),
            icon: 'icon',
            color: '#000000',
            isDeleted: const Value(true), // soft-deleted/Trash
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 4. Insert Tags
    await db.into(db.tags).insert(
          TagsCompanion.insert(
            id: 'tag_test',
            name: 'Test Tag',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // 5. Insert Transactions
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: 'tx_active',
            amount: 100,
            date: now,
            type: TransactionType.expense,
            accountId: 'acc_active',
            originalCurrency: 'EUR',
            createdAt: now,
            modifiedAt: now,
          ),
        );

    // Verify all tables have data (including soft-deleted)
    expect(
        (await db.select(db.profiles).get())
            .any((p) => p.id == 'user_test_wipe'),
        isTrue);
    expect(
        (await db.select(db.accounts).get()).any((a) => a.id == 'acc_active'),
        isTrue);
    expect(
        (await db.select(db.accounts).get()).any((a) => a.id == 'acc_deleted'),
        isTrue);
    expect(
        (await db.select(db.categories).get()).any((c) => c.id == 'cat_active'),
        isTrue);
    expect(
        (await db.select(db.categories).get())
            .any((c) => c.id == 'cat_deleted'),
        isTrue);
    expect((await db.select(db.tags).get()).any((t) => t.id == 'tag_test'),
        isTrue);
    expect(
        (await db.select(db.transactions).get())
            .any((t) => t.id == 'tx_active'),
        isTrue);

    // Act
    await useCase.execute();

    // Reopen database at the same path (which should have been wiped & deleted) to verify it is clean
    final dbFile = File('${tempDir.path}/stalvi.db');
    final freshDb = AppDatabase.forTesting(NativeDatabase(dbFile));

    try {
      // On fresh creation, database executes migration onCreate which seeds 'Anonymous' profile, 'Mi Cartera' account, etc.
      // But it should NOT contain our custom inserted test data!
      final profiles = await freshDb.select(freshDb.profiles).get();
      final accounts = await freshDb.select(freshDb.accounts).get();
      final categories = await freshDb.select(freshDb.categories).get();
      final tags = await freshDb.select(freshDb.tags).get();
      final transactions = await freshDb.select(freshDb.transactions).get();

      expect(profiles.any((p) => p.id == 'user_test_wipe'), isFalse);
      expect(accounts.any((a) => a.id == 'acc_active'), isFalse);
      expect(accounts.any((a) => a.id == 'acc_deleted'), isFalse);
      expect(categories.any((c) => c.id == 'cat_active'), isFalse);
      expect(categories.any((c) => c.id == 'cat_deleted'), isFalse);
      expect(tags.any((t) => t.id == 'tag_test'), isFalse);
      expect(transactions.any((t) => t.id == 'tx_active'), isFalse);

      // Verify the trash/recycle bin is empty (no items with isDeleted = true)
      final trashDao = freshDb.trashDao;
      final trashItems = await trashDao.getTrashItems();
      expect(trashItems, isEmpty);
    } finally {
      await freshDb.close();
    }
  });
}
