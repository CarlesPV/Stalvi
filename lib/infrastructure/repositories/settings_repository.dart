import 'package:shared_preferences/shared_preferences.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/domain/repositories/i_settings_repository.dart';

/// Infrastructure implementation of [ISettingsRepository] for local settings persistence.
class SettingsRepository implements ISettingsRepository {
  final SecureStorageManager _secureStorage;
  final SharedPreferences? _prefs;

  static const String kNotificationsEnabledKey = 'stalvi_notifications_enabled';

  SettingsRepository({
    SecureStorageManager? secureStorage,
    SharedPreferences? prefs,
  })  : _secureStorage = secureStorage ?? SecureStorageManager(),
        _prefs = prefs;

  @override
  Future<bool> getNotificationsEnabled() async {
    try {
      if (_prefs != null) {
        return _prefs.getBool(kNotificationsEnabledKey) ?? false;
      }
      return await _secureStorage.getNotificationsEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (_prefs != null) {
        await _prefs.setBool(kNotificationsEnabledKey, enabled);
        return;
      }
      await _secureStorage.setNotificationsEnabled(enabled);
    } catch (_) {}
  }
}
