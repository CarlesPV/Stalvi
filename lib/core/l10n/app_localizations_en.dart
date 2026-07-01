// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Settings';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String income(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Incomes',
      one: 'Income',
    );
    return '$_temp0';
  }

  @override
  String get incomes => 'Income';

  @override
  String expense(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expenses',
      one: 'Expense',
    );
    return '$_temp0';
  }

  @override
  String get expenses => 'Expenses';

  @override
  String get appTitle => 'Stalvi';

  @override
  String get splashTagline => 'Your finances, your way.';

  @override
  String get splashStartupFailed => 'Startup Failed';

  @override
  String get splashSecureStorageError =>
      'Stalvi couldn\'t initialise its secure storage. Please check available device storage and try again.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get authError => 'Authentication Error';

  @override
  String get authLockedTitle => 'Biometrics Locked';

  @override
  String get authLockedMessage =>
      'Too many failed attempts. Please unlock your device from the lock screen and try again.';

  @override
  String get authLockoutActive => 'Security lockout active';

  @override
  String get authVerifyMessage =>
      'Use biometrics or your device PIN to continue';

  @override
  String get authProcessing => 'Processing security authentication…';

  @override
  String get authProtectedBy => 'Protected by device biometrics';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get overview => 'Overview';

  @override
  String get accounts => 'Accounts';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get noTransactionsSubtitle =>
      'Add your first income or expense to see it here and start tracking.';

  @override
  String get failedLoadTransactions => 'Failed to load transactions';

  @override
  String get settingsBudgetsGoals => 'Budgets & Goals';

  @override
  String get settingsStatistics => 'Statistics';

  @override
  String get balanceTotal => 'Total Balance';

  @override
  String get statisticsTooltipCustomRange => 'Custom date range';

  @override
  String get statisticsTopSpending => 'Top Spending Categories';

  @override
  String get statisticsWhereMoneyGoes => 'Where your money goes';

  @override
  String get statisticsNoExpenses => 'No expenses recorded in this period.';

  @override
  String get statisticsTopIncome => 'Top Income Categories';

  @override
  String get statisticsWhatYouEarned => 'What you earned';

  @override
  String get statisticsNoIncome => 'No income recorded in this period.';

  @override
  String get statisticsNetBalance => 'Net Balance';

  @override
  String get statisticsSurplus => 'Surplus';

  @override
  String get statisticsDeficit => 'Deficit';

  @override
  String get presetLast30Days => 'Last 30 Days';

  @override
  String get presetThisMonth => 'This Month';

  @override
  String get presetLast3Months => 'Last 3 Months';

  @override
  String get presetLast6Months => 'Last 6 Months';

  @override
  String get presetThisYear => 'This Year';

  @override
  String get presetCustom => 'Custom';

  @override
  String get budgetsAndGoals => 'Budgets & Goals';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get failedLoadBudgets => 'Failed to load budgets.';

  @override
  String get noBudgetsTitle => 'No budgets set yet';

  @override
  String get noBudgetsSubtitle =>
      'Set spending limits for categories to track your monthly expenses and stay within your limits.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String budgetOverspent(String amount) {
    return '$amount overspent';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get failedLoadSavingsGoals => 'Failed to load savings goals.';

  @override
  String get noSavingsGoalsTitle => 'No savings goals yet';

  @override
  String get noSavingsGoalsSubtitle =>
      'Create a savings goal to plan for your future dreams, trips, or big purchases.';

  @override
  String savingsTargetDate(String date) {
    return 'Target date: $date';
  }

  @override
  String get savingsNoTargetDate => 'No target date';

  @override
  String savingsSavedOf(String saved, String target) {
    return '$saved saved of $target';
  }

  @override
  String get savingsGoalAchieved => 'Goal achieved!';

  @override
  String get txnSuccessCreated => 'Transaction created successfully!';

  @override
  String get labelAmount => 'AMOUNT';

  @override
  String get labelAccount => 'Account';

  @override
  String get labelSelectAccount => 'Select Account';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelSelectCategory => 'Select Category';

  @override
  String get labelDate => 'Date';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelNotesHint => 'Add details about this transaction...';

  @override
  String get btnSaveTransaction => 'Save Transaction';

  @override
  String get errorInvalidAmount => 'Please enter a valid amount greater than 0';

  @override
  String get errorAccountRequired => 'Please select an account';

  @override
  String get errorFutureDate => 'Transaction date cannot be in the future';

  @override
  String get errorAccountNotFound => 'Account not found';

  @override
  String get errorProfileNotFound => 'Profile not found';

  @override
  String get errorRateNotFound =>
      'Exchange rate not available for the requested currency';

  @override
  String get errorConversionFailed => 'Failed to convert currency';

  @override
  String get getStarted => 'Get Started';

  @override
  String get authSetupTitle => 'Create Your Profile';

  @override
  String get authSetupSubtitle => 'Set up your secure offline wallet to begin.';

  @override
  String get authSetupNameLabel => 'Name';

  @override
  String get authSetupUsernameLabel => 'Username';

  @override
  String get authSetupPinLabel => 'Set a 4-8 digit PIN';

  @override
  String get authSetupConfirmPinLabel => 'Confirm PIN';

  @override
  String get authSetupLanguageLabel => 'Default Language';

  @override
  String get authSetupCreateButton => 'Create Profile';

  @override
  String get authSetupValidationErrorPinLength =>
      'PIN must be between 4 and 8 digits.';

  @override
  String get authSetupValidationErrorPinMatch => 'PINs do not match.';

  @override
  String get authSetupValidationErrorTerms =>
      'You must accept the Terms & Conditions and Privacy Policy to proceed.';

  @override
  String get authSetupValidationErrorName => 'Please enter a name.';

  @override
  String get authSetupValidationErrorUsername => 'Please enter a username.';

  @override
  String get authPinEnter => 'Enter PIN';

  @override
  String authPinAttemptsRemaining(int attempts) {
    return '$attempts attempts remaining';
  }

  @override
  String get authPinIncorrect => 'Incorrect PIN. Please try again.';

  @override
  String acrossAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String get failedLoadAccounts => 'Failed to load accounts.';

  @override
  String get noAccountsTitle => 'No accounts yet';

  @override
  String get noAccountsSubtitle =>
      'Create an account or wallet to start managing your assets and tracking transactions.';

  @override
  String get defaultAccountLabel => 'Default';

  @override
  String get statisticsNoDataSubtitle =>
      'Try adding transactions or changing the filter range to see your category breakdown.';

  @override
  String get authBiometricOptInTitle => 'Enable Biometric Login';

  @override
  String get authBiometricOptInSubtitle =>
      'Use Fingerprint or FaceID to quickly and securely access your Stalvi account in the future.';

  @override
  String get authBiometricOptInEnable => 'Enable Biometrics';

  @override
  String get authBiometricOptInSkip => 'Skip for Now';

  @override
  String get noDataAvailable => 'No data available yet';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get authSetupCurrencyLabel => 'Default Currency';

  @override
  String get authSetupAcceptPrefix => 'I accept the ';

  @override
  String get authSetupAcceptAnd => ' and the ';

  @override
  String get settingsThemeMode => 'Theme Mode';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get profileSettingsTitle => 'Profile & Security';

  @override
  String get changePinButton => 'Change PIN';

  @override
  String get deleteAllDataButton => 'Delete All Data';

  @override
  String get oldPinLabel => 'Old PIN';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get confirmPinLabel => 'Confirm New PIN';

  @override
  String get incorrectOldPin => 'Incorrect Old PIN.';

  @override
  String get pinsDoNotMatch => 'PINs do not match.';

  @override
  String get pinUpdatedSuccessfully => 'PIN updated successfully.';

  @override
  String get deleteAllDataWarning =>
      'Are you sure you want to delete all data? This cannot be undone.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get usernameLabel => 'Username';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnNext => 'Next';

  @override
  String get recycleBinTitle => 'Recycle Bin';

  @override
  String get recycleBinEmpty => 'Recycle bin is empty.';

  @override
  String get recycleBinRestoreTooltip => 'Restore';

  @override
  String get recycleBinDeleteTooltip => 'Permanently Delete';

  @override
  String get recycleBinDeleteConfirmTitle => 'Permanent Delete';

  @override
  String get recycleBinDeleteConfirmMessage =>
      'Are you sure you want to permanently delete this item? This action cannot be undone.';

  @override
  String get recycleBinRestoredMessage => 'Item restored';

  @override
  String get recycleBinDeletedMessage => 'Item permanently deleted';

  @override
  String recycleBinDaysRemaining(int days) {
    return 'Expires in $days days';
  }

  @override
  String get errorCategoryRequired => 'Please select a category';

  @override
  String get errorCurrencyRequired => 'Please select a currency';

  @override
  String get labelCurrency => 'Currency';

  @override
  String get labelSelectCurrency => 'Select Currency';

  @override
  String get labelTag => 'Tag';

  @override
  String get labelSelectTag => 'Select Tag';

  @override
  String get noTag => 'None';

  @override
  String get optionalPlaceholder => '(Optional)';

  @override
  String get fallbackIncome => 'Income';

  @override
  String get fallbackExpense => 'Expense';

  @override
  String get errorMaxPinAttempts =>
      'Maximum PIN attempts reached. Please try again later.';

  @override
  String get errorPinNotNumeric => 'PIN must contain only numeric digits.';

  @override
  String get errorNoPinSet => 'No PIN is currently set.';

  @override
  String get authPinLockedTitle => 'Too Many Failed Attempts';

  @override
  String get authPinLockedMessage =>
      'Access has been temporarily blocked after too many incorrect PIN entries.';

  @override
  String get authPinLockedCountdown => 'seconds remaining';

  @override
  String get authPinLockedRetry => 'You may now try again';

  @override
  String get authSignInTitle => 'Verify identity';

  @override
  String get defaultAccountName => 'Main Account';

  @override
  String get filterAll => 'All';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpense => 'Expense';

  @override
  String get filterTransfer => 'Transfer';

  @override
  String get createAccountTitle => 'Create New Account';

  @override
  String get createAccountNameLabel => 'Account Name';

  @override
  String get createAccountNameHint => 'e.g. Personal Card, Cash, etc.';

  @override
  String get createAccountInitialBalanceLabel => 'Balance';

  @override
  String get createAccountTypeLabel => 'Account Type';

  @override
  String get createAccountColorThemeLabel => 'Color Theme';

  @override
  String get createAccountIconLabel => 'Icon';

  @override
  String get createAccountErrorName => 'Please enter an account name';

  @override
  String get createAccountErrorFailed => 'Failed to create account';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get deleteTransactionTitle => 'Delete Transaction?';

  @override
  String get transactionMovedToRecycleBin => 'Transaction moved to recycle bin';

  @override
  String get errorDeleteTransaction => 'Failed to delete transaction';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this transaction? This will move it to the recycle bin.';

  @override
  String get btnClose => 'Close';

  @override
  String get filterSheetTitle => 'Filter Transactions';

  @override
  String get filterSheetApply => 'Apply Filters';

  @override
  String get filterSheetClearAll => 'Clear All';

  @override
  String get filterSheetType => 'Transaction Type';

  @override
  String get filterSheetCategory => 'Category';

  @override
  String get filterSheetDateRange => 'Date Range';

  @override
  String get filterSheetAmountRange => 'Amount Range';

  @override
  String get filterSheetMinAmount => 'Min Amount';

  @override
  String get filterSheetMaxAmount => 'Max Amount';

  @override
  String get filterSheetTag => 'Tag';

  @override
  String get filterSheetCurrency => 'Currency';

  @override
  String get filterSheetAllTypes => 'All Types';

  @override
  String get filterSheetAllCategories => 'All Categories';

  @override
  String get filterSheetAllTags => 'All Tags';

  @override
  String get filterSheetAllCurrencies => 'All Currencies';

  @override
  String get filterSheetSelectDateRange => 'Select Date Range';

  @override
  String filterSheetActiveFilters(int count) {
    return '$count active filters';
  }

  @override
  String get filterSheetTransferType => 'Transfer';

  @override
  String get labelOriginAccount => 'Origin Account';

  @override
  String get labelDestinationAccount => 'Destination Account';

  @override
  String get errorCannotDeleteLastAccount =>
      'Cannot delete the last existing account.';

  @override
  String get categoriesAndTags => 'Categories & Tags';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get warning => 'Warning';

  @override
  String get replaceDefaultAccountConfirm =>
      'The previous default account will be replaced. Continue?';

  @override
  String get btnContinue => 'Continue';

  @override
  String get unknownAccount => 'Unknown Account';

  @override
  String get categories => 'Categories';

  @override
  String get tags => 'Tags';

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get deleteTagTitle => 'Delete Tag?';

  @override
  String deleteTagConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get errorNoOtherCategories =>
      'No other categories to reassign transactions to.';

  @override
  String get errorNoOtherTags => 'No other tags to reassign transactions to.';

  @override
  String get categoryInUseTitle => 'Category in Use';

  @override
  String get tagInUseTitle => 'Tag in Use';

  @override
  String categoryInUseMessage(String name) {
    return '$name is used by existing transactions. Please select a category to reassign them to:';
  }

  @override
  String tagInUseMessage(String name) {
    return '$name is used by existing transactions. Please select a tag to reassign them to:';
  }

  @override
  String get btnReassignAndDelete => 'Reassign & Delete';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get noTags => 'No tags yet';

  @override
  String get addCategoryTitle => 'Add Category';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get addTagTitle => 'Add Tag';

  @override
  String get editTagTitle => 'Edit Tag';

  @override
  String get labelCategoryName => 'Category Name';

  @override
  String get labelTagName => 'Tag Name';

  @override
  String get labelIcon => 'Icon';

  @override
  String get labelFromAccount => 'From Account';

  @override
  String get labelToAccount => 'To Account';

  @override
  String get selectSourceAccount => 'Select Source Account';

  @override
  String get selectDestinationAccount => 'Select Destination Account';

  @override
  String get currencyEUR => 'Euro (EUR)';

  @override
  String get currencyUSD => 'US Dollar (USD)';

  @override
  String get currencyGBP => 'British Pound (GBP)';

  @override
  String get currencyJPY => 'Japanese Yen (JPY)';

  @override
  String get currencyCHF => 'Swiss Franc (CHF)';

  @override
  String get currencyCAD => 'Canadian Dollar (CAD)';

  @override
  String get currencyAUD => 'Australian Dollar (AUD)';

  @override
  String get currencyCNY => 'Chinese Yuan (CNY)';

  @override
  String get errorDestinationAccountRequired =>
      'Please select a destination account';

  @override
  String get errorSameAccountTransfer =>
      'Source and destination accounts cannot be the same';

  @override
  String get savingsGoal => 'Savings Goal';

  @override
  String budgetSpentOf(String spent, String target) {
    return '$spent of $target';
  }

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get exportEncryptedBackup => 'Export Encrypted Backup';

  @override
  String get exportEncryptedBackupSubtitle =>
      'Export all data as a password-protected backup file';

  @override
  String get importRestoreBackup => 'Import / Restore Backup';

  @override
  String get importRestoreBackupSubtitle =>
      'Restore your data from a Stalvi backup file';

  @override
  String get exportTransactionsCsv => 'Export Transactions (CSV)';

  @override
  String get exportTransactionsCsvSubtitle =>
      'Export all transactions to a spreadsheet-compatible CSV file';

  @override
  String get exportMonthlyPdf => 'Export Monthly Report (PDF)';

  @override
  String get exportMonthlyPdfSubtitle =>
      'Generate a PDF summary for the current month';

  @override
  String get exportPasswordDialogTitle => 'Set Backup Password';

  @override
  String get exportPasswordDialogSubtitle =>
      'This password will be required to restore your backup. Store it safely.';

  @override
  String get exportPasswordLabel => 'Backup Password';

  @override
  String get exportPasswordConfirmLabel => 'Confirm Password';

  @override
  String get exportPasswordMismatch => 'Passwords do not match.';

  @override
  String get exportPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get importPasswordDialogTitle => 'Enter Backup Password';

  @override
  String get importPasswordDialogSubtitle =>
      'Enter the password used when the backup was created.';

  @override
  String get importConfirmTitle => 'Restore Backup?';

  @override
  String get importConfirmMessage =>
      'Restoring a backup will overwrite all current data. This cannot be undone. Are you sure?';

  @override
  String get exportSuccess => 'Export successful. File saved.';

  @override
  String get importSuccess =>
      'Backup restored successfully. Please restart the app.';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get importFailed => 'Restore failed. Check your password and file.';

  @override
  String get btnExport => 'Export';

  @override
  String get btnRestore => 'Restore';

  @override
  String statisticsOtherCategories(int count) {
    return 'Other ($count categories)';
  }

  @override
  String get btnViewDetails => 'View Details';

  @override
  String get btnOpen => 'Open';

  @override
  String get errorOpenFileFailed => 'Could not open file';

  @override
  String get expense_vs_income => 'Expenses vs Income';

  @override
  String get destination_account => 'Destination Account';

  @override
  String get chart_scale => 'Chart Scale';

  @override
  String get pdfDateFormat => 'MM/dd/yyyy';

  @override
  String get pdfDateTimeFormat => 'MM/dd/yyyy HH:mm';

  @override
  String pdfGeneratedOn(String appTitle, String date) {
    return 'Generated by $appTitle on $date';
  }

  @override
  String get addBudget => 'Add Budget';

  @override
  String get budgetDetails => 'Budget Details';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get addSavingsGoal => 'Add Savings Goal';

  @override
  String get savingsGoalDetails => 'Savings Goal Details';

  @override
  String get deleteSavingsGoal => 'Delete Savings Goal';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetDate => 'Target Date';

  @override
  String get errorEndDateBeforeStart => 'End date must be after start date';

  @override
  String get errorNameRequired => 'Please enter a name';

  @override
  String get pdfBudgetsTitle => 'Budgets';

  @override
  String get pdfBudgetsColCategory => 'Category';

  @override
  String get pdfBudgetsColDateRange => 'Date Range';

  @override
  String get pdfBudgetsColSpent => '% Spent';

  @override
  String get pdfBudgetsColMaxValue => 'Max Value';

  @override
  String get pdfSavingsGoalsTitle => 'Savings Goals';

  @override
  String get pdfSavingsColName => 'Name';

  @override
  String get pdfSavingsColCompleted => '% Completed';

  @override
  String get pdfSavingsColTarget => 'Target Amount';

  @override
  String get labelBudget => 'Budget';

  @override
  String exportSavedTo(String filePath) {
    return 'Saved to $filePath';
  }

  @override
  String get settingsAutomaticTransactions => 'Automatic Transactions';

  @override
  String get createAutomaticTransaction => 'Create Automatic Transaction';

  @override
  String get deleteAccountHasAutomaticTransactions =>
      'Cannot delete account because it has linked automatic transactions. Please delete them first.';

  @override
  String get recurrenceDaysLabel => 'Recurrence (Days)';

  @override
  String get nextExecution => 'Next Execution';

  @override
  String get autoTxNewTemplate => 'New Template';

  @override
  String get autoTxNewTitle => 'New Automatic Transaction';

  @override
  String get autoTxEditTitle => 'Edit Automatic Transaction';

  @override
  String get autoTxSavedMessage => 'Automatic Transaction Saved';

  @override
  String get autoTxTemplateNameLabel => 'Template Name';

  @override
  String get autoTxNameRequired => 'Name is required';

  @override
  String get autoTxLabelRecurrence => 'Recurrence';

  @override
  String get autoTxSelectRecurrence => 'Select Recurrence';

  @override
  String get autoTxRecurrenceWeekly => 'Weekly (Every 7 days)';

  @override
  String get autoTxRecurrenceMonthly => 'Monthly (Every 30 days)';

  @override
  String get autoTxRecurrenceYearly => 'Yearly (Every 365 days)';

  @override
  String get autoTxRecurrenceCustomInterval => 'Custom Interval (Days)';

  @override
  String get autoTxRecurrenceCustomHint => 'e.g. 14';

  @override
  String get autoTxRecurrenceApply => 'Apply';

  @override
  String get autoTxRecurrenceInvalidRange =>
      'Please enter a valid number of days (1-365).';

  @override
  String get autoTxFormatWeekly => 'Weekly';

  @override
  String get autoTxFormatMonthly => 'Monthly';

  @override
  String get autoTxFormatYearly => 'Yearly';

  @override
  String autoTxFormatEveryDays(int days) {
    return 'Every $days days';
  }
}
