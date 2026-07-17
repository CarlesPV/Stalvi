import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/core/utils/automatic_transaction_string_generator.dart';

void main() {
  group('AutomaticTransactionStringGenerator', () {
    late AutomaticTransaction baseTransaction;

    setUp(() {
      baseTransaction = AutomaticTransaction(
        id: '1',
        name: 'Test',
        amount: 100,
        currency: 'EUR',
        type: TransactionType.expense,
        accountId: 'acc1',
        recurrenceDays: 7,
        nextExecutionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
    });

    Widget buildTestWidget(
      AutomaticTransaction txn,
      ValueSetter<String> onFormat,
    ) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onFormat(txn.formatRecurrence(context));
            });
            return const Scaffold();
          },
        ),
      );
    }

    testWidgets('formats 7 days as Weekly', (WidgetTester tester) async {
      String? result;
      final txn = baseTransaction.copyWith(
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 7,
      );

      await tester.pumpWidget(buildTestWidget(txn, (val) => result = val));
      await tester.pumpAndSettle();

      expect(result, equals('Weekly'));
    });

    testWidgets('formats 30 days as Monthly', (WidgetTester tester) async {
      String? result;
      final txn = baseTransaction.copyWith(
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 30,
      );

      await tester.pumpWidget(buildTestWidget(txn, (val) => result = val));
      await tester.pumpAndSettle();

      expect(result, equals('Monthly'));
    });

    testWidgets('formats 365 days as Yearly', (WidgetTester tester) async {
      String? result;
      final txn = baseTransaction.copyWith(
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 365,
      );

      await tester.pumpWidget(buildTestWidget(txn, (val) => result = val));
      await tester.pumpAndSettle();

      expect(result, equals('Yearly'));
    });

    testWidgets('formats custom days correctly', (WidgetTester tester) async {
      String? result;
      final txn = baseTransaction.copyWith(
        recurrenceType: RecurrenceType.intervalDays,
        recurrenceDays: 14,
      );

      await tester.pumpWidget(buildTestWidget(txn, (val) => result = val));
      await tester.pumpAndSettle();

      expect(result, equals('Every 14 days'));
    });

    testWidgets('formats specificDayOfMonth correctly',
        (WidgetTester tester) async {
      String? result;
      final txn = baseTransaction.copyWith(
        recurrenceType: RecurrenceType.specificDayOfMonth,
        recurrenceDays: 15,
      );

      await tester.pumpWidget(buildTestWidget(txn, (val) => result = val));
      await tester.pumpAndSettle();

      expect(result, equals('Every month on the 15'));
    });
  });
}
