// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stalvi';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnClose => 'Cerrar';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnNext => 'Siguiente';

  @override
  String get btnOpen => 'Abrir';

  @override
  String get btnReassignAndDelete => 'Reasignar y eliminar';

  @override
  String get btnRestore => 'Restaurar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnViewDetails => 'Ver detalles';

  @override
  String get categories => 'Categorías';

  @override
  String get currencyAUD => 'Dólar Australiano (AUD)';

  @override
  String get currencyCAD => 'Dólar Canadiense (CAD)';

  @override
  String get currencyCHF => 'Franco Suizo (CHF)';

  @override
  String get currencyCNY => 'Yuan Chino (CNY)';

  @override
  String get currencyEUR => 'Euro (EUR)';

  @override
  String get currencyGBP => 'Libra Esterlina (GBP)';

  @override
  String get currencyJPY => 'Yen Japonés (JPY)';

  @override
  String get currencyUSD => 'Dólar Estadounidense (USD)';

  @override
  String get deleteAllDataButton => 'Borrar todos los datos';

  @override
  String get deleteAllDataWarning =>
      '¿Estás seguro de que quieres borrar todos los datos? Esto no se puede deshacer.';

  @override
  String get endDate => 'Fecha de Fin';

  @override
  String get getStarted => 'Empezar';

  @override
  String get labelAmount => 'CANTIDAD';

  @override
  String get labelCurrency => 'Moneda';

  @override
  String get labelDate => 'Fecha';

  @override
  String get labelIcon => 'Icono';

  @override
  String get labelNotes => 'Notas';

  @override
  String get labelNotesHint => 'Añada detalles sobre esta transacción...';

  @override
  String get labelSelectCurrency => 'Seleccionar moneda';

  @override
  String get noCategories => 'Aún no hay categorías';

  @override
  String get noDataAvailable => 'Aún no hay datos disponibles';

  @override
  String get optionalPlaceholder => '(Opcional)';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get recurrenceUtcWarning => 'La hora de referencia es UTC+2';

  @override
  String get setAsDefault => 'Establecer como predeterminada';

  @override
  String get startDate => 'Fecha de Inicio';

  @override
  String get targetAmount => 'Cantidad Objetivo';

  @override
  String get targetDate => 'Fecha Objetivo';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get txnSuccessCreated => '¡Transacción creada con éxito!';

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get warning => 'Advertencia';

  @override
  String get authBiometricOptInEnable => 'Habilitar biometría';

  @override
  String get authBiometricOptInSkip => 'Omitir por ahora';

  @override
  String get authBiometricOptInSubtitle =>
      'Usa tu huella dactilar o reconocimiento facial para acceder a Stalvi de forma rápida y segura en el futuro.';

  @override
  String get authBiometricOptInTitle => 'Habilitar acceso biométrico';

  @override
  String get authLockedMessage =>
      'Demasiados intentos fallidos. Por favor, desbloquee su dispositivo desde la pantalla de bloqueo e inténtelo de nuevo.';

  @override
  String get authLockedTitle => 'Biometría bloqueada';

  @override
  String get authLockoutActive => 'Bloqueo de seguridad activo';

  @override
  String authPinAttemptsRemaining(Object attempts) {
    return 'Quedan $attempts intentos';
  }

  @override
  String get authPinEnter => 'Introducir PIN';

  @override
  String get authPinLockedCountdown => 'segundos restantes';

  @override
  String get authPinLockedMessage =>
      'El acceso ha sido bloqueado temporalmente tras demasiadas entradas incorrectas del PIN.';

  @override
  String get authPinLockedRetry => 'Ahora puede intentarlo de nuevo';

  @override
  String get authPinLockedTitle => 'Demasiados intentos fallidos';

  @override
  String get authProcessing => 'Procesando autenticación de seguridad…';

  @override
  String get authProtectedBy => 'Protegido por la biometría del dispositivo';

  @override
  String get authSetupAcceptAnd => ' y la ';

  @override
  String get authSetupAcceptPrefix => 'Acepto los ';

  @override
  String get authSetupConfirmPinLabel => 'Confirmar PIN';

  @override
  String get authSetupCreateButton => 'Crear perfil';

  @override
  String get authSetupCurrencyLabel => 'Moneda predeterminada';

  @override
  String get authSetupLanguageLabel => 'Idioma predeterminado';

  @override
  String get authSetupNameLabel => 'Nombre';

  @override
  String get authSetupPinLabel => 'Establecer un PIN de 4 a 8 dígitos';

  @override
  String get authSetupSubtitle =>
      'Configura tu cartera segura fuera de línea para comenzar.';

  @override
  String get authSetupTitle => 'Crear tu perfil';

  @override
  String get authSetupUsernameLabel => 'Nombre de usuario';

  @override
  String get authSignInTitle => 'Verificar identidad';

  @override
  String get authVerifyMessage =>
      'Use la biometría o el PIN de su dispositivo para continuar';

  @override
  String get changePinButton => 'Cambiar PIN';

  @override
  String get confirmPinLabel => 'Confirmar nuevo PIN';

  @override
  String get newPinLabel => 'Nuevo PIN';

  @override
  String get oldPinLabel => 'PIN antiguo';

  @override
  String get pinUpdatedSuccessfully => 'PIN actualizado correctamente.';

  @override
  String get pinsDoNotMatch => 'Los PINs no coinciden.';

  @override
  String get statisticsTopIncome => 'Categorías de mayor ingreso';

  @override
  String get balanceTotal => 'Balance total';

  @override
  String get overview => 'Resumen';

  @override
  String get accountInUseByAutoTxMessage =>
      'Esta cuenta no se puede eliminar porque está vinculada a transacciones automáticas activas.';

  @override
  String get accountTypeBank => 'Banco';

  @override
  String get accountTypeCard => 'Tarjeta';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeOther => 'Otro';

  @override
  String get accounts => 'Cuentas';

  @override
  String acrossAccountsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas',
      one: '1 cuenta',
    );
    return '$_temp0';
  }

  @override
  String get addCategoryTitle => 'Añadir categoría';

  @override
  String get addTagTitle => 'Añadir etiqueta';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get autoTxEditTitle => 'Editar Transacción Automática';

  @override
  String autoTxFormatEveryDays(Object days) {
    return 'Cada $days días';
  }

  @override
  String get autoTxFormatMonthly => 'Mensual';

  @override
  String autoTxFormatSpecificDay(Object day) {
    return 'El día $day de cada mes';
  }

  @override
  String get autoTxFormatWeekly => 'Semanal';

  @override
  String get autoTxFormatYearly => 'Anual';

  @override
  String get autoTxLabelRecurrence => 'Recurrencia';

  @override
  String get autoTxNameRequired => 'El nombre es obligatorio';

  @override
  String get autoTxNewTitle => 'Nueva Transacción Automática';

  @override
  String get autoTxRecurrenceApply => 'Aplicar';

  @override
  String get autoTxRecurrenceCustomHint => 'p.ej. 14';

  @override
  String get autoTxRecurrenceCustomInterval => 'Intervalo Personalizado (Días)';

  @override
  String get autoTxRecurrenceDayOfMonth => 'Día X del mes';

  @override
  String get autoTxRecurrenceEveryXDays => 'Cada X días';

  @override
  String get autoTxRecurrenceMonthly => 'Mensual (Cada 30 días)';

  @override
  String get autoTxRecurrenceWeekly => 'Semanal (Cada 7 días)';

  @override
  String get autoTxRecurrenceYearly => 'Anual (Cada 365 días)';

  @override
  String get autoTxSavedMessage => 'Transacción Automática Guardada';

  @override
  String get autoTxSelectRecurrence => 'Seleccionar Recurrencia';

  @override
  String get autoTxTemplateNameLabel => 'Nombre';

  @override
  String get btnSaveTransaction => 'Guardar transacción';

  @override
  String get categoriesAndTags => 'Categorías y Etiquetas';

  @override
  String categoryInUseByAutoTxMessage(String name) {
    return '$name está en uso por transacciones automáticas y debe ser reasignada.';
  }

  @override
  String categoryInUseMessage(Object name) {
    return '$name está en uso en transacciones existentes. Por favor, seleccione una categoría para reasignarlas:';
  }

  @override
  String get categoryInUseTitle => 'Categoría en uso';

  @override
  String get createAccountIconLabel => 'Icono';

  @override
  String get createAccountInitialBalanceLabel => 'Saldo Inicial';

  @override
  String get createAccountNameHint => 'ej. Tarjeta Personal, Efectivo, etc.';

  @override
  String get createAccountNameLabel => 'Nombre de la cuenta';

  @override
  String get createAccountTitle => 'Crear nueva cuenta';

  @override
  String get createNewCategory => 'Crear nueva categoría';

  @override
  String get createNewLabel => 'Crear nueva etiqueta';

  @override
  String get createAccountTypeLabel => 'Tipo de cuenta';

  @override
  String get createAutomaticTransaction => 'Crear Transacción Automática';

  @override
  String get defaultAccountLabel => 'Predeterminada';

  @override
  String get defaultAccountName => 'Cuenta principal';

  @override
  String deleteCategoryConfirm(Object name) {
    return '¿Está seguro de que desea eliminar $name?';
  }

  @override
  String get deleteCategoryTitle => '¿Eliminar categoría?';

  @override
  String deleteTagConfirm(Object name) {
    return '¿Está seguro de que desea eliminar $name?';
  }

  @override
  String get deleteTagTitle => '¿Eliminar etiqueta?';

  @override
  String get deleteTransactionConfirmation =>
      '¿Estás seguro de que quieres eliminar esta transacción? Se moverá a la papelera de reciclaje.';

  @override
  String get deleteTransactionTitle => '¿Eliminar transacción?';

  @override
  String get destination_account => 'Cuenta de destino';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get editTagTitle => 'Editar etiqueta';

  @override
  String expense(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gastos',
      one: 'Gasto',
    );
    return '$_temp0';
  }

  @override
  String get expense_vs_income => 'Gastos vs Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get fallbackExpense => 'Gasto';

  @override
  String get fallbackIncome => 'Ingreso';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterExpense => 'Gastos';

  @override
  String get filterIncome => 'Ingresos';

  @override
  String filterSheetActiveFilters(Object count) {
    return '$count filtros activos';
  }

  @override
  String get filterSheetAllCategories => 'Todas las categorías';

  @override
  String get filterSheetAllCurrencies => 'Todas las monedas';

  @override
  String get filterSheetAllTags => 'Todas las etiquetas';

  @override
  String get filterSheetAllTypes => 'Todos los tipos';

  @override
  String get filterSheetAmountRange => 'Rango de importes';

  @override
  String get filterSheetApply => 'Aplicar filtros';

  @override
  String get filterSheetCategory => 'Categoría';

  @override
  String get filterSheetClearAll => 'Limpiar todo';

  @override
  String get filterSheetCurrency => 'Moneda';

  @override
  String get filterSheetDateRange => 'Rango de fechas';

  @override
  String get filterSheetMaxAmount => 'Importe máximo';

  @override
  String get filterSheetMinAmount => 'Importe mínimo';

  @override
  String get filterSheetSelectDateRange => 'Seleccionar rango de fechas';

  @override
  String get filterSheetTag => 'Etiqueta';

  @override
  String get filterSheetTitle => 'Filtrar transacciones';

  @override
  String get filterSheetTransferType => 'Transferencia';

  @override
  String get filterSheetType => 'Tipo de transacción';

  @override
  String get filterTransfer => 'Transferencia';

  @override
  String income(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ingresos',
      one: 'Ingreso',
    );
    return '$_temp0';
  }

  @override
  String get labelAccount => 'Cuenta';

  @override
  String get labelCategory => 'Categoría';

  @override
  String get labelCategoryName => 'Nombre de la categoría';

  @override
  String get labelDestinationAccount => 'Cuenta de destino';

  @override
  String get labelFromAccount => 'Desde cuenta';

  @override
  String get labelOriginAccount => 'Cuenta de origen';

  @override
  String get labelSelectAccount => 'Seleccionar cuenta';

  @override
  String get labelSelectCategory => 'Seleccionar categoría';

  @override
  String get labelSelectTag => 'Seleccionar etiqueta';

  @override
  String get labelTag => 'Etiqueta';

  @override
  String get labelTagName => 'Nombre de la etiqueta';

  @override
  String get labelToAccount => 'Hacia cuenta';

  @override
  String get noAccountsSubtitle =>
      'Crea una cuenta o billetera para comenzar a administrar tus activos y registrar transacciones.';

  @override
  String get noAccountsTitle => 'Aún no hay cuentas';

  @override
  String get noTag => 'Ninguna';

  @override
  String get noTags => 'Aún no hay etiquetas';

  @override
  String get noTransactionsSubtitle =>
      'Añada su primer ingreso o gasto para verlo aquí y comenzar el seguimiento.';

  @override
  String get noTransactionsTitle => 'Aún no hay transacciones';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get replaceDefaultAccountConfirm =>
      'La cuenta predeterminada anterior será reemplazada. ¿Continuar?';

  @override
  String get selectDestinationAccount => 'Seleccionar cuenta de destino';

  @override
  String get selectSourceAccount => 'Seleccionar cuenta de origen';

  @override
  String get splashTagline => 'Tus finanzas, a tu manera.';

  @override
  String tagInUseMessage(Object name) {
    return '$name está en uso en transacciones existentes. Por favor, seleccione una etiqueta para reasignarlas:';
  }

  @override
  String get tagInUseTitle => 'Etiqueta en uso';

  @override
  String get tags => 'Etiquetas';

  @override
  String get transactions => 'Transacciones';

  @override
  String get unknownAccount => 'Cuenta desconocida';

  @override
  String get accountTypeSavings => 'Ahorros';

  @override
  String get addBudget => 'Añadir Presupuesto';

  @override
  String get addSavingsGoal => 'Añadir Meta de Ahorro';

  @override
  String get budgetDetails => 'Detalles del Presupuesto';

  @override
  String budgetOverspent(Object amount) {
    return '$amount sobrepasado';
  }

  @override
  String budgetRemaining(Object amount) {
    return '$amount restante';
  }

  @override
  String budgetSpentOf(Object spent, Object target) {
    return '$spent de $target';
  }

  @override
  String get budgets => 'Presupuestos';

  @override
  String get budgetsAndGoals => 'Presupuestos y Objetivos';

  @override
  String get deleteBudget => 'Eliminar Presupuesto';

  @override
  String get deleteSavingsGoal => 'Eliminar Meta de Ahorro';

  @override
  String get goalName => 'Nombre de la Meta';

  @override
  String get labelBudget => 'Presupuesto';

  @override
  String get noBudgetsSubtitle =>
      'Establezca límites de gasto para las categorías para realizar un seguimiento de sus gastos mensuales y mantenerse dentro de sus límites.';

  @override
  String get noBudgetsTitle => 'Aún no se han definido presupuestos';

  @override
  String get noSavingsGoalsSubtitle =>
      'Cree un objetivo de ahorro para planificar sus futuros sueños, viajes o grandes compras.';

  @override
  String get noSavingsGoalsTitle => 'Aún no hay objetivos de ahorro';

  @override
  String get pdfBudgetsColCategory => 'Categoría';

  @override
  String get pdfBudgetsColDateRange => 'Rango de Fechas';

  @override
  String get pdfBudgetsColMaxValue => 'Valor Máximo';

  @override
  String get pdfBudgetsColSpent => '% Gastado';

  @override
  String get pdfBudgetsTitle => 'Presupuestos';

  @override
  String get pdfSavingsColCompleted => '% Completado';

  @override
  String get pdfSavingsColName => 'Nombre';

  @override
  String get pdfSavingsGoalsTitle => 'Metas de Ahorro';

  @override
  String get savingsGoal => 'Objetivo de ahorro';

  @override
  String get savingsGoalAchieved => '¡Objetivo conseguido!';

  @override
  String get savingsGoalDetails => 'Detalles del Objetivo de Ahorro';

  @override
  String get savingsGoals => 'Objetivos de ahorro';

  @override
  String get savingsNoTargetDate => 'Sin fecha objetivo';

  @override
  String savingsSavedOf(Object saved, Object target) {
    return '$saved guardados de $target';
  }

  @override
  String savingsTargetDate(Object date) {
    return 'Fecha objetivo: $date';
  }

  @override
  String get settingsBudgetsGoals => 'Presupuestos y Objetivos';

  @override
  String get chart_scale => 'Escala del gráfico';

  @override
  String get presetCustom => 'Personalizado';

  @override
  String get presetLast30Days => 'Últimos 30 días';

  @override
  String get presetLast3Months => 'Últimos 3 meses';

  @override
  String get presetLast6Months => 'Últimos 6 meses';

  @override
  String get presetThisMonth => 'Este mes';

  @override
  String get presetThisYear => 'Este año';

  @override
  String get settingsStatistics => 'Estadísticas';

  @override
  String get statisticsDeficit => 'Déficit';

  @override
  String get statisticsNetBalance => 'Balance neto';

  @override
  String get statisticsNoDataSubtitle =>
      'Intenta añadir transacciones o cambiar el rango del filtro para ver tu desglose de categorías.';

  @override
  String get statisticsNoExpenses =>
      'No se registraron gastos en este período.';

  @override
  String get statisticsNoIncome =>
      'No se registraron ingresos en este período.';

  @override
  String statisticsOtherCategories(Object count) {
    return 'Otras ($count categorías)';
  }

  @override
  String get statisticsSurplus => 'Superávit';

  @override
  String get statisticsTooltipCustomRange => 'Rango de fechas personalizado';

  @override
  String get statisticsTopSpending => 'Categorías de mayor gasto';

  @override
  String get statisticsWhatYouEarned => 'Lo que ha ganado';

  @override
  String get statisticsWhereMoneyGoes => 'A dónde va su dinero';

  @override
  String get aboutMe => 'Sobre mí';

  @override
  String get aboutMeGithubButton => 'Ver mi GitHub';

  @override
  String get btnExport => 'Exportar';

  @override
  String get createAccountColorThemeLabel => 'Tema de color';

  @override
  String get exportEncryptedBackup => 'Exportar copia de seguridad cifrada';

  @override
  String get exportEncryptedBackupSubtitle =>
      'Exporta todos los datos como archivo de copia de seguridad protegido con contraseña';

  @override
  String get exportMonthlyPdf => 'Exportar informe mensual (PDF)';

  @override
  String get exportMonthlyPdfSubtitle => 'Genera un resumen en PDF';

  @override
  String get exportPasswordConfirmLabel => 'Confirmar contraseña';

  @override
  String get exportPasswordDialogSubtitle =>
      'Esta contraseña será necesaria para restaurar la copia de seguridad. Guárdala en un lugar seguro.';

  @override
  String get exportPasswordDialogTitle =>
      'Establecer contraseña de copia de seguridad';

  @override
  String get exportPasswordLabel => 'Contraseña de copia de seguridad';

  @override
  String get exportPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get exportPdfCurrentMonth => 'Mes actual';

  @override
  String get exportPdfLast30Days => 'Últimos 30 días';

  @override
  String exportSavedTo(Object filePath) {
    return 'Guardado en $filePath';
  }

  @override
  String get exportSuccess => 'Exportación exitosa. Archivo guardado.';

  @override
  String get exportTransactionsCsv => 'Exportar transacciones (CSV)';

  @override
  String get exportTransactionsCsvSubtitle =>
      'Exporta todas las transacciones a un archivo CSV compatible con hojas de cálculo';

  @override
  String get importConfirmMessage =>
      'Restaurar una copia de seguridad sobreescribirá todos los datos actuales. Esta acción no se puede deshacer. ¿Estás seguro?';

  @override
  String get importConfirmTitle => '¿Restaurar copia de seguridad?';

  @override
  String get importPasswordDialogSubtitle =>
      'Introduce la contraseña utilizada al crear la copia de seguridad.';

  @override
  String get importPasswordDialogTitle =>
      'Introducir contraseña de copia de seguridad';

  @override
  String get importRestoreBackup => 'Importar / Restaurar copia de seguridad';

  @override
  String get importRestoreBackupSubtitle =>
      'Restaura tus datos desde un archivo de copia de seguridad de Stalvi';

  @override
  String get importSuccess =>
      'Copia de seguridad restaurada correctamente. Por favor, reinicia la aplicación.';

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
  String get pdfExportLast30Days => 'Últimos 30 días';

  @override
  String pdfGeneratedOn(Object appTitle, Object date) {
    return 'Generado por $appTitle el $date';
  }

  @override
  String get profileSettingsTitle => 'Perfil y Seguridad';

  @override
  String recycleBinDaysRemaining(Object days) {
    return 'Expira en $days días';
  }

  @override
  String get recycleBinDeleteConfirmMessage =>
      '¿Está seguro de que desea eliminar permanentemente este elemento? Esta acción no se puede deshacer.';

  @override
  String get recycleBinDeleteConfirmTitle => 'Eliminación permanente';

  @override
  String get recycleBinDeleteTooltip => 'Eliminar permanentemente';

  @override
  String get recycleBinDeletedMessage => 'Elemento eliminado permanentemente';

  @override
  String get recycleBinEmpty => 'La papelera de reciclaje está vacía.';

  @override
  String get recycleBinRestoreTooltip => 'Restaurar';

  @override
  String get recycleBinRestoredMessage => 'Elemento restaurado';

  @override
  String get recycleBinTitle => 'Papelera de reciclaje';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsAutomaticTransactions => 'Transacciones Automáticas';

  @override
  String get settingsDataManagement => 'Gestión de Datos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones Push';

  @override
  String get notificationsPermanentlyDeniedTitle =>
      'Notificaciones Desactivadas';

  @override
  String get notificationsPermanentlyDeniedBody =>
      'Has denegado permanentemente los permisos de notificación. Por favor, actívalos en los ajustes del sistema para recibir alertas.';

  @override
  String get btnOpenSettings => 'Abrir Ajustes';

  @override
  String get settingsThemeMode => 'Modo de Tema';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get transactionMovedToRecycleBin => 'Transacción movida a la papelera';

  @override
  String get authError => 'Error de autenticación';

  @override
  String get authPinIncorrect => 'PIN incorrecto. Inténtelo de nuevo.';

  @override
  String get authSetupValidationErrorName => 'Por favor, introduzca un nombre.';

  @override
  String get authSetupValidationErrorNameEmoji =>
      'El nombre no puede contener emoticonos ni caracteres especiales.';

  @override
  String get authSetupValidationErrorNameLength =>
      'El nombre no puede superar los 25 caracteres.';

  @override
  String get authSetupValidationErrorPinLength =>
      'El PIN debe tener entre 4 y 8 dígitos.';

  @override
  String get authSetupValidationErrorPinMatch => 'Los PIN no coinciden.';

  @override
  String get authSetupValidationErrorTerms =>
      'Debe aceptar los Términos y Condiciones y la Política de Privacidad para continuar.';

  @override
  String get authSetupValidationErrorUsername =>
      'Por favor, introduzca un nombre de usuario.';

  @override
  String get authSetupValidationErrorUsernameEmoji =>
      'El nombre de usuario no puede contener emoticonos ni caracteres especiales.';

  @override
  String get authSetupValidationErrorUsernameLength =>
      'El nombre de usuario no puede superar los 25 caracteres.';

  @override
  String get autoTxErrorInvalidDayOfMonth =>
      'Día del mes no válido (debe ser de 1 a 31)';

  @override
  String get autoTxErrorInvalidRecurrenceInterval =>
      'Intervalo de recurrencia no válido';

  @override
  String get createAccountErrorFailed => 'Fallo al crear la cuenta';

  @override
  String get createAccountErrorName =>
      'Por favor ingresa un nombre para la cuenta';

  @override
  String get errorAccountNotFound => 'Cuenta no encontrada';

  @override
  String get errorAccountRequired => 'Por favor, seleccione una cuenta';

  @override
  String get errorCannotDeleteLastAccount =>
      'No se puede eliminar la única cuenta existente.';

  @override
  String get errorCategoryRequired => 'Por favor, seleccione una categoría';

  @override
  String get errorConversionFailed => 'Error al convertir la moneda';

  @override
  String get errorCurrencyRequired => 'Por favor, seleccione una moneda';

  @override
  String get errorDeleteTransaction => 'Error al eliminar la transacción';

  @override
  String get errorDestinationAccountRequired =>
      'Por favor, seleccione una cuenta de destino';

  @override
  String get errorEndDateBeforeStart =>
      'La fecha de fin debe ser posterior a la de inicio';

  @override
  String get errorFutureDate =>
      'La fecha de la transacción no puede ser en el futuro';

  @override
  String get errorInvalidAmount =>
      'Por favor, introduzca una cantidad válida mayor que 0';

  @override
  String get errorMaxPinAttempts =>
      'Se ha alcanzado el número máximo de intentos de PIN. Por favor, inténtelo de nuevo más tarde.';

  @override
  String get errorNameRequired => 'Por favor, introduce un nombre';

  @override
  String get errorNoOtherCategories =>
      'No hay otras categorías para reasignar transacciones.';

  @override
  String get errorNoOtherTags =>
      'No hay otras etiquetas para reasignar transacciones.';

  @override
  String get errorNoPinSet => 'No hay ningún PIN configurado actualmente.';

  @override
  String get errorOpenFileFailed => 'No se pudo abrir el archivo';

  @override
  String get errorPinNotNumeric =>
      'El PIN debe contener solo dígitos numéricos.';

  @override
  String get errorProfileNotFound => 'Perfil no encontrado';

  @override
  String get errorRateNotFound =>
      'Tipo de cambio no disponible para la moneda solicitada';

  @override
  String get errorSameAccountTransfer =>
      'Las cuentas de origen y destino no pueden ser la misma';

  @override
  String get exportFailed =>
      'Error al exportar. Por favor, inténtalo de nuevo.';

  @override
  String get exportPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get failedLoadAccounts => 'No se pudieron cargar las cuentas.';

  @override
  String get failedLoadBudgets => 'Error al cargar los presupuestos.';

  @override
  String get failedLoadSavingsGoals =>
      'Error al cargar los objetivos de ahorro.';

  @override
  String get failedLoadTransactions => 'Error al cargar las transacciones';

  @override
  String get importFailed =>
      'Error al restaurar. Comprueba la contraseña y el archivo.';

  @override
  String get incorrectOldPin => 'PIN antiguo incorrecto.';

  @override
  String get splashSecureStorageError =>
      'Stalvi no pudo inicializar su almacenamiento seguro. Por favor, compruebe el almacenamiento disponible del dispositivo e inténtelo de nuevo.';

  @override
  String get splashStartupFailed => 'Error de Inicio';

  @override
  String get unexpectedError =>
      'Ocurrió un error inesperado. Por favor, inténtelo de nuevo.';

  @override
  String get hintAmountZero => '0.00';

  @override
  String get errorCouldNotLaunchUrl => 'No se pudo abrir el enlace';

  @override
  String get errorLoadingContent => 'Error al cargar el contenido.';
}
