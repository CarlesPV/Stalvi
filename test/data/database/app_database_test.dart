import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:stalvi/data/database/app_database.dart';
import 'package:stalvi/data/database/tables/account_table.dart';
import 'package:stalvi/data/database/tables/category_table.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      return DynamicLibrary.open('libsqlite3.so.0');
    });
  });

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database initialization seeds default Account and Categories',
      () async {
    // Act: Querying the tables will trigger the onCreate migration logic
    final accounts = await db.select(db.accounts).get();
    final categories = await db.select(db.categories).get();
    final profiles = await db.select(db.profiles).get();

    // Assert: Anonymous profile was created
    expect(profiles.length, 1);
    expect(profiles.first.name, 'Anonymous');

    // Assert: No default account should be created in DB migration
    expect(accounts.length, 0);

    // Assert: Functional Categories were created
    expect(categories.length, 3);

    final categoryNames = categories.map((c) => c.name).toList();
    expect(categoryNames, contains('Food'));
    expect(categoryNames, contains('Transport'));
    expect(categoryNames, contains('Salary'));

    final foodCat = categories.firstWhere((c) => c.name == 'Food');
    expect(foodCat.associatedType, CategoryAssociatedType.expense);

    final salaryCat = categories.firstWhere((c) => c.name == 'Salary');
    expect(salaryCat.associatedType, CategoryAssociatedType.income);
  });
}
