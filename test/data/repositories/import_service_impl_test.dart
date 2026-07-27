import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/import_service_impl.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';

class MockExportService extends Mock implements IExportService {}

void main() {
  late AppDatabase db;
  late MockExportService mockExportService;
  late ImportServiceImpl importService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockExportService = MockExportService();
    importService = ImportServiceImpl(
      database: db,
      exportService: mockExportService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// Seeds a profile row so that account FK constraints are satisfied.
  Future<void> seedProfile(AppDatabase db, String id) async {
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(
            id: id,
            name: 'Anonymous',
            username: 'anonymous',
            password: '',
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
          ),
        );
  }

  group('ImportServiceImpl – error handling', () {
    test('throws ImportException on decrypt failure', () async {
      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ExportException(
          message: 'Decryption failed',
          code: 'DECRYPT_FAILED',
        ),
      );

      expect(
        () => importService
            .restoreFromEncryptedJson([1, 2, 3], password: 'wrong_password'),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'DECRYPT_FAILED'),
        ),
      );
    });

    test('throws ImportException on invalid JSON', () async {
      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => 'not-a-json-string');

      expect(
        () => importService
            .restoreFromEncryptedJson([1, 2, 3], password: 'password'),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'JSON_PARSE_FAILED'),
        ),
      );
    });

    test('throws ImportException on unsupported version', () async {
      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => '{"version": 4}');

      expect(
        () => importService
            .restoreFromEncryptedJson([1, 2, 3], password: 'password'),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'UNSUPPORTED_VERSION'),
        ),
      );
    });
  });

  group('ImportServiceImpl – successful restore', () {
    test('restores a basic expense transaction correctly', () async {
      const validJson = '''
      {
        "version": 3,
        "accounts": [
          {
            "id": "acc-1",
            "user_id": "profile-1",
            "name": "Main Wallet",
            "type": "cash",
            "initial_balance": 1000.0,
            "currency": "EUR",
            "color": "#FFFFFF",
            "icon": "wallet",
            "is_default": true,
            "is_deleted": false,
            "created_at": "2025-06-22T00:00:00.000",
            "modified_at": "2025-06-22T00:00:00.000"
          }
        ],
        "categories": [
          {
            "id": "cat-1",
            "name": "Food",
            "associated_type": "expense",
            "icon": "food",
            "color": "#000000",
            "is_deleted": false,
            "created_at": "2025-06-22T00:00:00.000",
            "modified_at": "2025-06-22T00:00:00.000"
          }
        ],
        "tags": [
          {
            "id": "tag-1",
            "name": "Summer",
            "is_deleted": false,
            "created_at": "2025-06-22T00:00:00.000",
            "modified_at": "2025-06-22T00:00:00.000"
          }
        ],
        "transactions": [
          {
            "id": "tx-1",
            "amount": 500,
            "date": "2025-06-22T00:00:00.000",
            "type": "expense",
            "account_id": "acc-1",
            "category_id": "cat-1",
            "savings_goal_id": null,
            "notes": "Lunch",
            "original_currency": "EUR",
            "transfer_id": null,
            "is_deleted": false,
            "created_at": "2025-06-22T00:00:00.000",
            "modified_at": "2025-06-22T00:00:00.000"
          }
        ],
        "budgets": [],
        "savings_goals": [],
        "automatic_transactions": []
      }
      ''';

      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => validJson);

      await seedProfile(db, 'profile-1');

      await importService
          .restoreFromEncryptedJson([1, 2, 3], password: 'password');

      final accounts = await db.select(db.accounts).get();
      final categories = await db.select(db.categories).get();
      final tags = await db.select(db.tags).get();
      final transactions = await db.select(db.transactions).get();

      expect(accounts.length, 1);
      expect(accounts.first.id, 'acc-1');
      expect(accounts.first.name, 'Main Wallet');

      expect(categories.length, 1);
      expect(categories.first.id, 'cat-1');

      expect(tags.length, 1);
      expect(tags.first.id, 'tag-1');

      expect(transactions.length, 1);
      expect(transactions.first.id, 'tx-1');
      expect(transactions.first.notes, 'Lunch');
      expect(transactions.first.savingsGoalId, isNull);
    });

    test(
        'transfer pair: both legs import with correct accounts and shared transferId',
        () async {
      // Origin leg: acc-1 → acc-2 (negative amount, same transferId)
      // Destination leg: acc-2 receives positive amount, same transferId
      const validJson = '''
      {
        "version": 3,
        "accounts": [
          {
            "id": "acc-1",
            "user_id": "profile-1",
            "name": "Checking",
            "type": "bank",
            "initial_balance": 0.0,
            "currency": "EUR",
            "color": "#111111",
            "icon": "bank",
            "is_default": true,
            "is_deleted": false,
            "created_at": "2025-01-01T00:00:00.000",
            "modified_at": "2025-01-01T00:00:00.000"
          },
          {
            "id": "acc-2",
            "user_id": "profile-1",
            "name": "Savings",
            "type": "savings",
            "initial_balance": 0.0,
            "currency": "EUR",
            "color": "#222222",
            "icon": "savings",
            "is_default": false,
            "is_deleted": false,
            "created_at": "2025-01-01T00:00:00.000",
            "modified_at": "2025-01-01T00:00:00.000"
          }
        ],
        "categories": [],
        "tags": [],
        "transactions": [
          {
            "id": "tx-origin",
            "amount": 1000,
            "date": "2025-06-01T00:00:00.000",
            "type": "transfer",
            "account_id": "acc-1",
            "category_id": null,
            "savings_goal_id": null,
            "notes": null,
            "original_currency": "EUR",
            "converted_amount": null,
            "exchange_rate": null,
            "exchange_rate_snapshot": null,
            "transfer_id": "shared-transfer-uuid",
            "is_deleted": false,
            "created_at": "2025-06-01T00:00:00.000",
            "modified_at": "2025-06-01T00:00:00.000"
          },
          {
            "id": "tx-origin_dst",
            "amount": 1000,
            "date": "2025-06-01T00:00:00.000",
            "type": "transfer",
            "account_id": "acc-2",
            "category_id": null,
            "savings_goal_id": null,
            "notes": null,
            "original_currency": "EUR",
            "converted_amount": null,
            "exchange_rate": null,
            "exchange_rate_snapshot": null,
            "transfer_id": "shared-transfer-uuid",
            "is_deleted": false,
            "created_at": "2025-06-01T00:00:00.000",
            "modified_at": "2025-06-01T00:00:00.000"
          }
        ],
        "budgets": [],
        "savings_goals": [],
        "automatic_transactions": []
      }
      ''';

      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => validJson);

      await seedProfile(db, 'profile-1');

      await importService
          .restoreFromEncryptedJson([1, 2, 3], password: 'password');

      final transactions = await db.select(db.transactions).get();

      expect(
        transactions.length,
        2,
        reason: 'Both legs of the transfer must be imported',
      );

      final origin = transactions.firstWhere((t) => t.id == 'tx-origin');
      final destination =
          transactions.firstWhere((t) => t.id == 'tx-origin_dst');

      // Origin leg points to source account
      expect(
        origin.accountId,
        'acc-1',
        reason: 'Origin leg must reference the source account',
      );
      // Destination leg points to destination account
      expect(
        destination.accountId,
        'acc-2',
        reason: 'Destination leg must reference the destination account',
      );

      // Both legs share the same transferId
      expect(origin.transferId, 'shared-transfer-uuid');
      expect(destination.transferId, 'shared-transfer-uuid');
      expect(
        origin.transferId,
        destination.transferId,
        reason: 'Both legs must share the same transferId',
      );

      expect(origin.amount, 1000);
      expect(destination.amount, 1000);
    });

    test(
        'transfer to savings goal: single leg imports with savingsGoalId preserved',
        () async {
      const validJson = '''
      {
        "version": 3,
        "accounts": [
          {
            "id": "acc-1",
            "user_id": "profile-1",
            "name": "Checking",
            "type": "bank",
            "initial_balance": 0.0,
            "currency": "EUR",
            "color": "#111111",
            "icon": "bank",
            "is_default": true,
            "is_deleted": false,
            "created_at": "2025-01-01T00:00:00.000",
            "modified_at": "2025-01-01T00:00:00.000"
          }
        ],
        "categories": [],
        "tags": [],
        "transactions": [
          {
            "id": "tx-goal-transfer",
            "amount": 5000,
            "date": "2025-06-01T00:00:00.000",
            "type": "transfer",
            "account_id": "acc-1",
            "category_id": null,
            "savings_goal_id": "goal-1",
            "notes": null,
            "original_currency": "EUR",
            "converted_amount": null,
            "exchange_rate": null,
            "exchange_rate_snapshot": null,
            "transfer_id": null,
            "is_deleted": false,
            "created_at": "2025-06-01T00:00:00.000",
            "modified_at": "2025-06-01T00:00:00.000"
          }
        ],
        "budgets": [],
        "savings_goals": [
          {
            "id": "goal-1",
            "name": "Holiday Fund",
            "target_amount": 100000,
            "current_amount": 5000,
            "target_date": null,
            "color": "#00FF00",
            "icon": "flight",
            "created_at": "2025-01-01T00:00:00.000",
            "modified_at": "2025-06-01T00:00:00.000",
            "deleted_at": null,
            "is_deleted": false,
            "is_completed": false,
            "currency": "EUR"
          }
        ],
        "automatic_transactions": []
      }
      ''';

      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => validJson);

      await seedProfile(db, 'profile-1');

      await importService
          .restoreFromEncryptedJson([1, 2, 3], password: 'password');

      final transactions = await db.select(db.transactions).get();
      expect(transactions.length, 1);

      final tx = transactions.first;
      expect(tx.id, 'tx-goal-transfer');
      expect(
        tx.savingsGoalId,
        'goal-1',
        reason:
            'savings_goal_id must be preserved after import for goal transfers',
      );
      expect(tx.accountId, 'acc-1');
    });

    test('is_deleted flag is preserved from backup', () async {
      const validJson = '''
      {
        "version": 3,
        "accounts": [
          {
            "id": "acc-1",
            "user_id": "profile-1",
            "name": "Wallet",
            "type": "cash",
            "initial_balance": 0.0,
            "currency": "EUR",
            "color": "#FFFFFF",
            "icon": "wallet",
            "is_default": true,
            "is_deleted": false,
            "created_at": "2025-01-01T00:00:00.000",
            "modified_at": "2025-01-01T00:00:00.000"
          }
        ],
        "categories": [],
        "tags": [],
        "transactions": [
          {
            "id": "tx-active",
            "amount": 100,
            "date": "2025-06-01T00:00:00.000",
            "type": "expense",
            "account_id": "acc-1",
            "category_id": null,
            "savings_goal_id": null,
            "notes": null,
            "original_currency": "EUR",
            "transfer_id": null,
            "is_deleted": false,
            "created_at": "2025-06-01T00:00:00.000",
            "modified_at": "2025-06-01T00:00:00.000"
          },
          {
            "id": "tx-deleted",
            "amount": 200,
            "date": "2025-06-02T00:00:00.000",
            "type": "expense",
            "account_id": "acc-1",
            "category_id": null,
            "savings_goal_id": null,
            "notes": null,
            "original_currency": "EUR",
            "transfer_id": null,
            "is_deleted": true,
            "created_at": "2025-06-02T00:00:00.000",
            "modified_at": "2025-06-02T00:00:00.000"
          }
        ],
        "budgets": [],
        "savings_goals": [],
        "automatic_transactions": []
      }
      ''';

      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => validJson);

      await seedProfile(db, 'profile-1');

      await importService
          .restoreFromEncryptedJson([1, 2, 3], password: 'password');

      final transactions = await db.select(db.transactions).get();
      expect(transactions.length, 2);

      final active = transactions.firstWhere((t) => t.id == 'tx-active');
      final deleted = transactions.firstWhere((t) => t.id == 'tx-deleted');

      expect(
        active.isDeleted,
        isFalse,
        reason: 'Active transaction must not be marked deleted after import',
      );
      expect(
        deleted.isDeleted,
        isTrue,
        reason:
            'Soft-deleted transaction must retain its deleted state after import',
      );
    });
  });
}
