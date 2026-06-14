import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/core/theme/app_theme.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/entities/transaction.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/presentation/features/dashboard/dashboard_screen.dart';
import 'package:konta/presentation/providers/repository_providers.dart';
import 'package:konta/presentation/widgets/empty_state_widget.dart';

class NeverStream<T> extends Stream<T> {
  const NeverStream();

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return NeverSubscription<T>();
  }
}

class NeverSubscription<T> implements StreamSubscription<T> {
  @override
  Future<void> cancel() => Future.value();
  @override
  void onData(void Function(T data)? handleData) {}
  @override
  void onError(Function? handleError) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;
}

void main() {
  final testAccount = Account(
    id: 'acc_wallet',
    userId: 'user_1',
    name: 'Cash Wallet',
    type: AccountType.cash,
    initialBalance: 500.0,
    currency: 'EUR',
    color: '#FF5722',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime(2026, 6, 1),
    modifiedAt: DateTime(2026, 6, 1),
  );

  final testTransaction = Transaction(
    id: 'txn_1',
    accountId: 'acc_wallet',
    categoryId: 'cat_food',
    amount: 1550, // €15.50
    originalCurrency: 'EUR',
    exchangeRate: 1.0,
    type: TransactionType.expense,
    date: DateTime(2026, 6, 10),
    notes: 'Dinner with friends',
    createdAt: DateTime(2026, 6, 10),
    modifiedAt: DateTime(2026, 6, 10),
  );

  Widget createTestWidget({
    required Stream<List<Transaction>> transactionsStream,
    required Future<List<Account>> accountsFuture,
  }) {
    return ProviderScope(
      overrides: [
        transactionsStreamProvider.overrideWith((ref) => transactionsStream),
        accountsListProvider.overrideWith((ref) => accountsFuture),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders empty state in Overview tab when transactions list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value(<Transaction>[]),
          accountsFuture: Future.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Overview tab is index 0 by default. It displays recent transactions empty state.
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Add your first income or expense to see it here and start tracking.'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state in Transactions tab when transactions list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value(<Transaction>[]),
          accountsFuture: Future.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on the Transactions navigation destination (second tab)
      // Since 'Transactions' label is also used elsewhere, we target the NavigationDestination label.
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('renders empty state in Accounts tab when accounts list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsFuture: Future.value(<Account>[]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tap on the Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No accounts yet'), findsOneWidget);
      expect(
        find.text('Create an account or wallet to start managing your assets and tracking transactions.'),
        findsOneWidget,
      );
    });

    testWidgets('renders lists of transactions and accounts when data is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          transactionsStream: Stream.value([testTransaction]),
          accountsFuture: Future.value([testAccount]),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Overview Tab is default. Verify transaction item notes exist.
      expect(find.text('Dinner with friends'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);

      // Tap Transactions tab
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Dinner with friends'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);

      // Tap Accounts tab
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Cash Wallet'), findsOneWidget);
      expect(find.text('CASH'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);
    });
  });
}
