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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Stalvi'**
  String get appTitle;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get btnOpen;

  /// No description provided for @btnReassignAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Reassign & Delete'**
  String get btnReassignAndDelete;

  /// No description provided for @btnRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get btnRestore;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get btnSelect;

  /// No description provided for @btnViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get btnViewDetails;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @currencyAUD.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar (AUD)'**
  String get currencyAUD;

  /// No description provided for @currencyCAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar (CAD)'**
  String get currencyCAD;

  /// No description provided for @currencyCHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc (CHF)'**
  String get currencyCHF;

  /// No description provided for @currencyCNY.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan (CNY)'**
  String get currencyCNY;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro (EUR)'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In en, this message translates to:
  /// **'British Pound (GBP)'**
  String get currencyGBP;

  /// No description provided for @currencyJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen (JPY)'**
  String get currencyJPY;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD)'**
  String get currencyUSD;

  /// No description provided for @deleteAllDataButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllDataButton;

  /// No description provided for @deleteAllDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This cannot be undone.'**
  String get deleteAllDataWarning;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @labelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// No description provided for @labelCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get labelCurrency;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get labelIcon;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// No description provided for @labelNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add details about this transaction...'**
  String get labelNotesHint;

  /// No description provided for @labelSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get labelSelectCurrency;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailable;

  /// No description provided for @optionalPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optionalPlaceholder;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @recurrenceUtcWarning.
  ///
  /// In en, this message translates to:
  /// **'Reference time is UTC+2'**
  String get recurrenceUtcWarning;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @txnSuccessCreated.
  ///
  /// In en, this message translates to:
  /// **'Transaction created successfully!'**
  String get txnSuccessCreated;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @authBiometricOptInEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometrics'**
  String get authBiometricOptInEnable;

  /// No description provided for @authBiometricOptInSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get authBiometricOptInSkip;

  /// No description provided for @authBiometricOptInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Fingerprint or FaceID to quickly and securely access your Stalvi account in the future.'**
  String get authBiometricOptInSubtitle;

  /// No description provided for @authBiometricOptInTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get authBiometricOptInTitle;

  /// No description provided for @authLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please unlock your device from the lock screen and try again.'**
  String get authLockedMessage;

  /// No description provided for @authLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometrics Locked'**
  String get authLockedTitle;

  /// No description provided for @authLockoutActive.
  ///
  /// In en, this message translates to:
  /// **'Security lockout active'**
  String get authLockoutActive;

  /// No description provided for @authPinAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{attempts} attempts remaining'**
  String authPinAttemptsRemaining(Object attempts);

  /// No description provided for @authPinEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get authPinEnter;

  /// No description provided for @authPinLockedCountdown.
  ///
  /// In en, this message translates to:
  /// **'seconds remaining'**
  String get authPinLockedCountdown;

  /// No description provided for @authPinLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Access has been temporarily blocked after too many incorrect PIN entries.'**
  String get authPinLockedMessage;

  /// No description provided for @authPinLockedRetry.
  ///
  /// In en, this message translates to:
  /// **'You may now try again'**
  String get authPinLockedRetry;

  /// No description provided for @authPinLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Too Many Failed Attempts'**
  String get authPinLockedTitle;

  /// No description provided for @authProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing security authentication…'**
  String get authProcessing;

  /// No description provided for @authSetupAcceptAnd.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get authSetupAcceptAnd;

  /// No description provided for @authSetupAcceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get authSetupAcceptPrefix;

  /// No description provided for @authSetupConfirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get authSetupConfirmPinLabel;

  /// No description provided for @authSetupCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get authSetupCreateButton;

  /// No description provided for @authSetupCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get authSetupCurrencyLabel;

  /// No description provided for @authSetupLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get authSetupLanguageLabel;

  /// No description provided for @authSetupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authSetupNameLabel;

  /// No description provided for @authSetupPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Set a 4-8 digit PIN'**
  String get authSetupPinLabel;

  /// No description provided for @authSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your secure offline wallet to begin.'**
  String get authSetupSubtitle;

  /// No description provided for @authSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get authSetupTitle;

  /// No description provided for @authSetupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authSetupUsernameLabel;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get authSignInTitle;

  /// No description provided for @authVerifyMessage.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics or your device PIN to continue'**
  String get authVerifyMessage;

  /// No description provided for @changePinButton.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinButton;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmPinLabel;

  /// No description provided for @newPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPinLabel;

  /// No description provided for @oldPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Old PIN'**
  String get oldPinLabel;

  /// No description provided for @pinUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PIN updated successfully.'**
  String get pinUpdatedSuccessfully;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinsDoNotMatch;

  /// No description provided for @statisticsTopIncome.
  ///
  /// In en, this message translates to:
  /// **'Top Income Categories'**
  String get statisticsTopIncome;

  /// No description provided for @balanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get balanceTotal;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @accountInUseByAutoTxMessage.
  ///
  /// In en, this message translates to:
  /// **'This account cannot be deleted because it is linked to active automatic transactions.'**
  String get accountInUseByAutoTxMessage;

  /// No description provided for @deleteAccountWithTransactionsWarning.
  ///
  /// In en, this message translates to:
  /// **'This account has associated transactions. Deleting it will also delete all its transactions.'**
  String get deleteAccountWithTransactionsWarning;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @acrossAccountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String acrossAccountsCount(num count);

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategoryTitle;

  /// No description provided for @addTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTagTitle;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @autoTxEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Automatic Transaction'**
  String get autoTxEditTitle;

  /// No description provided for @autoTxFormatEveryDays.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days'**
  String autoTxFormatEveryDays(Object days);

  /// No description provided for @autoTxFormatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get autoTxFormatMonthly;

  /// No description provided for @autoTxFormatSpecificDay.
  ///
  /// In en, this message translates to:
  /// **'Every month on the {day}'**
  String autoTxFormatSpecificDay(Object day);

  /// No description provided for @autoTxFormatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get autoTxFormatWeekly;

  /// No description provided for @autoTxFormatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get autoTxFormatYearly;

  /// No description provided for @autoTxLabelRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get autoTxLabelRecurrence;

  /// No description provided for @autoTxNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get autoTxNameRequired;

  /// No description provided for @autoTxNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Automatic Transaction'**
  String get autoTxNewTitle;

  /// No description provided for @autoTxRecurrenceApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get autoTxRecurrenceApply;

  /// No description provided for @autoTxRecurrenceCustomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 14'**
  String get autoTxRecurrenceCustomHint;

  /// No description provided for @autoTxRecurrenceCustomInterval.
  ///
  /// In en, this message translates to:
  /// **'Custom Interval (Days)'**
  String get autoTxRecurrenceCustomInterval;

  /// No description provided for @autoTxRecurrenceDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day X of month'**
  String get autoTxRecurrenceDayOfMonth;

  /// No description provided for @autoTxRecurrenceEveryXDays.
  ///
  /// In en, this message translates to:
  /// **'Every X days'**
  String get autoTxRecurrenceEveryXDays;

  /// No description provided for @autoTxRecurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly (Every 30 days)'**
  String get autoTxRecurrenceMonthly;

  /// No description provided for @autoTxRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly (Every 7 days)'**
  String get autoTxRecurrenceWeekly;

  /// No description provided for @autoTxRecurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly (Every 365 days)'**
  String get autoTxRecurrenceYearly;

  /// No description provided for @autoTxSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Automatic Transaction Saved'**
  String get autoTxSavedMessage;

  /// No description provided for @autoTxSelectRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Select Recurrence'**
  String get autoTxSelectRecurrence;

  /// No description provided for @autoTxTemplateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get autoTxTemplateNameLabel;

  /// No description provided for @btnSaveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get btnSaveTransaction;

  /// No description provided for @categoriesAndTags.
  ///
  /// In en, this message translates to:
  /// **'Categories & Tags'**
  String get categoriesAndTags;

  /// No description provided for @categoryInUseByAutoTxMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is in use by automatic transactions and must be reassigned.'**
  String categoryInUseByAutoTxMessage(String name);

  /// No description provided for @categoryInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is used by existing transactions. Please select a category to reassign them to:'**
  String categoryInUseMessage(Object name);

  /// No description provided for @categoryInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Category in Use'**
  String get categoryInUseTitle;

  /// No description provided for @createAccountIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get createAccountIconLabel;

  /// No description provided for @createAccountInitialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get createAccountInitialBalanceLabel;

  /// No description provided for @createAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal Card, Cash, etc.'**
  String get createAccountNameHint;

  /// No description provided for @createAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get createAccountNameLabel;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createAccountTitle;

  /// No description provided for @createNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createNewCategory;

  /// No description provided for @createNewLabel.
  ///
  /// In en, this message translates to:
  /// **'Create New Label'**
  String get createNewLabel;

  /// No description provided for @createAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get createAccountTypeLabel;

  /// No description provided for @createAutomaticTransaction.
  ///
  /// In en, this message translates to:
  /// **'Create Automatic Transaction'**
  String get createAutomaticTransaction;

  /// No description provided for @defaultAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAccountLabel;

  /// No description provided for @defaultAccountName.
  ///
  /// In en, this message translates to:
  /// **'Main Account'**
  String get defaultAccountName;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteCategoryConfirm(Object name);

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteTagConfirm(Object name);

  /// No description provided for @deleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag?'**
  String get deleteTagTitle;

  /// No description provided for @deleteTransactionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This will move it to the recycle bin.'**
  String get deleteTransactionConfirmation;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @destination_account.
  ///
  /// In en, this message translates to:
  /// **'Destination Account'**
  String get destination_account;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitle;

  /// No description provided for @editTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTagTitle;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Expense} other{Expenses}}'**
  String expense(num count);

  /// No description provided for @expense_vs_income.
  ///
  /// In en, this message translates to:
  /// **'Expenses vs Income'**
  String get expense_vs_income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @fallbackExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get fallbackExpense;

  /// No description provided for @fallbackIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get fallbackIncome;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterSheetActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'{count} active filters'**
  String filterSheetActiveFilters(Object count);

  /// No description provided for @filterSheetAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get filterSheetAllCategories;

  /// No description provided for @filterSheetAllCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All Currencies'**
  String get filterSheetAllCurrencies;

  /// No description provided for @filterSheetAllTags.
  ///
  /// In en, this message translates to:
  /// **'All Tags'**
  String get filterSheetAllTags;

  /// No description provided for @filterSheetAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get filterSheetAllTypes;

  /// No description provided for @filterSheetAmountRange.
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get filterSheetAmountRange;

  /// No description provided for @filterSheetApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get filterSheetApply;

  /// No description provided for @filterSheetCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterSheetCategory;

  /// No description provided for @filterSheetClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get filterSheetClearAll;

  /// No description provided for @filterSheetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get filterSheetCurrency;

  /// No description provided for @filterSheetDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterSheetDateRange;

  /// No description provided for @filterSheetMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Amount'**
  String get filterSheetMaxAmount;

  /// No description provided for @filterSheetMinAmount.
  ///
  /// In en, this message translates to:
  /// **'Min Amount'**
  String get filterSheetMinAmount;

  /// No description provided for @filterSheetSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get filterSheetSelectDateRange;

  /// No description provided for @filterSheetTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterSheetTag;

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterSheetTitle;

  /// No description provided for @filterSheetTransferType.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterSheetTransferType;

  /// No description provided for @filterSheetType.
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get filterSheetType;

  /// No description provided for @filterTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get filterTransfer;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Income} other{Incomes}}'**
  String income(num count);

  /// No description provided for @labelAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get labelCategoryName;

  /// No description provided for @labelDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination Account'**
  String get labelDestinationAccount;

  /// No description provided for @labelFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get labelFromAccount;

  /// No description provided for @labelOriginAccount.
  ///
  /// In en, this message translates to:
  /// **'Origin Account'**
  String get labelOriginAccount;

  /// No description provided for @labelSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get labelSelectAccount;

  /// No description provided for @labelSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get labelSelectCategory;

  /// No description provided for @labelSelectTag.
  ///
  /// In en, this message translates to:
  /// **'Select Tag'**
  String get labelSelectTag;

  /// No description provided for @labelTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get labelTag;

  /// No description provided for @labelTagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get labelTagName;

  /// No description provided for @labelToAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get labelToAccount;

  /// No description provided for @noAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account or wallet to start managing your assets and tracking transactions.'**
  String get noAccountsSubtitle;

  /// No description provided for @noAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsTitle;

  /// No description provided for @noTag.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noTag;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTags;

  /// No description provided for @noTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first income or expense to see it here and start tracking.'**
  String get noTransactionsSubtitle;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsTitle;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @replaceDefaultAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'The previous default account will be replaced. Continue?'**
  String get replaceDefaultAccountConfirm;

  /// No description provided for @selectDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Destination Account'**
  String get selectDestinationAccount;

  /// No description provided for @selectSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Source Account'**
  String get selectSourceAccount;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your finances, your way.'**
  String get splashTagline;

  /// No description provided for @tagInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is used by existing transactions. Please select a tag to reassign them to:'**
  String tagInUseMessage(Object name);

  /// No description provided for @tagInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag in Use'**
  String get tagInUseTitle;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @unknownAccount.
  ///
  /// In en, this message translates to:
  /// **'Unknown Account'**
  String get unknownAccount;

  /// No description provided for @accountTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// No description provided for @addSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Savings Goal'**
  String get addSavingsGoal;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget Details'**
  String get budgetDetails;

  /// No description provided for @budgetOverspent.
  ///
  /// In en, this message translates to:
  /// **'{amount} overspent'**
  String budgetOverspent(Object amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(Object amount);

  /// No description provided for @budgetSpentOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {target}'**
  String budgetSpentOf(Object spent, Object target);

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @budgetsAndGoals.
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get budgetsAndGoals;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteSavingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Savings Goal'**
  String get deleteSavingsGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @labelBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get labelBudget;

  /// No description provided for @noBudgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set spending limits for categories to track your monthly expenses and stay within your limits.'**
  String get noBudgetsSubtitle;

  /// No description provided for @noBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets set yet'**
  String get noBudgetsTitle;

  /// No description provided for @noSavingsGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal to plan for your future dreams, trips, or big purchases.'**
  String get noSavingsGoalsSubtitle;

  /// No description provided for @noSavingsGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noSavingsGoalsTitle;

  /// No description provided for @pdfBudgetsColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get pdfBudgetsColCategory;

  /// No description provided for @pdfBudgetsColDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get pdfBudgetsColDateRange;

  /// No description provided for @pdfBudgetsColMaxValue.
  ///
  /// In en, this message translates to:
  /// **'Max Value'**
  String get pdfBudgetsColMaxValue;

  /// No description provided for @pdfBudgetsColSpent.
  ///
  /// In en, this message translates to:
  /// **'% Spent'**
  String get pdfBudgetsColSpent;

  /// No description provided for @pdfBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get pdfBudgetsTitle;

  /// No description provided for @pdfSavingsColCompleted.
  ///
  /// In en, this message translates to:
  /// **'% Completed'**
  String get pdfSavingsColCompleted;

  /// No description provided for @pdfSavingsColName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pdfSavingsColName;

  /// No description provided for @pdfSavingsGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get pdfSavingsGoalsTitle;

  /// No description provided for @savingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Savings Goal'**
  String get savingsGoal;

  /// No description provided for @savingsGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get savingsGoalAchieved;

  /// No description provided for @savingsGoalDetails.
  ///
  /// In en, this message translates to:
  /// **'Savings Goal Details'**
  String get savingsGoalDetails;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @savingsNoTargetDate.
  ///
  /// In en, this message translates to:
  /// **'No target date'**
  String get savingsNoTargetDate;

  /// No description provided for @savingsSavedOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved of {target}'**
  String savingsSavedOf(Object saved, Object target);

  /// No description provided for @savingsTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date: {date}'**
  String savingsTargetDate(Object date);

  /// No description provided for @settingsBudgetsGoals.
  ///
  /// In en, this message translates to:
  /// **'Budgets & Goals'**
  String get settingsBudgetsGoals;

  /// No description provided for @chart_scale.
  ///
  /// In en, this message translates to:
  /// **'Chart Scale'**
  String get chart_scale;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// No description provided for @presetLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get presetLast30Days;

  /// No description provided for @presetLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get presetLast3Months;

  /// No description provided for @presetLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get presetLast6Months;

  /// No description provided for @presetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get presetThisMonth;

  /// No description provided for @presetThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get presetThisYear;

  /// No description provided for @settingsStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get settingsStatistics;

  /// No description provided for @statisticsDeficit.
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get statisticsDeficit;

  /// No description provided for @statisticsNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get statisticsNetBalance;

  /// No description provided for @statisticsTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get statisticsTransfers;

  /// No description provided for @statisticsNoDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adding transactions or changing the filter range to see your category breakdown.'**
  String get statisticsNoDataSubtitle;

  /// No description provided for @statisticsNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded in this period.'**
  String get statisticsNoExpenses;

  /// No description provided for @statisticsNoIncome.
  ///
  /// In en, this message translates to:
  /// **'No income recorded in this period.'**
  String get statisticsNoIncome;

  /// No description provided for @statisticsOtherCategories.
  ///
  /// In en, this message translates to:
  /// **'Other ({count} categories)'**
  String statisticsOtherCategories(Object count);

  /// No description provided for @statisticsSurplus.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get statisticsSurplus;

  /// No description provided for @statisticsTooltipCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom date range'**
  String get statisticsTooltipCustomRange;

  /// No description provided for @statisticsTopSpending.
  ///
  /// In en, this message translates to:
  /// **'Top Spending Categories'**
  String get statisticsTopSpending;

  /// No description provided for @statisticsWhatYouEarned.
  ///
  /// In en, this message translates to:
  /// **'What you earned'**
  String get statisticsWhatYouEarned;

  /// No description provided for @statisticsWhereMoneyGoes.
  ///
  /// In en, this message translates to:
  /// **'Where your money goes'**
  String get statisticsWhereMoneyGoes;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @aboutMeGithubButton.
  ///
  /// In en, this message translates to:
  /// **'View my GitHub'**
  String get aboutMeGithubButton;

  /// No description provided for @btnExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get btnExport;

  /// No description provided for @createAccountColorThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get createAccountColorThemeLabel;

  /// No description provided for @exportEncryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Encrypted Backup'**
  String get exportEncryptedBackup;

  /// No description provided for @exportEncryptedBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all data as a password-protected backup file'**
  String get exportEncryptedBackupSubtitle;

  /// No description provided for @exportMonthlyPdf.
  ///
  /// In en, this message translates to:
  /// **'Export Monthly Report (PDF)'**
  String get exportMonthlyPdf;

  /// No description provided for @exportMonthlyPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a PDF summary'**
  String get exportMonthlyPdfSubtitle;

  /// No description provided for @exportPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get exportPasswordConfirmLabel;

  /// No description provided for @exportPasswordDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This password will be required to restore your backup. Store it safely.'**
  String get exportPasswordDialogSubtitle;

  /// No description provided for @exportPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Backup Password'**
  String get exportPasswordDialogTitle;

  /// No description provided for @exportPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get exportPasswordLabel;

  /// No description provided for @exportPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get exportPasswordTooShort;

  /// No description provided for @exportPdfCurrentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get exportPdfCurrentMonth;

  /// No description provided for @exportPdfLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get exportPdfLast30Days;

  /// No description provided for @exportPdfSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get exportPdfSelectMonth;

  /// No description provided for @exportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {filePath}'**
  String exportSavedTo(Object filePath);

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export successful. File saved.'**
  String get exportSuccess;

  /// No description provided for @exportTransactionsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions (CSV)'**
  String get exportTransactionsCsv;

  /// No description provided for @exportTransactionsCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export all transactions to a spreadsheet-compatible CSV file'**
  String get exportTransactionsCsvSubtitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup will overwrite all current data. This cannot be undone. Are you sure?'**
  String get importConfirmMessage;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get importConfirmTitle;

  /// No description provided for @importPasswordDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the password used when the backup was created.'**
  String get importPasswordDialogSubtitle;

  /// No description provided for @importPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Backup Password'**
  String get importPasswordDialogTitle;

  /// No description provided for @importRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Import / Restore Backup'**
  String get importRestoreBackup;

  /// No description provided for @importRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your data from a Stalvi backup file'**
  String get importRestoreBackupSubtitle;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored successfully. Please restart the app.'**
  String get importSuccess;

  /// No description provided for @languageCatalan.
  ///
  /// In en, this message translates to:
  /// **'Català'**
  String get languageCatalan;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @pdfDateFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy'**
  String get pdfDateFormat;

  /// No description provided for @pdfDateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy HH:mm'**
  String get pdfDateTimeFormat;

  /// No description provided for @pdfExportLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get pdfExportLast30Days;

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated by {appTitle} on {date}'**
  String pdfGeneratedOn(Object appTitle, Object date);

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Security'**
  String get profileSettingsTitle;

  /// No description provided for @recycleBinDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String recycleBinDaysRemaining(Object days);

  /// No description provided for @recycleBinDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this item? This action cannot be undone.'**
  String get recycleBinDeleteConfirmMessage;

  /// No description provided for @recycleBinDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent Delete'**
  String get recycleBinDeleteConfirmTitle;

  /// No description provided for @recycleBinDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get recycleBinDeleteTooltip;

  /// No description provided for @recycleBinDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Item permanently deleted'**
  String get recycleBinDeletedMessage;

  /// No description provided for @recycleBinEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty.'**
  String get recycleBinEmpty;

  /// No description provided for @recycleBinRestoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get recycleBinRestoreTooltip;

  /// No description provided for @recycleBinRestoredMessage.
  ///
  /// In en, this message translates to:
  /// **'Item restored'**
  String get recycleBinRestoredMessage;

  /// No description provided for @recycleBinTitle.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBinTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsAutomaticTransactions.
  ///
  /// In en, this message translates to:
  /// **'Automatic Transactions'**
  String get settingsAutomaticTransactions;

  /// No description provided for @settingsDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Import & Export Data'**
  String get settingsDataManagement;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsNotifications;

  /// No description provided for @notificationsPermanentlyDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications Disabled'**
  String get notificationsPermanentlyDeniedTitle;

  /// No description provided for @notificationsPermanentlyDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied notification permissions. Please enable them in your system settings to receive alerts.'**
  String get notificationsPermanentlyDeniedBody;

  /// No description provided for @btnOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get btnOpenSettings;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeMode;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @transactionMovedToRecycleBin.
  ///
  /// In en, this message translates to:
  /// **'Transaction moved to recycle bin'**
  String get transactionMovedToRecycleBin;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authError;

  /// No description provided for @authPinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get authPinIncorrect;

  /// No description provided for @authSetupValidationErrorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get authSetupValidationErrorName;

  /// No description provided for @authSetupValidationErrorNameEmoji.
  ///
  /// In en, this message translates to:
  /// **'Name cannot contain emojis or special characters.'**
  String get authSetupValidationErrorNameEmoji;

  /// No description provided for @authSetupValidationErrorNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 25 characters.'**
  String get authSetupValidationErrorNameLength;

  /// No description provided for @authSetupValidationErrorPinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be between 4 and 8 digits.'**
  String get authSetupValidationErrorPinLength;

  /// No description provided for @authSetupValidationErrorPinMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get authSetupValidationErrorPinMatch;

  /// No description provided for @authSetupValidationErrorTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms & Conditions and Privacy Policy to proceed.'**
  String get authSetupValidationErrorTerms;

  /// No description provided for @authSetupValidationErrorUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get authSetupValidationErrorUsername;

  /// No description provided for @authSetupValidationErrorUsernameEmoji.
  ///
  /// In en, this message translates to:
  /// **'Username cannot contain emojis or special characters.'**
  String get authSetupValidationErrorUsernameEmoji;

  /// No description provided for @authSetupValidationErrorUsernameLength.
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed 25 characters.'**
  String get authSetupValidationErrorUsernameLength;

  /// No description provided for @autoTxErrorInvalidDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Invalid day of month (must be 1-31)'**
  String get autoTxErrorInvalidDayOfMonth;

  /// No description provided for @autoTxErrorInvalidRecurrenceInterval.
  ///
  /// In en, this message translates to:
  /// **'Invalid recurrence interval'**
  String get autoTxErrorInvalidRecurrenceInterval;

  /// No description provided for @createAccountErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get createAccountErrorFailed;

  /// No description provided for @createAccountErrorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get createAccountErrorName;

  /// No description provided for @errorAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get errorAccountNotFound;

  /// No description provided for @errorAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get errorAccountRequired;

  /// No description provided for @errorCannotDeleteLastAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last existing account.'**
  String get errorCannotDeleteLastAccount;

  /// No description provided for @errorCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get errorCategoryRequired;

  /// No description provided for @errorConversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to convert currency'**
  String get errorConversionFailed;

  /// No description provided for @errorCurrencyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get errorCurrencyRequired;

  /// No description provided for @errorDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction'**
  String get errorDeleteTransaction;

  /// No description provided for @errorDestinationAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination account'**
  String get errorDestinationAccountRequired;

  /// No description provided for @errorEndDateBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get errorEndDateBeforeStart;

  /// No description provided for @errorFutureDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction date cannot be in the future'**
  String get errorFutureDate;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get errorInvalidAmount;

  /// No description provided for @errorMaxPinAttempts.
  ///
  /// In en, this message translates to:
  /// **'Maximum PIN attempts reached. Please try again later.'**
  String get errorMaxPinAttempts;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get errorNameRequired;

  /// No description provided for @errorNoOtherCategories.
  ///
  /// In en, this message translates to:
  /// **'No other categories to reassign transactions to.'**
  String get errorNoOtherCategories;

  /// No description provided for @errorNoOtherTags.
  ///
  /// In en, this message translates to:
  /// **'No other tags to reassign transactions to.'**
  String get errorNoOtherTags;

  /// No description provided for @errorNoPinSet.
  ///
  /// In en, this message translates to:
  /// **'No PIN is currently set.'**
  String get errorNoPinSet;

  /// No description provided for @errorOpenFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open file'**
  String get errorOpenFileFailed;

  /// No description provided for @errorPinNotNumeric.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain only numeric digits.'**
  String get errorPinNotNumeric;

  /// No description provided for @errorProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get errorProfileNotFound;

  /// No description provided for @errorRateNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate not available for the requested currency'**
  String get errorRateNotFound;

  /// No description provided for @errorSameAccountTransfer.
  ///
  /// In en, this message translates to:
  /// **'Source and destination accounts cannot be the same'**
  String get errorSameAccountTransfer;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Please try again.'**
  String get exportFailed;

  /// No description provided for @exportPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get exportPasswordMismatch;

  /// No description provided for @failedLoadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounts.'**
  String get failedLoadAccounts;

  /// No description provided for @failedLoadBudgets.
  ///
  /// In en, this message translates to:
  /// **'Failed to load budgets.'**
  String get failedLoadBudgets;

  /// No description provided for @failedLoadSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Failed to load savings goals.'**
  String get failedLoadSavingsGoals;

  /// No description provided for @failedLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedLoadTransactions;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Check your password and file.'**
  String get importFailed;

  /// No description provided for @incorrectOldPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Old PIN.'**
  String get incorrectOldPin;

  /// No description provided for @splashSecureStorageError.
  ///
  /// In en, this message translates to:
  /// **'Stalvi couldn\'t initialise its secure storage. Please check available device storage and try again.'**
  String get splashSecureStorageError;

  /// No description provided for @splashStartupFailed.
  ///
  /// In en, this message translates to:
  /// **'Startup Failed'**
  String get splashStartupFailed;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedError;

  /// No description provided for @hintAmountZero.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get hintAmountZero;

  /// No description provided for @errorCouldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch URL'**
  String get errorCouldNotLaunchUrl;

  /// No description provided for @errorLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Error loading content.'**
  String get errorLoadingContent;

  /// No description provided for @errorCannotDeleteDefaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the default account. Please set another account as default first.'**
  String get errorCannotDeleteDefaultAccount;

  /// No description provided for @errorNoDefaultAccountForReassignment.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete account because no default account exists for reassignment.'**
  String get errorNoDefaultAccountForReassignment;

  /// No description provided for @errorDefaultAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'You must have at least one default account.'**
  String get errorDefaultAccountRequired;

  /// No description provided for @widgetIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get widgetIncomeTitle;

  /// No description provided for @widgetExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get widgetExpenseTitle;

  /// No description provided for @a11yAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add new transaction'**
  String get a11yAddTransaction;

  /// No description provided for @a11yDoubleTapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Double tap to edit'**
  String get a11yDoubleTapToEdit;

  /// No description provided for @a11yDoubleTapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details'**
  String get a11yDoubleTapToViewDetails;

  /// No description provided for @a11yExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get a11yExpense;

  /// No description provided for @a11yIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get a11yIncome;

  /// No description provided for @a11yTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get a11yTransfer;

  /// No description provided for @a11yTransactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get a11yTransactionDetails;

  /// No description provided for @a11ySelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get a11ySelectCategory;

  /// No description provided for @a11ySelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get a11ySelectAccount;

  /// No description provided for @a11ySelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get a11ySelectDate;

  /// No description provided for @a11yPinBackspace.
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get a11yPinBackspace;

  /// No description provided for @a11yPinBiometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get a11yPinBiometric;

  /// No description provided for @a11yPinDigit.
  ///
  /// In en, this message translates to:
  /// **'Digit {digit}'**
  String a11yPinDigit(Object digit);

  /// No description provided for @a11yPinProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} digits entered'**
  String a11yPinProgress(Object count, Object total);

  /// No description provided for @a11yEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get a11yEditCategory;

  /// No description provided for @a11yDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get a11yDeleteCategory;

  /// No description provided for @a11yStatisticsSummary.
  ///
  /// In en, this message translates to:
  /// **'Statistics summary'**
  String get a11yStatisticsSummary;

  /// No description provided for @a11yBudgetProgress.
  ///
  /// In en, this message translates to:
  /// **'Budget progress'**
  String get a11yBudgetProgress;

  /// No description provided for @a11yChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics chart.'**
  String get a11yChartTitle;

  /// No description provided for @a11yChartTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category: {category} with {percent}%.'**
  String a11yChartTopCategory(String category, String percent);

  /// No description provided for @a11yChartSecondCategory.
  ///
  /// In en, this message translates to:
  /// **'Second: {category} with {percent}%.'**
  String a11yChartSecondCategory(String category, String percent);

  /// No description provided for @a11yChartOtherCategories.
  ///
  /// In en, this message translates to:
  /// **'Other categories make up the rest.'**
  String get a11yChartOtherCategories;

  /// No description provided for @a11yChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get a11yChartNoData;

  /// No description provided for @a11yDiscreetModeHidden.
  ///
  /// In en, this message translates to:
  /// **'Balance hidden.'**
  String get a11yDiscreetModeHidden;

  /// No description provided for @a11yDiscreetModeHint.
  ///
  /// In en, this message translates to:
  /// **'Double tap the visibility button to show.'**
  String get a11yDiscreetModeHint;

  /// No description provided for @a11yDiscreetModeToggleHide.
  ///
  /// In en, this message translates to:
  /// **'Hide balances (discreet mode)'**
  String get a11yDiscreetModeToggleHide;

  /// No description provided for @a11yDiscreetModeToggleShow.
  ///
  /// In en, this message translates to:
  /// **'Show balances'**
  String get a11yDiscreetModeToggleShow;

  /// No description provided for @a11yRestoreItem.
  ///
  /// In en, this message translates to:
  /// **'Restore {item}'**
  String a11yRestoreItem(String item);

  /// No description provided for @a11yDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete {item} permanently'**
  String a11yDeletePermanently(String item);

  /// No description provided for @a11yAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept terms and privacy policy'**
  String get a11yAcceptTerms;

  /// No description provided for @a11yChartSummary.
  ///
  /// In en, this message translates to:
  /// **'Statistics chart. {details}'**
  String a11yChartSummary(String details);

  /// No description provided for @a11yColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get a11yColorBlue;

  /// No description provided for @a11yColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get a11yColorGreen;

  /// No description provided for @a11yColorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get a11yColorAmber;

  /// No description provided for @a11yColorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get a11yColorPink;

  /// No description provided for @a11yColorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get a11yColorPurple;

  /// No description provided for @a11yColorDeepOrange.
  ///
  /// In en, this message translates to:
  /// **'Deep orange'**
  String get a11yColorDeepOrange;

  /// No description provided for @a11yColorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get a11yColorCyan;

  /// No description provided for @a11yColorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get a11yColorTeal;

  /// No description provided for @a11yColorLightGreen.
  ///
  /// In en, this message translates to:
  /// **'Light green'**
  String get a11yColorLightGreen;

  /// No description provided for @a11yColorLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get a11yColorLime;

  /// No description provided for @a11yColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get a11yColorOrange;

  /// No description provided for @a11yColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get a11yColorRed;

  /// No description provided for @a11yColorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get a11yColorBrown;

  /// No description provided for @a11yColorBlueGrey.
  ///
  /// In en, this message translates to:
  /// **'Blue grey'**
  String get a11yColorBlueGrey;

  /// No description provided for @a11yColorDeepPurple.
  ///
  /// In en, this message translates to:
  /// **'Deep purple'**
  String get a11yColorDeepPurple;

  /// No description provided for @a11yColorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get a11yColorIndigo;

  /// No description provided for @a11yColorLightPink.
  ///
  /// In en, this message translates to:
  /// **'Light pink'**
  String get a11yColorLightPink;

  /// No description provided for @a11yColorMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get a11yColorMint;

  /// No description provided for @a11yColorLightLime.
  ///
  /// In en, this message translates to:
  /// **'Light lime'**
  String get a11yColorLightLime;

  /// No description provided for @a11yColorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get a11yColorCoral;

  /// No description provided for @a11yColorLightBrown.
  ///
  /// In en, this message translates to:
  /// **'Light brown'**
  String get a11yColorLightBrown;

  /// No description provided for @a11yColorGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get a11yColorGrey;

  /// No description provided for @a11yColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get a11yColorYellow;

  /// No description provided for @a11yColorLightBlue.
  ///
  /// In en, this message translates to:
  /// **'Light blue'**
  String get a11yColorLightBlue;

  /// No description provided for @a11yColorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get a11yColorBlack;

  /// No description provided for @a11yColorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get a11yColorWhite;

  /// No description provided for @a11yIconAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get a11yIconAccountBalance;

  /// No description provided for @a11yIconAccountBalanceWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get a11yIconAccountBalanceWallet;

  /// No description provided for @a11yIconAttachMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get a11yIconAttachMoney;

  /// No description provided for @a11yIconMoneyOff.
  ///
  /// In en, this message translates to:
  /// **'No money'**
  String get a11yIconMoneyOff;

  /// No description provided for @a11yIconCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get a11yIconCreditCard;

  /// No description provided for @a11yIconSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get a11yIconSavings;

  /// No description provided for @a11yIconReceiptLong.
  ///
  /// In en, this message translates to:
  /// **'Detailed receipt'**
  String get a11yIconReceiptLong;

  /// No description provided for @a11yIconReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get a11yIconReceipt;

  /// No description provided for @a11yIconRequestQuote.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get a11yIconRequestQuote;

  /// No description provided for @a11yIconPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get a11yIconPaid;

  /// No description provided for @a11yIconPriceCheck.
  ///
  /// In en, this message translates to:
  /// **'Price check'**
  String get a11yIconPriceCheck;

  /// No description provided for @a11yIconPriceChange.
  ///
  /// In en, this message translates to:
  /// **'Price change'**
  String get a11yIconPriceChange;

  /// No description provided for @a11yIconCurrencyExchange.
  ///
  /// In en, this message translates to:
  /// **'Currency exchange'**
  String get a11yIconCurrencyExchange;

  /// No description provided for @a11yIconMonetizationOn.
  ///
  /// In en, this message translates to:
  /// **'Monetization'**
  String get a11yIconMonetizationOn;

  /// No description provided for @a11yIconTrendingUp.
  ///
  /// In en, this message translates to:
  /// **'Trending up'**
  String get a11yIconTrendingUp;

  /// No description provided for @a11yIconTrendingDown.
  ///
  /// In en, this message translates to:
  /// **'Trending down'**
  String get a11yIconTrendingDown;

  /// No description provided for @a11yIconShowChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get a11yIconShowChart;

  /// No description provided for @a11yIconReplay.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get a11yIconReplay;

  /// No description provided for @a11yIconShoppingCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping cart'**
  String get a11yIconShoppingCart;

  /// No description provided for @a11yIconShoppingBag.
  ///
  /// In en, this message translates to:
  /// **'Shopping bag'**
  String get a11yIconShoppingBag;

  /// No description provided for @a11yIconLocalMall.
  ///
  /// In en, this message translates to:
  /// **'Shopping mall'**
  String get a11yIconLocalMall;

  /// No description provided for @a11yIconStorefront.
  ///
  /// In en, this message translates to:
  /// **'Storefront'**
  String get a11yIconStorefront;

  /// No description provided for @a11yIconRedeem.
  ///
  /// In en, this message translates to:
  /// **'Gift reward'**
  String get a11yIconRedeem;

  /// No description provided for @a11yIconLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty card'**
  String get a11yIconLoyalty;

  /// No description provided for @a11yIconSell.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get a11yIconSell;

  /// No description provided for @a11yIconDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get a11yIconDiscount;

  /// No description provided for @a11yIconRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get a11yIconRestaurant;

  /// No description provided for @a11yIconLunchDining.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get a11yIconLunchDining;

  /// No description provided for @a11yIconDinnerDining.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get a11yIconDinnerDining;

  /// No description provided for @a11yIconLocalCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get a11yIconLocalCafe;

  /// No description provided for @a11yIconFastfood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get a11yIconFastfood;

  /// No description provided for @a11yIconBakeryDining.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get a11yIconBakeryDining;

  /// No description provided for @a11yIconIcecream.
  ///
  /// In en, this message translates to:
  /// **'Ice cream'**
  String get a11yIconIcecream;

  /// No description provided for @a11yIconLocalGroceryStore.
  ///
  /// In en, this message translates to:
  /// **'Supermarket'**
  String get a11yIconLocalGroceryStore;

  /// No description provided for @a11yIconHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get a11yIconHome;

  /// No description provided for @a11yIconHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get a11yIconHouse;

  /// No description provided for @a11yIconApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get a11yIconApartment;

  /// No description provided for @a11yIconCottage.
  ///
  /// In en, this message translates to:
  /// **'Cottage'**
  String get a11yIconCottage;

  /// No description provided for @a11yIconBed.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get a11yIconBed;

  /// No description provided for @a11yIconBathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get a11yIconBathroom;

  /// No description provided for @a11yIconKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get a11yIconKitchen;

  /// No description provided for @a11yIconChair.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get a11yIconChair;

  /// No description provided for @a11yIconYard.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get a11yIconYard;

  /// No description provided for @a11yIconGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get a11yIconGarage;

  /// No description provided for @a11yIconElectricalServices.
  ///
  /// In en, this message translates to:
  /// **'Electrician'**
  String get a11yIconElectricalServices;

  /// No description provided for @a11yIconPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get a11yIconPlumbing;

  /// No description provided for @a11yIconDirectionsCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get a11yIconDirectionsCar;

  /// No description provided for @a11yIconLocalGasStation.
  ///
  /// In en, this message translates to:
  /// **'Gas station'**
  String get a11yIconLocalGasStation;

  /// No description provided for @a11yIconCarRepair.
  ///
  /// In en, this message translates to:
  /// **'Car repair'**
  String get a11yIconCarRepair;

  /// No description provided for @a11yIconDirectionsBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get a11yIconDirectionsBus;

  /// No description provided for @a11yIconDirectionsSubway.
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get a11yIconDirectionsSubway;

  /// No description provided for @a11yIconDirectionsBike.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get a11yIconDirectionsBike;

  /// No description provided for @a11yIconTwoWheeler.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get a11yIconTwoWheeler;

  /// No description provided for @a11yIconFlight.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get a11yIconFlight;

  /// No description provided for @a11yIconHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get a11yIconHotel;

  /// No description provided for @a11yIconLocalTaxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get a11yIconLocalTaxi;

  /// No description provided for @a11yIconTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get a11yIconTrain;

  /// No description provided for @a11yIconDirectionsBoat.
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get a11yIconDirectionsBoat;

  /// No description provided for @a11yIconEvStation.
  ///
  /// In en, this message translates to:
  /// **'Electric vehicle charger'**
  String get a11yIconEvStation;

  /// No description provided for @a11yIconLocalParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get a11yIconLocalParking;

  /// No description provided for @a11yIconToll.
  ///
  /// In en, this message translates to:
  /// **'Toll'**
  String get a11yIconToll;

  /// No description provided for @a11yIconLuggage.
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get a11yIconLuggage;

  /// No description provided for @a11yIconLocalHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get a11yIconLocalHospital;

  /// No description provided for @a11yIconMedicalServices.
  ///
  /// In en, this message translates to:
  /// **'Medical services'**
  String get a11yIconMedicalServices;

  /// No description provided for @a11yIconMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get a11yIconMedication;

  /// No description provided for @a11yIconHealing.
  ///
  /// In en, this message translates to:
  /// **'First aid'**
  String get a11yIconHealing;

  /// No description provided for @a11yIconFitnessCenter.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get a11yIconFitnessCenter;

  /// No description provided for @a11yIconSpa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get a11yIconSpa;

  /// No description provided for @a11yIconSelfImprovement.
  ///
  /// In en, this message translates to:
  /// **'Self improvement'**
  String get a11yIconSelfImprovement;

  /// No description provided for @a11yIconPsychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get a11yIconPsychology;

  /// No description provided for @a11yIconLocalPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get a11yIconLocalPharmacy;

  /// No description provided for @a11yIconVaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get a11yIconVaccines;

  /// No description provided for @a11yIconHealthAndSafety.
  ///
  /// In en, this message translates to:
  /// **'Health and safety'**
  String get a11yIconHealthAndSafety;

  /// No description provided for @a11yIconAccessibilityNew.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get a11yIconAccessibilityNew;

  /// No description provided for @a11yIconSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get a11yIconSchool;

  /// No description provided for @a11yIconMenuBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get a11yIconMenuBook;

  /// No description provided for @a11yIconAutoStories.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get a11yIconAutoStories;

  /// No description provided for @a11yIconScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get a11yIconScience;

  /// No description provided for @a11yIconCalculate.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get a11yIconCalculate;

  /// No description provided for @a11yIconLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get a11yIconLaptop;

  /// No description provided for @a11yIconWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get a11yIconWork;

  /// No description provided for @a11yIconBusinessCenter.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get a11yIconBusinessCenter;

  /// No description provided for @a11yIconCorporateFare.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get a11yIconCorporateFare;

  /// No description provided for @a11yIconBadge.
  ///
  /// In en, this message translates to:
  /// **'Employment badge'**
  String get a11yIconBadge;

  /// No description provided for @a11yIconEngineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get a11yIconEngineering;

  /// No description provided for @a11yIconComputer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get a11yIconComputer;

  /// No description provided for @a11yIconMovie.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get a11yIconMovie;

  /// No description provided for @a11yIconTv.
  ///
  /// In en, this message translates to:
  /// **'Television'**
  String get a11yIconTv;

  /// No description provided for @a11yIconMusicNote.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get a11yIconMusicNote;

  /// No description provided for @a11yIconHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get a11yIconHeadphones;

  /// No description provided for @a11yIconSportsEsports.
  ///
  /// In en, this message translates to:
  /// **'Video games'**
  String get a11yIconSportsEsports;

  /// No description provided for @a11yIconSportsSoccer.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get a11yIconSportsSoccer;

  /// No description provided for @a11yIconSportsBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get a11yIconSportsBasketball;

  /// No description provided for @a11yIconSportsTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get a11yIconSportsTennis;

  /// No description provided for @a11yIconHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get a11yIconHiking;

  /// No description provided for @a11yIconTerrain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get a11yIconTerrain;

  /// No description provided for @a11yIconBeachAccess.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get a11yIconBeachAccess;

  /// No description provided for @a11yIconPark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get a11yIconPark;

  /// No description provided for @a11yIconTheaterComedy.
  ///
  /// In en, this message translates to:
  /// **'Theatre'**
  String get a11yIconTheaterComedy;

  /// No description provided for @a11yIconCasino.
  ///
  /// In en, this message translates to:
  /// **'Casino'**
  String get a11yIconCasino;

  /// No description provided for @a11yIconSportsBar.
  ///
  /// In en, this message translates to:
  /// **'Sports bar'**
  String get a11yIconSportsBar;

  /// No description provided for @a11yIconAttractions.
  ///
  /// In en, this message translates to:
  /// **'Amusement park'**
  String get a11yIconAttractions;

  /// No description provided for @a11yIconBolt.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get a11yIconBolt;

  /// No description provided for @a11yIconWaterDrop.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get a11yIconWaterDrop;

  /// No description provided for @a11yIconWifi.
  ///
  /// In en, this message translates to:
  /// **'Internet wifi'**
  String get a11yIconWifi;

  /// No description provided for @a11yIconPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get a11yIconPhone;

  /// No description provided for @a11yIconSmartphone.
  ///
  /// In en, this message translates to:
  /// **'Mobile phone'**
  String get a11yIconSmartphone;

  /// No description provided for @a11yIconTvOutlined.
  ///
  /// In en, this message translates to:
  /// **'Streaming subscription'**
  String get a11yIconTvOutlined;

  /// No description provided for @a11yIconRecycling.
  ///
  /// In en, this message translates to:
  /// **'Recycling'**
  String get a11yIconRecycling;

  /// No description provided for @a11yIconLocalLaundryService.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get a11yIconLocalLaundryService;

  /// No description provided for @a11yIconCleaningServices.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get a11yIconCleaningServices;

  /// No description provided for @a11yIconHandyman.
  ///
  /// In en, this message translates to:
  /// **'Handyman'**
  String get a11yIconHandyman;

  /// No description provided for @a11yIconBuild.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get a11yIconBuild;

  /// No description provided for @a11yIconConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get a11yIconConstruction;

  /// No description provided for @a11yIconChildCare.
  ///
  /// In en, this message translates to:
  /// **'Childcare'**
  String get a11yIconChildCare;

  /// No description provided for @a11yIconPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get a11yIconPets;

  /// No description provided for @a11yIconStyle.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get a11yIconStyle;

  /// No description provided for @a11yIconFace.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get a11yIconFace;

  /// No description provided for @a11yIconVolunteerActivism.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get a11yIconVolunteerActivism;

  /// No description provided for @a11yIconChurch.
  ///
  /// In en, this message translates to:
  /// **'Place of worship'**
  String get a11yIconChurch;

  /// No description provided for @a11yIconCelebration.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get a11yIconCelebration;

  /// No description provided for @a11yIconCake.
  ///
  /// In en, this message translates to:
  /// **'Birthday cake'**
  String get a11yIconCake;

  /// No description provided for @a11yIconCardGiftcard.
  ///
  /// In en, this message translates to:
  /// **'Gift card'**
  String get a11yIconCardGiftcard;

  /// No description provided for @a11yIconCategory.
  ///
  /// In en, this message translates to:
  /// **'General category'**
  String get a11yIconCategory;

  /// No description provided for @a11yIconMoreHoriz.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get a11yIconMoreHoriz;

  /// No description provided for @a11yIconStar.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get a11yIconStar;

  /// No description provided for @a11yIconFlag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get a11yIconFlag;

  /// No description provided for @a11yIconBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get a11yIconBookmark;

  /// No description provided for @a11yIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get a11yIconLabel;

  /// No description provided for @a11yIconTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get a11yIconTag;

  /// No description provided for @a11yIconFlightTakeoff.
  ///
  /// In en, this message translates to:
  /// **'Departure flight'**
  String get a11yIconFlightTakeoff;

  /// No description provided for @a11yIconFlightLand.
  ///
  /// In en, this message translates to:
  /// **'Arrival flight'**
  String get a11yIconFlightLand;

  /// No description provided for @a11yIconCommute.
  ///
  /// In en, this message translates to:
  /// **'Commute'**
  String get a11yIconCommute;

  /// No description provided for @a11yIconSubway.
  ///
  /// In en, this message translates to:
  /// **'Subway train'**
  String get a11yIconSubway;

  /// No description provided for @a11yIconElectricCar.
  ///
  /// In en, this message translates to:
  /// **'Electric car'**
  String get a11yIconElectricCar;

  /// No description provided for @a11yIconMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get a11yIconMotorcycle;

  /// No description provided for @a11yIconMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get a11yIconMap;

  /// No description provided for @a11yIconExplore.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get a11yIconExplore;

  /// No description provided for @a11yIconNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get a11yIconNavigation;

  /// No description provided for @a11yIconCardMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership card'**
  String get a11yIconCardMembership;

  /// No description provided for @a11yIconStore.
  ///
  /// In en, this message translates to:
  /// **'Department store'**
  String get a11yIconStore;

  /// No description provided for @a11yIconLocalOffer.
  ///
  /// In en, this message translates to:
  /// **'Special offer'**
  String get a11yIconLocalOffer;

  /// No description provided for @a11yIconPower.
  ///
  /// In en, this message translates to:
  /// **'Power plug'**
  String get a11yIconPower;

  /// No description provided for @a11yIconElectricBolt.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get a11yIconElectricBolt;

  /// No description provided for @a11yIconRouter.
  ///
  /// In en, this message translates to:
  /// **'Router'**
  String get a11yIconRouter;

  /// No description provided for @a11yIconDevices.
  ///
  /// In en, this message translates to:
  /// **'Electronic devices'**
  String get a11yIconDevices;

  /// No description provided for @a11yIconCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage'**
  String get a11yIconCloud;

  /// No description provided for @a11yIconSolarPower.
  ///
  /// In en, this message translates to:
  /// **'Solar power'**
  String get a11yIconSolarPower;

  /// No description provided for @a11yIconLocalBar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get a11yIconLocalBar;

  /// No description provided for @a11yIconLiquor.
  ///
  /// In en, this message translates to:
  /// **'Liquor'**
  String get a11yIconLiquor;

  /// No description provided for @a11yIconRamenDining.
  ///
  /// In en, this message translates to:
  /// **'Noodles'**
  String get a11yIconRamenDining;

  /// No description provided for @a11yIconTakeoutDining.
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get a11yIconTakeoutDining;

  /// No description provided for @a11yIconWineBar.
  ///
  /// In en, this message translates to:
  /// **'Wine bar'**
  String get a11yIconWineBar;

  /// No description provided for @a11yIconCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get a11yIconCoffee;

  /// No description provided for @a11yIconSoupKitchen.
  ///
  /// In en, this message translates to:
  /// **'Soup kitchen'**
  String get a11yIconSoupKitchen;

  /// No description provided for @a11yIconCameraAlt.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get a11yIconCameraAlt;

  /// No description provided for @a11yIconPalette.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get a11yIconPalette;

  /// No description provided for @a11yIconStadium.
  ///
  /// In en, this message translates to:
  /// **'Stadium'**
  String get a11yIconStadium;

  /// No description provided for @a11yIconMusicVideo.
  ///
  /// In en, this message translates to:
  /// **'Music video'**
  String get a11yIconMusicVideo;

  /// No description provided for @a11yIconSportsMotorsports.
  ///
  /// In en, this message translates to:
  /// **'Motorsports'**
  String get a11yIconSportsMotorsports;

  /// No description provided for @a11yIconSportsGolf.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get a11yIconSportsGolf;

  /// No description provided for @a11yIconSportsBaseball.
  ///
  /// In en, this message translates to:
  /// **'Baseball'**
  String get a11yIconSportsBaseball;

  /// No description provided for @a11yIconSportsFootball.
  ///
  /// In en, this message translates to:
  /// **'American football'**
  String get a11yIconSportsFootball;

  /// No description provided for @a11yIconPool.
  ///
  /// In en, this message translates to:
  /// **'Swimming pool'**
  String get a11yIconPool;

  /// No description provided for @a11yIconFamilyRestroom.
  ///
  /// In en, this message translates to:
  /// **'Family care'**
  String get a11yIconFamilyRestroom;

  /// No description provided for @a11yIconContentCut.
  ///
  /// In en, this message translates to:
  /// **'Hairdresser'**
  String get a11yIconContentCut;

  /// No description provided for @a11yIconDryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Dry cleaning'**
  String get a11yIconDryCleaning;

  /// No description provided for @a11yIconSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get a11yIconSecurity;

  /// No description provided for @a11yIconShield.
  ///
  /// In en, this message translates to:
  /// **'Insurance shield'**
  String get a11yIconShield;

  /// No description provided for @a11yIconWorkspacePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription'**
  String get a11yIconWorkspacePremium;

  /// No description provided for @a11yIconPestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest control'**
  String get a11yIconPestControl;

  /// No description provided for @a11yIconRoofing.
  ///
  /// In en, this message translates to:
  /// **'Roofing repair'**
  String get a11yIconRoofing;

  /// No description provided for @a11yIconDeck.
  ///
  /// In en, this message translates to:
  /// **'Terrace'**
  String get a11yIconDeck;

  /// No description provided for @a11yIconSchoolOutlined.
  ///
  /// In en, this message translates to:
  /// **'Higher education'**
  String get a11yIconSchoolOutlined;

  /// No description provided for @a11yIconEvent.
  ///
  /// In en, this message translates to:
  /// **'Calendar event'**
  String get a11yIconEvent;

  /// No description provided for @a11yIconAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get a11yIconAlarm;

  /// No description provided for @a11yIconWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get a11yIconWatch;

  /// No description provided for @a11yIconInterests.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get a11yIconInterests;

  /// No description provided for @a11yIconNewspaper.
  ///
  /// In en, this message translates to:
  /// **'Newspaper press'**
  String get a11yIconNewspaper;

  /// No description provided for @a11yIconPrint.
  ///
  /// In en, this message translates to:
  /// **'Printing'**
  String get a11yIconPrint;

  /// No description provided for @a11yEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String a11yEditItem(String name);

  /// No description provided for @a11yDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String a11yDeleteItem(String name);

  /// No description provided for @a11yEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String a11yEditName(String name);

  /// No description provided for @a11yDeleteName.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String a11yDeleteName(String name);

  /// No description provided for @a11ySelectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get a11ySelectYear;

  /// No description provided for @a11ySelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get a11ySelectMonth;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get selectYear;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @a11yProgressBar.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percentage} percent'**
  String a11yProgressBar(String percentage);

  /// No description provided for @a11yProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percentage} percent'**
  String a11yProgress(String percentage);

  /// No description provided for @a11yProgressPercentage.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percentage} percent'**
  String a11yProgressPercentage(String percentage);

  /// No description provided for @a11yShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// No description provided for @a11yHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// No description provided for @a11ySelectedHint.
  ///
  /// In en, this message translates to:
  /// **'Currently selected'**
  String get a11ySelectedHint;

  /// No description provided for @a11yTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Double tap to select'**
  String get a11yTapToSelect;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @a11yPinLockoutRemaining.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining until unlock'**
  String a11yPinLockoutRemaining(int seconds);

  /// No description provided for @a11yRecycleBinUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent: '**
  String get a11yRecycleBinUrgent;

  /// No description provided for @a11yLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get a11yLoading;
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
