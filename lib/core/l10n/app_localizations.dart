import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es')
  ];

  /// Title for the dashboard screen
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Title for the transactions screen or tab
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Title for the budgets screen or tab
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Title for the settings screen or tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button or title for adding a transaction
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Label for positive financial income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Label for negative financial expense
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Label for plural negative financial expenses
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Generic fallback error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Error message when database operation fails
  ///
  /// In en, this message translates to:
  /// **'Database error occurred. Please contact support.'**
  String get errorDatabase;

  /// Error message when authentication fails
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check your credentials.'**
  String get errorAuth;

  /// Error message when network request fails
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get errorNetwork;

  /// App name branding
  ///
  /// In en, this message translates to:
  /// **'Stalvi'**
  String get appTitle;

  /// Tagline displayed on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Your finances, your way.'**
  String get splashTagline;

  /// Error title shown when app startup fails
  ///
  /// In en, this message translates to:
  /// **'Startup Failed'**
  String get splashStartupFailed;

  /// Error message shown when secure storage fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Stalvi couldn\'t initialise its secure storage. Please check available device storage and try again.'**
  String get splashSecureStorageError;

  /// General button label to retry an operation
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Loading message during biometric initialization
  ///
  /// In en, this message translates to:
  /// **'Checking biometrics…'**
  String get authCheckingBiometrics;

  /// Error title for biometric authentication failure
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authError;

  /// Title when biometric lockout occurs
  ///
  /// In en, this message translates to:
  /// **'Biometrics Locked'**
  String get authLockedTitle;

  /// Description when biometric lockout occurs
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please unlock your device from the lock screen and try again.'**
  String get authLockedMessage;

  /// Warning chip label for active biometric lockout
  ///
  /// In en, this message translates to:
  /// **'Security lockout active'**
  String get authLockoutActive;

  /// Prompt title to verify identity
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get authVerifyIdentity;

  /// Prompt description to verify identity
  ///
  /// In en, this message translates to:
  /// **'Use biometrics or your device PIN to access your financial data securely.'**
  String get authVerifyMessage;

  /// Button label during verification state
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get authVerifying;

  /// Button label to trigger biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authAuthenticate;

  /// Button label to skip biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get authSkip;

  /// Footer text describing security
  ///
  /// In en, this message translates to:
  /// **'Protected by device biometrics'**
  String get authProtectedBy;

  /// Generic fallback error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// Title/label for the overview tab
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Title/label for the accounts tab or section
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// Section header for recent transactions list
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Title when transaction list is empty
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// Subtitle when transaction list is empty
  ///
  /// In en, this message translates to:
  /// **'Add your first income or expense to see it here and start tracking.'**
  String get noTransactionsSubtitle;

  /// Error message when transactions stream fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedLoadTransactions;

  /// Settings option for budgets and goals
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get settingsBudgetsGoals;

  /// Settings option for statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get settingsStatistics;

  /// Label for the total balance card
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get balanceTotal;

  /// Tooltip for custom date range button
  ///
  /// In en, this message translates to:
  /// **'Custom date range'**
  String get statisticsTooltipCustomRange;

  /// Section title for top spending categories
  ///
  /// In en, this message translates to:
  /// **'Top Spending Categories'**
  String get statisticsTopSpending;

  /// Section subtitle for top spending categories
  ///
  /// In en, this message translates to:
  /// **'Where your money goes'**
  String get statisticsWhereMoneyGoes;

  /// Label when no expenses exist for statistics
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded in this period.'**
  String get statisticsNoExpenses;

  /// Section title for top income categories
  ///
  /// In en, this message translates to:
  /// **'Top Income Categories'**
  String get statisticsTopIncome;

  /// Section subtitle for top income categories
  ///
  /// In en, this message translates to:
  /// **'What you earned'**
  String get statisticsWhatYouEarned;

  /// Label when no income exists for statistics
  ///
  /// In en, this message translates to:
  /// **'No income recorded in this period.'**
  String get statisticsNoIncome;

  /// Label for the net balance section
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get statisticsNetBalance;

  /// Label for net balance surplus
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get statisticsSurplus;

  /// Label for net balance deficit
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get statisticsDeficit;

  /// Label for this month date filter
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get presetThisMonth;

  /// Label for last 3 months date filter
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get presetLast3Months;

  /// Label for last 6 months date filter
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get presetLast6Months;

  /// Label for this year date filter
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get presetThisYear;

  /// Label for custom date filter
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// Title for the budgets and goals screen
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get budgetsAndGoals;

  /// Title/label for savings goals tab or section
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// Error message when budgets stream fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load budgets.'**
  String get failedLoadBudgets;

  /// Title when budgets list is empty
  ///
  /// In en, this message translates to:
  /// **'No budgets set yet'**
  String get noBudgetsTitle;

  /// Subtitle when budgets list is empty
  ///
  /// In en, this message translates to:
  /// **'Set spending limits for categories to track your monthly expenses and stay within your limits.'**
  String get noBudgetsSubtitle;

  /// Fallback name for categories without a name or value
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// Remaining budget spent description when limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'{amount} overspent'**
  String budgetOverspent(String amount);

  /// Remaining budget spent description when within limit
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(String amount);

  /// Error message when savings goals stream fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load savings goals.'**
  String get failedLoadSavingsGoals;

  /// Title when savings goals list is empty
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noSavingsGoalsTitle;

  /// Subtitle when savings goals list is empty
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal to plan for your future dreams, trips, or big purchases.'**
  String get noSavingsGoalsSubtitle;

  /// Savings goal target date description
  ///
  /// In en, this message translates to:
  /// **'Target date: {date}'**
  String savingsTargetDate(String date);

  /// Description when savings goal has no target date
  ///
  /// In en, this message translates to:
  /// **'No target date'**
  String get savingsNoTargetDate;

  /// Savings goal current progress vs target
  ///
  /// In en, this message translates to:
  /// **'{saved} saved of {target}'**
  String savingsSavedOf(String saved, String target);

  /// Text showing savings goal milestone completion
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get savingsGoalAchieved;

  /// Success message when transaction is saved
  ///
  /// In en, this message translates to:
  /// **'Transaction created successfully!'**
  String get txnSuccessCreated;

  /// Label for amount input field
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get labelAmount;

  /// Label for account field
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// Prompt or header to select an account
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get labelSelectAccount;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// Prompt or header to select a category
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get labelSelectCategory;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// Label for notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// Hint text for notes input field
  ///
  /// In en, this message translates to:
  /// **'Add details about this transaction...'**
  String get labelNotesHint;

  /// Button label to save transaction
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get btnSaveTransaction;

  /// Validation error for invalid transaction amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get errorInvalidAmount;

  /// Validation error when account is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get errorAccountRequired;

  /// Validation error when transaction date is in the future
  ///
  /// In en, this message translates to:
  /// **'Transaction date cannot be in the future'**
  String get errorFutureDate;

  /// Error when account doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get errorAccountNotFound;

  /// Error when user profile doesn't exist
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get errorProfileNotFound;

  /// Error when exchange rate is missing
  ///
  /// In en, this message translates to:
  /// **'Exchange rate not available for the requested currency'**
  String get errorRateNotFound;

  /// Error when currency conversion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to convert currency'**
  String get errorConversionFailed;

  /// Default label for empty state call-to-action button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Title for the profile setup screen
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get authSetupTitle;

  /// Subtitle for the profile setup screen
  ///
  /// In en, this message translates to:
  /// **'Set up your secure offline wallet to begin.'**
  String get authSetupSubtitle;

  /// Label for name input
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authSetupNameLabel;

  /// Label for username input
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authSetupUsernameLabel;

  /// Label for PIN input
  ///
  /// In en, this message translates to:
  /// **'Set a 4-8 digit PIN'**
  String get authSetupPinLabel;

  /// Label for confirming PIN
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get authSetupConfirmPinLabel;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get authSetupLanguageLabel;

  /// Label for terms and conditions checkbox
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms & Conditions and Privacy Policy'**
  String get authSetupTermsCheckbox;

  /// Button label to submit setup form
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get authSetupCreateButton;

  /// Validation error when PIN length is invalid
  ///
  /// In en, this message translates to:
  /// **'PIN must be between 4 and 8 digits.'**
  String get authSetupValidationErrorPinLength;

  /// Validation error when PINs do not match
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get authSetupValidationErrorPinMatch;

  /// Validation error when terms are not accepted
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms & Conditions and Privacy Policy to proceed.'**
  String get authSetupValidationErrorTerms;

  /// Validation error when name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get authSetupValidationErrorName;

  /// Validation error when username is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get authSetupValidationErrorUsername;

  /// Prompt to enter PIN
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get authPinEnter;

  /// Message indicating how many PIN attempts are remaining before lockout
  ///
  /// In en, this message translates to:
  /// **'{attempts} attempts remaining'**
  String authPinAttemptsRemaining(int attempts);

  /// Error message when PIN is incorrect
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get authPinIncorrect;

  /// Default wallet name when user profile is initialized
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get defaultWalletName;

  /// Default wallet name when user profile is initialized
  ///
  /// In en, this message translates to:
  /// **'Default Wallet'**
  String get defaultWallet;

  /// Label indicating number of accounts
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String acrossAccountsCount(int count);

  /// Error message when accounts list fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounts.'**
  String get failedLoadAccounts;

  /// Title when accounts list is empty
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsTitle;

  /// Subtitle when accounts list is empty
  ///
  /// In en, this message translates to:
  /// **'Create an account or wallet to start managing your assets and tracking transactions.'**
  String get noAccountsSubtitle;

  /// Label indicating an account is the default account
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAccountLabel;

  /// Subtitle when there is no data to show in statistics charts
  ///
  /// In en, this message translates to:
  /// **'Try adding transactions or changing the filter range to see your category breakdown.'**
  String get statisticsNoDataSubtitle;

  /// Title for the biometric opt-in screen
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get authBiometricOptInTitle;

  /// Subtitle for the biometric opt-in screen
  ///
  /// In en, this message translates to:
  /// **'Use Fingerprint or FaceID to quickly and securely access your Stalvi account in the future.'**
  String get authBiometricOptInSubtitle;

  /// Button label to enable biometric login
  ///
  /// In en, this message translates to:
  /// **'Enable Biometrics'**
  String get authBiometricOptInEnable;

  /// Button label to skip biometric login
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get authBiometricOptInSkip;

  /// Default label for empty state when no data is found
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailable;

  /// Title for the Terms and Conditions screen
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Title for the Privacy Policy screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// General localized label for My Wallet
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// Label for default currency selector during setup
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get authSetupCurrencyLabel;

  /// Prefix text for terms acceptance checkbox
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get authSetupAcceptPrefix;

  /// Conjunction text for terms and privacy acceptance checkbox
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get authSetupAcceptAnd;

  /// Label for theme mode selection in settings
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeMode;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Title for the profile and security settings screen
  ///
  /// In en, this message translates to:
  /// **'Profile & Security'**
  String get profileSettingsTitle;

  /// Button to change PIN
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinButton;

  /// Button to delete all application data
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllDataButton;

  /// Label for old PIN input
  ///
  /// In en, this message translates to:
  /// **'Old PIN'**
  String get oldPinLabel;

  /// Label for new PIN input
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPinLabel;

  /// Label for confirm new PIN input
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmPinLabel;

  /// Error message for incorrect old PIN
  ///
  /// In en, this message translates to:
  /// **'Incorrect Old PIN.'**
  String get incorrectOldPin;

  /// Error message when new PINs do not match
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinsDoNotMatch;

  /// Success message after updating PIN
  ///
  /// In en, this message translates to:
  /// **'PIN updated successfully.'**
  String get pinUpdatedSuccessfully;

  /// Warning message before deleting all data
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This cannot be undone.'**
  String get deleteAllDataWarning;

  /// Label for language selection in settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Label for username input
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// General cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// General save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// General delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// General next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// Title for the Recycle Bin screen
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBinTitle;

  /// Text shown when the recycle bin is empty
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty.'**
  String get recycleBinEmpty;

  /// Tooltip text for restoring an item
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get recycleBinRestoreTooltip;

  /// Tooltip text for permanently deleting an item
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get recycleBinDeleteTooltip;

  /// Title for the permanent delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get recycleBinDeleteConfirmTitle;

  /// Message for the permanent delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this item? This action cannot be undone.'**
  String get recycleBinDeleteConfirmMessage;

  /// Snackbar message shown when an item is successfully restored
  ///
  /// In en, this message translates to:
  /// **'Item restored'**
  String get recycleBinRestoredMessage;

  /// Snackbar message shown when an item is permanently deleted
  ///
  /// In en, this message translates to:
  /// **'Item permanently deleted'**
  String get recycleBinDeletedMessage;

  /// Days remaining until item in recycle bin is deleted
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String recycleBinDaysRemaining(int days);

  /// Label indicating an input field is optional
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Validation error when category is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get errorCategoryRequired;

  /// Validation error when currency is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get errorCurrencyRequired;

  /// Label for currency selector field
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get labelCurrency;

  /// Header or prompt to select a currency
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get labelSelectCurrency;

  /// Label for tag selector field
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get labelTag;

  /// Header or prompt to select a tag
  ///
  /// In en, this message translates to:
  /// **'Select Tag'**
  String get labelSelectTag;

  /// Label when no tag is selected
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noTag;

  /// Optional label formatted with parentheses
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optionalPlaceholder;

  /// Fallback name for empty income transaction notes
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get fallbackIncome;

  /// Fallback name for empty expense transaction notes
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get fallbackExpense;

  /// Error message when PIN attempts exceed limit
  ///
  /// In en, this message translates to:
  /// **'Maximum PIN attempts reached. Please try again later.'**
  String get errorMaxPinAttempts;

  /// Error message when PIN contains non-numeric characters
  ///
  /// In en, this message translates to:
  /// **'PIN must contain only numeric digits.'**
  String get errorPinNotNumeric;

  /// Error message when trying to verify a PIN but none is configured
  ///
  /// In en, this message translates to:
  /// **'No PIN is currently set.'**
  String get errorNoPinSet;

  /// Title shown during the PIN brute-force lockout screen
  ///
  /// In en, this message translates to:
  /// **'Too Many Failed Attempts'**
  String get authPinLockedTitle;

  /// Description shown during the PIN brute-force lockout screen
  ///
  /// In en, this message translates to:
  /// **'Access has been temporarily blocked after too many incorrect PIN entries.'**
  String get authPinLockedMessage;

  /// Label shown below the countdown ring during PIN lockout
  ///
  /// In en, this message translates to:
  /// **'seconds remaining'**
  String get authPinLockedCountdown;

  /// Label shown after PIN lockout expires, granting one more attempt
  ///
  /// In en, this message translates to:
  /// **'You may now try again'**
  String get authPinLockedRetry;

  /// Title for the biometric sign-in prompt
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get authSignInTitle;

  /// Default name for the main cash account created during setup
  ///
  /// In en, this message translates to:
  /// **'Main Account'**
  String get defaultAccountName;

  /// Filter option to show all transactions
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter option to show only income transactions
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// Filter option to show only expense transactions
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// Filter option to show only transfer transactions
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterTransfer;

  /// Title for the create account dialog
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createAccountTitle;

  /// Label for account name input
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get createAccountNameLabel;

  /// Hint text for account name input
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal Card, Cash, etc.'**
  String get createAccountNameHint;

  /// Label for initial balance input
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get createAccountInitialBalanceLabel;

  /// Label for account type selection
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get createAccountTypeLabel;

  /// Label for color theme selection
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get createAccountColorThemeLabel;

  /// Label for icon selection
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get createAccountIconLabel;

  /// Success message after account creation
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get createAccountSuccess;

  /// Error message when account name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get createAccountErrorName;

  /// Error message when account creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get createAccountErrorFailed;

  /// Account type: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// Account type: Cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// Account type: Bank
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// Account type: Savings
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// Account type: Card
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// Title for the delete transaction dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionTitle;

  /// Success message when transaction is deleted
  ///
  /// In en, this message translates to:
  /// **'Transaction moved to recycle bin'**
  String get transactionMovedToRecycleBin;

  /// Error message when transaction deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction'**
  String get errorDeleteTransaction;

  /// Message confirming the deletion of a transaction
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This will move it to the recycle bin.'**
  String get deleteTransactionConfirmation;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// Context menu option to set account as default
  ///
  /// In en, this message translates to:
  /// **'Set as Default Account'**
  String get setAsDefaultAccount;

  /// Snackbar message when account is set as default
  ///
  /// In en, this message translates to:
  /// **'Account set as default'**
  String get setAsDefaultAccountSuccess;

  /// Snackbar error when setting default account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to set default account'**
  String get setAsDefaultAccountError;

  /// Title for the transaction filter bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterSheetTitle;

  /// Button label to apply filters in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get filterSheetApply;

  /// Button label to clear all active filters
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get filterSheetClearAll;

  /// Label for transaction type filter section
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get filterSheetType;

  /// Label for category filter section
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterSheetCategory;

  /// Label for date range filter section
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterSheetDateRange;

  /// Label for amount range filter section
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get filterSheetAmountRange;

  /// Label for minimum amount input in filter sheet
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get filterSheetMinAmount;

  /// Label for maximum amount input in filter sheet
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get filterSheetMaxAmount;

  /// Label for tag filter section
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterSheetTag;

  /// Label for currency filter section
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get filterSheetCurrency;

  /// Label for showing all transaction types in filter
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get filterSheetAllTypes;

  /// Label for showing all categories in filter
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get filterSheetAllCategories;

  /// Label for showing all tags in filter
  ///
  /// In en, this message translates to:
  /// **'All Tags'**
  String get filterSheetAllTags;

  /// Label for showing all currencies in filter
  ///
  /// In en, this message translates to:
  /// **'All Currencies'**
  String get filterSheetAllCurrencies;

  /// Placeholder text for date range picker in filter sheet
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get filterSheetSelectDateRange;

  /// Badge label showing number of active filters
  ///
  /// In en, this message translates to:
  /// **'{count} active filters'**
  String filterSheetActiveFilters(int count);

  /// Label for transfer type in filter sheet
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterSheetTransferType;

  /// Label for the origin account of a transfer
  ///
  /// In en, this message translates to:
  /// **'Origin Account'**
  String get labelOriginAccount;

  /// Label for the destination account of a transfer
  ///
  /// In en, this message translates to:
  /// **'Destination Account'**
  String get labelDestinationAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
