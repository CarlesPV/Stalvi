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

    test('Formats budget exceeded payload correctly for all languages', () {
      final en = NotificationService.formatBudgetExceededNotification(
        languageCode: 'en',
      );
      expect(en.title, equals('Budget Limit Exceeded'));
      expect(en.body, equals('You have exceeded your budget limit.'));

      final es = NotificationService.formatBudgetExceededNotification(
        languageCode: 'es',
      );
      expect(es.title, equals('Presupuesto superado'));
      expect(es.body, equals('Has superado el límite de tu presupuesto.'));

      final ca = NotificationService.formatBudgetExceededNotification(
        languageCode: 'ca',
      );
      expect(ca.title, equals('Pressupost superat'));
      expect(ca.body, equals('Heu superat el límit del vostre pressupost.'));
    });

    test('Formats goal reached payload correctly for all languages', () {
      final en =
          NotificationService.formatGoalReachedNotification(languageCode: 'en');
      expect(en.title, equals('Savings Goal Reached'));
      expect(
        en.body,
        equals('Congratulations! You have reached your savings goal.'),
      );

      final es =
          NotificationService.formatGoalReachedNotification(languageCode: 'es');
      expect(es.title, equals('Meta de ahorro alcanzada'));
      expect(es.body, equals('¡Felicidades! Has alcanzado tu meta de ahorro.'));

      final ca =
          NotificationService.formatGoalReachedNotification(languageCode: 'ca');
      expect(ca.title, equals('Objectiu d\'estalvi assolit'));
      expect(
        ca.body,
        equals('Felicitats! Heu assolit el vostre objectiu d\'estalvi.'),
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

    test(
        'showBudgetExceededNotification calls plugin show method with correct arguments',
        () async {
      when(
        mockPlugin.show(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async {});

      await service.showBudgetExceededNotification(
        languageCode: 'es',
        notificationId: 9999,
      );

      verify(
        mockPlugin.show(
          9999,
          'Presupuesto superado',
          'Has superado el límite de tu presupuesto.',
          any,
        ),
      ).called(1);
    });

    test(
        'showGoalReachedNotification calls plugin show method with correct arguments',
        () async {
      when(
        mockPlugin.show(
          any,
          any,
          any,
          any,
        ),
      ).thenAnswer((_) async {});

      await service.showGoalReachedNotification(
        languageCode: 'ca',
        notificationId: 8888,
      );

      verify(
        mockPlugin.show(
          8888,
          'Objectiu d\'estalvi assolit',
          'Felicitats! Heu assolit el vostre objectiu d\'estalvi.',
          any,
        ),
      ).called(1);
    });
  });
}
