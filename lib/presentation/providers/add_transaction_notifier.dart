import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/usecases/add_transaction_usecase.dart';
import 'repository_providers.dart';
import 'statistics_providers.dart';
import 'locale_provider.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

/// State representation for the Add Transaction form.
/// State representation for the Add Transaction form.
class AddTransactionState {
  final String amountText;
  final TransactionType type;
  final String? accountId;
  final String? toAccountId;
  final String? categoryId;
  final String notes;
  final DateTime date;
  final String? currency;
  final String? tagId;
  final AsyncValue<void> submissionStatus;
  final Map<String, String> errors;

  const AddTransactionState({
    required this.amountText,
    required this.type,
    required this.accountId,
    this.toAccountId,
    required this.categoryId,
    required this.notes,
    required this.date,
    this.currency,
    this.tagId,
    required this.submissionStatus,
    required this.errors,
  });

  factory AddTransactionState.initial() {
    return AddTransactionState(
      amountText: '',
      type: TransactionType.expense,
      accountId: null,
      toAccountId: null,
      categoryId: null,
      notes: '',
      date: DateTime.now(),
      currency: null,
      tagId: null,
      submissionStatus: const AsyncData<void>(null),
      errors: const {},
    );
  }

  AddTransactionState copyWith({
    String? amountText,
    TransactionType? type,
    String? accountId,
    String? Function()? toAccountIdFn,
    String? Function()? categoryId,
    String? notes,
    DateTime? date,
    String? Function()? currency,
    String? Function()? tagId,
    AsyncValue<void>? submissionStatus,
    Map<String, String>? errors,
  }) {
    return AddTransactionState(
      amountText: amountText ?? this.amountText,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountIdFn != null ? toAccountIdFn() : toAccountId,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      currency: currency != null ? currency() : this.currency,
      tagId: tagId != null ? tagId() : this.tagId,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errors: errors ?? this.errors,
    );
  }
}

/// Form state controller that manages form input fields, performs validation,
/// and executes [AddTransactionUseCase] using the clean architecture boundaries.
class AddTransactionNotifier extends AutoDisposeNotifier<AddTransactionState> {
  @override
  AddTransactionState build() {
    // Listens to accounts list. When loaded, defaults the selected account to
    // the default account (or the first available).
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

    // Try to get initial value if accounts are already cached/loaded.
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

    // Default to the user's default setting for currency.
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

    return AddTransactionState.initial().copyWith(
      accountId: initialAccountId,
      currency: initialCurrency != null ? () => initialCurrency : null,
    );
  }

  /// Update the numeric string amount in the form state.
  void updateAmount(String text) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('amount');
    state = state.copyWith(amountText: text, errors: newErrors);
  }

  /// Update the transaction type (income / expense / transfer) in the form state.
  /// Also resets category ID if the selected type changes, since category items
  /// are filtered by category type.
  void updateType(TransactionType type) {
    if (state.type != type) {
      state = state.copyWith(
        type: type,
        categoryId: () => null, // Reset selected category as its type changes
        toAccountIdFn: () => null, // Clear destination account if type changes
        errors: const {}, // Completely clear form errors
        submissionStatus:
            const AsyncData<void>(null), // Reset submission status
      );
    }
  }

  /// Select account.
  void updateAccount(String accountId) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('accountId');
    if (state.toAccountId != accountId) {
      newErrors.remove('toAccountId');
    }
    state = state.copyWith(accountId: accountId, errors: newErrors);
  }

  /// Select destination account for transfers.
  void updateToAccount(String? toAccountId) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove('toAccountId');
    state = state.copyWith(toAccountIdFn: () => toAccountId, errors: newErrors);
  }

  /// Select category.
  void updateCategory(String? categoryId) {
    final newErrors = Map<String, String>.from(state.errors);
    if (categoryId != null) {
      newErrors.remove('categoryId');
    }
    state = state.copyWith(categoryId: () => categoryId, errors: newErrors);
  }

  /// Update notes.
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Update date.
  void updateDate(DateTime date) {
    final newErrors = Map<String, String>.from(state.errors);
    final now = DateTime.now();
    if (!date.isAfter(now)) {
      newErrors.remove('date');
    }
    state = state.copyWith(date: date, errors: newErrors);
  }

  /// Update currency.
  void updateCurrency(String currency) {
    final newErrors = Map<String, String>.from(state.errors);
    if (currency.trim().isNotEmpty) {
      newErrors.remove('currency');
    }
    state = state.copyWith(currency: () => currency, errors: newErrors);
  }

  /// Update tag.
  void updateTag(String? tagId) {
    state = state.copyWith(tagId: () => tagId);
  }

  /// Validates the form state and attempts to execute the use case.
  /// Returns `true` on success and `false` on failure.
  Future<bool> submit() async {
    final amountDouble = CurrencyFormatter.tryParse(state.amountText);
    final locale = ref.read(localeProvider);
    final l10n = lookupAppLocalizations(locale);

    final validationErrors = <String, String>{};

    if (amountDouble == null || amountDouble <= 0) {
      validationErrors['amount'] = 'INVALID_AMOUNT';
    }

    if (state.accountId == null) {
      validationErrors['accountId'] = 'ACCOUNT_REQUIRED';
    }

    if (state.type == TransactionType.transfer) {
      if (state.toAccountId == null) {
        validationErrors['toAccountId'] = 'TO_ACCOUNT_REQUIRED';
      } else if (state.accountId == state.toAccountId) {
        validationErrors['toAccountId'] = 'SAME_ACCOUNTS';
      }
    } else {
      if (state.categoryId == null) {
        validationErrors['categoryId'] = 'CATEGORY_REQUIRED';
      }
    }

    final now = DateTime.now();
    if (state.date.isAfter(now)) {
      validationErrors['date'] = 'FUTURE_DATE';
    }

    if (state.currency == null || state.currency!.trim().isEmpty) {
      validationErrors['currency'] = 'CURRENCY_REQUIRED';
    }

    if (validationErrors.isNotEmpty) {
      final firstKey = validationErrors.keys.first;
      final firstCode = validationErrors[firstKey]!;
      String message = '';
      switch (firstCode) {
        case 'INVALID_AMOUNT':
          message = l10n.errorInvalidAmount;
          break;
        case 'ACCOUNT_REQUIRED':
          message = l10n.errorAccountRequired;
          break;
        case 'TO_ACCOUNT_REQUIRED':
          message = l10n.errorDestinationAccountRequired;
          break;
        case 'SAME_ACCOUNTS':
          message = l10n.errorSameAccountTransfer;
          break;
        case 'CATEGORY_REQUIRED':
          message = l10n.errorCategoryRequired;
          break;
        case 'FUTURE_DATE':
          message = l10n.errorFutureDate;
          break;
        case 'CURRENCY_REQUIRED':
          message = l10n.errorCurrencyRequired;
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
      final useCase = ref.read(addTransactionUseCaseProvider);
      final cents = (amountDouble! * 100).round();

      final id = const Uuid().v4();
      final trimmedNotes = state.notes.trim();

      final savingsGoals =
          ref.read(savingsGoalsStreamProvider).valueOrNull ?? [];
      final isSavingsGoal = savingsGoals.any((g) => g.id == state.toAccountId);

      await useCase.execute(
        AddTransactionParams(
          id: id,
          amount: cents,
          date: state.date,
          type: state.type,
          accountId: state.accountId!,
          destinationAccountId:
              (state.type == TransactionType.transfer && !isSavingsGoal)
                  ? state.toAccountId
                  : null,
          destinationSavingsGoalId:
              (state.type == TransactionType.transfer && isSavingsGoal)
                  ? state.toAccountId
                  : null,
          categoryId: state.categoryId,
          notes: trimmedNotes.isEmpty ? null : trimmedNotes,
          currency: state.currency,
        ),
      );

      // Successfully saved transaction, invalidate account list to refresh balances
      ref.invalidate(accountsListProvider);
      ref.invalidate(transactionsStreamProvider);
      ref.invalidate(periodSummaryProvider);
      ref.invalidate(topExpenseCategoriesProvider);
      ref.invalidate(topIncomeCategoriesProvider);

      state = state.copyWith(submissionStatus: const AsyncValue.data(null));
      return true;
    } catch (e, st) {
      state = state.copyWith(submissionStatus: AsyncValue.error(e, st));
      return false;
    }
  }
}

/// Global provider for the auto-disposing state notifier.
final addTransactionNotifierProvider =
    AutoDisposeNotifierProvider<AddTransactionNotifier, AddTransactionState>(
  AddTransactionNotifier.new,
);
