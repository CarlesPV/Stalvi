import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/usecases/update_credentials_usecase.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

enum PinChangeStep { verifyOld, enterNew }

class ProfileSettingsState {
  final Profile? profile;
  final bool isLoading;
  final String? error;
  final PinChangeStep pinChangeStep;
  final int failedAttempts;

  const ProfileSettingsState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.pinChangeStep = PinChangeStep.verifyOld,
    this.failedAttempts = 0,
  });

  ProfileSettingsState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
    PinChangeStep? pinChangeStep,
    int? failedAttempts,
  }) {
    return ProfileSettingsState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pinChangeStep: pinChangeStep ?? this.pinChangeStep,
      failedAttempts: failedAttempts ?? this.failedAttempts,
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
}

final profileSettingsControllerProvider =
    StateNotifierProvider<ProfileSettingsController, ProfileSettingsState>(
        (ref) {
  return ProfileSettingsController(ref);
});
