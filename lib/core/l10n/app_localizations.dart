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
  /// **'Konta'**
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
  /// **'Konta couldn\'t initialise its secure storage. Please check available device storage and try again.'**
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
