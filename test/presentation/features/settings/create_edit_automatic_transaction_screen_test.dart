import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/account.dart';
import 'package:stalvi/domain/entities/account_type.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/entities/automatic_transaction.dart';
import 'package:stalvi/presentation/features/settings/create_edit_automatic_transaction_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:stalvi/presentation/providers/automatic_transactions_providers.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';
import 'package:stalvi/domain/usecases/automatic_transactions/crud_automatic_transactions_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/security/secure_storage_manager.dart';

class MockCreateAutomaticTransactionUseCase extends Mock
    implements CreateAutomaticTransactionUseCase {}

class MockUpdateAutomaticTransactionUseCase extends Mock
    implements UpdateAutomaticTransactionUseCase {}

class MockSecureStorageManager extends Mock implements SecureStorageManager {}

class FakeAutomaticTransaction extends Fake implements AutomaticTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAutomaticTransaction());
  });

  late MockCreateAutomaticTransactionUseCase mockCreateUseCase;
  late MockUpdateAutomaticTransactionUseCase mockUpdateUseCase;
  late MockSecureStorageManager mockSecureStorage;

  final testAccount = Account(
    id: 'acc_1',
    userId: 'user_1',
    name: 'My Wallet',
    type: AccountType.cash,
    initialBalance: 100.0,
    currency: 'EUR',
    color: '#000000',
    icon: 'wallet',
    isDefault: true,
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testCategory = Category(
    id: 'cat_1',
    name: 'Food',
    associatedType: CategoryType.expense,
    icon: 'restaurant',
    color: '#FF0000',
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testTag = Tag(
    id: 'tag_1',
    name: 'Subscriptions',
    isDeleted: false,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  final testProfile = Profile(
    id: 'user_1',
    name: 'Test User',
    username: 'test_user',
    password: '',
    defaultCurrency: 'EUR',
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  setUp(() {
    mockCreateUseCase = MockCreateAutomaticTransactionUseCase();
    mockUpdateUseCase = MockUpdateAutomaticTransactionUseCase();
    mockSecureStorage = MockSecureStorageManager();
    when(() => mockSecureStorage.getUserLocale()).thenAnswer((_) async => 'en');
  });

  Widget createTestableWidget({AutomaticTransaction? transaction}) {
    return ProviderScope(
      overrides: [
        createAutomaticTransactionUseCaseProvider
            .overrideWithValue(mockCreateUseCase),
        updateAutomaticTransactionUseCaseProvider
            .overrideWithValue(mockUpdateUseCase),
        accountsListProvider.overrideWith((ref) => Stream.value([testAccount])),
        categoriesListProvider
            .overrideWith((ref) => Stream.value([testCategory])),
        tagsListProvider
            .overrideWith((ref) async => [testTag]),
        defaultProfileProvider.overrideWith((ref) => testProfile),
        secureStorageProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreateEditAutomaticTransactionScreen(
          transactionToEdit: transaction,
        ),
      ),
    );
  }

  testWidgets('shows validation errors when saving empty form',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Transaction');
    await tester.scrollUntilVisible(
      saveButton,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    expect(
      find.text('Please enter a valid amount greater than 0'),
      findsOneWidget,
    ); // Depends on actual l10n.errorInvalidAmount
    // Note: Account is pre-filled, so it doesn't show an error.
    expect(
      find.text('Please select a category'),
      findsOneWidget,
    ); // Depends on actual l10n.errorCategoryRequired
  });

  testWidgets('clears validation error when valid name is entered',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Transaction');
    await tester.scrollUntilVisible(
      saveButton,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);

    final nameField = find.byType(TextField).at(1);
    await tester.scrollUntilVisible(
      nameField,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(nameField, 'Spotify');
    await tester.pump();

    expect(find.text('Name is required'), findsNothing);
  });

  testWidgets('displays validation error for negative amount',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final amountField = find.byType(TextField).first;
    await tester.scrollUntilVisible(
      amountField,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(amountField, '-10');

    final saveButton = find.text('Save Transaction');
    await tester.scrollUntilVisible(
      saveButton,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(
      find.text('Please enter a valid amount greater than 0'),
      findsOneWidget,
    );
  });

  testWidgets(
      'recurrence selector sheet renders without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final recurrenceTile = find.text('Recurrence');
    await tester.scrollUntilVisible(
      recurrenceTile,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(recurrenceTile);
    await tester.pumpAndSettle();

    expect(find.text('Select Recurrence'), findsOneWidget);
  });

  testWidgets(
      'shows validation error for invalid custom recurrence day directly below field',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open recurrence selector
    final recurrenceTile = find.text('Recurrence');
    await tester.scrollUntilVisible(
      recurrenceTile,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(recurrenceTile);
    await tester.pumpAndSettle();

    // Tap Day of month radio
    final dayOfMonthRadio = find.text('Day X of month');
    await tester.tap(dayOfMonthRadio);
    await tester.pumpAndSettle();

    // Enter invalid day like 32
    final customTextField = find.byType(TextField).last;
    await tester.enterText(customTextField, '32');
    await tester.pumpAndSettle();

    // Tap apply
    final applyButton = find.text('Apply');
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    // The validation error should appear
    expect(find.text('Invalid day of month (must be 1-31)'), findsOneWidget);
  });

  testWidgets(
      'CreateEditAutomaticTransactionScreen places Label field immediately below Category field',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final categoryTile = find.text('Category');
    final tagTile = find.text('Tag (Optional)');
    final currencyTile = find.text('Currency');
    final recurrenceTile = find.text('Recurrence');

    expect(categoryTile, findsOneWidget);
    expect(tagTile, findsOneWidget);
    expect(currencyTile, findsOneWidget);
    expect(recurrenceTile, findsOneWidget);

    final categoryY = tester.getTopLeft(categoryTile).dy;
    final tagY = tester.getTopLeft(tagTile).dy;
    final currencyY = tester.getTopLeft(currencyTile).dy;
    final recurrenceY = tester.getTopLeft(recurrenceTile).dy;

    expect(categoryY < tagY, isTrue, reason: 'Label/Tag field must be below Category field');
    expect(tagY < currencyY, isTrue, reason: 'Label/Tag field must be above Currency field');
    expect(currencyY < recurrenceY, isTrue, reason: 'Currency field must be above Recurrence field');
  });

  testWidgets(
      'selecting a label in CreateEditAutomaticTransactionScreen updates the form state tile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    final tagTile = find.text('Tag (Optional)');
    await tester.scrollUntilVisible(
      tagTile,
      50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tagTile);
    await tester.pumpAndSettle();

    expect(find.text('Select Tag'), findsOneWidget);
    final tagOption = find.text('Subscriptions');
    expect(tagOption, findsOneWidget);

    await tester.tap(tagOption);
    await tester.pumpAndSettle();

    expect(find.text('Subscriptions'), findsOneWidget);
  });
}
