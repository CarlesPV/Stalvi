import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:stalvi/domain/usecases/initialize_default_data_usecase.dart';

import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';

class MockCategoryRepository extends Mock implements ICategoryRepository {}

class MockTagRepository extends Mock implements ITagRepository {}

class FakeCategory extends Fake implements Category {}

class FakeTag extends Fake implements Tag {}

void main() {
  late InitializeDefaultDataUseCase useCase;
  late MockCategoryRepository mockCategoryRepository;
  late MockTagRepository mockTagRepository;

  setUpAll(() {
    registerFallbackValue(FakeCategory());
    registerFallbackValue(FakeTag());
  });

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    mockTagRepository = MockTagRepository();
    useCase = InitializeDefaultDataUseCase(
      mockCategoryRepository,
      mockTagRepository,
    );

    // Default stubbing for category calls
    when(
      () => mockCategoryRepository.getAllCategories(),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => mockCategoryRepository.getCategoryById(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockCategoryRepository.deleteCategory(any()),
    ).thenAnswer((_) async {});
    when(() => mockCategoryRepository.createCategory(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Category,
    );
    when(() => mockCategoryRepository.updateCategory(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Category,
    );

    // Default stubbing for tag calls
    when(() => mockTagRepository.getAllTags()).thenAnswer((_) async => <Tag>[]);
    when(
      () => mockTagRepository.getTagById(any()),
    ).thenAnswer((_) async => null);
    when(() => mockTagRepository.deleteTag(any())).thenAnswer((_) async {});
    when(() => mockTagRepository.createTag(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Tag,
    );
    when(() => mockTagRepository.updateTag(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as Tag,
    );
    when(
      () => mockCategoryRepository.deleteCategoryPermanently(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockTagRepository.deleteTagPermanently(any()),
    ).thenAnswer((_) async {});
  });

  group('InitializeDefaultDataUseCase Unit Tests', () {
    test(
      'should seed default typical categories and typical tags in selected locale',
      () async {
        // Arrange
        const userId = 'user_123';
        const locale = 'es';

        // Act
        await useCase.execute(userId: userId, locale: locale);

        // Assert
        final capturedCategories = verify(
          () => mockCategoryRepository.createCategory(captureAny()),
        ).captured;
        expect(capturedCategories.length, 18);

        final names =
            capturedCategories.map((c) => (c as Category).name).toList();
        expect(names, contains('Comida'));
        expect(names, contains('Transporte'));
        expect(names, contains('Salario'));
        expect(names, contains('Vivienda'));
        expect(names, contains('Servicios'));
        expect(names, contains('Entretenimiento'));
        expect(names, contains('Compras'));
        expect(names, contains('Salud'));
        expect(names, contains('Educación'));
        expect(names, contains('Suscripciones'));
        expect(names, contains('Viajes'));
        expect(names, contains('Inversiones'));
        expect(names, contains('Regalos'));
        expect(names, contains('Mascota'));
        expect(names, contains('Cuidado Personal'));
        expect(names, contains('Deporte'));
        expect(names, contains('Venta'));
        expect(names, contains('Reembolso'));

        final capturedTags = verify(
          () => mockTagRepository.createTag(captureAny()),
        ).captured;
        expect(capturedTags.length, 6);

        final tagNames = capturedTags.map((t) => (t as Tag).name).toList();
        expect(tagNames, contains('Viaje de verano'));
        expect(tagNames, contains('Evento'));
        expect(tagNames, contains('Proyecto'));
        expect(tagNames, contains('Boda'));
        expect(tagNames, contains('Cumpleaños'));
        expect(tagNames, contains('Viaje de negocios'));
      },
    );

    test(
      'should seed categories and tags in English when no locale is specified',
      () async {
        // Arrange
        const userId = 'user_123';

        // Act
        await useCase.execute(userId: userId);

        // Assert
        final capturedCategories = verify(
          () => mockCategoryRepository.createCategory(captureAny()),
        ).captured;
        expect(capturedCategories.length, 18);
        final names =
            capturedCategories.map((c) => (c as Category).name).toList();
        expect(names, contains('Food'));
        expect(names, contains('Transport'));
        expect(names, contains('Salary'));
      },
    );

    test(
        'should permanently delete duplicate/old default categories and tags '
        'instead of soft-deleting them (ensuring clean recycle bin)', () async {
      // Arrange
      const userId = 'user_123';

      // Setup duplicate categories and tags with old random UUIDs
      final oldCategory = Category(
        id: 'old-random-uuid-cat',
        name: 'Food',
        associatedType: CategoryType.expense,
        icon: 'restaurant',
        color: '#FF9800',
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final oldTag = Tag(
        id: 'old-random-uuid-tag',
        name: 'Summer Trip',
        isDeleted: false,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      when(
        () => mockCategoryRepository.getAllCategories(),
      ).thenAnswer((_) async => [oldCategory]);
      when(
        () => mockTagRepository.getAllTags(),
      ).thenAnswer((_) async => [oldTag]);

      // Act
      await useCase.execute(userId: userId, locale: 'en');

      // Assert
      // Verify no soft deletes were called
      verifyNever(() => mockCategoryRepository.deleteCategory(any()));
      verifyNever(() => mockTagRepository.deleteTag(any()));

      // Verify permanent deletes were called instead
      verify(
        () => mockCategoryRepository.deleteCategoryPermanently(
          'old-random-uuid-cat',
        ),
      ).called(1);
      verify(
        () => mockTagRepository.deleteTagPermanently('old-random-uuid-tag'),
      ).called(1);
    });

    test(
      'should ensure absolutely no categories or tags have isDeleted: true during setup',
      () async {
        // Arrange
        const userId = 'user_123';

        // Act
        await useCase.execute(userId: userId, locale: 'en');

        // Assert
        final capturedCategories = verify(
          () => mockCategoryRepository.createCategory(captureAny()),
        ).captured;
        for (final cat in capturedCategories) {
          expect((cat as Category).isDeleted, isFalse);
        }

        final capturedTags = verify(
          () => mockTagRepository.createTag(captureAny()),
        ).captured;
        for (final tag in capturedTags) {
          expect((tag as Tag).isDeleted, isFalse);
        }
      },
    );
  });
}
