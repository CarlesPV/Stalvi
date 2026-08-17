import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stalvi/core/theme/app_theme.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';
import 'package:stalvi/presentation/features/transactions/add_transaction_screen.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';

class FakeCategoryRepository implements ICategoryRepository {
  final List<Category> _categories = [];

  @override
  Stream<List<Category>> watchAllCategories() async* {
    yield _categories;
  }

  @override
  Future<Category> createCategory(Category category) async {
    _categories.add(category);
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> deleteCategoryPermanently(String id) async {}

  @override
  Future<List<Category>> getAllCategories() async => _categories;

  @override
  Future<Category?> getCategoryById(String id) async => null;
}

class FakeTagRepository implements ITagRepository {
  final List<Tag> _tags = [];

  Stream<List<Tag>> watchAllTags() async* {
    yield _tags;
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    _tags.add(tag);
    return tag;
  }

  @override
  Future<Tag> updateTag(Tag tag) async {
    return tag;
  }

  @override
  Future<void> deleteTag(String id) async {}

  @override
  Future<void> deleteTagPermanently(String id) async {}

  @override
  Future<List<Tag>> getAllTags() async => _tags;

  @override
  Future<Tag?> getTagById(String id) async => null;
}

void main() {
  testWidgets('Inline Category and Tag creation flow in Add Transaction', (
    WidgetTester tester,
  ) async {
    // Provide a large enough screen
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository(),
          ),
          tagRepositoryProvider.overrideWithValue(FakeTagRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AddTransactionScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Select a category
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();

    // Tap Add Category
    final addCategoryOption = find.text('Create New Category');
    expect(addCategoryOption, findsOneWidget);
    await tester.tap(addCategoryOption);
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(
      find.byType(TextField).last,
      'New Integration Category',
    );
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify it was auto-selected
    expect(find.text('New Integration Category'), findsWidgets);

    // Select a tag
    await tester.tap(find.text('Tag (Optional)'));
    await tester.pumpAndSettle();

    // Tap Add Tag
    final addTagOption = find.text('Create New Label');
    expect(addTagOption, findsOneWidget);
    await tester.tap(addTagOption);
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(find.byType(TextField).last, 'New Integration Tag');
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify it was auto-selected
    expect(find.text('New Integration Tag'), findsWidgets);
  });
}
