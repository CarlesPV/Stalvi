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
  String get appTitle => 'Konta';

  @override
  String get splashTagline => 'Les teves finances, a la teva manera.';

  @override
  String get splashStartupFailed => 'Error d\'Inici';

  @override
  String get splashSecureStorageError =>
      'Konta no ha pogut inicialitzar el seu emmagatzematge segur. Si us plau, comproveu l\'espai disponible al dispositiu i torneu-ho a provar.';

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
}
