// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get dashboard => 'Tauler de control';

  @override
  String get transactions => 'Transaccions';

  @override
  String get budgets => 'Pressupostos';

  @override
  String get settings => 'Ajustos';

  @override
  String get addTransaction => 'Afegir transacció';

  @override
  String get income => 'Ingressos';

  @override
  String get expense => 'Despesa';

  @override
  String get expenses => 'Despeses';

  @override
  String get errorGeneric =>
      'Alguna cosa ha anat malament. Si us plau, torneu-ho a provar.';

  @override
  String get errorDatabase =>
      'S\'ha produït un error a la base de dades. Si us plau, contacteu amb el suport.';

  @override
  String get errorAuth =>
      'L\'autenticació ha fallat. Si us plau, verifiqueu les vostres credencials.';

  @override
  String get errorNetwork =>
      'Error de xarxa. Si us plau, comproveu la vostra connexió a internet.';

  @override
  String get appTitle => 'Stalvi';

  @override
  String get splashTagline => 'Les teves finances, a la teva manera.';

  @override
  String get splashStartupFailed => 'Error d\'Inici';

  @override
  String get splashSecureStorageError =>
      'Stalvi no ha pogut inicialitzar el seu emmagatzematge segur. Si us plau, comproveu l\'espai disponible al dispositiu i torneu-ho a provar.';

  @override
  String get tryAgain => 'Torna-ho a provar';

  @override
  String get authCheckingBiometrics => 'Comprovant biometria…';

  @override
  String get authError => 'Error d\'autenticació';

  @override
  String get authLockedTitle => 'Biometria bloqueada';

  @override
  String get authLockedMessage =>
      'Masses intents fallits. Si us plau, desbloquegeu el dispositiu des de la pantalla de bloqueig i torneu-ho a provar.';

  @override
  String get authLockoutActive => 'Bloqueig de seguretat actiu';

  @override
  String get authVerifyIdentity => 'Verifiqueu la vostra identitat';

  @override
  String get authVerifyMessage =>
      'Utilitzeu la biometria o el PIN del dispositiu per accedir a les vostres dades financeres de forma segura.';

  @override
  String get authVerifying => 'Verificant…';

  @override
  String get authAuthenticate => 'Autenticar';

  @override
  String get authSkip => 'Omet de moment';

  @override
  String get authProtectedBy => 'Protegit per la biometria del dispositiu';

  @override
  String get unexpectedError =>
      'S\'ha produït un error inesperat. Si us plau, torneu-ho a provar.';

  @override
  String get overview => 'Resum';

  @override
  String get accounts => 'Comptes';

  @override
  String get recentTransactions => 'Transaccions recents';

  @override
  String get noTransactionsTitle => 'Encara no hi ha transaccions';

  @override
  String get noTransactionsSubtitle =>
      'Afegiu el vostre primer ingrés o despesa per veure\'l aquí i començar el seguiment.';

  @override
  String get failedLoadTransactions => 'Error en carregar les transaccions';

  @override
  String get settingsBudgetsGoals => 'Pressupostos i Objectius';

  @override
  String get settingsStatistics => 'Estadístiques';

  @override
  String get balanceTotal => 'Balanç total';

  @override
  String get statisticsTooltipCustomRange => 'Rang de dates personalitzat';

  @override
  String get statisticsTopSpending => 'Categories de més despesa';

  @override
  String get statisticsWhereMoneyGoes => 'On van els vostres diners';

  @override
  String get statisticsNoExpenses =>
      'No s\'han registrat despeses en aquest període.';

  @override
  String get statisticsTopIncome => 'Categories de més ingressos';

  @override
  String get statisticsWhatYouEarned => 'El que heu guanyat';

  @override
  String get statisticsNoIncome =>
      'No s\'han registrat ingressos en aquest període.';

  @override
  String get statisticsNetBalance => 'Balanç net';

  @override
  String get statisticsSurplus => 'Superàvit';

  @override
  String get statisticsDeficit => 'Dèficit';

  @override
  String get presetThisMonth => 'Aquest mes';

  @override
  String get presetLast3Months => 'Últims 3 mesos';

  @override
  String get presetLast6Months => 'Últims 6 mesos';

  @override
  String get presetThisYear => 'Aquest any';

  @override
  String get presetCustom => 'Personalitzat';

  @override
  String get budgetsAndGoals => 'Pressupostos i Objectius';

  @override
  String get savingsGoals => 'Objectius d\'estalvi';

  @override
  String get failedLoadBudgets => 'Error en carregar els pressupostos.';

  @override
  String get noBudgetsTitle => 'Encara no s\'han definit pressupostos';

  @override
  String get noBudgetsSubtitle =>
      'Establiu límits de despesa per a les categories per fer un seguiment de les vostres despeses mensuals i mantenir-vos dins dels vostres límits.';

  @override
  String get uncategorized => 'Sense categoria';

  @override
  String budgetOverspent(String amount) {
    return '$amount sobrepassat';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount restant';
  }

  @override
  String get failedLoadSavingsGoals =>
      'Error en carregar els objectius d\'estalvi.';

  @override
  String get noSavingsGoalsTitle => 'Encara no hi ha objectius d\'estalvi';

  @override
  String get noSavingsGoalsSubtitle =>
      'Creeu un objectiu d\'estalvi per planificar els vostres somnis futurs, viatges o grans compres.';

  @override
  String savingsTargetDate(String date) {
    return 'Data objectiu: $date';
  }

  @override
  String get savingsNoTargetDate => 'Sense data objectiu';

  @override
  String savingsSavedOf(String saved, String target) {
    return '$saved estalviats de $target';
  }

  @override
  String get savingsGoalAchieved => 'Objectiu aconseguit!';

  @override
  String get txnSuccessCreated => 'Transacció creada amb èxit!';

  @override
  String get labelAmount => 'QUANTITAT';

  @override
  String get labelAccount => 'Compte';

  @override
  String get labelSelectAccount => 'Seleccionar compte';

  @override
  String get labelCategory => 'Categoria';

  @override
  String get labelSelectCategory => 'Seleccionar categoria';

  @override
  String get labelDate => 'Data';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelNotesHint => 'Afegiu detalls sobre aquesta transacció...';

  @override
  String get btnSaveTransaction => 'Desar transacció';

  @override
  String get errorInvalidAmount =>
      'Si us plau, introduïu una quantitat vàlida superior a 0';

  @override
  String get errorAccountRequired => 'Si us plau, seleccioneu un compte';

  @override
  String get errorFutureDate =>
      'La data de la transacció no pot ser en el futur';

  @override
  String get errorAccountNotFound => 'Compte no trobat';

  @override
  String get errorProfileNotFound => 'Perfil no trobat';

  @override
  String get errorRateNotFound =>
      'Tipus de canvi no disponible per a la moneda sol·licitada';

  @override
  String get errorConversionFailed => 'Error en convertir la moneda';

  @override
  String get getStarted => 'Començar';

  @override
  String get authSetupTitle => 'Crear el teu perfil';

  @override
  String get authSetupSubtitle =>
      'Configura la teva cartera segura fora de línia per començar.';

  @override
  String get authSetupNameLabel => 'Nom';

  @override
  String get authSetupUsernameLabel => 'Nom d\'usuari';

  @override
  String get authSetupPinLabel => 'Establir un PIN de 4 a 8 dígits';

  @override
  String get authSetupConfirmPinLabel => 'Confirmar PIN';

  @override
  String get authSetupLanguageLabel => 'Idioma predeterminat';

  @override
  String get authSetupTermsCheckbox =>
      'Accepto els Termes i Condicions i la Política de Privacitat';

  @override
  String get authSetupCreateButton => 'Crear perfil';

  @override
  String get authSetupValidationErrorPinLength =>
      'El PIN ha de tenir entre 4 i 8 dígits.';

  @override
  String get authSetupValidationErrorPinMatch => 'Els PIN no coincideixen.';

  @override
  String get authSetupValidationErrorTerms =>
      'Heu d\'acceptar els Termes i Condicions i la Política de Privacitat per continuar.';

  @override
  String get authSetupValidationErrorName => 'Si us plau, introduïu un nom.';

  @override
  String get authSetupValidationErrorUsername =>
      'Si us plau, introduïu un nom d\'usuari.';

  @override
  String get authPinEnter => 'Introduir PIN';

  @override
  String authPinAttemptsRemaining(int attempts) {
    return 'Queden $attempts intents';
  }

  @override
  String get authPinIncorrect => 'PIN incorrecte. Torneu-ho a provar.';

  @override
  String get defaultWalletName => 'La meva cartera';

  @override
  String get defaultWallet => 'Moneder Principal';

  @override
  String acrossAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes',
      one: '1 compte',
    );
    return '$_temp0';
  }

  @override
  String get failedLoadAccounts => 'No s\'han pogut carregar els comptes.';

  @override
  String get noAccountsTitle => 'Encara no hi ha comptes';

  @override
  String get noAccountsSubtitle =>
      'Crea un compte o moneder per començar a gestionar els teus actius i registrar transaccions.';

  @override
  String get defaultAccountLabel => 'Predeterminat';

  @override
  String get statisticsNoDataSubtitle =>
      'Intenta afegir transaccions o canviar el rang del filtre per veure el teu desglossament de categories.';

  @override
  String get authBiometricOptInTitle => 'Habilitar accés biomètric';

  @override
  String get authBiometricOptInSubtitle =>
      'Utilitza la teva petjada dactilar o reconeixement facial per accedir a Stalvi de forma ràpida i segura en el futur.';

  @override
  String get authBiometricOptInEnable => 'Habilitar biometria';

  @override
  String get authBiometricOptInSkip => 'Omet de moment';

  @override
  String get noDataAvailable => 'Encara no hi ha dades disponibles';

  @override
  String get termsAndConditions => 'Termes i condicions';

  @override
  String get privacyPolicy => 'Política de privadesa';

  @override
  String get myWallet => 'La meva cartera';

  @override
  String get authSetupCurrencyLabel => 'Divisa predeterminada';

  @override
  String get authSetupAcceptPrefix => 'Accepto els ';

  @override
  String get authSetupAcceptAnd => ' i la ';

  @override
  String get settingsThemeMode => 'Mode de tema';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Clar';

  @override
  String get themeModeDark => 'Fosc';

  @override
  String get profileSettingsTitle => 'Perfil i Seguretat';

  @override
  String get changePinButton => 'Canviar PIN';

  @override
  String get deleteAllDataButton => 'Esborrar totes les dades';

  @override
  String get oldPinLabel => 'PIN antic';

  @override
  String get newPinLabel => 'Nou PIN';

  @override
  String get confirmPinLabel => 'Confirmar nou PIN';

  @override
  String get incorrectOldPin => 'PIN antic incorrecte.';

  @override
  String get pinsDoNotMatch => 'Els PINs no coincideixen.';

  @override
  String get pinUpdatedSuccessfully => 'PIN actualitzat correctament.';

  @override
  String get deleteAllDataWarning =>
      'Estàs segur que vols esborrar totes les dades? Això no es pot desfer.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get usernameLabel => 'Nom d\'usuari';

  @override
  String get btnCancel => 'Cancel·lar';

  @override
  String get btnSave => 'Desar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnNext => 'Següent';

  @override
  String get recycleBinTitle => 'Paperera de reciclatge';

  @override
  String get recycleBinEmpty => 'La paperera de reciclatge és buida.';

  @override
  String get recycleBinRestoreTooltip => 'Restaurar';

  @override
  String get recycleBinDeleteTooltip => 'Eliminar permanentment';

  @override
  String get recycleBinDeleteConfirmTitle => 'Eliminació permanent';

  @override
  String get recycleBinDeleteConfirmMessage =>
      'Segur que voleu eliminar permanentment aquest element? Aquesta acció no es pot desfer.';

  @override
  String get recycleBinRestoredMessage => 'Element restaurat';

  @override
  String get recycleBinDeletedMessage => 'Element eliminat permanentment';

  @override
  String recycleBinDaysRemaining(int days) {
    return 'Expira en $days dies';
  }

  @override
  String get optional => 'Opcional';

  @override
  String get errorCategoryRequired => 'Si us plau, seleccioneu una categoria';

  @override
  String get errorCurrencyRequired => 'Si us plau, seleccioneu una moneda';

  @override
  String get labelCurrency => 'Moneda';

  @override
  String get labelSelectCurrency => 'Seleccionar moneda';

  @override
  String get labelTag => 'Etiqueta';

  @override
  String get labelSelectTag => 'Seleccionar etiqueta';

  @override
  String get noTag => 'Cap';

  @override
  String get optionalPlaceholder => '(Opcional)';

  @override
  String get fallbackIncome => 'Ingrés';

  @override
  String get fallbackExpense => 'Despesa';

  @override
  String get errorMaxPinAttempts =>
      'S\'ha assolit el nombre màxim d\'intents de PIN. Si us plau, torneu-ho a provar més tard.';

  @override
  String get errorPinNotNumeric =>
      'El PIN ha de contenir només dígits numèrics.';

  @override
  String get errorNoPinSet => 'No hi ha cap PIN configurat actualment.';

  @override
  String get authPinLockedTitle => 'Masses intents fallits';

  @override
  String get authPinLockedMessage =>
      'L\'accés ha estat bloquejat temporalment després de masses entrades incorrectes del PIN.';

  @override
  String get authPinLockedCountdown => 'segons restants';

  @override
  String get authPinLockedRetry => 'Ara podeu tornar-ho a provar';

  @override
  String get authSignInTitle => 'Verificar identitat';

  @override
  String get defaultAccountName => 'Compte principal';

  @override
  String get filterAll => 'Tots';

  @override
  String get filterIncome => 'Ingressos';

  @override
  String get filterExpense => 'Despeses';

  @override
  String get filterTransfer => 'Transferència';

  @override
  String get createAccountTitle => 'Crear nou compte';

  @override
  String get createAccountNameLabel => 'Nom del compte';

  @override
  String get createAccountNameHint => 'ex. Targeta Personal, Efectiu, etc.';

  @override
  String get createAccountInitialBalanceLabel => 'Saldo';

  @override
  String get createAccountTypeLabel => 'Tipus de compte';

  @override
  String get createAccountColorThemeLabel => 'Tema de color';

  @override
  String get createAccountIconLabel => 'Icona';

  @override
  String get createAccountSuccess => 'Compte creat amb èxit';

  @override
  String get createAccountErrorName =>
      'Si us plau, introdueix un nom per al compte';

  @override
  String get createAccountErrorFailed => 'Error al crear el compte';

  @override
  String get accountTypeOther => 'Altre';

  @override
  String get accountTypeCash => 'Efectiu';

  @override
  String get accountTypeBank => 'Banc';

  @override
  String get accountTypeSavings => 'Estalvis';

  @override
  String get accountTypeCard => 'Targeta';

  @override
  String get deleteTransactionTitle => 'Eliminar transacció?';

  @override
  String get transactionMovedToRecycleBin => 'Transacció moguda a la paperera';

  @override
  String get errorDeleteTransaction => 'Error al eliminar la transacció';

  @override
  String get deleteTransactionConfirmation =>
      'Estàs segur que vols eliminar aquesta transacció? Es mourà a la paperera de reciclatge.';

  @override
  String get btnClose => 'Tancar';

  @override
  String get setAsDefaultAccount => 'Establir com a compte predeterminat';

  @override
  String get setAsDefaultAccountSuccess =>
      'Compte establert com a predeterminat';

  @override
  String get setAsDefaultAccountError =>
      'Error en establir el compte predeterminat';

  @override
  String get filterSheetTitle => 'Filtrar transaccions';

  @override
  String get filterSheetApply => 'Aplicar filtres';

  @override
  String get filterSheetClearAll => 'Netejar tot';

  @override
  String get filterSheetType => 'Tipus de transacció';

  @override
  String get filterSheetCategory => 'Categoria';

  @override
  String get filterSheetDateRange => 'Rang de dates';

  @override
  String get filterSheetAmountRange => 'Rang d\'imports';

  @override
  String get filterSheetMinAmount => 'Import mínim';

  @override
  String get filterSheetMaxAmount => 'Import màxim';

  @override
  String get filterSheetTag => 'Etiqueta';

  @override
  String get filterSheetCurrency => 'Moneda';

  @override
  String get filterSheetAllTypes => 'Tots els tipus';

  @override
  String get filterSheetAllCategories => 'Totes les categories';

  @override
  String get filterSheetAllTags => 'Totes les etiquetes';

  @override
  String get filterSheetAllCurrencies => 'Totes les monedes';

  @override
  String get filterSheetSelectDateRange => 'Seleccionar rang de dates';

  @override
  String filterSheetActiveFilters(int count) {
    return '$count filtres actius';
  }

  @override
  String get filterSheetTransferType => 'Transferència';
}
