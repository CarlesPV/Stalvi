import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_export_service.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';
import 'package:stalvi/domain/usecases/pdf_export_date_range.dart';
import '../../providers/repository_providers.dart';
import '../../providers/statistics_providers.dart';

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

class ProfileSettingsController extends StateNotifier<ProfileSettingsState> {
  final Ref _ref;

  ProfileSettingsController(this._ref) : super(const ProfileSettingsState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(profileRepositoryProvider);
      final profile = await repo.getFirstProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUsername(String username) async {
    final currentProfile = state.profile;
    if (currentProfile == null) return;
    if (username.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(profileRepositoryProvider);
      final updatedProfile = currentProfile.copyWith(
        username: username,
        modifiedAt: DateTime.now(),
      );
      await repo.updateProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
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
      final repo = _ref.read(profileRepositoryProvider);
      final updatedProfile = currentProfile.copyWith(
        defaultCurrency: newCurrency,
        modifiedAt: DateTime.now(),
      );
      await repo.updateProfile(updatedProfile);
      _ref.invalidate(defaultProfileProvider);
      _ref.invalidate(statisticsCurrencyProvider);
      _ref.invalidate(periodSummaryProvider);
      _ref.invalidate(topExpenseCategoriesProvider);
      _ref.invalidate(topIncomeCategoriesProvider);
      _ref.invalidate(globalBalanceProvider);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
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
      final useCase = _ref.read(updateCredentialsUseCaseProvider);
      await useCase.verifyOldPin(oldPin);
      state = state.copyWith(
        isLoading: false,
        pinChangeStep: PinChangeStep.enterNew,
        failedAttempts: 0,
      );
    } catch (e) {
      final newAttempts = state.failedAttempts + 1;
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
      final useCase = _ref.read(updateCredentialsUseCaseProvider);
      await useCase
          .execute(UpdateCredentialsParams(oldPin: oldPin, newPin: newPin));
      state = state.copyWith(
        isLoading: false,
        pinChangeStep: PinChangeStep.verifyOld,
      );
    } catch (e) {
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
      final useCase = _ref.read(updateCredentialsUseCaseProvider);
      await useCase.verifyOldPin(pin);
      state = state.copyWith(
        isLoading: false,
        failedDeleteAttempts: 0,
      );
      return true;
    } catch (e) {
      final newAttempts = state.failedDeleteAttempts + 1;
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
      final useCase = _ref.read(wipeAllDataUseCaseProvider);
      await useCase.execute();
      state = state.copyWith(isLoading: false);
    } catch (e) {
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
      final useCase = _ref.read(exportEncryptedJsonUseCaseProvider);
      final result = await useCase.call(password: password);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
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
      final useCase = _ref.read(importEncryptedJsonUseCaseProvider);
      await useCase.call(fileBytes, password: password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Exports all transactions to a CSV file.
  Future<ExportResult> exportTransactionsCsv() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = _ref.read(exportTransactionsCsvUseCaseProvider);
      final result = await useCase.call();
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Exports the transactions as a PDF report.
  Future<ExportResult> exportMonthlyPdf({
    required PdfExportDateRange dateRange,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = _ref.read(exportMonthlyPdfUseCaseProvider);
      final currency = state.profile?.defaultCurrency ?? 'EUR';
      final result = await useCase.call(
        targetCurrency: currency,
        dateRange: dateRange,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final profileSettingsControllerProvider =
    StateNotifierProvider<ProfileSettingsController, ProfileSettingsState>(
        (ref) {
  return ProfileSettingsController(ref);
});
