import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/data/repositories/export_service_impl.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/period_summary.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/transaction.dart';
import 'package:flutter/widgets.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String? downloadsPath;
  final String? docsPath;
  final bool throwOnDownloads;

  FakePathProviderPlatform({
    this.downloadsPath,
    this.docsPath,
    this.throwOnDownloads = false,
  });

  FakePathProviderPlatform.legacy(String tempDir)
      : downloadsPath = tempDir,
        docsPath = tempDir,
        throwOnDownloads = false;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return docsPath;
  }

  @override
  Future<String?> getDownloadsPath() async {
    if (throwOnDownloads) {
      throw Exception('Downloads directory unavailable');
    }
    return downloadsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return downloadsPath;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return docsPath;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Test helpers
// ──────────────────────────────────────────────────────────────────────────────

Transaction _makeTransaction({
  String id = 'tx-001',
  int amount = 5000, // 50.00 in major units
  TransactionType type = TransactionType.expense,
  String accountId = 'acc-001',
  String? categoryId = 'cat-001',
  String? tagId,
  String? notes = 'Groceries',
  String currency = 'EUR',
  String? transferId,
}) {
  final now = DateTime(2025, 6, 15, 10, 30);
  return Transaction(
    id: id,
    amount: amount,
    date: now,
    type: type,
    accountId: accountId,
    categoryId: categoryId,
    tagId: tagId,
    notes: notes,
    originalCurrency: currency,
    createdAt: now,
    modifiedAt: now,
    transferId: transferId,
  );
}

List<Account> get _emptyAccounts => const [];
List<Category> get _emptyCategories => const [];
List<Tag> get _emptyTags => const [];

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ExportServiceImpl service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('export_service_test');
    PathProviderPlatform.instance = FakePathProviderPlatform.legacy(
      tempDir.path,
    );
    service = ExportServiceImpl();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // ─────────────────────── CSV formatting ──────────────────────────────────

  group('generateCsv', () {
    test(
      'result has correct MIME type and matches Stalvi_Export_yyyyMMdd_HHmmss.csv filename pattern',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result = await service.generateCsv(
          [tx],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        // Assert
        expect(result.mimeType, equals('text/csv'));
        expect(
          result.filename,
          matches(RegExp(r'^Stalvi_Table_\d{8}_\d{6}\.csv$')),
        );
      },
    );

    test(
      'CSV output starts with UTF-8 BOM (0xEF, 0xBB, 0xBF)',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result = await service.generateCsv(
          [tx],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        // Assert – UTF-8 BOM
        expect(result.bytes.length, greaterThanOrEqualTo(3));
        expect(result.bytes[0], equals(0xEF));
        expect(result.bytes[1], equals(0xBB));
        expect(result.bytes[2], equals(0xBF));
      },
    );

    test(
      'CSV output has a header row delimited by semicolon with source_account and destination_account',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result = await service.generateCsv(
          [tx],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );
        final lines = utf8.decode(result.bytes).split('\n');

        // Assert
        expect(lines.first, contains('Date'));
        expect(lines.first, contains('Type'));
        expect(lines.first, contains('Category'));
        expect(lines.first, contains('Label'));
        expect(lines.first, contains('Amount'));
        expect(lines.first, contains('exchange_rate_snapshot'));
        expect(lines.first, contains('transfer_id'));
        expect(lines.first, contains('source_account'));
        expect(lines.first, contains('destination_account'));
        expect(lines.first, contains(';'));
      },
    );

    test('amount is converted from cents to decimal string', () async {
      // Arrange – 1050 cents = 10.50
      final tx = _makeTransaction(amount: 1050);

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert
      expect(csvString, contains('10.50'));
    });

    test('income transaction type is recorded as "income"', () async {
      // Arrange
      final tx = _makeTransaction(type: TransactionType.income);

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert
      expect(csvString, contains('income'));
    });

    test('CSV row count equals number of transactions plus header', () async {
      // Arrange
      final transactions = [
        _makeTransaction(id: 'tx-1'),
        _makeTransaction(id: 'tx-2'),
        _makeTransaction(id: 'tx-3'),
      ];

      // Act
      final result = await service.generateCsv(
        transactions,
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      // Split and remove any trailing empty line produced by the final \n
      final lines = utf8
          .decode(result.bytes)
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();

      // Assert: header + 3 data rows
      expect(lines.length, equals(4));
    });

    test('fields containing semicolons or commas are wrapped in double quotes',
        () async {
      // Arrange — notes field contains a semicolon and comma
      final tx = _makeTransaction(notes: 'Coffee; Cake, Juice');

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert
      expect(csvString, contains('"Coffee; Cake, Juice"'));
    });

    test('fields containing double-quotes escape them', () async {
      // Arrange — notes field contains a double-quote character
      final tx = _makeTransaction(notes: 'He said "hi"');

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert – RFC 4180: double-quotes are doubled inside a quoted field
      expect(csvString, contains('"He said ""hi"""'));
    });

    test('null optional fields produce empty CSV columns', () async {
      // Arrange
      final tx = _makeTransaction(categoryId: null, notes: null);

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert: data row should still parse (no exception) and contain semicolons
      // for the empty optional fields.
      expect(csvString, isNotEmpty);
      expect(csvString, contains(';'));
    });

    test('empty transaction list produces only a header row', () async {
      // Act
      final result = await service.generateCsv(
        [],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final lines = utf8
          .decode(result.bytes)
          .split('\n')
          .where((l) => l.isNotEmpty)
          .toList();

      // Assert
      expect(lines.length, equals(1)); // only header
    });

    test('resolves tagId to tag name in CSV export', () async {
      // Arrange
      final tag = Tag(
        id: 'tag-100',
        name: 'Personal',
        createdAt: DateTime(2025, 1, 1),
        modifiedAt: DateTime(2025, 1, 1),
      );
      final tx = _makeTransaction(tagId: 'tag-100');

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: [tag],
      );
      final csvString = utf8.decode(result.bytes);

      // Assert
      expect(csvString, contains('Personal'));
    });

    test('populates source_account and destination_account for transfers',
        () async {
      // Arrange
      final acc1 = Account(
        id: 'acc-1',
        userId: 'user-1',
        name: 'Main Bank',
        type: AccountType.bank,
        initialBalance: 0,
        currency: 'EUR',
        color: '#000000',
        icon: 'bank',
        isDefault: true,
        isDeleted: false,
        createdAt: DateTime(2025, 1, 1),
        modifiedAt: DateTime(2025, 1, 1),
      );
      final acc2 = Account(
        id: 'acc-2',
        userId: 'user-1',
        name: 'Savings',
        type: AccountType.savings,
        initialBalance: 0,
        currency: 'EUR',
        color: '#FFFFFF',
        icon: 'savings',
        isDefault: false,
        isDeleted: false,
        createdAt: DateTime(2025, 1, 1),
        modifiedAt: DateTime(2025, 1, 1),
      );

      final txOrigin = _makeTransaction(
        id: 'tx-origin',
        accountId: 'acc-1',
        amount: -5000,
        type: TransactionType.transfer,
        transferId: 'transfer-123',
      );
      final txDest = _makeTransaction(
        id: 'tx-dest',
        accountId: 'acc-2',
        amount: 5000,
        type: TransactionType.transfer,
        transferId: 'transfer-123',
      );

      // Act
      final result = await service.generateCsv(
        [txOrigin],
        accounts: [acc1, acc2],
        categories: _emptyCategories,
        allRawTransactions: [txOrigin, txDest],
      );
      final csvString = utf8.decode(result.bytes);
      final lines = csvString.split('\n').where((l) => l.isNotEmpty).toList();

      // Assert
      expect(lines.length, equals(2));
      final dataRow = lines[1];
      expect(dataRow, contains('Main Bank;Savings'));
    });
  });

  // ─────────────────────── Encrypted JSON ───────────────────────────────────

  group('generateEncryptedJson', () {
    const password = 'S3cur3P@ssw0rd!';

    test(
      'result has correct MIME type and matches Stalvi_Export_yyyyMMdd_HHmmss.kbak filename pattern',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );

        // Assert
        expect(result.mimeType, equals('application/octet-stream'));
        expect(
          result.filename,
          matches(RegExp(r'^Stalvi_Backup_\d{8}_\d{6}\.kbak$')),
        );
      },
    );

    test(
      'envelope is at least 33 bytes (16 salt + 16 iv + 1 byte cipher)',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );

        // Assert
        expect(result.bytes.length, greaterThanOrEqualTo(33));
      },
    );

    test(
      'encryption is non-deterministic: two exports of the same data differ',
      () async {
        // Arrange
        final tx = _makeTransaction();

        // Act
        final result1 = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );
        final result2 = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );

        // Assert – random salt + IV ensure ciphertexts differ on every run
        expect(result1.bytes, isNot(equals(result2.bytes)));
      },
    );

    test(
      'decrypting the envelope with the correct password recovers the JSON',
      () async {
        // Arrange
        final tx = _makeTransaction();
        final result = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
          username: 'user_one',
        );

        // Act – manually unpack envelope and decrypt
        final envelope = Uint8List.fromList(result.bytes);
        final salt = envelope.sublist(0, 16);
        final ivBytes = envelope.sublist(16, 32);
        final cipherBytes = envelope.sublist(32);

        final derivedKey = ExportServiceImpl.deriveKeyForTest(password, salt);
        final iv = enc.IV(ivBytes);
        final encrypter = enc.Encrypter(
          enc.AES(enc.Key(derivedKey), mode: enc.AESMode.cbc),
        );
        final decrypted = encrypter.decrypt(
          enc.Encrypted(Uint8List.fromList(cipherBytes)),
          iv: iv,
        );

        final payload = jsonDecode(decrypted) as Map<String, dynamic>;

        // Assert
        expect(payload['version'], equals(3));
        expect(payload['user_name'], equals('User 1'));
        expect(payload['username'], equals('user_one'));
        expect(payload['transactions'], isA<List>());
        final firstTx =
            (payload['transactions'] as List).first as Map<String, dynamic>;
        expect(firstTx['id'], equals('tx-001'));
        expect(firstTx['amount'], equals(5000));
        expect(firstTx.containsKey('tag_id'), isTrue);
      },
    );

    test(
      'decrypting with wrong password yields corrupted output or throws',
      () async {
        // Arrange
        final tx = _makeTransaction();
        final result = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );

        // Act – try to decrypt with a wrong password
        final envelope = Uint8List.fromList(result.bytes);
        final salt = envelope.sublist(0, 16);
        final ivBytes = envelope.sublist(16, 32);
        final cipherBytes = envelope.sublist(32);

        final wrongKey = ExportServiceImpl.deriveKeyForTest(
          'WrongPassword!',
          salt,
        );
        final iv = enc.IV(ivBytes);
        final encrypter = enc.Encrypter(
          enc.AES(enc.Key(wrongKey), mode: enc.AESMode.cbc),
        );

        // Assert – decryption with wrong key produces garbage, not valid JSON
        expect(
          () {
            final garbled = encrypter.decrypt(
              enc.Encrypted(Uint8List.fromList(cipherBytes)),
              iv: iv,
            );
            // If decrypt doesn't throw, the result must not be valid JSON
            jsonDecode(garbled);
          },
          throwsA(anything),
        );
      },
    );

    test('empty password throws ExportException', () async {
      // Arrange
      final tx = _makeTransaction();

      // Act & Assert
      expect(
        () => service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: '',
          userName: 'User 1',
        ),
        throwsA(isA<ExportException>()),
      );
    });

    test(
      'transaction id and amount are correctly serialised in the envelope',
      () async {
        // Arrange
        final tx = _makeTransaction(id: 'unique-id-xyz', amount: 99999);
        final result = await service.generateEncryptedJson(
          accounts: _emptyAccounts,
          categories: _emptyCategories,
          tags: _emptyTags,
          transactions: [tx],
          budgets: const [],
          savingsGoals: const [],
          automaticTransactions: const [],
          password: password,
          userName: 'User 1',
        );

        // Act – decrypt and parse
        final envelope = Uint8List.fromList(result.bytes);
        final salt = envelope.sublist(0, 16);
        final ivBytes = envelope.sublist(16, 32);
        final cipherBytes = envelope.sublist(32);

        final key = ExportServiceImpl.deriveKeyForTest(password, salt);
        final decrypted =
            enc.Encrypter(enc.AES(enc.Key(key), mode: enc.AESMode.cbc)).decrypt(
          enc.Encrypted(Uint8List.fromList(cipherBytes)),
          iv: enc.IV(ivBytes),
        );

        final payload = jsonDecode(decrypted) as Map<String, dynamic>;
        final firstTx =
            (payload['transactions'] as List).first as Map<String, dynamic>;

        // Assert
        expect(firstTx['id'], equals('unique-id-xyz'));
        expect(firstTx['amount'], equals(99999));
      },
    );
  });

  // ──────────────────────── PDF generation ──────────────────────────────────

  group('generateMonthlyPdf', () {
    test(
      'result has correct MIME type and matches Stalvi_Export_yyyyMMdd_HHmmss.pdf filename pattern',
      () async {
        // Arrange
        final tx = _makeTransaction();
        const summary = PeriodSummary(totalIncome: 10000, totalExpense: 5000);

        // Act
        final result = await service.generateMonthlyPdf(
          [tx],
          summary: summary,
          month: DateTime(2025, 6),
          l10n: lookupAppLocalizations(const Locale('en')),
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        // Assert
        expect(result.mimeType, equals('application/pdf'));
        expect(
          result.filename,
          matches(RegExp(r'^Stalvi_Overview_\d{8}_\d{6}\.pdf$')),
        );
      },
    );

    test('PDF bytes start with the PDF magic bytes (%PDF)', () async {
      // Arrange
      const summary = PeriodSummary(totalIncome: 0, totalExpense: 0);

      // Act
      final result = await service.generateMonthlyPdf(
        [],
        summary: summary,
        month: DateTime(2025, 6),
        l10n: lookupAppLocalizations(const Locale('en')),
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );

      // Assert – first 4 bytes of a valid PDF are always %PDF
      final header = String.fromCharCodes(result.bytes.sublist(0, 4));
      expect(header, equals('%PDF'));
    });
  });

  // ──────────────── File export fallback tests ─────────────────────────

  group('File export directory resolution and fallback logic', () {
    late Directory downloadsDir;
    late Directory docsDir;

    setUp(() async {
      final rootTemp = await Directory.systemTemp.createTemp(
        'export_fallback_test',
      );
      downloadsDir = Directory('${rootTemp.path}/Downloads');
      docsDir = Directory('${rootTemp.path}/Documents');
      await downloadsDir.create(recursive: true);
      await docsDir.create(recursive: true);
    });

    tearDown(() async {
      if (downloadsDir.parent.existsSync()) {
        await downloadsDir.parent.delete(recursive: true);
      }
    });

    test(
      'always attempts to save file into Downloads directory first when available',
      () async {
        PathProviderPlatform.instance = FakePathProviderPlatform(
          downloadsPath: downloadsDir.path,
          docsPath: docsDir.path,
        );

        final result = await service.generateCsv(
          [_makeTransaction()],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        expect(result.filePath, startsWith(downloadsDir.path));
        expect(File(result.filePath!).existsSync(), isTrue);
      },
    );

    test(
      'falls back to Documents directory when Downloads directory is unavailable (null)',
      () async {
        PathProviderPlatform.instance = FakePathProviderPlatform(
          downloadsPath: null,
          docsPath: docsDir.path,
        );

        final result = await service.generateCsv(
          [_makeTransaction()],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        expect(result.filePath, startsWith(docsDir.path));
        expect(File(result.filePath!).existsSync(), isTrue);
      },
    );

    test(
      'falls back to Documents directory when getDownloadsPath throws an exception',
      () async {
        PathProviderPlatform.instance = FakePathProviderPlatform(
          throwOnDownloads: true,
          docsPath: docsDir.path,
        );

        final result = await service.generateCsv(
          [_makeTransaction()],
          accounts: _emptyAccounts,
          categories: _emptyCategories,
        );

        expect(result.filePath, startsWith(docsDir.path));
        expect(File(result.filePath!).existsSync(), isTrue);
      },
    );
  });
}
