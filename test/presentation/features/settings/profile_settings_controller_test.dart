import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/entities/profile.dart';
import 'package:konta/domain/repositories/i_profile_repository.dart';
import 'package:konta/domain/usecases/update_credentials_usecase.dart';
import 'package:konta/presentation/features/settings/profile_settings_controller.dart';
import 'package:konta/presentation/providers/repository_providers.dart';

class FakeProfileRepository implements IProfileRepository {
  @override
  Future<Profile> getFirstProfile() async {
    return Profile(
      id: '1',
      name: 'Test User',
      username: 'test_user',
      password: '',
      defaultCurrency: 'EUR',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUpdateCredentialsUseCase implements UpdateCredentialsUseCase {
  bool shouldFailVerify = false;

  @override
  Future<void> verifyOldPin(String oldPin) async {
    if (shouldFailVerify) {
      throw const ValidationException(message: 'old_pin_incorrect');
    }
  }

  @override
  Future<void> execute(UpdateCredentialsParams params) async {
    // success
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeProfileRepository fakeProfileRepository;
  late FakeUpdateCredentialsUseCase fakeUpdateCredentialsUseCase;
  late ProviderContainer container;

  setUp(() {
    fakeProfileRepository = FakeProfileRepository();
    fakeUpdateCredentialsUseCase = FakeUpdateCredentialsUseCase();

    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        updateCredentialsUseCaseProvider
            .overrideWithValue(fakeUpdateCredentialsUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileSettingsController PIN change flow', () {
    test('initial state should be PinChangeState.enterOld', () async {
      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeState, PinChangeState.enterOld);
    });

    test('verifyOldPin moves state to enterNew on success', () async {
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      await controller.verifyOldPin('1234');

      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeState, PinChangeState.enterNew);
      expect(state.error, isNull);
    });

    test('verifyOldPin keeps state at enterOld and sets error on failure',
        () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);

      try {
        await controller.verifyOldPin('wrong');
        fail('Should throw ValidationException');
      } catch (e) {
        expect(e, isA<ValidationException>());
      }

      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeState, PinChangeState.enterOld);
      expect(state.error, contains('old_pin_incorrect'));
    });

    test('changePin sets state back to enterOld on success', () async {
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      await controller.verifyOldPin('1234');

      expect(container.read(profileSettingsControllerProvider).pinChangeState,
          PinChangeState.enterNew);

      await controller.changePin('1234', '5678');

      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeState, PinChangeState.enterOld);
      expect(state.error, isNull);
    });
  });
}
