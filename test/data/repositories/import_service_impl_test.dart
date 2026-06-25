import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/repositories/import_service_impl.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';

class MockExportService extends Mock implements IExportService {}

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

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

  group('ImportServiceImpl Tests', () {
    test('restoreFromEncryptedJson throws ImportException on decrypt failure',
        () async {
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

    test('restoreFromEncryptedJson throws ImportException on invalid JSON',
        () async {
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

    test(
        'restoreFromEncryptedJson throws ImportException on unsupported version',
        () async {
      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => '{"version": 3}');

      expect(
        () => importService
            .restoreFromEncryptedJson([1, 2, 3], password: 'password'),
        throwsA(
          isA<ImportException>()
              .having((e) => e.code, 'code', 'UNSUPPORTED_VERSION'),
        ),
      );
    });

    test(
        'restoreFromEncryptedJson successfully restores database from correct payload',
        () async {
      const validJson = '''
      {
        "version": 2,
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
            "notes": "Lunch",
            "original_currency": "EUR",
            "created_at": "2025-06-22T00:00:00.000",
            "modified_at": "2025-06-22T00:00:00.000"
          }
        ]
      }
      ''';

      when(
        () => mockExportService.decryptJsonPayload(
          any(),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => validJson);

      // Pre-seed a profile so that accounts (which reference profiles) can be inserted
      await db.into(db.profiles).insert(
            ProfilesCompanion.insert(
              id: 'profile-1',
              name: 'Anonymous',
              username: 'anonymous',
              password: '',
              createdAt: DateTime.now(),
              modifiedAt: DateTime.now(),
            ),
          );

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
    });
  });
}
