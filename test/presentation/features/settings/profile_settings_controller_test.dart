import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';
import 'package:stalvi/presentation/features/settings/profile_settings_controller.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/statistics_providers.dart';
import 'package:stalvi/domain/entities/period_summary.dart';

class FakeProfileRepository implements IProfileRepository {
  Profile _profile = Profile(
    id: '1',
    name: 'Test User',
    username: 'test_user',
    password: '',
    defaultCurrency: 'EUR',
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  @override
  Future<Profile> getFirstProfile() async {
    return _profile;
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    _profile = profile;
    return _profile;
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

  group('ProfileSettingsController delete all data PIN flow', () {
    test('initial state failedDeleteAttempts should be 0', () async {
      final state = container.read(profileSettingsControllerProvider);
      expect(state.failedDeleteAttempts, 0);
    });

    test('verifyDeleteDataPin returns true on success', () async {
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      final ok = await controller.verifyDeleteDataPin('1234');

      expect(ok, isTrue);
      final state = container.read(profileSettingsControllerProvider);
      expect(state.failedDeleteAttempts, 0);
    });

    test('verifyDeleteDataPin returns false and increments attempts on failure',
        () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);
      final ok = await controller.verifyDeleteDataPin('wrong');

      expect(ok, isFalse);
      final state = container.read(profileSettingsControllerProvider);
      expect(state.failedDeleteAttempts, 1);
    });

    test('verifyDeleteDataPin blocks and returns false after 6 failed attempts',
        () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);

      for (int i = 0; i < 6; i++) {
        await controller.verifyDeleteDataPin('wrong');
      }

      final state = container.read(profileSettingsControllerProvider);
      expect(state.failedDeleteAttempts, 6);

      final ok = await controller.verifyDeleteDataPin('1234');
      expect(ok, isFalse);
    });

    test('resetDeleteDataState resets failedDeleteAttempts if less than 6',
        () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);

      await controller.verifyDeleteDataPin('wrong');
      expect(
        container.read(profileSettingsControllerProvider).failedDeleteAttempts,
        1,
      );

      controller.resetDeleteDataState();
      expect(
        container.read(profileSettingsControllerProvider).failedDeleteAttempts,
        0,
      );
    });

    test(
        'resetDeleteDataState does not reset failedDeleteAttempts if already 6 or more',
        () async {
      fakeUpdateCredentialsUseCase.shouldFailVerify = true;
      final controller =
          container.read(profileSettingsControllerProvider.notifier);

      for (int i = 0; i < 6; i++) {
        await controller.verifyDeleteDataPin('wrong');
      }
      expect(
        container.read(profileSettingsControllerProvider).failedDeleteAttempts,
        6,
      );

      controller.resetDeleteDataState();
      expect(
        container.read(profileSettingsControllerProvider).failedDeleteAttempts,
        6,
      );
    });
  });

  group('ProfileSettingsController currency update', () {
    test('updateCurrency updates profile and invalidates dashboard providers',
        () async {
      int periodSummaryBuildCount = 0;
      int dashboardPeriodSummaryBuildCount = 0;

      final testContainer = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          updateCredentialsUseCaseProvider
              .overrideWithValue(fakeUpdateCredentialsUseCase),
          periodSummaryProvider.overrideWith((ref) {
            periodSummaryBuildCount++;
            return const AsyncData(
              PeriodSummary(totalIncome: 0, totalExpense: 0),
            );
          }),
          dashboardPeriodSummaryProvider.overrideWith((ref) {
            dashboardPeriodSummaryBuildCount++;
            return const AsyncData(
              PeriodSummary(totalIncome: 0, totalExpense: 0),
            );
          }),
        ],
      );

      final controller =
          testContainer.read(profileSettingsControllerProvider.notifier);

      // Wait for initial profile load
      await Future.delayed(Duration.zero);

      // Initialize the providers so we can track if they get invalidated
      testContainer.read(periodSummaryProvider);
      testContainer.read(dashboardPeriodSummaryProvider);

      expect(periodSummaryBuildCount, 1);
      expect(dashboardPeriodSummaryBuildCount, 1);

      // Update currency
      await controller.updateCurrency('USD');

      // The profile should be updated
      final state = testContainer.read(profileSettingsControllerProvider);
      expect(state.profile?.defaultCurrency, 'USD');

      // Since they were invalidated and not listened to, they are disposed.
      // Reading them again will trigger a new build.
      testContainer.read(periodSummaryProvider);
      testContainer.read(dashboardPeriodSummaryProvider);

      expect(periodSummaryBuildCount, 2);
      expect(dashboardPeriodSummaryBuildCount, 2);

      testContainer.dispose();
    });
  });
}
