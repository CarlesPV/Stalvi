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
    test('initial state should be PinChangeStep.verifyOld', () async {
      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeStep, PinChangeStep.verifyOld);
      expect(state.failedAttempts, 0);
    });

    test('verifyOldPin moves state to enterNew on success', () async {
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      await controller.verifyOldPin('1234');

      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeStep, PinChangeStep.enterNew);
      expect(state.error, isNull);
      expect(state.failedAttempts, 0);
    });

    test(
        'verifyOldPin keeps state at verifyOld, sets error, and increments failedAttempts on failure',
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
      expect(state.pinChangeStep, PinChangeStep.verifyOld);
      expect(state.error, contains('old_pin_incorrect'));
      expect(state.failedAttempts, 1);
    });

    test('changePin sets state back to verifyOld on success', () async {
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      await controller.verifyOldPin('1234');

      expect(
        container.read(profileSettingsControllerProvider).pinChangeStep,
        PinChangeStep.enterNew,
      );

      await controller.changePin('1234', '5678');

      final state = container.read(profileSettingsControllerProvider);
      expect(state.pinChangeStep, PinChangeStep.verifyOld);
      expect(state.error, isNull);
    });

    test('verifyOldPin blocks after 6 failed attempts', () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);

      // Fail 6 times
      for (int i = 0; i < 6; i++) {
        try {
          await controller.verifyOldPin('wrong');
        } catch (_) {}
      }

      final state = container.read(profileSettingsControllerProvider);
      expect(state.failedAttempts, 6);

      // 7th attempt should throw generic exception
      try {
        await controller.verifyOldPin('wrong');
        fail('Should throw Exception');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Maximum PIN attempts reached'));
      }
    });
  });
}
