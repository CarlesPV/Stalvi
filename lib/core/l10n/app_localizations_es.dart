// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dashboard => 'Panel de control';

  @override
  String get transactions => 'Transacciones';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get settings => 'Ajustes';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get errorGeneric => 'Algo salió mal. Por favor, inténtelo de nuevo.';

  @override
  String get errorDatabase =>
      'Ocurrió un error en la base de datos. Por favor, contacte con soporte.';

  @override
  String get errorAuth =>
      'Autenticación fallida. Por favor, verifique sus credenciales.';

  @override
  String get errorNetwork =>
      'Error de red. Por favor, compruebe su conexión a internet.';
}
