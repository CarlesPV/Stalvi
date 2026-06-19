import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/savings_goal.dart';
import 'package:stalvi/domain/repositories/i_savings_goal_repository.dart';
import 'package:stalvi/domain/usecases/create_savings_goal_usecase.dart';

class MockSavingsGoalRepository extends Mock
    implements ISavingsGoalRepository {}

class FakeSavingsGoal extends Fake implements SavingsGoal {}

void main() {
  late CreateSavingsGoalUseCase usecase;
  late MockSavingsGoalRepository mockSavingsGoalRepo;

  final now = DateTime.now();

  setUpAll(() {
    registerFallbackValue(FakeSavingsGoal());
  });

  setUp(() {
    mockSavingsGoalRepo = MockSavingsGoalRepository();
    usecase = CreateSavingsGoalUseCase(mockSavingsGoalRepo);
  });

  final validParams = CreateSavingsGoalParams(
    id: 'goal_1',
    name: 'New Car',
    targetAmount: 2000000, // 20k
    targetDate: now.add(const Duration(days: 365)),
    color: '#000000',
    icon: 'car',
  );

  group('CreateSavingsGoalUseCase', () {
    test('should successfully create savings goal', () async {
      when(() => mockSavingsGoalRepo.createSavingsGoal(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as SavingsGoal);

      final result = await usecase.execute(validParams);

      expect(result.id, validParams.id);
      expect(result.targetAmount, validParams.targetAmount);
      verify(() => mockSavingsGoalRepo.createSavingsGoal(any())).called(1);
    });

    test('should throw validation error when target amount is 0', () async {
      final params = CreateSavingsGoalParams(
        id: 'goal_1',
        name: 'New Car',
        targetAmount: 0,
        targetDate: now.add(const Duration(days: 365)),
        color: '#000000',
        icon: 'car',
      );

      final call = usecase.execute(params);
      await expectLater(
        () => call,
        throwsA(
          isA<ValidationException>()
              .having((e) => e.code, 'code', 'INVALID_AMOUNT'),
        ),
      );
    });

    test('should throw validation error when target date is in the past',
        () async {
      final params = CreateSavingsGoalParams(
        id: 'goal_1',
        name: 'New Car',
        targetAmount: 2000000,
        targetDate: now.subtract(const Duration(days: 1)),
        color: '#000000',
        icon: 'car',
      );

      final call = usecase.execute(params);
      await expectLater(
        () => call,
        throwsA(
          isA<ValidationException>()
              .having((e) => e.code, 'code', 'INVALID_TARGET_DATE'),
        ),
      );
    });

    test('should successfully create savings goal without target date',
        () async {
      when(() => mockSavingsGoalRepo.createSavingsGoal(any()))
          .thenAnswer((inv) async => inv.positionalArguments[0] as SavingsGoal);

      const params = CreateSavingsGoalParams(
        id: 'goal_1',
        name: 'New Car',
        targetAmount: 2000000,
        targetDate: null,
        color: '#000000',
        icon: 'car',
      );

      final result = await usecase.execute(params);

      expect(result.targetDate, isNull);
      verify(() => mockSavingsGoalRepo.createSavingsGoal(any())).called(1);
    });
  });
}
