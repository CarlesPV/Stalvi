import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/domain/entities/recurrence_type.dart';
import 'automatic_transactions_providers.dart';
import 'repository_providers.dart';
import 'locale_provider.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

class CreateEditAutomaticTransactionState {
  final String? id;
  final String name;
  final String amountText;
  final TransactionType type;
  final String? accountId;
  final String? categoryId;
  final String notes;
  final String? currency;
  final RecurrenceType recurrenceType;
  final int recurrenceDays;
  final AsyncValue<void> submissionStatus;
  final Map<String, String> errors;

  const CreateEditAutomaticTransactionState({
    this.id,
    required this.name,
    required this.amountText,
    required this.type,
    required this.accountId,
    required this.categoryId,
    required this.notes,
    this.currency,
    required this.recurrenceType,
    required this.recurrenceDays,
    required this.submissionStatus,
    required this.errors,
  });

  factory CreateEditAutomaticTransactionState.initial() {
    return const CreateEditAutomaticTransactionState(
      id: null,
      name: '',
      amountText: '',
      type: TransactionType.expense,
      accountId: null,
      categoryId: null,
      notes: '',
      currency: null,
      recurrenceType: RecurrenceType.intervalDays,
      recurrenceDays: 30, // Default to 30 days (1 month)
      submissionStatus: AsyncData<void>(null),
      errors: {},
    );
  }

  factory CreateEditAutomaticTransactionState.fromTransaction(
    AutomaticTransaction transaction,
  ) {
    return CreateEditAutomaticTransactionState(
      id: transaction.id,
      name: transaction.name,
      amountText: (transaction.amount / 100).toString(),
      type: transaction.type,
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      notes: transaction.notes ?? '',
      currency: transaction.currency,
      recurrenceType: transaction.recurrenceType,
      recurrenceDays: transaction.recurrenceDays,
      submissionStatus: const AsyncData<void>(null),
      errors: const {},
    );
  }

  CreateEditAutomaticTransactionState copyWith({
    String? id,
    String? name,
    String? amountText,
    TransactionType? type,
    String? accountId,
    String? Function()? categoryId,
    String? notes,
    String? Function()? currency,
    RecurrenceType? recurrenceType,
    int? recurrenceDays,
    AsyncValue<void>? submissionStatus,
    Map<String, String>? errors,
  }) {
    return CreateEditAutomaticTransactionState(
      id: id ?? this.id,
      name: name ?? this.name,
      amountText: amountText ?? this.amountText,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      notes: notes ?? this.notes,
      currency: currency != null ? currency() : this.currency,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errors: errors ?? this.errors,
    );
  }
}

class CreateEditAutomaticTransactionNotifier extends AutoDisposeFamilyNotifier<
    CreateEditAutomaticTransactionState, AutomaticTransaction?> {
  @override
  CreateEditAutomaticTransactionState build(AutomaticTransaction? arg) {
    if (arg != null) {
      return CreateEditAutomaticTransactionState.fromTransaction(arg);
    }

    ref.listen(accountsListProvider, (previous, next) {
      next.whenData((accounts) {
        if (state.accountId == null && accounts.isNotEmpty) {
          final defaultAccount = accounts.firstWhere(
            (a) => a.isDefault,
            orElse: () => accounts.first,
          );
          state = state.copyWith(accountId: defaultAccount.id);
        }
      });
    });

    final accountsAsyncValue = ref.read(accountsListProvider);
    String? initialAccountId;
    if (accountsAsyncValue.hasValue) {
      final accounts = accountsAsyncValue.value!;
      if (accounts.isNotEmpty) {
        final defaultAccount = accounts.firstWhere(
          (a) => a.isDefault,
          orElse: () => accounts.first,
        );
        initialAccountId = defaultAccount.id;
      }
    }

    ref.listen(defaultProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (state.currency == null) {
          state = state.copyWith(currency: () => profile.defaultCurrency);
        }
      });
    });

    final profileAsyncValue = ref.read(defaultProfileProvider);
    String? initialCurrency;
    if (profileAsyncValue.hasValue) {
      initialCurrency = profileAsyncValue.value!.defaultCurrency;
    }

    return CreateEditAutomaticTransactionState.initial().copyWith(
      accountId: initialAccountId,
      currency: initialCurrency != null ? () => initialCurrency : null,
    );
  }

  void updateName(String name) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('name');
    state = state.copyWith(name: name, errors: newErrors);
  }

  void updateAmount(String text) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('amount');
    state = state.copyWith(amountText: text, errors: newErrors);
  }

  void updateType(TransactionType type) {
    if (state.type != type) {
      state = state.copyWith(
        type: type,
        categoryId: () => null,
        errors: const {},
        submissionStatus: const AsyncData<void>(null),
      );
    }
  }

  void updateAccount(String accountId) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('accountId');
    state = state.copyWith(accountId: accountId, errors: newErrors);
  }

  void updateCategory(String? categoryId) {
    final newErrors = Map<String, String>.from(state.errors);
    if (categoryId != null) {
      newErrors.remove('categoryId');
    }
    state = state.copyWith(categoryId: () => categoryId, errors: newErrors);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateCurrency(String currency) {
    final newErrors = Map<String, String>.from(state.errors);
    if (currency.trim().isNotEmpty) {
      newErrors.remove('currency');
    }
    state = state.copyWith(currency: () => currency, errors: newErrors);
  }

  void updateRecurrence(RecurrenceType type, int value) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('recurrenceDays');
    state = state.copyWith(
      recurrenceType: type,
      recurrenceDays: value,
      errors: newErrors,
    );
  }

  Future<bool> submit() async {
    final amountDouble = CurrencyFormatter.tryParse(state.amountText);
    final locale = ref.read(localeProvider);
    final l10n = lookupAppLocalizations(locale);

    final validationErrors = <String, String>{};

    if (state.name.trim().isEmpty) {
      validationErrors['name'] = 'NAME_REQUIRED';
    }

    if (amountDouble == null || amountDouble <= 0) {
      validationErrors['amount'] = 'INVALID_AMOUNT';
    }

    if (state.accountId == null) {
      validationErrors['accountId'] = 'ACCOUNT_REQUIRED';
    }

    if (state.categoryId == null) {
      validationErrors['categoryId'] = 'CATEGORY_REQUIRED';
    }

    if (state.currency == null || state.currency!.trim().isEmpty) {
      validationErrors['currency'] = 'CURRENCY_REQUIRED';
    }

    if (state.recurrenceType == RecurrenceType.specificDayOfMonth) {
      if (state.recurrenceDays <= 0 || state.recurrenceDays > 31) {
        validationErrors['recurrenceDays'] = 'INVALID_RECURRENCE_DAY';
      }
    } else if (state.recurrenceType == RecurrenceType.intervalDays) {
      if (state.recurrenceDays <= 0 || state.recurrenceDays > 365) {
        validationErrors['recurrenceDays'] = 'INVALID_RECURRENCE_INTERVAL';
      }
    }
    // weekly / monthly / yearly have no recurrenceDays constraint.

    if (validationErrors.isNotEmpty) {
      final firstKey = validationErrors.keys.first;
      final firstCode = validationErrors[firstKey]!;
      String message = '';
      switch (firstCode) {
        case 'NAME_REQUIRED':
          message = 'Name is required'; // Or localized string
          break;
        case 'INVALID_AMOUNT':
          message = l10n.errorInvalidAmount;
          break;
        case 'ACCOUNT_REQUIRED':
          message = l10n.errorAccountRequired;
          break;
        case 'CATEGORY_REQUIRED':
          message = l10n.errorCategoryRequired;
          break;
        case 'CURRENCY_REQUIRED':
          message = l10n.errorCurrencyRequired;
          break;
        case 'INVALID_RECURRENCE_DAY':
          message = 'Invalid day of month (must be 1-31)';
          break;
        case 'INVALID_RECURRENCE_INTERVAL':
          message = 'Invalid recurrence interval'; // Or localized string
          break;
      }
      state = state.copyWith(
        errors: validationErrors,
        submissionStatus: AsyncValue.error(
          ValidationException(
            message: message,
            code: firstCode,
          ),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(
      errors: const {},
      submissionStatus: const AsyncValue.loading(),
    );

    try {
      final cents = (amountDouble! * 100).round();
      final id = state.id ?? const Uuid().v4();
      final trimmedNotes = state.notes.trim();

      DateTime calcNextDate() {
        // On edit: keep the existing future date unchanged.
        if (arg != null && arg!.nextExecutionDate.isAfter(DateTime.now())) {
          return arg!.nextExecutionDate;
        }
        final now = DateTime.now();
        switch (state.recurrenceType) {
          case RecurrenceType.intervalDays:
            return now.add(Duration(days: state.recurrenceDays));

          case RecurrenceType.weekly:
            return now.add(const Duration(days: 7));

          case RecurrenceType.monthly:
            // Same calendar day next month, clamped.
            final lastDay = DateTime(now.year, now.month + 2, 0).day;
            final targetDay = now.day.clamp(1, lastDay);
            int nextMonth = now.month + 1;
            int nextYear = now.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            return DateTime(
              nextYear,
              nextMonth,
              targetDay,
              now.hour,
              now.minute,
              now.second,
            );

          case RecurrenceType.yearly:
            // Same calendar date next year, clamped.
            final yLastDay = DateTime(now.year + 1, now.month + 1, 0).day;
            final yTargetDay = now.day.clamp(1, yLastDay);
            return DateTime(
              now.year + 1,
              now.month,
              yTargetDay,
              now.hour,
              now.minute,
              now.second,
            );

          case RecurrenceType.specificDayOfMonth:
            int nextMonth = now.month + 1;
            int nextYear = now.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            final lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            final targetDay = state.recurrenceDays.clamp(1, lastDayOfNextMonth);
            return DateTime(
              nextYear,
              nextMonth,
              targetDay,
              now.hour,
              now.minute,
              now.second,
            );
        }
      }

      final txn = AutomaticTransaction(
        id: id,
        name: state.name.trim(),
        amount: cents,
        currency: state.currency!,
        type: state.type,
        accountId: state.accountId!,
        categoryId: state.categoryId,
        notes: trimmedNotes.isEmpty ? null : trimmedNotes,
        recurrenceType: state.recurrenceType,
        recurrenceDays: state.recurrenceDays,
        nextExecutionDate: calcNextDate(),
        createdAt: arg?.createdAt ?? DateTime.now(),
      );

      if (arg == null) {
        await ref.read(createAutomaticTransactionUseCaseProvider).execute(txn);
      } else {
        await ref.read(updateAutomaticTransactionUseCaseProvider).execute(txn);
      }

      ref.invalidate(automaticTransactionsListProvider);

      state = state.copyWith(submissionStatus: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(submissionStatus: AsyncValue.error(e, st));
      return false;
    }
  }
}

final createEditAutomaticTransactionNotifierProvider =
    NotifierProvider.autoDispose.family<CreateEditAutomaticTransactionNotifier,
        CreateEditAutomaticTransactionState, AutomaticTransaction?>(
  CreateEditAutomaticTransactionNotifier.new,
);
