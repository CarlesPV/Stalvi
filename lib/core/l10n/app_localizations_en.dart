// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stalvi';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnClose => 'Close';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnNext => 'Next';

  @override
  String get btnOpen => 'Open';

  @override
  String get btnReassignAndDelete => 'Reassign & Delete';

  @override
  String get btnRestore => 'Restore';

  @override
  String get btnSave => 'Save';

  @override
  String get btnSelect => 'Select';

  @override
  String get btnViewDetails => 'View Details';

  @override
  String get categories => 'Categories';

  @override
  String get currencyAUD => 'Australian Dollar (AUD)';

  @override
  String get currencyCAD => 'Canadian Dollar (CAD)';

  @override
  String get currencyCHF => 'Swiss Franc (CHF)';

  @override
  String get currencyCNY => 'Chinese Yuan (CNY)';

  @override
  String get currencyEUR => 'Euro (EUR)';

  @override
  String get currencyGBP => 'British Pound (GBP)';

  @override
  String get currencyJPY => 'Japanese Yen (JPY)';

  @override
  String get currencyUSD => 'US Dollar (USD)';

  @override
  String get deleteAllDataButton => 'Delete All Data';

  @override
  String get deleteAllDataWarning =>
      'Are you sure you want to delete all data? This cannot be undone.';

  @override
  String get endDate => 'End Date';

  @override
  String get getStarted => 'Get Started';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelCurrency => 'Currency';

  @override
  String get labelDate => 'Date';

  @override
  String get labelIcon => 'Icon';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelNotesHint => 'Add details about this transaction...';

  @override
  String get labelSelectCurrency => 'Select Currency';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get noDataAvailable => 'No data available yet';

  @override
  String get optionalPlaceholder => '(Optional)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get recurrenceUtcWarning => 'Reference time is UTC+2';

  @override
  String get setAsDefault => 'Set as Default';

  @override
  String get startDate => 'Start Date';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get targetDate => 'Target Date';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get txnSuccessCreated => 'Transaction created successfully!';

  @override
  String get usernameLabel => 'Username';

  @override
  String get warning => 'Warning';

  @override
  String get authBiometricOptInEnable => 'Enable Biometrics';

  @override
  String get authBiometricOptInSkip => 'Skip for Now';

  @override
  String get authBiometricOptInSubtitle =>
      'Use Fingerprint or FaceID to quickly and securely access your Stalvi account in the future.';

  @override
  String get authBiometricOptInTitle => 'Enable Biometric Login';

  @override
  String get authLockedMessage =>
      'Too many failed attempts. Please unlock your device from the lock screen and try again.';

  @override
  String get authLockedTitle => 'Biometrics Locked';

  @override
  String get authLockoutActive => 'Security lockout active';

  @override
  String authPinAttemptsRemaining(Object attempts) {
    return '$attempts attempts remaining';
  }

  @override
  String get authPinEnter => 'Enter PIN';

  @override
  String get authPinLockedCountdown => 'seconds remaining';

  @override
  String get authPinLockedMessage =>
      'Access has been temporarily blocked after too many incorrect PIN entries.';

  @override
  String get authPinLockedRetry => 'You may now try again';

  @override
  String get authPinLockedTitle => 'Too Many Failed Attempts';

  @override
  String get authProcessing => 'Processing security authentication…';

  @override
  String get authSetupAcceptAnd => ' and the ';

  @override
  String get authSetupAcceptPrefix => 'I accept the ';

  @override
  String get authSetupConfirmPinLabel => 'Confirm PIN';

  @override
  String get authSetupCreateButton => 'Create Profile';

  @override
  String get authSetupCurrencyLabel => 'Default Currency';

  @override
  String get authSetupLanguageLabel => 'Default Language';

  @override
  String get authSetupNameLabel => 'Name';

  @override
  String get authSetupPinLabel => 'Set a 4-8 digit PIN';

  @override
  String get authSetupSubtitle => 'Set up your secure offline wallet to begin.';

  @override
  String get authSetupTitle => 'Create Your Profile';

  @override
  String get authSetupUsernameLabel => 'Username';

  @override
  String get authSignInTitle => 'Verify identity';

  @override
  String get authVerifyMessage =>
      'Use biometrics or your device PIN to continue';

  @override
  String get changePinButton => 'Change PIN';

  @override
  String get confirmPinLabel => 'Confirm New PIN';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get oldPinLabel => 'Old PIN';

  @override
  String get pinUpdatedSuccessfully => 'PIN updated successfully.';

  @override
  String get pinsDoNotMatch => 'PINs do not match.';

  @override
  String get statisticsTopIncome => 'Top Income Categories';

  @override
  String get balanceTotal => 'Total Balance';

  @override
  String get overview => 'Overview';

  @override
  String get accountInUseByAutoTxMessage =>
      'This account cannot be deleted because it is linked to active automatic transactions.';

  @override
  String get deleteAccountWithTransactionsWarning =>
      'This account has associated transactions. Deleting it will also delete all its transactions.';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accounts => 'Accounts';

  @override
  String acrossAccountsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String get addCategoryTitle => 'Add Category';

  @override
  String get addTagTitle => 'Add Tag';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get autoTxEditTitle => 'Edit Automatic Transaction';

  @override
  String autoTxFormatEveryDays(Object days) {
    return 'Every $days days';
  }

  @override
  String get autoTxFormatMonthly => 'Monthly';

  @override
  String autoTxFormatSpecificDay(Object day) {
    return 'Every month on the $day';
  }

  @override
  String get autoTxFormatWeekly => 'Weekly';

  @override
  String get autoTxFormatYearly => 'Yearly';

  @override
  String get autoTxLabelRecurrence => 'Recurrence';

  @override
  String get autoTxNameRequired => 'Name is required';

  @override
  String get autoTxNewTitle => 'New Automatic Transaction';

  @override
  String get autoTxRecurrenceApply => 'Apply';

  @override
  String get autoTxRecurrenceCustomHint => 'e.g. 14';

  @override
  String get autoTxRecurrenceCustomInterval => 'Custom Interval (Days)';

  @override
  String get autoTxRecurrenceDayOfMonth => 'Day X of month';

  @override
  String get autoTxRecurrenceEveryXDays => 'Every X days';

  @override
  String get autoTxRecurrenceMonthly => 'Monthly (Every 30 days)';

  @override
  String get autoTxRecurrenceWeekly => 'Weekly (Every 7 days)';

  @override
  String get autoTxRecurrenceYearly => 'Yearly (Every 365 days)';

  @override
  String get autoTxSavedMessage => 'Automatic Transaction Saved';

  @override
  String get autoTxSelectRecurrence => 'Select Recurrence';

  @override
  String get autoTxTemplateNameLabel => 'Name';

  @override
  String get btnSaveTransaction => 'Save Transaction';

  @override
  String get categoriesAndTags => 'Categories & Tags';

  @override
  String categoryInUseByAutoTxMessage(String name) {
    return '$name is in use by automatic transactions and must be reassigned.';
  }

  @override
  String categoryInUseMessage(Object name) {
    return '$name is used by existing transactions. Please select a category to reassign them to:';
  }

  @override
  String get categoryInUseTitle => 'Category in Use';

  @override
  String get createAccountIconLabel => 'Icon';

  @override
  String get createAccountInitialBalanceLabel => 'Initial Balance';

  @override
  String get createAccountNameHint => 'e.g. Personal Card, Cash, etc.';

  @override
  String get createAccountNameLabel => 'Account Name';

  @override
  String get createAccountTitle => 'Create New Account';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get createNewLabel => 'Create New Label';

  @override
  String get createAccountTypeLabel => 'Account Type';

  @override
  String get createAutomaticTransaction => 'Create Automatic Transaction';

  @override
  String get defaultAccountLabel => 'Default';

  @override
  String get defaultAccountName => 'Main Account';

  @override
  String deleteCategoryConfirm(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get deleteCategoryTitle => 'Delete Category?';

  @override
  String deleteTagConfirm(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get deleteTagTitle => 'Delete Tag?';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this transaction? This will move it to the recycle bin.';

  @override
  String get deleteTransactionTitle => 'Delete Transaction?';

  @override
  String get destination_account => 'Destination Account';

  @override
  String get editCategoryTitle => 'Edit Category';

  @override
  String get editTagTitle => 'Edit Tag';

  @override
  String expense(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expenses',
      one: 'Expense',
    );
    return '$_temp0';
  }

  @override
  String get expense_vs_income => 'Expenses vs Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get fallbackExpense => 'Expense';

  @override
  String get fallbackIncome => 'Income';

  @override
  String get filterAll => 'All';

  @override
  String get filterExpense => 'Expense';

  @override
  String get filterIncome => 'Income';

  @override
  String filterSheetActiveFilters(Object count) {
    return '$count active filters';
  }

  @override
  String get filterSheetAllCategories => 'All Categories';

  @override
  String get filterSheetAllCurrencies => 'All Currencies';

  @override
  String get filterSheetAllTags => 'All Tags';

  @override
  String get filterSheetAllTypes => 'All Types';

  @override
  String get filterSheetAmountRange => 'Amount Range';

  @override
  String get filterSheetApply => 'Apply Filters';

  @override
  String get filterSheetCategory => 'Category';

  @override
  String get filterSheetClearAll => 'Clear All';

  @override
  String get filterSheetCurrency => 'Currency';

  @override
  String get filterSheetDateRange => 'Date Range';

  @override
  String get filterSheetMaxAmount => 'Max Amount';

  @override
  String get filterSheetMinAmount => 'Min Amount';

  @override
  String get filterSheetSelectDateRange => 'Select Date Range';

  @override
  String get filterSheetTag => 'Tag';

  @override
  String get filterSheetTitle => 'Filter Transactions';

  @override
  String get filterSheetTransferType => 'Transfer';

  @override
  String get filterSheetType => 'Transaction Type';

  @override
  String get filterTransfer => 'Transfer';

  @override
  String income(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Incomes',
      one: 'Income',
    );
    return '$_temp0';
  }

  @override
  String get labelAccount => 'Account';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelCategoryName => 'Category Name';

  @override
  String get labelDestinationAccount => 'Destination Account';

  @override
  String get labelFromAccount => 'From Account';

  @override
  String get labelOriginAccount => 'Origin Account';

  @override
  String get labelSelectAccount => 'Select Account';

  @override
  String get labelSelectCategory => 'Select Category';

  @override
  String get labelSelectTag => 'Select Tag';

  @override
  String get labelTag => 'Tag';

  @override
  String get labelTagName => 'Tag Name';

  @override
  String get labelToAccount => 'To Account';

  @override
  String get noAccountsSubtitle =>
      'Create an account or wallet to start managing your assets and tracking transactions.';

  @override
  String get noAccountsTitle => 'No accounts yet';

  @override
  String get noTag => 'None';

  @override
  String get noTags => 'No tags yet';

  @override
  String get noTransactionsSubtitle =>
      'Add your first income or expense to see it here and start tracking.';

  @override
  String get noTransactionsTitle => 'No transactions yet';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get replaceDefaultAccountConfirm =>
      'The previous default account will be replaced. Continue?';

  @override
  String get selectDestinationAccount => 'Select Destination Account';

  @override
  String get selectSourceAccount => 'Select Source Account';

  @override
  String get splashTagline => 'Your finances, your way.';

  @override
  String tagInUseMessage(Object name) {
    return '$name is used by existing transactions. Please select a tag to reassign them to:';
  }

  @override
  String get tagInUseTitle => 'Tag in Use';

  @override
  String get tags => 'Tags';

  @override
  String get transactions => 'Transactions';

  @override
  String get unknownAccount => 'Unknown Account';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get addSavingsGoal => 'Add Savings Goal';

  @override
  String get budgetDetails => 'Budget Details';

  @override
  String budgetOverspent(Object amount) {
    return '$amount overspent';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount remaining';
  }

  @override
  String budgetSpentOf(Object spent, Object target) {
    return '$spent of $target';
  }

  @override
  String get budgets => 'Budgets';

  @override
  String get budgetsAndGoals => 'Budgets & Goals';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteSavingsGoal => 'Delete Savings Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get labelBudget => 'Budget';

  @override
  String get noBudgetsSubtitle =>
      'Set spending limits for categories to track your monthly expenses and stay within your limits.';

  @override
  String get noBudgetsTitle => 'No budgets set yet';

  @override
  String get noSavingsGoalsSubtitle =>
      'Create a savings goal to plan for your future dreams, trips, or big purchases.';

  @override
  String get noSavingsGoalsTitle => 'No savings goals yet';

  @override
  String get pdfBudgetsColCategory => 'Category';

  @override
  String get pdfBudgetsColDateRange => 'Date Range';

  @override
  String get pdfBudgetsColMaxValue => 'Max Value';

  @override
  String get pdfBudgetsColSpent => '% Spent';

  @override
  String get pdfBudgetsTitle => 'Budgets';

  @override
  String get pdfSavingsColCompleted => '% Completed';

  @override
  String get pdfSavingsColName => 'Name';

  @override
  String get pdfSavingsGoalsTitle => 'Savings Goals';

  @override
  String get savingsGoal => 'Savings Goal';

  @override
  String get savingsGoalAchieved => 'Goal achieved!';

  @override
  String get savingsGoalDetails => 'Savings Goal Details';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get savingsNoTargetDate => 'No target date';

  @override
  String savingsSavedOf(Object saved, Object target) {
    return '$saved saved of $target';
  }

  @override
  String savingsTargetDate(Object date) {
    return 'Target date: $date';
  }

  @override
  String get settingsBudgetsGoals => 'Budgets & Goals';

  @override
  String get chart_scale => 'Chart Scale';

  @override
  String get presetCustom => 'Custom';

  @override
  String get presetLast30Days => 'Last 30 Days';

  @override
  String get presetLast3Months => 'Last 3 Months';

  @override
  String get presetLast6Months => 'Last 6 Months';

  @override
  String get presetThisMonth => 'This Month';

  @override
  String get presetThisYear => 'This Year';

  @override
  String get settingsStatistics => 'Statistics';

  @override
  String get statisticsDeficit => 'Deficit';

  @override
  String get statisticsNetBalance => 'Net Balance';

  @override
  String get statisticsTransfers => 'Transfers';

  @override
  String get statisticsNoDataSubtitle =>
      'Try adding transactions or changing the filter range to see your category breakdown.';

  @override
  String get statisticsNoExpenses => 'No expenses recorded in this period.';

  @override
  String get statisticsNoIncome => 'No income recorded in this period.';

  @override
  String statisticsOtherCategories(Object count) {
    return 'Other ($count categories)';
  }

  @override
  String get statisticsSurplus => 'Surplus';

  @override
  String get statisticsTooltipCustomRange => 'Custom date range';

  @override
  String get statisticsTopSpending => 'Top Spending Categories';

  @override
  String get statisticsWhatYouEarned => 'What you earned';

  @override
  String get statisticsWhereMoneyGoes => 'Where your money goes';

  @override
  String get aboutMe => 'About Me';

  @override
  String get aboutMeGithubButton => 'View my GitHub';

  @override
  String get btnExport => 'Export';

  @override
  String get createAccountColorThemeLabel => 'Color Theme';

  @override
  String get exportEncryptedBackup => 'Export Encrypted Backup';

  @override
  String get exportEncryptedBackupSubtitle =>
      'Export all data as a password-protected backup file';

  @override
  String get exportMonthlyPdf => 'Export Monthly Report (PDF)';

  @override
  String get exportMonthlyPdfSubtitle => 'Generate a PDF summary';

  @override
  String get exportPasswordConfirmLabel => 'Confirm Password';

  @override
  String get exportPasswordDialogSubtitle =>
      'This password will be required to restore your backup. Store it safely.';

  @override
  String get exportPasswordDialogTitle => 'Set Backup Password';

  @override
  String get exportPasswordLabel => 'Backup Password';

  @override
  String get exportPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get exportPdfCurrentMonth => 'Current Month';

  @override
  String get exportPdfLast30Days => 'Last 30 Days';

  @override
  String get exportPdfSelectMonth => 'Select Month';

  @override
  String exportSavedTo(Object filePath) {
    return 'Saved to $filePath';
  }

  @override
  String get exportSuccess => 'Export successful. File saved.';

  @override
  String get exportTransactionsCsv => 'Export Transactions (CSV)';

  @override
  String get exportTransactionsCsvSubtitle =>
      'Export all transactions to a spreadsheet-compatible CSV file';

  @override
  String get importConfirmMessage =>
      'Restoring a backup will overwrite all current data. This cannot be undone. Are you sure?';

  @override
  String get importConfirmTitle => 'Restore Backup?';

  @override
  String get importPasswordDialogSubtitle =>
      'Enter the password used when the backup was created.';

  @override
  String get importPasswordDialogTitle => 'Enter Backup Password';

  @override
  String get importRestoreBackup => 'Import / Restore Backup';

  @override
  String get importRestoreBackupSubtitle =>
      'Restore your data from a Stalvi backup file';

  @override
  String get importSuccess =>
      'Backup restored successfully. Please restart the app.';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get pdfDateFormat => 'MM/dd/yyyy';

  @override
  String get pdfDateTimeFormat => 'MM/dd/yyyy HH:mm';

  @override
  String get pdfExportLast30Days => 'Last 30 days';

  @override
  String pdfGeneratedOn(Object appTitle, Object date) {
    return 'Generated by $appTitle on $date';
  }

  @override
  String get profileSettingsTitle => 'Profile & Security';

  @override
  String recycleBinDaysRemaining(Object days) {
    return 'Expires in $days days';
  }

  @override
  String get recycleBinDeleteConfirmMessage =>
      'Are you sure you want to permanently delete this item? This action cannot be undone.';

  @override
  String get recycleBinDeleteConfirmTitle => 'Permanent Delete';

  @override
  String get recycleBinDeleteTooltip => 'Permanently Delete';

  @override
  String get recycleBinDeletedMessage => 'Item permanently deleted';

  @override
  String get recycleBinEmpty => 'Recycle bin is empty.';

  @override
  String get recycleBinRestoreTooltip => 'Restore';

  @override
  String get recycleBinRestoredMessage => 'Item restored';

  @override
  String get recycleBinTitle => 'Recycle Bin';

  @override
  String get settings => 'Settings';

  @override
  String get settingsAutomaticTransactions => 'Automatic Transactions';

  @override
  String get settingsDataManagement => 'Import & Export Data';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Push Notifications';

  @override
  String get notificationsPermanentlyDeniedTitle => 'Notifications Disabled';

  @override
  String get notificationsPermanentlyDeniedBody =>
      'You have permanently denied notification permissions. Please enable them in your system settings to receive alerts.';

  @override
  String get btnOpenSettings => 'Open Settings';

  @override
  String get settingsThemeMode => 'Theme Mode';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeSystem => 'System';

  @override
  String get transactionMovedToRecycleBin => 'Transaction moved to recycle bin';

  @override
  String get authError => 'Authentication Error';

  @override
  String get authPinIncorrect => 'Incorrect PIN. Please try again.';

  @override
  String get authSetupValidationErrorName => 'Please enter a name.';

  @override
  String get authSetupValidationErrorNameEmoji =>
      'Name cannot contain emojis or special characters.';

  @override
  String get authSetupValidationErrorNameLength =>
      'Name cannot exceed 25 characters.';

  @override
  String get authSetupValidationErrorPinLength =>
      'PIN must be between 4 and 8 digits.';

  @override
  String get authSetupValidationErrorPinMatch => 'PINs do not match.';

  @override
  String get authSetupValidationErrorTerms =>
      'You must accept the Terms & Conditions and Privacy Policy to proceed.';

  @override
  String get authSetupValidationErrorUsername => 'Please enter a username.';

  @override
  String get authSetupValidationErrorUsernameEmoji =>
      'Username cannot contain emojis or special characters.';

  @override
  String get authSetupValidationErrorUsernameLength =>
      'Username cannot exceed 25 characters.';

  @override
  String get autoTxErrorInvalidDayOfMonth =>
      'Invalid day of month (must be 1-31)';

  @override
  String get autoTxErrorInvalidRecurrenceInterval =>
      'Invalid recurrence interval';

  @override
  String get createAccountErrorFailed => 'Failed to create account';

  @override
  String get createAccountErrorName => 'Please enter an account name';

  @override
  String get errorAccountNotFound => 'Account not found';

  @override
  String get errorAccountRequired => 'Please select an account';

  @override
  String get errorCannotDeleteLastAccount =>
      'Cannot delete the last existing account.';

  @override
  String get errorCategoryRequired => 'Please select a category';

  @override
  String get errorConversionFailed => 'Failed to convert currency';

  @override
  String get errorCurrencyRequired => 'Please select a currency';

  @override
  String get errorDeleteTransaction => 'Failed to delete transaction';

  @override
  String get errorDestinationAccountRequired =>
      'Please select a destination account';

  @override
  String get errorEndDateBeforeStart => 'End date must be after start date';

  @override
  String get errorFutureDate => 'Transaction date cannot be in the future';

  @override
  String get errorInvalidAmount => 'Please enter a valid amount greater than 0';

  @override
  String get errorMaxPinAttempts =>
      'Maximum PIN attempts reached. Please try again later.';

  @override
  String get errorNameRequired => 'Please enter a name';

  @override
  String get errorNoOtherCategories =>
      'No other categories to reassign transactions to.';

  @override
  String get errorNoOtherTags => 'No other tags to reassign transactions to.';

  @override
  String get errorNoPinSet => 'No PIN is currently set.';

  @override
  String get errorOpenFileFailed => 'Could not open file';

  @override
  String get errorPinNotNumeric => 'PIN must contain only numeric digits.';

  @override
  String get errorProfileNotFound => 'Profile not found';

  @override
  String get errorRateNotFound =>
      'Exchange rate not available for the requested currency';

  @override
  String get errorSameAccountTransfer =>
      'Source and destination accounts cannot be the same';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get exportPasswordMismatch => 'Passwords do not match.';

  @override
  String get failedLoadAccounts => 'Failed to load accounts.';

  @override
  String get failedLoadBudgets => 'Failed to load budgets.';

  @override
  String get failedLoadSavingsGoals => 'Failed to load savings goals.';

  @override
  String get failedLoadTransactions => 'Failed to load transactions';

  @override
  String get importFailed => 'Restore failed. Check your password and file.';

  @override
  String get incorrectOldPin => 'Incorrect Old PIN.';

  @override
  String get splashSecureStorageError =>
      'Stalvi couldn\'t initialise its secure storage. Please check available device storage and try again.';

  @override
  String get splashStartupFailed => 'Startup Failed';

  @override
  String get unexpectedError =>
      'An unexpected error occurred. Please try again.';

  @override
  String get hintAmountZero => '0.00';

  @override
  String get errorCouldNotLaunchUrl => 'Could not launch URL';

  @override
  String get errorLoadingContent => 'Error loading content.';

  @override
  String get errorCannotDeleteDefaultAccount =>
      'Cannot delete the default account. Please set another account as default first.';

  @override
  String get errorNoDefaultAccountForReassignment =>
      'Cannot delete account because no default account exists for reassignment.';

  @override
  String get errorDefaultAccountRequired =>
      'You must have at least one default account.';

  @override
  String get widgetIncomeTitle => 'Income';

  @override
  String get widgetExpenseTitle => 'Expenses';

  @override
  String get a11yAddTransaction => 'Add new transaction';

  @override
  String get a11yDoubleTapToEdit => 'Double tap to edit';

  @override
  String get a11yDoubleTapToViewDetails => 'Double tap to view details';

  @override
  String get a11yExpense => 'Expense';

  @override
  String get a11yIncome => 'Income';

  @override
  String get a11yTransfer => 'Transfer';

  @override
  String get a11yTransactionDetails => 'Transaction details';

  @override
  String get a11ySelectCategory => 'Select category';

  @override
  String get a11ySelectAccount => 'Select account';

  @override
  String get a11ySelectDate => 'Select date';

  @override
  String get a11yPinBackspace => 'Backspace';

  @override
  String get a11yPinBiometric => 'Biometric authentication';

  @override
  String a11yPinDigit(Object digit) {
    return 'Digit $digit';
  }

  @override
  String a11yPinProgress(Object count, Object total) {
    return '$count of $total digits entered';
  }

  @override
  String get a11yEditCategory => 'Edit category';

  @override
  String get a11yDeleteCategory => 'Delete category';

  @override
  String get a11yStatisticsSummary => 'Statistics summary';

  @override
  String get a11yBudgetProgress => 'Budget progress';

  @override
  String get a11yChartTitle => 'Statistics chart.';

  @override
  String a11yChartTopCategory(String category, String percent) {
    return 'Top category: $category with $percent%.';
  }

  @override
  String a11yChartSecondCategory(String category, String percent) {
    return 'Second: $category with $percent%.';
  }

  @override
  String get a11yChartOtherCategories => 'Other categories make up the rest.';

  @override
  String get a11yChartNoData => 'No data available.';

  @override
  String get a11yDiscreetModeHidden => 'Balance hidden.';

  @override
  String get a11yDiscreetModeHint =>
      'Double tap the visibility button to show.';

  @override
  String get a11yDiscreetModeToggleHide => 'Hide balances (discreet mode)';

  @override
  String get a11yDiscreetModeToggleShow => 'Show balances';

  @override
  String a11yRestoreItem(String item) {
    return 'Restore $item';
  }

  @override
  String a11yDeletePermanently(String item) {
    return 'Delete $item permanently';
  }

  @override
  String get a11yAcceptTerms => 'Accept terms and privacy policy';

  @override
  String a11yChartSummary(String details) {
    return 'Statistics chart. $details';
  }

  @override
  String get a11yColorBlue => 'Blue';

  @override
  String get a11yColorGreen => 'Green';

  @override
  String get a11yColorAmber => 'Amber';

  @override
  String get a11yColorPink => 'Pink';

  @override
  String get a11yColorPurple => 'Purple';

  @override
  String get a11yColorDeepOrange => 'Deep orange';

  @override
  String get a11yColorCyan => 'Cyan';

  @override
  String get a11yColorTeal => 'Teal';

  @override
  String get a11yColorLightGreen => 'Light green';

  @override
  String get a11yColorLime => 'Lime';

  @override
  String get a11yColorOrange => 'Orange';

  @override
  String get a11yColorRed => 'Red';

  @override
  String get a11yColorBrown => 'Brown';

  @override
  String get a11yColorBlueGrey => 'Blue grey';

  @override
  String get a11yColorDeepPurple => 'Deep purple';

  @override
  String get a11yColorIndigo => 'Indigo';

  @override
  String get a11yColorLightPink => 'Light pink';

  @override
  String get a11yColorMint => 'Mint';

  @override
  String get a11yColorLightLime => 'Light lime';

  @override
  String get a11yColorCoral => 'Coral';

  @override
  String get a11yColorLightBrown => 'Light brown';

  @override
  String get a11yColorGrey => 'Grey';

  @override
  String get a11yColorYellow => 'Yellow';

  @override
  String get a11yColorLightBlue => 'Light blue';

  @override
  String get a11yColorBlack => 'Black';

  @override
  String get a11yColorWhite => 'White';

  @override
  String get a11yIconAccountBalance => 'Bank';

  @override
  String get a11yIconAccountBalanceWallet => 'Wallet';

  @override
  String get a11yIconAttachMoney => 'Money';

  @override
  String get a11yIconMoneyOff => 'No money';

  @override
  String get a11yIconCreditCard => 'Credit card';

  @override
  String get a11yIconSavings => 'Savings';

  @override
  String get a11yIconReceiptLong => 'Detailed receipt';

  @override
  String get a11yIconReceipt => 'Receipt';

  @override
  String get a11yIconRequestQuote => 'Invoice';

  @override
  String get a11yIconPaid => 'Paid';

  @override
  String get a11yIconPriceCheck => 'Price check';

  @override
  String get a11yIconPriceChange => 'Price change';

  @override
  String get a11yIconCurrencyExchange => 'Currency exchange';

  @override
  String get a11yIconMonetizationOn => 'Monetization';

  @override
  String get a11yIconTrendingUp => 'Trending up';

  @override
  String get a11yIconTrendingDown => 'Trending down';

  @override
  String get a11yIconShowChart => 'Chart';

  @override
  String get a11yIconReplay => 'Recurring';

  @override
  String get a11yIconShoppingCart => 'Shopping cart';

  @override
  String get a11yIconShoppingBag => 'Shopping bag';

  @override
  String get a11yIconLocalMall => 'Shopping mall';

  @override
  String get a11yIconStorefront => 'Storefront';

  @override
  String get a11yIconRedeem => 'Gift reward';

  @override
  String get a11yIconLoyalty => 'Loyalty card';

  @override
  String get a11yIconSell => 'Sale';

  @override
  String get a11yIconDiscount => 'Discount';

  @override
  String get a11yIconRestaurant => 'Restaurant';

  @override
  String get a11yIconLunchDining => 'Lunch';

  @override
  String get a11yIconDinnerDining => 'Dinner';

  @override
  String get a11yIconLocalCafe => 'Cafe';

  @override
  String get a11yIconFastfood => 'Fast food';

  @override
  String get a11yIconBakeryDining => 'Bakery';

  @override
  String get a11yIconIcecream => 'Ice cream';

  @override
  String get a11yIconLocalGroceryStore => 'Supermarket';

  @override
  String get a11yIconHome => 'Home';

  @override
  String get a11yIconHouse => 'House';

  @override
  String get a11yIconApartment => 'Apartment';

  @override
  String get a11yIconCottage => 'Cottage';

  @override
  String get a11yIconBed => 'Bedroom';

  @override
  String get a11yIconBathroom => 'Bathroom';

  @override
  String get a11yIconKitchen => 'Kitchen';

  @override
  String get a11yIconChair => 'Furniture';

  @override
  String get a11yIconYard => 'Garden';

  @override
  String get a11yIconGarage => 'Garage';

  @override
  String get a11yIconElectricalServices => 'Electrician';

  @override
  String get a11yIconPlumbing => 'Plumbing';

  @override
  String get a11yIconDirectionsCar => 'Car';

  @override
  String get a11yIconLocalGasStation => 'Gas station';

  @override
  String get a11yIconCarRepair => 'Car repair';

  @override
  String get a11yIconDirectionsBus => 'Bus';

  @override
  String get a11yIconDirectionsSubway => 'Metro';

  @override
  String get a11yIconDirectionsBike => 'Bicycle';

  @override
  String get a11yIconTwoWheeler => 'Motorbike';

  @override
  String get a11yIconFlight => 'Flight';

  @override
  String get a11yIconHotel => 'Hotel';

  @override
  String get a11yIconLocalTaxi => 'Taxi';

  @override
  String get a11yIconTrain => 'Train';

  @override
  String get a11yIconDirectionsBoat => 'Boat';

  @override
  String get a11yIconEvStation => 'Electric vehicle charger';

  @override
  String get a11yIconLocalParking => 'Parking';

  @override
  String get a11yIconToll => 'Toll';

  @override
  String get a11yIconLuggage => 'Luggage';

  @override
  String get a11yIconLocalHospital => 'Hospital';

  @override
  String get a11yIconMedicalServices => 'Medical services';

  @override
  String get a11yIconMedication => 'Medication';

  @override
  String get a11yIconHealing => 'First aid';

  @override
  String get a11yIconFitnessCenter => 'Gym';

  @override
  String get a11yIconSpa => 'Spa';

  @override
  String get a11yIconSelfImprovement => 'Self improvement';

  @override
  String get a11yIconPsychology => 'Psychology';

  @override
  String get a11yIconLocalPharmacy => 'Pharmacy';

  @override
  String get a11yIconVaccines => 'Vaccine';

  @override
  String get a11yIconHealthAndSafety => 'Health and safety';

  @override
  String get a11yIconAccessibilityNew => 'Accessibility';

  @override
  String get a11yIconSchool => 'School';

  @override
  String get a11yIconMenuBook => 'Book';

  @override
  String get a11yIconAutoStories => 'Reading';

  @override
  String get a11yIconScience => 'Science';

  @override
  String get a11yIconCalculate => 'Accounting';

  @override
  String get a11yIconLaptop => 'Laptop';

  @override
  String get a11yIconWork => 'Work';

  @override
  String get a11yIconBusinessCenter => 'Business';

  @override
  String get a11yIconCorporateFare => 'Company';

  @override
  String get a11yIconBadge => 'Employment badge';

  @override
  String get a11yIconEngineering => 'Engineering';

  @override
  String get a11yIconComputer => 'Computer';

  @override
  String get a11yIconMovie => 'Cinema';

  @override
  String get a11yIconTv => 'Television';

  @override
  String get a11yIconMusicNote => 'Music';

  @override
  String get a11yIconHeadphones => 'Audio';

  @override
  String get a11yIconSportsEsports => 'Video games';

  @override
  String get a11yIconSportsSoccer => 'Football';

  @override
  String get a11yIconSportsBasketball => 'Basketball';

  @override
  String get a11yIconSportsTennis => 'Tennis';

  @override
  String get a11yIconHiking => 'Hiking';

  @override
  String get a11yIconTerrain => 'Mountain';

  @override
  String get a11yIconBeachAccess => 'Beach';

  @override
  String get a11yIconPark => 'Park';

  @override
  String get a11yIconTheaterComedy => 'Theatre';

  @override
  String get a11yIconCasino => 'Casino';

  @override
  String get a11yIconSportsBar => 'Sports bar';

  @override
  String get a11yIconAttractions => 'Amusement park';

  @override
  String get a11yIconBolt => 'Electricity';

  @override
  String get a11yIconWaterDrop => 'Water';

  @override
  String get a11yIconWifi => 'Internet wifi';

  @override
  String get a11yIconPhone => 'Phone';

  @override
  String get a11yIconSmartphone => 'Mobile phone';

  @override
  String get a11yIconTvOutlined => 'Streaming subscription';

  @override
  String get a11yIconRecycling => 'Recycling';

  @override
  String get a11yIconLocalLaundryService => 'Laundry';

  @override
  String get a11yIconCleaningServices => 'Cleaning';

  @override
  String get a11yIconHandyman => 'Handyman';

  @override
  String get a11yIconBuild => 'Tools';

  @override
  String get a11yIconConstruction => 'Construction';

  @override
  String get a11yIconChildCare => 'Childcare';

  @override
  String get a11yIconPets => 'Pets';

  @override
  String get a11yIconStyle => 'Fashion';

  @override
  String get a11yIconFace => 'Beauty';

  @override
  String get a11yIconVolunteerActivism => 'Donation';

  @override
  String get a11yIconChurch => 'Place of worship';

  @override
  String get a11yIconCelebration => 'Party';

  @override
  String get a11yIconCake => 'Birthday cake';

  @override
  String get a11yIconCardGiftcard => 'Gift card';

  @override
  String get a11yIconCategory => 'General category';

  @override
  String get a11yIconMoreHoriz => 'Other';

  @override
  String get a11yIconStar => 'Favorite';

  @override
  String get a11yIconFlag => 'Flag';

  @override
  String get a11yIconBookmark => 'Bookmark';

  @override
  String get a11yIconLabel => 'Label';

  @override
  String get a11yIconTag => 'Tag';

  @override
  String get a11yIconFlightTakeoff => 'Departure flight';

  @override
  String get a11yIconFlightLand => 'Arrival flight';

  @override
  String get a11yIconCommute => 'Commute';

  @override
  String get a11yIconSubway => 'Subway train';

  @override
  String get a11yIconElectricCar => 'Electric car';

  @override
  String get a11yIconMotorcycle => 'Motorcycle';

  @override
  String get a11yIconMap => 'Map';

  @override
  String get a11yIconExplore => 'Exploration';

  @override
  String get a11yIconNavigation => 'Navigation';

  @override
  String get a11yIconCardMembership => 'Membership card';

  @override
  String get a11yIconStore => 'Department store';

  @override
  String get a11yIconLocalOffer => 'Special offer';

  @override
  String get a11yIconPower => 'Power plug';

  @override
  String get a11yIconElectricBolt => 'Energy';

  @override
  String get a11yIconRouter => 'Router';

  @override
  String get a11yIconDevices => 'Electronic devices';

  @override
  String get a11yIconCloud => 'Cloud storage';

  @override
  String get a11yIconSolarPower => 'Solar power';

  @override
  String get a11yIconLocalBar => 'Bar';

  @override
  String get a11yIconLiquor => 'Liquor';

  @override
  String get a11yIconRamenDining => 'Noodles';

  @override
  String get a11yIconTakeoutDining => 'Takeaway';

  @override
  String get a11yIconWineBar => 'Wine bar';

  @override
  String get a11yIconCoffee => 'Coffee';

  @override
  String get a11yIconSoupKitchen => 'Soup kitchen';

  @override
  String get a11yIconCameraAlt => 'Photography';

  @override
  String get a11yIconPalette => 'Art';

  @override
  String get a11yIconStadium => 'Stadium';

  @override
  String get a11yIconMusicVideo => 'Music video';

  @override
  String get a11yIconSportsMotorsports => 'Motorsports';

  @override
  String get a11yIconSportsGolf => 'Golf';

  @override
  String get a11yIconSportsBaseball => 'Baseball';

  @override
  String get a11yIconSportsFootball => 'American football';

  @override
  String get a11yIconPool => 'Swimming pool';

  @override
  String get a11yIconFamilyRestroom => 'Family care';

  @override
  String get a11yIconContentCut => 'Hairdresser';

  @override
  String get a11yIconDryCleaning => 'Dry cleaning';

  @override
  String get a11yIconSecurity => 'Security';

  @override
  String get a11yIconShield => 'Insurance shield';

  @override
  String get a11yIconWorkspacePremium => 'Premium subscription';

  @override
  String get a11yIconPestControl => 'Pest control';

  @override
  String get a11yIconRoofing => 'Roofing repair';

  @override
  String get a11yIconDeck => 'Terrace';

  @override
  String get a11yIconSchoolOutlined => 'Higher education';

  @override
  String get a11yIconEvent => 'Calendar event';

  @override
  String get a11yIconAlarm => 'Alarm';

  @override
  String get a11yIconWatch => 'Watch';

  @override
  String get a11yIconInterests => 'Hobbies';

  @override
  String get a11yIconNewspaper => 'Newspaper press';

  @override
  String get a11yIconPrint => 'Printing';

  @override
  String a11yEditItem(String name) {
    return 'Edit $name';
  }

  @override
  String a11yDeleteItem(String name) {
    return 'Delete $name';
  }

  @override
  String a11yEditName(String name) {
    return 'Edit $name';
  }

  @override
  String a11yDeleteName(String name) {
    return 'Delete $name';
  }

  @override
  String get a11ySelectYear => 'Select Year';

  @override
  String get a11ySelectMonth => 'Select Month';

  @override
  String get selectYear => 'Select Year';

  @override
  String get selectMonth => 'Select Month';

  @override
  String a11yProgressBar(String percentage) {
    return 'Progress: $percentage percent';
  }

  @override
  String a11yProgress(String percentage) {
    return 'Progress: $percentage percent';
  }

  @override
  String a11yProgressPercentage(String percentage) {
    return 'Progress: $percentage percent';
  }

  @override
  String get a11yShowPassword => 'Show password';

  @override
  String get a11yHidePassword => 'Hide password';

  @override
  String get a11ySelectedHint => 'Currently selected';

  @override
  String get a11yTapToSelect => 'Double tap to select';

  @override
  String get addCategory => 'Add category';

  @override
  String get addTag => 'Add tag';

  @override
  String a11yPinLockoutRemaining(int seconds) {
    return '$seconds seconds remaining until unlock';
  }

  @override
  String get a11yRecycleBinUrgent => 'Urgent: ';

  @override
  String get a11yLoading => 'Loading';
}
