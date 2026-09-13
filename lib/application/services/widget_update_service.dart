import 'package:flutter/material.dart' show DateTimeRange, Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/currency_converter.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/exchange_rate.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/repositories/i_exchange_rate_repository.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/repositories/i_transaction_repository.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

/// Abstraction for [HomeWidget] calls to enable straightforward testing and mocking.
abstract class HomeWidgetClient {
  Future<bool?> saveWidgetData<T>(
    String id,
    T? data, {
    String? appGroupId,
  });

  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });
}

/// Default implementation delegating directly to [HomeWidget] methods.
class DefaultHomeWidgetClient implements HomeWidgetClient {
  const DefaultHomeWidgetClient();

  @override
  Future<bool?> saveWidgetData<T>(
    String id,
    T? data, {
    String? appGroupId,
  }) {
    return HomeWidget.saveWidgetData<T>(id, data, appGroupId: appGroupId);
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.updateWidget(
      name: name,
      androidName: androidName,
      iOSName: iOSName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }
}

/// Service in the Application layer responsible for pushing calculated financial
/// metrics (such as the last 30 days income and expenses) to the native home screen widgets.
class WidgetUpdateService {
  static const String incomeKey = 'widget_income_text';
  static const String expenseKey = 'widget_expense_text';
  static const String incomeTitleKey = 'widget_income_title';
  static const String expenseTitleKey = 'widget_expense_title';
  static const String androidWidgetName = 'StalviWidgetProvider';
  static const String iOSWidgetName = 'StalviWidget';
  static const String appGroupId = 'group.com.peirov.stalvi';

  final ITransactionRepository _transactionRepository;
  final IProfileRepository _profileRepository;
  final IExchangeRateRepository? _exchangeRateRepository;
  final HomeWidgetClient _homeWidgetClient;
  final DateTime Function() _clock;
  final Locale? _locale;

  WidgetUpdateService({
    required ITransactionRepository transactionRepository,
    required IProfileRepository profileRepository,
    IExchangeRateRepository? exchangeRateRepository,
    HomeWidgetClient? homeWidgetClient,
    DateTime Function()? clock,
    Locale? locale,
  })  : _transactionRepository = transactionRepository,
        _profileRepository = profileRepository,
        _exchangeRateRepository = exchangeRateRepository,
        _homeWidgetClient = homeWidgetClient ?? const DefaultHomeWidgetClient(),
        _clock = clock ?? DateTime.now,
        _locale = locale;

  /// Formats a monetary amount by appending the given currency symbol.
  static String formatAmount(double amount, String currencySymbol) {
    return '${amount.toStringAsFixed(2)} $currencySymbol';
  }

  /// Calculates total income and expenses for the last 30 days in the user's
  /// default currency, formats them, saves them and localized titles to native
  /// widget storage, and requests a native widget UI refresh.
  Future<void> updateWidgetData({Locale? locale}) async {
    // 1. Fetch user's default currency
    final profile = await _profileRepository.getFirstProfile();
    final defaultCurrency = profile?.defaultCurrency ?? 'EUR';
    final currencySymbol = CurrencyFormatter.getCurrencySymbol(defaultCurrency);

    // 2. Fetch transactions from the last 30 days
    final now = _clock();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final startDate = DateTime(
      thirtyDaysAgo.year,
      thirtyDaysAgo.month,
      thirtyDaysAgo.day,
      0,
      0,
      0,
    );
    final endDate = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    final transactions = await _transactionRepository
        .watchFilteredTransactions(
          TransactionQueryFilter(
            dateRange: DateTimeRange(start: startDate, end: endDate),
          ),
        )
        .first;

    // Optional exchange rates for multi-currency conversion
    ExchangeRate? rates;
    if (_exchangeRateRepository != null) {
      try {
        rates = await _exchangeRateRepository.getLocalRates(
          baseCurrency: defaultCurrency,
        );
      } catch (_) {
        rates = null;
      }
    }

    // 3. Calculate total income and total expenses
    double totalIncomeCents = 0.0;
    double totalExpenseCents = 0.0;

    for (final tx in transactions) {
      if (tx.date.isBefore(startDate) || tx.date.isAfter(endDate)) {
        continue;
      }

      final amountCents = CurrencyConverter.convertAmount(
        tx,
        defaultCurrency,
        rates,
      );

      if (tx.type == TransactionType.income) {
        totalIncomeCents += amountCents;
      } else if (tx.type == TransactionType.expense) {
        totalExpenseCents += amountCents;
      }
    }

    final incomeFormatted = formatAmount(
      totalIncomeCents / 100.0,
      currencySymbol,
    );
    final expenseFormatted = formatAmount(
      totalExpenseCents / 100.0,
      currencySymbol,
    );

    // 4. Save formatted strings and localized titles using home_widget
    final activeLocale = locale ?? _locale ?? const Locale('en');
    final l10n = lookupAppLocalizations(activeLocale);

    await _homeWidgetClient.saveWidgetData<String>(
      incomeKey,
      incomeFormatted,
      appGroupId: appGroupId,
    );
    await _homeWidgetClient.saveWidgetData<String>(
      expenseKey,
      expenseFormatted,
      appGroupId: appGroupId,
    );
    await _homeWidgetClient.saveWidgetData<String>(
      incomeTitleKey,
      l10n.widgetIncomeTitle,
      appGroupId: appGroupId,
    );
    await _homeWidgetClient.saveWidgetData<String>(
      expenseTitleKey,
      l10n.widgetExpenseTitle,
      appGroupId: appGroupId,
    );

    // 5. Force native UI refresh
    await _homeWidgetClient.updateWidget(
      name: androidWidgetName,
      androidName: androidWidgetName,
      iOSName: iOSWidgetName,
    );
  }
}

/// Riverpod provider for [WidgetUpdateService].
final widgetUpdateServiceProvider = Provider<WidgetUpdateService>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final exchangeRateRepo = ref.watch(exchangeRateRepositoryProvider);
  final locale = ref.watch(localeProvider);

  return WidgetUpdateService(
    transactionRepository: transactionRepo,
    profileRepository: profileRepo,
    exchangeRateRepository: exchangeRateRepo,
    locale: locale,
  );
});
