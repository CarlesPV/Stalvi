// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get budgets => 'Budgets';

  @override
  String get settings => 'Settings';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get expenses => 'Expenses';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorDatabase =>
      'Database error occurred. Please contact support.';

  @override
  String get errorAuth =>
      'Authentication failed. Please check your credentials.';

  @override
  String get errorNetwork =>
      'Network error. Please check your internet connection.';

  @override
  String get appTitle => 'Konta';

  @override
  String get splashTagline => 'Your finances, your way.';

  @override
  String get splashStartupFailed => 'Startup Failed';

  @override
  String get splashSecureStorageError =>
      'Konta couldn\'t initialise its secure storage. Please check available device storage and try again.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get authCheckingBiometrics => 'Checking biometrics…';

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
  String get authVerifyIdentity => 'Verify Your Identity';

  @override
  String get authVerifyMessage =>
      'Use biometrics or your device PIN to access your financial data securely.';

  @override
  String get authVerifying => 'Verifying…';

  @override
  String get authAuthenticate => 'Authenticate';

  @override
  String get authSkip => 'Skip for now';

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
  String get authSetupTermsCheckbox =>
      'I accept the Terms & Conditions and Privacy Policy';

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
  String get defaultWalletName => 'My Wallet';

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
      'Use Fingerprint or FaceID to quickly and securely access your Konta account in the future.';

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
  String get myWallet => 'My Wallet';

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
  String get optional => 'Optional';

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
}
