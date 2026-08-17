import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';
import 'package:stalvi/domain/usecases/update_credentials_usecase.dart';

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

void main() {
  late MockSecureStorageManager mockSecureStorageManager;
  late UpdateCredentialsUseCase useCase;

  setUp(() {
    mockSecureStorageManager = MockSecureStorageManager();
    useCase = UpdateCredentialsUseCase(mockSecureStorageManager);
  });

  String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  test('should successfully update PIN when old PIN matches', () async {
    const oldPin = '1234';
    const newPin = '5678';
    final oldPinHash = hashPin(oldPin);

    when(
      () => mockSecureStorageManager.getPinHash(),
    ).thenAnswer((_) async => oldPinHash);
    when(
      () => mockSecureStorageManager.savePinHash(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockSecureStorageManager.savePinLength(any()),
    ).thenAnswer((_) async => {});

    await useCase.execute(
      const UpdateCredentialsParams(oldPin: oldPin, newPin: newPin),
    );

    verify(
      () => mockSecureStorageManager.savePinHash(hashPin(newPin)),
    ).called(1);
    verify(
      () => mockSecureStorageManager.savePinLength(newPin.length),
    ).called(1);
  });

  test('should throw ValidationException when old PIN is incorrect', () async {
    const oldPin = '1234';
    const wrongPin = '0000';
    const newPin = '5678';
    final oldPinHash = hashPin(oldPin);

    when(
      () => mockSecureStorageManager.getPinHash(),
    ).thenAnswer((_) async => oldPinHash);

    expect(
      () => useCase.execute(
        const UpdateCredentialsParams(oldPin: wrongPin, newPin: newPin),
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('should throw ValidationException when new PIN is too short', () async {
    const oldPin = '1234';
    const newPin = '123'; // < 4 digits
    final oldPinHash = hashPin(oldPin);

    when(
      () => mockSecureStorageManager.getPinHash(),
    ).thenAnswer((_) async => oldPinHash);

    expect(
      () => useCase.execute(
        const UpdateCredentialsParams(oldPin: oldPin, newPin: newPin),
      ),
      throwsA(isA<ValidationException>()),
    );
  });
}
