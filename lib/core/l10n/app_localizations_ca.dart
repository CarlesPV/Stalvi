// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Stalvi';

  @override
  String get btnCancel => 'Cancel·lar';

  @override
  String get btnClose => 'Tancar';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnNext => 'Següent';

  @override
  String get btnOpen => 'Obrir';

  @override
  String get btnReassignAndDelete => 'Reassignar i eliminar';

  @override
  String get btnRestore => 'Restaurar';

  @override
  String get btnSave => 'Desar';

  @override
  String get btnViewDetails => 'Veure detalls';

  @override
  String get categories => 'Categories';

  @override
  String get currencyAUD => 'Dòlar Australià (AUD)';

  @override
  String get currencyCAD => 'Dòlar Canadenc (CAD)';

  @override
  String get currencyCHF => 'Franc Suís (CHF)';

  @override
  String get currencyCNY => 'Iuan Xinès (CNY)';

  @override
  String get currencyEUR => 'Euro (EUR)';

  @override
  String get currencyGBP => 'Lliura Esterlina (GBP)';

  @override
  String get currencyJPY => 'Ien Japonès (JPY)';

  @override
  String get currencyUSD => 'Dòlar dels Estats Units (USD)';

  @override
  String get deleteAllDataButton => 'Esborrar totes les dades';

  @override
  String get deleteAllDataWarning =>
      'Estàs segur que vols esborrar totes les dades? Això no es pot desfer.';

  @override
  String get endDate => 'Data de Fi';

  @override
  String get getStarted => 'Començar';

  @override
  String get labelAmount => 'QUANTITAT';

  @override
  String get labelCurrency => 'Moneda';

  @override
  String get labelDate => 'Data';

  @override
  String get labelIcon => 'Icona';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelNotesHint => 'Afegiu detalls sobre aquesta transacció...';

  @override
  String get labelSelectCurrency => 'Seleccionar moneda';

  @override
  String get noCategories => 'Encara no hi ha categories';

  @override
  String get noDataAvailable => 'Encara no hi ha dades disponibles';

  @override
  String get optionalPlaceholder => '(Opcional)';

  @override
  String get privacyPolicy => 'Política de privadesa';

  @override
  String get recurrenceUtcWarning => 'L\'hora de referència és UTC+2';

  @override
  String get setAsDefault => 'Establir com a predeterminat';

  @override
  String get startDate => 'Data d\'Inici';

  @override
  String get targetAmount => 'Quantitat Objectiu';

  @override
  String get targetDate => 'Data Objectiu';

  @override
  String get termsAndConditions => 'Termes i condicions';

  @override
  String get tryAgain => 'Torna-ho a provar';

  @override
  String get txnSuccessCreated => 'Transacció creada amb èxit!';

  @override
  String get uncategorized => 'Sense categoria';

  @override
  String get usernameLabel => 'Nom d\'usuari';

  @override
  String get warning => 'Advertiment';

  @override
  String get authBiometricOptInEnable => 'Habilitar biometria';

  @override
  String get authBiometricOptInSkip => 'Omet de moment';

  @override
  String get authBiometricOptInSubtitle =>
      'Utilitza la teva petjada dactilar o reconeixement facial per accedir a Stalvi de forma ràpida i segura en el futur.';

  @override
  String get authBiometricOptInTitle => 'Habilitar accés biomètric';

  @override
  String get authLockedMessage =>
      'Masses intents fallits. Si us plau, desbloquegeu el dispositiu des de la pantalla de bloqueig i torneu-ho a provar.';

  @override
  String get authLockedTitle => 'Biometria bloqueada';

  @override
  String get authLockoutActive => 'Bloqueig de seguretat actiu';

  @override
  String authPinAttemptsRemaining(Object attempts) {
    return 'Queden $attempts intents';
  }

  @override
  String get authPinEnter => 'Introduir PIN';

  @override
  String get authPinLockedCountdown => 'segons restants';

  @override
  String get authPinLockedMessage =>
      'L\'accés ha estat bloquejat temporalment després de masses entrades incorrectes del PIN.';

  @override
  String get authPinLockedRetry => 'Ara podeu tornar-ho a provar';

  @override
  String get authPinLockedTitle => 'Masses intents fallits';

  @override
  String get authProcessing => 'Processant l\'autenticació de seguretat…';

  @override
  String get authProtectedBy => 'Protegit per la biometria del dispositiu';

  @override
  String get authSetupAcceptAnd => ' i la ';

  @override
  String get authSetupAcceptPrefix => 'Accepto els ';

  @override
  String get authSetupConfirmPinLabel => 'Confirmar PIN';

  @override
  String get authSetupCreateButton => 'Crear perfil';

  @override
  String get authSetupCurrencyLabel => 'Divisa predeterminada';

  @override
  String get authSetupLanguageLabel => 'Idioma predeterminat';

  @override
  String get authSetupNameLabel => 'Nom';

  @override
  String get authSetupPinLabel => 'Establir un PIN de 4 a 8 dígits';

  @override
  String get authSetupSubtitle =>
      'Configura la teva cartera segura fora de línia per començar.';

  @override
  String get authSetupTitle => 'Crear el teu perfil';

  @override
  String get authSetupUsernameLabel => 'Nom d\'usuari';

  @override
  String get authSignInTitle => 'Verificar identitat';

  @override
  String get authVerifyMessage =>
      'Utilitzeu la biometria o el PIN del dispositiu per continuar';

  @override
  String get changePinButton => 'Canviar PIN';

  @override
  String get confirmPinLabel => 'Confirmar nou PIN';

  @override
  String get newPinLabel => 'Nou PIN';

  @override
  String get oldPinLabel => 'PIN antic';

  @override
  String get pinUpdatedSuccessfully => 'PIN actualitzat correctament.';

  @override
  String get pinsDoNotMatch => 'Els PINs no coincideixen.';

  @override
  String get statisticsTopIncome => 'Categories de més ingressos';

  @override
  String get balanceTotal => 'Balanç total';

  @override
  String get overview => 'Resum';

  @override
  String get accountInUseByAutoTxMessage =>
      'Aquest compte no es pot eliminar perquè està vinculat a transaccions automàtiques actives.';

  @override
  String get accountTypeBank => 'Banc';

  @override
  String get accountTypeCard => 'Targeta';

  @override
  String get accountTypeCash => 'Efectiu';

  @override
  String get accountTypeOther => 'Altre';

  @override
  String get accounts => 'Comptes';

  @override
  String acrossAccountsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes',
      one: '1 compte',
    );
    return '$_temp0';
  }

  @override
  String get addCategoryTitle => 'Afegir categoria';

  @override
  String get addTagTitle => 'Afegir etiqueta';

  @override
  String get addTransaction => 'Afegir transacció';

  @override
  String get autoTxEditTitle => 'Editar Transacció Automàtica';

  @override
  String autoTxFormatEveryDays(Object days) {
    return 'Cada $days dies';
  }

  @override
  String get autoTxFormatMonthly => 'Mensual';

  @override
  String autoTxFormatSpecificDay(Object day) {
    return 'El dia $day de cada mes';
  }

  @override
  String get autoTxFormatWeekly => 'Setmanal';

  @override
  String get autoTxFormatYearly => 'Anual';

  @override
  String get autoTxLabelRecurrence => 'Recurrència';

  @override
  String get autoTxNameRequired => 'El nom és obligatori';

  @override
  String get autoTxNewTitle => 'Nova Transacció Automàtica';

  @override
  String get autoTxRecurrenceApply => 'Aplicar';

  @override
  String get autoTxRecurrenceCustomHint => 'p.ex. 14';

  @override
  String get autoTxRecurrenceCustomInterval => 'Interval Personalitzat (Dies)';

  @override
  String get autoTxRecurrenceDayOfMonth => 'Dia X del mes';

  @override
  String get autoTxRecurrenceEveryXDays => 'Cada X dies';

  @override
  String get autoTxRecurrenceMonthly => 'Mensual (Cada 30 dies)';

  @override
  String get autoTxRecurrenceWeekly => 'Setmanal (Cada 7 dies)';

  @override
  String get autoTxRecurrenceYearly => 'Anual (Cada 365 dies)';

  @override
  String get autoTxSavedMessage => 'Transacció Automàtica Desada';

  @override
  String get autoTxSelectRecurrence => 'Seleccionar Recurrència';

  @override
  String get autoTxTemplateNameLabel => 'Nom';

  @override
  String get btnSaveTransaction => 'Desar transacció';

  @override
  String get categoriesAndTags => 'Categories i Etiquetes';

  @override
  String categoryInUseByAutoTxMessage(String name) {
    return '$name està en ús per transaccions automàtiques i s\'ha de reassignar.';
  }

  @override
  String categoryInUseMessage(Object name) {
    return '$name està en ús en transaccions existents. Si us plau, seleccioneu una categoria per reassignar-les:';
  }

  @override
  String get categoryInUseTitle => 'Categoria en ús';

  @override
  String get createAccountIconLabel => 'Icona';

  @override
  String get createAccountInitialBalanceLabel => 'Saldo Inicial';

  @override
  String get createAccountNameHint => 'ex. Targeta Personal, Efectiu, etc.';

  @override
  String get createAccountNameLabel => 'Nom del compte';

  @override
  String get createAccountTitle => 'Crear nou compte';

  @override
  String get createAccountTypeLabel => 'Tipus de compte';

  @override
  String get createAutomaticTransaction => 'Crear Transacció Automàtica';

  @override
  String get defaultAccountLabel => 'Predeterminat';

  @override
  String get defaultAccountName => 'Compte principal';

  @override
  String deleteCategoryConfirm(Object name) {
    return 'Segur que voleu eliminar $name?';
  }

  @override
  String get deleteCategoryTitle => 'Eliminar categoria?';

  @override
  String deleteTagConfirm(Object name) {
    return 'Segur que voleu eliminar $name?';
  }

  @override
  String get deleteTagTitle => 'Eliminar etiqueta?';

  @override
  String get deleteTransactionConfirmation =>
      'Estàs segur que vols eliminar aquesta transacció? Es mourà a la paperera de reciclatge.';

  @override
  String get deleteTransactionTitle => 'Eliminar transacció?';

  @override
  String get destination_account => 'Compte de destí';

  @override
  String get editCategoryTitle => 'Editar categoria';

  @override
  String get editTagTitle => 'Editar etiqueta';

  @override
  String expense(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Despeses',
      one: 'Despesa',
    );
    return '$_temp0';
  }

  @override
  String get expense_vs_income => 'Despeses vs Ingressos';

  @override
  String get expenses => 'Despeses';

  @override
  String get fallbackExpense => 'Despesa';

  @override
  String get fallbackIncome => 'Ingrés';

  @override
  String get filterAll => 'Tots';

  @override
  String get filterExpense => 'Despeses';

  @override
  String get filterIncome => 'Ingressos';

  @override
  String filterSheetActiveFilters(Object count) {
    return '$count filtres actius';
  }

  @override
  String get filterSheetAllCategories => 'Totes les categories';

  @override
  String get filterSheetAllCurrencies => 'Totes les monedes';

  @override
  String get filterSheetAllTags => 'Totes les etiquetes';

  @override
  String get filterSheetAllTypes => 'Tots els tipus';

  @override
  String get filterSheetAmountRange => 'Rang d\'imports';

  @override
  String get filterSheetApply => 'Aplicar filtres';

  @override
  String get filterSheetCategory => 'Categoria';

  @override
  String get filterSheetClearAll => 'Netejar tot';

  @override
  String get filterSheetCurrency => 'Moneda';

  @override
  String get filterSheetDateRange => 'Rang de dates';

  @override
  String get filterSheetMaxAmount => 'Import màxim';

  @override
  String get filterSheetMinAmount => 'Import mínim';

  @override
  String get filterSheetSelectDateRange => 'Seleccionar rang de dates';

  @override
  String get filterSheetTag => 'Etiqueta';

  @override
  String get filterSheetTitle => 'Filtrar transaccions';

  @override
  String get filterSheetTransferType => 'Transferència';

  @override
  String get filterSheetType => 'Tipus de transacció';

  @override
  String get filterTransfer => 'Transferència';

  @override
  String income(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ingressos',
      one: 'Ingrés',
    );
    return '$_temp0';
  }

  @override
  String get labelAccount => 'Compte';

  @override
  String get labelCategory => 'Categoria';

  @override
  String get labelCategoryName => 'Nom de la categoria';

  @override
  String get labelDestinationAccount => 'Compte de destinació';

  @override
  String get labelFromAccount => 'Des de compte';

  @override
  String get labelOriginAccount => 'Compte d\'origen';

  @override
  String get labelSelectAccount => 'Seleccionar compte';

  @override
  String get labelSelectCategory => 'Seleccionar categoria';

  @override
  String get labelSelectTag => 'Seleccionar etiqueta';

  @override
  String get labelTag => 'Etiqueta';

  @override
  String get labelTagName => 'Nom de l\'etiqueta';

  @override
  String get labelToAccount => 'A compte';

  @override
  String get noAccountsSubtitle =>
      'Crea un compte o moneder per començar a gestionar els teus actius i registrar transaccions.';

  @override
  String get noAccountsTitle => 'Encara no hi ha comptes';

  @override
  String get noTag => 'Cap';

  @override
  String get noTags => 'Encara no hi ha etiquetes';

  @override
  String get noTransactionsSubtitle =>
      'Afegiu el vostre primer ingrés o despesa per veure\'l aquí i començar el seguiment.';

  @override
  String get noTransactionsTitle => 'Encara no hi ha transaccions';

  @override
  String get recentTransactions => 'Transaccions recents';

  @override
  String get replaceDefaultAccountConfirm =>
      'El compte predeterminat anterior serà reemplaçat. Vols continuar?';

  @override
  String get selectDestinationAccount => 'Seleccionar compte de destí';

  @override
  String get selectSourceAccount => 'Seleccionar compte d\'origen';

  @override
  String get splashTagline => 'Les teves finances, a la teva manera.';

  @override
  String tagInUseMessage(Object name) {
    return '$name està en ús en transaccions existents. Si us plau, seleccioneu una etiqueta per reassignar-les:';
  }

  @override
  String get tagInUseTitle => 'Etiqueta en ús';

  @override
  String get tags => 'Etiquetes';

  @override
  String get transactions => 'Transaccions';

  @override
  String get unknownAccount => 'Compte desconegut';

  @override
  String get accountTypeSavings => 'Estalvis';

  @override
  String get addBudget => 'Afegir Pressupost';

  @override
  String get addSavingsGoal => 'Afegir Meta d\'Estalvi';

  @override
  String get budgetDetails => 'Detalls del Pressupost';

  @override
  String budgetOverspent(Object amount) {
    return '$amount sobrepassat';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount restant';
  }

  @override
  String budgetSpentOf(Object spent, Object target) {
    return '$spent de $target';
  }

  @override
  String get budgets => 'Pressupostos';

  @override
  String get budgetsAndGoals => 'Pressupostos i Objectius';

  @override
  String get deleteBudget => 'Eliminar Pressupost';

  @override
  String get deleteSavingsGoal => 'Eliminar Meta d\'Estalvi';

  @override
  String get goalName => 'Nom de la Meta';

  @override
  String get labelBudget => 'Pressupost';

  @override
  String get noBudgetsSubtitle =>
      'Establiu límits de despesa per a les categories per fer un seguiment de les vostres despeses mensuals i mantenir-vos dins dels vostres límits.';

  @override
  String get noBudgetsTitle => 'Encara no s\'han definit pressupostos';

  @override
  String get noSavingsGoalsSubtitle =>
      'Creeu un objectiu d\'estalvi per planificar els vostres somnis futurs, viatges o grans compres.';

  @override
  String get noSavingsGoalsTitle => 'Encara no hi ha objectius d\'estalvi';

  @override
  String get pdfBudgetsColCategory => 'Categoria';

  @override
  String get pdfBudgetsColDateRange => 'Rang de Dates';

  @override
  String get pdfBudgetsColMaxValue => 'Valor Màxim';

  @override
  String get pdfBudgetsColSpent => '% Gastat';

  @override
  String get pdfBudgetsTitle => 'Pressupostos';

  @override
  String get pdfSavingsColCompleted => '% Completat';

  @override
  String get pdfSavingsColName => 'Nom';

  @override
  String get pdfSavingsColTarget => 'Quantitat Objectiu';

  @override
  String get pdfSavingsGoalsTitle => 'Metes d\'Estalvi';

  @override
  String get savingsGoal => 'Objectiu d\'estalvi';

  @override
  String get savingsGoalAchieved => 'Objectiu aconseguit!';

  @override
  String get savingsGoalDetails => 'Detalls de la Meta d\'Estalvi';

  @override
  String get savingsGoals => 'Objectius d\'estalvi';

  @override
  String get savingsNoTargetDate => 'Sense data objectiu';

  @override
  String savingsSavedOf(Object saved, Object target) {
    return '$saved estalviats de $target';
  }

  @override
  String savingsTargetDate(Object date) {
    return 'Data objectiu: $date';
  }

  @override
  String get settingsBudgetsGoals => 'Pressupostos i Objectius';

  @override
  String get chart_scale => 'Escala del gràfic';

  @override
  String get presetCustom => 'Personalitzat';

  @override
  String get presetLast30Days => 'Últims 30 dies';

  @override
  String get presetLast3Months => 'Últims 3 mesos';

  @override
  String get presetLast6Months => 'Últims 6 mesos';

  @override
  String get presetThisMonth => 'Aquest mes';

  @override
  String get presetThisYear => 'Aquest any';

  @override
  String get settingsStatistics => 'Estadístiques';

  @override
  String get statisticsDeficit => 'Dèficit';

  @override
  String get statisticsNetBalance => 'Balanç net';

  @override
  String get statisticsNoDataSubtitle =>
      'Intenta afegir transaccions o canviar el rang del filtre per veure el teu desglossament de categories.';

  @override
  String get statisticsNoExpenses =>
      'No s\'han registrat despeses en aquest període.';

  @override
  String get statisticsNoIncome =>
      'No s\'han registrat ingressos en aquest període.';

  @override
  String statisticsOtherCategories(Object count) {
    return 'Altres ($count categories)';
  }

  @override
  String get statisticsSurplus => 'Superàvit';

  @override
  String get statisticsTooltipCustomRange => 'Rang de dates personalitzat';

  @override
  String get statisticsTopSpending => 'Categories de més despesa';

  @override
  String get statisticsWhatYouEarned => 'El que heu guanyat';

  @override
  String get statisticsWhereMoneyGoes => 'On van els vostres diners';

  @override
  String get aboutMe => 'Sobre mi';

  @override
  String get aboutMeGithubButton => 'Veure el meu GitHub';

  @override
  String get btnExport => 'Exportar';

  @override
  String get createAccountColorThemeLabel => 'Tema de color';

  @override
  String get exportEncryptedBackup => 'Exportar còpia de seguretat xifrada';

  @override
  String get exportEncryptedBackupSubtitle =>
      'Exporta totes les dades com a arxiu de còpia de seguretat protegit amb contrasenya';

  @override
  String get exportMonthlyPdf => 'Exportar informe mensual (PDF)';

  @override
  String get exportMonthlyPdfSubtitle => 'Genera un resum en PDF';

  @override
  String get exportPasswordConfirmLabel => 'Confirmar contrasenya';

  @override
  String get exportPasswordDialogSubtitle =>
      'Aquesta contrasenya serà necessària per restaurar la còpia de seguretat. Guarda-la en un lloc segur.';

  @override
  String get exportPasswordDialogTitle =>
      'Establir contrasenya de còpia de seguretat';

  @override
  String get exportPasswordLabel => 'Contrasenya de còpia de seguretat';

  @override
  String get exportPasswordTooShort =>
      'La contrasenya ha de tenir almenys 6 caràcters.';

  @override
  String get exportPdfCurrentMonth => 'Mes actual';

  @override
  String get exportPdfLast30Days => 'Últims 30 Dies';

  @override
  String exportSavedTo(Object filePath) {
    return 'Desat a $filePath';
  }

  @override
  String get exportSuccess => 'Exportació correcta. Arxiu desat.';

  @override
  String get exportTransactionsCsv => 'Exportar transaccions (CSV)';

  @override
  String get exportTransactionsCsvSubtitle =>
      'Exporta totes les transaccions a un arxiu CSV compatible amb fulls de càlcul';

  @override
  String get importConfirmMessage =>
      'Restaurar una còpia de seguretat sobreescriurà totes les dades actuals. Aquesta acció no es pot desfer. Estàs segur?';

  @override
  String get importConfirmTitle => 'Restaurar còpia de seguretat?';

  @override
  String get importPasswordDialogSubtitle =>
      'Introdueix la contrasenya que vas fer servir quan vas crear la còpia de seguretat.';

  @override
  String get importPasswordDialogTitle =>
      'Introduir contrasenya de còpia de seguretat';

  @override
  String get importRestoreBackup => 'Importar / Restaurar còpia de seguretat';

  @override
  String get importRestoreBackupSubtitle =>
      'Restaura les teves dades des d\'un arxiu de còpia de seguretat de Stalvi';

  @override
  String get importSuccess =>
      'Còpia de seguretat restaurada correctament. Si us plau, reinicia l\'aplicació.';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get pdfDateFormat => 'dd/MM/yyyy';

  @override
  String get pdfDateTimeFormat => 'dd/MM/yyyy HH:mm';

  @override
  String get pdfExportLast30Days => 'Últims 30 dies';

  @override
  String pdfGeneratedOn(Object appTitle, Object date) {
    return 'Generat per $appTitle el $date';
  }

  @override
  String get profileSettingsTitle => 'Perfil i Seguretat';

  @override
  String recycleBinDaysRemaining(Object days) {
    return 'Expira en $days dies';
  }

  @override
  String get recycleBinDeleteConfirmMessage =>
      'Segur que voleu eliminar permanentment aquest element? Aquesta acció no es pot desfer.';

  @override
  String get recycleBinDeleteConfirmTitle => 'Eliminació permanent';

  @override
  String get recycleBinDeleteTooltip => 'Eliminar permanentment';

  @override
  String get recycleBinDeletedMessage => 'Element eliminat permanentment';

  @override
  String get recycleBinEmpty => 'La paperera de reciclatge és buida.';

  @override
  String get recycleBinRestoreTooltip => 'Restaurar';

  @override
  String get recycleBinRestoredMessage => 'Element restaurat';

  @override
  String get recycleBinTitle => 'Paperera de reciclatge';

  @override
  String get settings => 'Ajustos';

  @override
  String get settingsAutomaticTransactions => 'Transaccions Automàtiques';

  @override
  String get settingsDataManagement => 'Gestió de Dades';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsThemeMode => 'Mode de tema';

  @override
  String get themeModeDark => 'Fosc';

  @override
  String get themeModeLight => 'Clar';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get transactionMovedToRecycleBin => 'Transacció moguda a la paperera';

  @override
  String get authError => 'Error d\'autenticació';

  @override
  String get authPinIncorrect => 'PIN incorrecte. Torneu-ho a provar.';

  @override
  String get authSetupValidationErrorName => 'Si us plau, introduïu un nom.';

  @override
  String get authSetupValidationErrorPinLength =>
      'El PIN ha de tenir entre 4 i 8 dígits.';

  @override
  String get authSetupValidationErrorPinMatch => 'Els PIN no coincideixen.';

  @override
  String get authSetupValidationErrorTerms =>
      'Heu d\'acceptar els Termes i Condicions i la Política de Privacitat per continuar.';

  @override
  String get authSetupValidationErrorUsername =>
      'Si us plau, introduïu un nom d\'usuari.';

  @override
  String get autoTxErrorInvalidDayOfMonth =>
      'Dia del mes no vàlid (ha de ser de 1 a 31)';

  @override
  String get autoTxErrorInvalidRecurrenceInterval =>
      'Interval de recurrència no vàlid';

  @override
  String get createAccountErrorFailed => 'Error al crear el compte';

  @override
  String get createAccountErrorName =>
      'Si us plau, introdueix un nom per al compte';

  @override
  String get errorAccountNotFound => 'Compte no trobat';

  @override
  String get errorAccountRequired => 'Si us plau, seleccioneu un compte';

  @override
  String get errorCannotDeleteLastAccount =>
      'No es pot eliminar l\'únic compte existent.';

  @override
  String get errorCategoryRequired => 'Si us plau, seleccioneu una categoria';

  @override
  String get errorConversionFailed => 'Error en convertir la moneda';

  @override
  String get errorCurrencyRequired => 'Si us plau, seleccioneu una moneda';

  @override
  String get errorDeleteTransaction => 'Error al eliminar la transacció';

  @override
  String get errorDestinationAccountRequired =>
      'Si us plau, seleccioneu un compte de destí';

  @override
  String get errorEndDateBeforeStart =>
      'La data de fi ha de ser posterior a la d\'inici';

  @override
  String get errorFutureDate =>
      'La data de la transacció no pot ser en el futur';

  @override
  String get errorInvalidAmount =>
      'Si us plau, introduïu una quantitat vàlida superior a 0';

  @override
  String get errorMaxPinAttempts =>
      'S\'ha assolit el nombre màxim d\'intents de PIN. Si us plau, torneu-ho a provar més tard.';

  @override
  String get errorNameRequired => 'Si us plau, introdueix un nom';

  @override
  String get errorNoOtherCategories =>
      'No hi ha altres categories per reassignar transaccions.';

  @override
  String get errorNoOtherTags =>
      'No hi ha altres etiquetes per reassignar transaccions.';

  @override
  String get errorNoPinSet => 'No hi ha cap PIN configurat actualment.';

  @override
  String get errorOpenFileFailed => 'No s\'ha pogut obrir el fitxer';

  @override
  String get errorPinNotNumeric =>
      'El PIN ha de contenir només dígits numèrics.';

  @override
  String get errorProfileNotFound => 'Perfil no trobat';

  @override
  String get errorRateNotFound =>
      'Tipus de canvi no disponible per a la moneda sol·licitada';

  @override
  String get errorSameAccountTransfer =>
      'Els comptes d\'origen i destí no poden ser el mateix';

  @override
  String get exportFailed =>
      'Error en exportar. Si us plau, torna-ho a provar.';

  @override
  String get exportPasswordMismatch => 'Les contrasenyes no coincideixen.';

  @override
  String get failedLoadAccounts => 'No s\'han pogut carregar els comptes.';

  @override
  String get failedLoadBudgets => 'Error en carregar els pressupostos.';

  @override
  String get failedLoadSavingsGoals =>
      'Error en carregar els objectius d\'estalvi.';

  @override
  String get failedLoadTransactions => 'Error en carregar les transaccions';

  @override
  String get importFailed =>
      'Error en restaurar. Comprova la contrasenya i l\'arxiu.';

  @override
  String get incorrectOldPin => 'PIN antic incorrecte.';

  @override
  String get splashSecureStorageError =>
      'Stalvi no ha pogut inicialitzar el seu emmagatzematge segur. Si us plau, comproveu l\'espai disponible al dispositiu i torneu-ho a provar.';

  @override
  String get splashStartupFailed => 'Error d\'Inici';

  @override
  String get unexpectedError =>
      'S\'ha produït un error inesperat. Si us plau, torneu-ho a provar.';

  @override
  String get notificationAutoTxTitle => 'Transacció automàtica creada';

  @override
  String notificationAutoTxBody(String name) {
    return 'La transacció $name s\'ha completat amb èxit.';
  }
}
