import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/automatic_transaction_table.dart';
import '../tables/account_table.dart';
import '../tables/category_table.dart';
import '../tables/tag_table.dart';

part 'automatic_transaction_dao.g.dart';

@DriftAccessor(tables: [AutomaticTransactions, Accounts, Categories, Tags])
class AutomaticTransactionDao extends DatabaseAccessor<AppDatabase>
    with _$AutomaticTransactionDaoMixin {
  AutomaticTransactionDao(super.db);

  Future<int> insertAutomaticTransaction(
    AutomaticTransactionsCompanion companion,
  ) {
    return into(automaticTransactions).insert(companion);
  }

  Future<AutomaticTransactionEntity> getAutomaticTransactionById(String id) {
    return (select(automaticTransactions)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<List<AutomaticTransactionEntity>> getAllAutomaticTransactions() {
    return select(automaticTransactions).get();
  }

  Future<bool> updateAutomaticTransaction(
    AutomaticTransactionsCompanion companion,
  ) {
    return update(automaticTransactions).replace(companion);
  }

  Future<int> deleteAutomaticTransaction(String id) {
    return (delete(automaticTransactions)..where((t) => t.id.equals(id))).go();
  }
}
