import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Class representing the notification payload data (title & body).
class NotificationPayload {
  final String title;
  final String body;

  const NotificationPayload({
    required this.title,
    required this.body,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPayload &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => title.hashCode ^ body.hashCode;

  @override
  String toString() => 'NotificationPayload(title: "$title", body: "$body")';
}

/// Service in the Infrastructure layer responsible for managing local push notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String channelId = 'stalvi_automatic_transactions';
  static const String channelName = 'Automatic Transactions';
  static const String channelDescription =
      'Notifications for automatically created recurring transactions';

  /// Initializes local notifications for Android & iOS platforms.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initSettings);

      // Create Android Notification Channel
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
          ),
        );
      }

      _isInitialized = true;
    } catch (_) {}
  }

  /// Checks if OS notification permission is currently granted.
  Future<bool> isPermissionGranted() async {
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid) {
        final androidImpl =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidImpl?.areNotificationsEnabled();
        if (enabled != null) return enabled;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosImpl =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final permissions = await iosImpl?.checkPermissions();
        if (permissions != null) return permissions.isEnabled;
      }
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Checks if OS notification permission is permanently denied.
  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      if (kIsWeb) return false;
      final status = await Permission.notification.status;
      return status.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  /// Requests notification permissions for Android 13+ (POST_NOTIFICATIONS) and iOS/macOS.
  Future<bool> requestPermissions() async {
    try {
      if (kIsWeb) return false;

      if (Platform.isAndroid) {
        final androidImpl =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidImpl?.requestNotificationsPermission();
        if (granted != null) return granted;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosImpl =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted != null) return granted;
      }
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {}
    return false;
  }

  /// Formats notification payload (title & body) localized for English, Spanish, and Catalan.
  static NotificationPayload formatAutoTxNotification({
    required String transactionName,
    String? languageCode,
  }) {
    final lang = languageCode?.toLowerCase() ?? 'en';

    String title;
    String body;

    switch (lang) {
      case 'es':
        title = 'Transacción automática creada';
        body = 'La transacción $transactionName se ha completado con éxito.';
        break;
      case 'ca':
        title = 'Transacció automàtica creada';
        body = 'La transacció $transactionName s\'ha completat amb èxit.';
        break;
      case 'en':
      default:
        title = 'Automatic Transaction Created';
        body = 'Transaction $transactionName has been completed successfully.';
        break;
    }

    return NotificationPayload(title: title, body: body);
  }

  /// Formats notification payload for budget exceeded alert localized for English, Spanish, and Catalan.
  static NotificationPayload formatBudgetExceededNotification({
    String? languageCode,
  }) {
    final lang = languageCode?.toLowerCase() ?? 'en';

    String title;
    String body;

    switch (lang) {
      case 'es':
        title = 'Presupuesto superado';
        body = 'Has superado el límite de tu presupuesto.';
        break;
      case 'ca':
        title = 'Pressupost superat';
        body = 'Heu superat el límit del vostre pressupost.';
        break;
      case 'en':
      default:
        title = 'Budget Limit Exceeded';
        body = 'You have exceeded your budget limit.';
        break;
    }

    return NotificationPayload(title: title, body: body);
  }

  /// Formats notification payload for savings goal reached alert localized for English, Spanish, and Catalan.
  static NotificationPayload formatGoalReachedNotification({
    String? languageCode,
  }) {
    final lang = languageCode?.toLowerCase() ?? 'en';

    String title;
    String body;

    switch (lang) {
      case 'es':
        title = 'Meta de ahorro alcanzada';
        body = '¡Felicidades! Has alcanzado tu meta de ahorro.';
        break;
      case 'ca':
        title = 'Objectiu d\'estalvi assolit';
        body = 'Felicitats! Heu assolit el vostre objectiu d\'estalvi.';
        break;
      case 'en':
      default:
        title = 'Savings Goal Reached';
        body = 'Congratulations! You have reached your savings goal.';
        break;
    }

    return NotificationPayload(title: title, body: body);
  }

  /// Shows a local push notification for a created automatic transaction.
  Future<void> showAutomaticTransactionNotification({
    required String transactionName,
    String? languageCode,
    int? notificationId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final payload = formatAutoTxNotification(
      transactionName: transactionName,
      languageCode: languageCode,
    );

    await _showNotificationPayload(payload, notificationId: notificationId);
  }

  /// Shows a local push notification when a budget limit is exceeded.
  Future<void> showBudgetExceededNotification({
    String? languageCode,
    int? notificationId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final payload = formatBudgetExceededNotification(
      languageCode: languageCode,
    );

    await _showNotificationPayload(payload, notificationId: notificationId);
  }

  /// Shows a local push notification when a savings goal is reached.
  Future<void> showGoalReachedNotification({
    String? languageCode,
    int? notificationId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final payload = formatGoalReachedNotification(
      languageCode: languageCode,
    );

    await _showNotificationPayload(payload, notificationId: notificationId);
  }

  Future<void> _showNotificationPayload(
    NotificationPayload payload, {
    int? notificationId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = notificationId ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    try {
      await _notificationsPlugin.show(
        id,
        payload.title,
        payload.body,
        details,
      );
    } catch (_) {}
  }
}

/// Riverpod provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
