import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/core/utils/currency_formatter.dart';
import 'package:konta/domain/entities/transaction_type.dart';
import 'package:konta/domain/usecases/add_transaction_usecase.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

/// State representation for the Add Transaction form.
class AddTransactionState {
  final String amountText;
  final TransactionType type;
  final String? accountId;
  final String? categoryId;
  final String notes;
  final DateTime date;
  final AsyncValue<void> submissionStatus;

  const AddTransactionState({
    required this.amountText,
    required this.type,
    required this.accountId,
    required this.categoryId,
    required this.notes,
    required this.date,
    required this.submissionStatus,
  });

  factory AddTransactionState.initial() {
    return AddTransactionState(
      amountText: '',
      type: TransactionType.expense,
      accountId: null,
      categoryId: null,
      notes: '',
      date: DateTime.now(),
      submissionStatus: const AsyncData<void>(null),
    );
  }

  AddTransactionState copyWith({
    String? amountText,
    TransactionType? type,
    String? accountId,
    String? Function()? categoryId,
    String? notes,
    DateTime? date,
    AsyncValue<void>? submissionStatus,
  }) {
    return AddTransactionState(
      amountText: amountText ?? this.amountText,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      notes: notes ?? this.notes,
      date: date ?? this.date,
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

    return AddTransactionState.initial().copyWith(
      accountId: initialAccountId,
    );
  }

  /// Update the numeric string amount in the form state.
  void updateAmount(String text) {
    state = state.copyWith(amountText: text);
  }

  /// Update the transaction type (income / expense) in the form state.
  /// Also resets category ID if the selected type changes, since category items
  /// are filtered by category type.
  void updateType(TransactionType type) {
    if (state.type != type) {
      state = state.copyWith(
        type: type,
        categoryId: () => null, // Reset selected category as its type changes
      );
    }
  }

  /// Select account.
  void updateAccount(String accountId) {
    state = state.copyWith(accountId: accountId);
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

    state = state.copyWith(submissionStatus: const AsyncValue.loading());

    try {
      final useCase = ref.read(addTransactionUseCaseProvider);
      final cents = (amountDouble * 100).round();
      final id = const Uuid().v4();

      await useCase.execute(
        AddTransactionParams(
          id: id,
          amount: cents,
          date: state.date,
          type: state.type,
          accountId: state.accountId!,
          categoryId: state.categoryId,
          notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        ),
      );

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
