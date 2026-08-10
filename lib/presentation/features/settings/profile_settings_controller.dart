import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/utils/input_sanitizer.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';
import 'package:stalvi/domain/usecases/pdf_export_date_range.dart';
import '../../providers/repository_providers.dart';
import '../../providers/statistics_providers.dart';
import '../../providers/settings_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_settings_controller.g.dart';

enum PinChangeStep { verifyOld, enterNew }

class ProfileSettingsState {
  final Profile? profile;
  final bool isLoading;
  final String? error;
  final PinChangeStep pinChangeStep;
  final int failedAttempts;
  final int failedDeleteAttempts;

  const ProfileSettingsState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.pinChangeStep = PinChangeStep.verifyOld,
    this.failedAttempts = 0,
    this.failedDeleteAttempts = 0,
  });

  ProfileSettingsState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
    PinChangeStep? pinChangeStep,
    int? failedAttempts,
    int? failedDeleteAttempts,
  }) {
    return ProfileSettingsState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pinChangeStep: pinChangeStep ?? this.pinChangeStep,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      failedDeleteAttempts: failedDeleteAttempts ?? this.failedDeleteAttempts,
    );
  }
}

@riverpod
class ProfileSettingsController extends _$ProfileSettingsController {
  @override
  ProfileSettingsState build() {
    Future.microtask(_loadProfile);
    return const ProfileSettingsState(isLoading: true);
  }

  Future<void> _loadProfile() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final profile = await repo.getFirstProfile();
      if (!ref.mounted) return;
      state = state.copyWith(profile: profile, isLoading: false, error: null);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<NotificationToggleResult> toggleNotifications(bool value) async {
    return await ref
        .read(settingsNotifierProvider.notifier)
        .toggleNotifications(value);
  }

  Future<void> updateUsername(String username) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.length > 25) {
      throw const ValidationException(
        message: 'Username cannot exceed 25 characters.',
      );
    }
    if (InputSanitizer.containsEmoji(username)) {
      throw const ValidationException(
        message: 'Username cannot contain emojis.',
      );
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final updatedProfile = currentProfile.copyWith(
        username: username,
        modifiedAt: DateTime.now(),
      );
      await repo.updateProfile(updatedProfile);
      if (!ref.mounted) return;
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateCurrency(String newCurrency) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;
    if (newCurrency.trim().isEmpty) return;
    if (currentProfile.defaultCurrency == newCurrency) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final updatedProfile = currentProfile.copyWith(
        defaultCurrency: newCurrency,
        modifiedAt: DateTime.now(),
      );
      await repo.updateProfile(updatedProfile);
      ref.invalidate(defaultProfileProvider);
      ref.invalidate(statisticsCurrencyProvider);
      ref.invalidate(periodSummaryProvider);
      ref.invalidate(dashboardPeriodSummaryProvider);
      ref.invalidate(topExpenseCategoriesProvider);
      ref.invalidate(topIncomeCategoriesProvider);
      ref.invalidate(globalBalanceProvider);
      if (!ref.mounted) return;
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOldPin(String oldPin) async {
    if (state.failedAttempts >= 6) {
      throw Exception('Maximum PIN attempts reached. Please try again later.');
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(updateCredentialsUseCaseProvider);
      await useCase.verifyOldPin(oldPin);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        pinChangeStep: PinChangeStep.enterNew,
        failedAttempts: 0,
      );
    } catch (e) {
      final newAttempts = state.failedAttempts + 1;
      if (!ref.mounted) rethrow;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        failedAttempts: newAttempts,
      );
      rethrow;
    }
  }

  Future<void> changePin(String oldPin, String newPin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(updateCredentialsUseCaseProvider);
      await useCase.execute(
        UpdateCredentialsParams(oldPin: oldPin, newPin: newPin),
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        pinChangeStep: PinChangeStep.verifyOld,
      );
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void resetPinChangeState() {
    state = state.copyWith(
      pinChangeStep: PinChangeStep.verifyOld,
      error: null,
      failedAttempts: 0,
    );
  }

  void resetDeleteDataState() {
    state = state.copyWith(
      error: null,
      failedDeleteAttempts:
          state.failedDeleteAttempts >= 6 ? state.failedDeleteAttempts : 0,
    );
  }

  Future<bool> verifyDeleteDataPin(String pin) async {
    if (state.failedDeleteAttempts >= 6) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(updateCredentialsUseCaseProvider);
      await useCase.verifyOldPin(pin);
      if (!ref.mounted) return true;
      state = state.copyWith(isLoading: false, failedDeleteAttempts: 0);
      return true;
    } catch (e) {
      final newAttempts = state.failedDeleteAttempts + 1;
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        failedDeleteAttempts: newAttempts,
      );
      return false;
    }
  }

  Future<void> wipeAllData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(wipeAllDataUseCaseProvider);
      await useCase.execute();
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Exports all user data as an AES-256-CBC-encrypted JSON backup.
  ///
  /// Returns the [ExportResult] on success; throws on failure.
  Future<ExportResult> exportEncryptedBackup({required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(exportEncryptedJsonUseCaseProvider);
      final result = await useCase.call(password: password);
      if (!ref.mounted) return result;
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Restores the database from an encrypted JSON backup file.
  ///
  /// ⚠️ Destructive: overwrites all existing data.
  Future<void> importEncryptedBackup(
    List<int> fileBytes, {
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(importEncryptedJsonUseCaseProvider);
      await useCase.call(fileBytes, password: password);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Exports all transactions to a CSV file.
  Future<ExportResult> exportTransactionsCsv() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(exportTransactionsCsvUseCaseProvider);
      final result = await useCase.call();
      if (!ref.mounted) return result;
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Exports the transactions as a PDF report.
  Future<ExportResult> exportMonthlyPdf({
    required PdfExportDateRange dateRange,
    String? customMonthLabel,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = ref.read(exportMonthlyPdfUseCaseProvider);
      final currency = state.profile?.defaultCurrency ?? 'EUR';
      final result = await useCase.call(
        targetCurrency: currency,
        dateRange: dateRange,
        customMonthLabel: customMonthLabel,
      );
      if (!ref.mounted) return result;
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
