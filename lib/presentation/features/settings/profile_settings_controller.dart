import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/usecases/update_credentials_usecase.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

enum PinChangeState { enterOld, enterNew }

class ProfileSettingsState {
  final Profile? profile;
  final bool isLoading;
  final String? error;
  final PinChangeState pinChangeState;

  const ProfileSettingsState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.pinChangeState = PinChangeState.enterOld,
  });

  ProfileSettingsState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
    PinChangeState? pinChangeState,
  }) {
    return ProfileSettingsState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pinChangeState: pinChangeState ?? this.pinChangeState,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final useCase = _ref.read(updateCredentialsUseCaseProvider);
      await useCase.verifyOldPin(oldPin);
      state = state.copyWith(
        isLoading: false,
        pinChangeState: PinChangeState.enterNew,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
        pinChangeState: PinChangeState.enterOld,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void resetPinChangeState() {
    state = state.copyWith(
      pinChangeState: PinChangeState.enterOld,
      error: null,
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
