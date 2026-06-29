import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import '../database/app_database.dart' as db;
import '../database/tables/account_table.dart' as db_table;

extension AccountMapper on Account {
  db.Account toDb() {
    return db.Account(
      id: id,
      userId: userId,
      name: name,
      type: _mapTypeToDb(type),
      initialBalance: initialBalance,
      currency: currency,
      color: color,
      icon: icon,
      isDefault: isDefault,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  db_table.AccountType _mapTypeToDb(AccountType domainType) {
    switch (domainType) {
      case AccountType.cash:
        return db_table.AccountType.cash;
      case AccountType.bank:
        return db_table.AccountType.bank;
      case AccountType.savings:
        return db_table.AccountType.savings;
      case AccountType.card:
        return db_table.AccountType.card;
      case AccountType.other:
        return db_table.AccountType.other;
    }
  }
}

extension DbAccountMapper on db.Account {
  Account toDomain() {
    return Account(
      id: id,
      userId: userId,
      name: name,
      type: _mapTypeToDomain(type),
      initialBalance: initialBalance,
      currency: currency,
      color: color,
      icon: icon,
      isDefault: isDefault,
      isDeleted: isDeleted,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  AccountType _mapTypeToDomain(db_table.AccountType dbType) {
    switch (dbType) {
      case db_table.AccountType.cash:
        return AccountType.cash;
      case db_table.AccountType.bank:
        return AccountType.bank;
      case db_table.AccountType.savings:
        return AccountType.savings;
      case db_table.AccountType.card:
        return AccountType.card;
      case db_table.AccountType.other:
        return AccountType.other;
    }
  }
}
