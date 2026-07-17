import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/profile.dart';
import 'package:stalvi/domain/repositories/i_profile_repository.dart';
import 'package:stalvi/presentation/features/settings/data_management_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stalvi/infrastructure/services/biometric_auth_service.dart';

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class FakeFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    int compressionQuality = 30,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([
      PlatformFile(
        path: '/mock/path/backup.json',
        name: 'backup.json',
        size: 100,
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
    ]);
  }
}

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

void main() {
  late FakeProfileRepository fakeProfileRepository;
  late MockBiometricAuthService mockBiometricAuth;

  setUp(() {
    fakeProfileRepository = FakeProfileRepository();
    mockBiometricAuth = MockBiometricAuthService();

    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => false);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => false);
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
        biometricAuthServiceProvider.overrideWithValue(mockBiometricAuth),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DataManagementScreen(),
      ),
    );
  }

  testWidgets('renders all import and export tiles',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('Data Management'), findsOneWidget);

    // Verify presence of list tiles
    expect(find.text('Export Encrypted Backup'), findsOneWidget);
    expect(find.text('Import / Restore Backup'), findsOneWidget);
    expect(find.text('Export Transactions (CSV)'), findsOneWidget);
    expect(find.text('Export Monthly Report (PDF)'), findsOneWidget);

    // Verify presence of correct icons
    expect(find.byIcon(Icons.backup_rounded), findsOneWidget);
    expect(find.byIcon(Icons.restore_rounded), findsOneWidget);
    expect(find.byIcon(Icons.table_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);
  });

  testWidgets(
      'Export password dialog renders without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => true);
    when(
      () => mockBiometricAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        lockedOutMessage: any(named: 'lockedOutMessage'),
        authFailedMessage: any(named: 'authFailedMessage'),
        unknownErrorMessage: any(named: 'unknownErrorMessage'),
        signInTitle: any(named: 'signInTitle'),
        cancelButton: any(named: 'cancelButton'),
      ),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export Encrypted Backup'));
    await tester.pumpAndSettle();

    expect(find.text('Set Backup Password'), findsOneWidget);
  });

  testWidgets(
      'Import confirmation and password dialogs render without overflow on small screens',
      (WidgetTester tester) async {
    FilePicker.platform = FakeFilePicker();
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => mockBiometricAuth.isBiometricsEnabled())
        .thenAnswer((_) async => true);
    when(() => mockBiometricAuth.isBiometricAvailable())
        .thenAnswer((_) async => true);
    when(
      () => mockBiometricAuth.authenticate(
        localizedReason: any(named: 'localizedReason'),
        lockedOutMessage: any(named: 'lockedOutMessage'),
        authFailedMessage: any(named: 'authFailedMessage'),
        unknownErrorMessage: any(named: 'unknownErrorMessage'),
        signInTitle: any(named: 'signInTitle'),
        cancelButton: any(named: 'cancelButton'),
      ),
    ).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import / Restore Backup'));
    await tester.pumpAndSettle();
    // Verify confirmation dialog is shown
    expect(find.text('Restore Backup?'), findsOneWidget);

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Backup Password'), findsOneWidget);
  });
}
