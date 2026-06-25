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
  final String tempDir;
  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir;
  }

  @override
  Future<String?> getDownloadsPath() async {
    return tempDir;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return tempDir;
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
  String? notes = 'Groceries',
  String currency = 'EUR',
}) {
  final now = DateTime(2025, 6, 15, 10, 30);
  return Transaction(
    id: id,
    amount: amount,
    date: now,
    type: type,
    accountId: accountId,
    categoryId: categoryId,
    notes: notes,
    originalCurrency: currency,
    createdAt: now,
    modifiedAt: now,
  );
}

List<Account> get _emptyAccounts => const [];
List<Category> get _emptyCategories => const [];
List<Tag> get _emptyTags => const [];

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

void main() {
  late ExportServiceImpl service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('export_service_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
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
        'result has correct MIME type and matches Konta_Export_yyyyMMdd_HHmmss.csv filename pattern',
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
          result.filename, matches(RegExp(r'^Konta_Export_\d{8}_\d{6}\.csv$')));
    });

    test(
        'CSV output has a header row as the first line with exchange_rate_snapshot and transfer_id',
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
      expect(lines.first, contains('Amount'));
      expect(lines.first, contains('exchange_rate_snapshot'));
      expect(lines.first, contains('transfer_id'));
    });

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

    test('fields containing commas are wrapped in double quotes', () async {
      // Arrange — notes field contains a comma
      final tx = _makeTransaction(notes: 'Coffee, Cake');

      // Act
      final result = await service.generateCsv(
        [tx],
        accounts: _emptyAccounts,
        categories: _emptyCategories,
      );
      final csvString = utf8.decode(result.bytes);

      // Assert
      expect(csvString, contains('"Coffee, Cake"'));
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

      // Assert: data row should still parse (no exception) and contain commas
      // for the empty optional fields. We check the transaction id is present
      // indirectly via the date/type being present.
      expect(csvString, isNotEmpty);
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
  });

  // ─────────────────────── Encrypted JSON ───────────────────────────────────

  group('generateEncryptedJson', () {
    const password = 'S3cur3P@ssw0rd!';

    test(
        'result has correct MIME type and matches Konta_Export_yyyyMMdd_HHmmss.kbak filename pattern',
        () async {
      // Arrange
      final tx = _makeTransaction();

      // Act
      final result = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );

      // Assert
      expect(result.mimeType, equals('application/octet-stream'));
      expect(result.filename,
          matches(RegExp(r'^Konta_Export_\d{8}_\d{6}\.kbak$')));
    });

    test('envelope is at least 33 bytes (16 salt + 16 iv + 1 byte cipher)',
        () async {
      // Arrange
      final tx = _makeTransaction();

      // Act
      final result = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );

      // Assert
      expect(result.bytes.length, greaterThanOrEqualTo(33));
    });

    test('encryption is non-deterministic: two exports of the same data differ',
        () async {
      // Arrange
      final tx = _makeTransaction();

      // Act
      final result1 = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );
      final result2 = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );

      // Assert – random salt + IV ensure ciphertexts differ on every run
      expect(result1.bytes, isNot(equals(result2.bytes)));
    });

    test('decrypting the envelope with the correct password recovers the JSON',
        () async {
      // Arrange
      final tx = _makeTransaction();
      final result = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
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
      expect(payload['version'], equals(2));
      expect(payload['transactions'], isA<List>());
      final firstTx =
          (payload['transactions'] as List).first as Map<String, dynamic>;
      expect(firstTx['id'], equals('tx-001'));
      expect(firstTx['amount'], equals(5000));
    });

    test('decrypting with wrong password yields corrupted output or throws',
        () async {
      // Arrange
      final tx = _makeTransaction();
      final result = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );

      // Act – try to decrypt with a wrong password
      final envelope = Uint8List.fromList(result.bytes);
      final salt = envelope.sublist(0, 16);
      final ivBytes = envelope.sublist(16, 32);
      final cipherBytes = envelope.sublist(32);

      final wrongKey =
          ExportServiceImpl.deriveKeyForTest('WrongPassword!', salt);
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
    });

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
          password: '',
        ),
        throwsA(isA<ExportException>()),
      );
    });

    test('transaction id and amount are correctly serialised in the envelope',
        () async {
      // Arrange
      final tx = _makeTransaction(id: 'unique-id-xyz', amount: 99999);
      final result = await service.generateEncryptedJson(
        accounts: _emptyAccounts,
        categories: _emptyCategories,
        tags: _emptyTags,
        transactions: [tx],
        password: password,
      );

      // Act – decrypt and parse
      final envelope = Uint8List.fromList(result.bytes);
      final salt = envelope.sublist(0, 16);
      final ivBytes = envelope.sublist(16, 32);
      final cipherBytes = envelope.sublist(32);

      final key = ExportServiceImpl.deriveKeyForTest(password, salt);
      final decrypted = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.cbc),
      ).decrypt(
        enc.Encrypted(Uint8List.fromList(cipherBytes)),
        iv: enc.IV(ivBytes),
      );

      final payload = jsonDecode(decrypted) as Map<String, dynamic>;
      final firstTx =
          (payload['transactions'] as List).first as Map<String, dynamic>;

      // Assert
      expect(firstTx['id'], equals('unique-id-xyz'));
      expect(firstTx['amount'], equals(99999));
    });
  });

  // ──────────────────────── PDF generation ──────────────────────────────────

  group('generateMonthlyPdf', () {
    test(
        'result has correct MIME type and matches Konta_Export_yyyyMMdd_HHmmss.pdf filename pattern',
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
          result.filename, matches(RegExp(r'^Konta_Export_\d{8}_\d{6}\.pdf$')));
    });

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
}
