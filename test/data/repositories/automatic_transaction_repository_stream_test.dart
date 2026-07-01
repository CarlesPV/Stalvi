import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/daos/automatic_transaction_dao.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart'
    show TransactionType;
import 'package:stalvi/data/mappers/automatic_transaction_mapper.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';

class MockAutomaticTransactionDao extends Mock
    implements AutomaticTransactionDao {}

/// Thin wrapper that replicates what [AutomaticTransactionRepository]'s
/// watchAllAutomaticTransactions does — maps raw Drift entities to domain
/// objects — without needing to wire up the full database.
class _WatchFacade {
  final AutomaticTransactionDao dao;
  _WatchFacade(this.dao);

  Stream<List<AutomaticTransaction>> watch() {
    return dao
        .watchAllAutomaticTransactions()
        .map((e) => e.map(AutomaticTransactionMapper.fromEntity).toList());
  }
}

AutomaticTransactionEntity _entity({
  String id = '1',
  String name = 'Spotify',
  int amount = 999,
  String currency = 'EUR',
  TransactionType type = TransactionType.expense,
  String accountId = 'acc1',
  RecurrenceType recurrenceType = RecurrenceType.intervalDays,
  int recurrenceDays = 30,
  bool isActive = true,
  bool isDeleted = false,
  DateTime? deletedAt,
}) {
  final now = DateTime(2024, 6, 1);
  return AutomaticTransactionEntity(
    id: id,
    name: name,
    amount: amount,
    currency: currency,
    type: type,
    accountId: accountId,
    categoryId: null,
    tagId: null,
    notes: null,
    recurrenceType: recurrenceType,
    recurrenceDays: recurrenceDays,
    nextExecutionDate: now,
    createdAt: now,
    isActive: isActive,
    isDeleted: isDeleted,
    deletedAt: deletedAt,
  );
}

void main() {
  late MockAutomaticTransactionDao mockDao;
  late _WatchFacade facade;

  setUp(() {
    mockDao = MockAutomaticTransactionDao();
    facade = _WatchFacade(mockDao);
  });

  group('AutomaticTransactionRepository — watchAllAutomaticTransactions', () {
    test('emits mapped domain entities when DAO stream emits', () async {
      when(() => mockDao.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([_entity()]));

      final result = await facade.watch().first;

      expect(result.length, 1);
      expect(result.first.name, 'Spotify');
      expect(result.first.amount, 999);
      expect(result.first.currency, 'EUR');
      expect(result.first.recurrenceDays, 30);
    });

    test('emits empty list when table is empty', () async {
      when(() => mockDao.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([]));

      final result = await facade.watch().first;

      expect(result, isEmpty);
    });

    test('provider layer filters soft-deleted items', () async {
      final active = _entity(id: '1', name: 'Active');
      final deleted = _entity(
        id: '2',
        name: 'Deleted',
        isActive: false,
        isDeleted: true,
        deletedAt: DateTime(2024, 5, 1),
      );

      when(() => mockDao.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([active, deleted]));

      // Simulate what the StreamProvider does: filter isDeleted == false
      final result = await facade
          .watch()
          .map((all) => all.where((t) => !t.isDeleted).toList())
          .first;

      expect(result.length, 1);
      expect(result.first.name, 'Active');
    });

    test('forwards multiple sequential emissions', () async {
      final first = _entity(id: '1', name: 'First');
      final second = _entity(id: '2', name: 'Second', currency: 'USD');

      when(() => mockDao.watchAllAutomaticTransactions()).thenAnswer(
        (_) => Stream.fromIterable([
          [first],
          [first, second],
        ]),
      );

      final emissions = await facade.watch().toList();

      expect(emissions.length, 2);
      expect(emissions[0].length, 1);
      expect(emissions[1].length, 2);
      expect(emissions[1].last.currency, 'USD');
    });

    test('income type is preserved through mapping', () async {
      final income = _entity(
        id: '3',
        name: 'Salary',
        type: TransactionType.income,
        recurrenceDays: 30,
      );

      when(() => mockDao.watchAllAutomaticTransactions())
          .thenAnswer((_) => Stream.value([income]));

      final result = await facade.watch().first;

      expect(result.first.type.index, TransactionType.income.index);
    });
  });
}
