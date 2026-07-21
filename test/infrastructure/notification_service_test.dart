import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stalvi/infrastructure/services/notification_service.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Payload Formatting', () {
    test('Formats English payload correctly', () {
      final payload = NotificationService.formatAutoTxNotification(
        transactionName: 'Monthly Rent',
        languageCode: 'en',
      );

      expect(payload.title, equals('Automatic Transaction Created'));
      expect(
        payload.body,
        equals('Transaction Monthly Rent has been completed successfully.'),
      );
    });

    test('Formats Spanish payload correctly', () {
      final payload = NotificationService.formatAutoTxNotification(
        transactionName: 'Alquiler mensual',
        languageCode: 'es',
      );

      expect(payload.title, equals('Transacción automática creada'));
      expect(
        payload.body,
        equals('La transacción Alquiler mensual se ha completado con éxito.'),
      );
    });

    test('Formats Catalan payload correctly', () {
      final payload = NotificationService.formatAutoTxNotification(
        transactionName: 'Lloguer mensual',
        languageCode: 'ca',
      );

      expect(payload.title, equals('Transacció automàtica creada'));
      expect(
        payload.body,
        equals('La transacció Lloguer mensual s\'ha completat amb èxit.'),
      );
    });

    test('Defaults to English if unknown language code is provided', () {
      final payload = NotificationService.formatAutoTxNotification(
        transactionName: 'Electricity Bill',
        languageCode: 'fr',
      );

      expect(payload.title, equals('Automatic Transaction Created'));
      expect(
        payload.body,
        equals('Transaction Electricity Bill has been completed successfully.'),
      );
    });
  });

  group('NotificationService Dispatch', () {
    late MockFlutterLocalNotificationsPlugin mockPlugin;
    late NotificationService service;

    setUp(() {
      mockPlugin = MockFlutterLocalNotificationsPlugin();
      service = NotificationService(plugin: mockPlugin);
      when(mockPlugin.initialize(any)).thenAnswer((_) async => true);
    });

    test(
        'showAutomaticTransactionNotification calls plugin show method with correct arguments',
        () async {
      when(
        mockPlugin.show(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async {});

      await service.showAutomaticTransactionNotification(
        transactionName: 'Gym Membership',
        languageCode: 'es',
        notificationId: 12345,
      );

      verify(
        mockPlugin.show(
          12345,
          'Transacción automática creada',
          'La transacción Gym Membership se ha completado con éxito.',
          any,
        ),
      ).called(1);
    });
  });
}
