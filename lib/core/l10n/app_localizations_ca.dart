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
  String get expense => 'Despeses';

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
}
