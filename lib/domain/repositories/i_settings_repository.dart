import 'dart:async';

/// Domain contract for managing application settings persistence.
abstract class ISettingsRepository {
  /// Retrieves whether push notifications are enabled.
  /// Defaults to `true` (ON).
  Future<bool> getNotificationsEnabled();

  /// Persists the user's choice for push notifications.
  Future<void> setNotificationsEnabled(bool enabled);
}
