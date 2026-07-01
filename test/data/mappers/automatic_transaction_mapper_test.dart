import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/data/mappers/automatic_transaction_mapper.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/transaction_table.dart' as db_table;

void main() {
  group('AutomaticTransactionMapper', () {
    final now = DateTime.now();
    final entity = AutomaticTransactionEntity(
      id: '1',
      name: 'Test',
      amount: 1000,
      currency: 'USD',
      type: db_table.TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      tagId: 'tag1',
      notes: 'Test note',
      recurrenceDays: 30,
      nextExecutionDate: now,
      createdAt: now,
      isActive: true,
      isDeleted: false,
    );

    final model = AutomaticTransaction(
      id: '1',
      name: 'Test',
      amount: 1000,
      currency: 'USD',
      type: TransactionType.expense,
      accountId: 'acc1',
      categoryId: 'cat1',
      tagId: 'tag1',
      notes: 'Test note',
      recurrenceDays: 30,
      nextExecutionDate: now,
      createdAt: now,
    );

    test('fromEntity maps correctly', () {
      final result = AutomaticTransactionMapper.fromEntity(entity);
      expect(result.id, model.id);
      expect(result.amount, model.amount);
      expect(result.type, model.type);
      expect(result.accountId, model.accountId);
      expect(result.categoryId, model.categoryId);
      expect(result.tagId, model.tagId);
      expect(result.notes, model.notes);
      expect(result.recurrenceDays, model.recurrenceDays);
      expect(result.nextExecutionDate, model.nextExecutionDate);
      expect(result.createdAt, model.createdAt);
    });

    test('toCompanion maps correctly', () {
      final companion = AutomaticTransactionMapper.toCompanion(model);
      expect(companion.id.value, model.id);
      expect(companion.amount.value, model.amount);
      expect(companion.type.value, db_table.TransactionType.expense);
      expect(companion.accountId.value, model.accountId);
      expect(companion.categoryId.value, model.categoryId);
      expect(companion.tagId.value, model.tagId);
      expect(companion.notes.value, model.notes);
      expect(companion.recurrenceDays.value, model.recurrenceDays);
      expect(companion.nextExecutionDate.value, model.nextExecutionDate);
      expect(companion.createdAt.value, model.createdAt);
    });
  });
}
