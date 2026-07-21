import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      debugPrint(
        '[NotificationService] Local notifications initialized successfully.',
      );
    } catch (e, st) {
      debugPrint(
        '[NotificationService] Failed to initialize local notifications: $e\n$st',
      );
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
        return granted ?? false;
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosImpl =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint(
        '[NotificationService] Error requesting notification permissions: $e',
      );
    }
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
      debugPrint(
        '[NotificationService] Notification dispatched: id=$id title="${payload.title}" body="${payload.body}"',
      );
    } catch (e, st) {
      debugPrint('[NotificationService] Failed to show notification: $e\n$st');
    }
  }
}

/// Riverpod provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
