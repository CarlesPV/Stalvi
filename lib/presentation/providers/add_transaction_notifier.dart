import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/utils/currency_formatter.dart';
import 'package:stalvi/domain/entities/transaction_type.dart';
import 'package:stalvi/domain/usecases/add_transaction_usecase.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

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
  }) {
    return AddTransactionState(
      amountText: amountText ?? this.amountText,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountIdFn != null ? toAccountIdFn() : this.toAccountId,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      currency: currency != null ? currency() : this.currency,
      tagId: tagId != null ? tagId() : this.tagId,
      submissionStatus: submissionStatus ?? this.submissionStatus,
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
    state = state.copyWith(amountText: text);
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
      );
    }
  }

  /// Select account.
  void updateAccount(String accountId) {
    state = state.copyWith(accountId: accountId);
  }

  /// Select destination account for transfers.
  void updateToAccount(String? toAccountId) {
    state = state.copyWith(toAccountIdFn: () => toAccountId);
  }

  /// Select category.
  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: () => categoryId);
  }

  /// Update notes.
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Update date.
  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Update currency.
  void updateCurrency(String currency) {
    state = state.copyWith(currency: () => currency);
  }

  /// Update tag.
  void updateTag(String? tagId) {
    state = state.copyWith(tagId: () => tagId);
  }

  /// Validates the form state and attempts to execute the use case.
  /// Returns `true` on success and `false` on failure.
  Future<bool> submit() async {
    final amountDouble = CurrencyFormatter.tryParse(state.amountText);
    if (amountDouble == null || amountDouble <= 0) {
      state = state.copyWith(
        submissionStatus: AsyncValue.error(
          const ValidationException(
            message: 'Please enter a valid amount greater than 0',
            code: 'INVALID_AMOUNT',
          ),
          StackTrace.current,
        ),
      );
      return false;
    }

    if (state.accountId == null) {
      state = state.copyWith(
        submissionStatus: AsyncValue.error(
          const ValidationException(
            message: 'Please select an account',
            code: 'ACCOUNT_REQUIRED',
          ),
          StackTrace.current,
        ),
      );
      return false;
    }

    if (state.type == TransactionType.transfer) {
      if (state.toAccountId == null) {
        state = state.copyWith(
          submissionStatus: AsyncValue.error(
            const ValidationException(
              message: 'Please select a destination account',
              code: 'TO_ACCOUNT_REQUIRED',
            ),
            StackTrace.current,
          ),
        );
        return false;
      }
      if (state.accountId == state.toAccountId) {
        state = state.copyWith(
          submissionStatus: AsyncValue.error(
            const ValidationException(
              message: 'Source and destination accounts cannot be the same',
              code: 'SAME_ACCOUNTS',
            ),
            StackTrace.current,
          ),
        );
        return false;
      }
    } else {
      if (state.categoryId == null) {
        state = state.copyWith(
          submissionStatus: AsyncValue.error(
            const ValidationException(
              message: 'Please select a category',
              code: 'CATEGORY_REQUIRED',
            ),
            StackTrace.current,
          ),
        );
        return false;
      }
    }

    final now = DateTime.now();
    if (state.date.isAfter(now)) {
      state = state.copyWith(
        submissionStatus: AsyncValue.error(
          const ValidationException(
            message: 'Transaction date cannot be in the future',
            code: 'FUTURE_DATE',
          ),
          StackTrace.current,
        ),
      );
      return false;
    }

    if (state.currency == null || state.currency!.trim().isEmpty) {
      state = state.copyWith(
        submissionStatus: AsyncValue.error(
          const ValidationException(
            message: 'Please select a currency',
            code: 'CURRENCY_REQUIRED',
          ),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(submissionStatus: const AsyncValue.loading());

    try {
      final useCase = ref.read(addTransactionUseCaseProvider);
      final cents = (amountDouble * 100).round();

      if (state.type == TransactionType.transfer) {
        final outflowId = const Uuid().v4();
        final inflowId = const Uuid().v4();

        // 1. Create Outflow transaction (Transfer type on From Account)
        await useCase.execute(
          AddTransactionParams(
            id: outflowId,
            amount: cents,
            date: state.date,
            type: TransactionType.transfer,
            accountId: state.accountId!,
            categoryId: state.categoryId,
            notes: state.notes.trim().isEmpty ? 'Transfer' : state.notes.trim(),
            currency: state.currency,
          ),
        );

        // 2. Create Inflow transaction (Income type on To Account)
        await useCase.execute(
          AddTransactionParams(
            id: inflowId,
            amount: cents,
            date: state.date,
            type: TransactionType.income,
            accountId: state.toAccountId!,
            categoryId: state.categoryId,
            notes: state.notes.trim().isEmpty ? 'Transfer' : state.notes.trim(),
            currency: state.currency,
          ),
        );
      } else {
        final id = const Uuid().v4();
        await useCase.execute(
          AddTransactionParams(
            id: id,
            amount: cents,
            date: state.date,
            type: state.type,
            accountId: state.accountId!,
            categoryId: state.categoryId,
            notes: state.notes.trim(),
            currency: state.currency,
          ),
        );
      }

      // Successfully saved transaction, invalidate account list to refresh balances
      ref.invalidate(accountsListProvider);

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
