import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/repositories/i_settings_repository.dart';
import 'package:stalvi/infrastructure/services/notification_service.dart';
import 'repository_providers.dart';

enum NotificationToggleResult { success, denied, permanentlyDenied }

/// A [Notifier] that manages the push notifications toggle state.
///
/// Default state is `false` (OFF). When toggling ON, it verifies and requests
/// OS notification permissions. If permission is denied, the toggle reverts to `false` (OFF).
class SettingsNotifier extends Notifier<bool> {
  late final ISettingsRepository _settingsRepo;
  late final NotificationService _notificationService;
  bool _isInitialized = false;

  @override
  bool build() {
    _settingsRepo = ref.watch(settingsRepositoryProvider);
    _notificationService = ref.watch(notificationServiceProvider);

    // Default state is OFF (false)
    _loadPersistedState();
    return false;
  }

  /// Asynchronously loads the saved notifications preference from the repository.
  Future<void> _loadPersistedState() async {
    try {
      final enabled = await _settingsRepo.getNotificationsEnabled();
      if (!_isInitialized) {
        state = enabled;
        _isInitialized = true;
      }
    } catch (_) {
      _isInitialized = true;
    }
  }

  /// Toggles notifications on/off.
  ///
  /// If toggling ON:
  ///   1. Checks if OS notification permission is already granted.
  ///   2. If not granted, checks if permanently denied.
  ///   3. Requests notification permission.
  ///   4. If permission is granted, persists and sets state to `true`.
  ///   5. If permission is denied, reverts state to `false` and persists `false`.
  /// If toggling OFF:
  ///   - Sets state to `false` and persists `false`.
  Future<NotificationToggleResult> toggleNotifications(bool value) async {
    _isInitialized = true;

    if (!value) {
      state = false;
      await _settingsRepo.setNotificationsEnabled(false);
      return NotificationToggleResult.success;
    }

    // Toggling ON — check & request permission if necessary
    bool granted = await _notificationService.isPermissionGranted();
    if (granted) {
      state = true;
      await _settingsRepo.setNotificationsEnabled(true);
      return NotificationToggleResult.success;
    }

    if (await _notificationService.isPermissionPermanentlyDenied()) {
      return NotificationToggleResult.permanentlyDenied;
    }

    granted = await _notificationService.requestPermissions();

    if (granted) {
      state = true;
      await _settingsRepo.setNotificationsEnabled(true);
      return NotificationToggleResult.success;
    } else {
      // User denied OS permission — revert toggle to OFF
      state = false;
      await _settingsRepo.setNotificationsEnabled(false);

      if (await _notificationService.isPermissionPermanentlyDenied()) {
        return NotificationToggleResult.permanentlyDenied;
      }
      return NotificationToggleResult.denied;
    }
  }
}

/// Global provider for application settings (push notifications toggle).
final settingsNotifierProvider = NotifierProvider<SettingsNotifier, bool>(
  SettingsNotifier.new,
);
