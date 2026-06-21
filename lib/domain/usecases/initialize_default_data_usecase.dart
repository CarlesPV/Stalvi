import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/category_type.dart';
import 'package:stalvi/domain/repositories/i_category_repository.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/domain/repositories/i_tag_repository.dart';

/// Use case that seeds a user's default data (categories and tags).
///
/// Account creation is **not** handled here.  The default account is created
/// by [CreateProfileUseCase] immediately after the profile is persisted so
/// that the account's currency always matches the profile's currency.
class InitializeDefaultDataUseCase {
  final ICategoryRepository _categoryRepository;
  final ITagRepository _tagRepository;

  InitializeDefaultDataUseCase(
    this._categoryRepository,
    this._tagRepository,
  );

  /// Executes the default data seeding (categories and tags only).
  Future<void> execute({
    required String userId,
    String? locale,
  }) async {
    final now = DateTime.now();
    final lang = locale ?? 'en';

    // ── Localized Categories Seeding ─────────────────────────────────────────
    final existingCategories = await _categoryRepository.getAllCategories();

    final categoryTranslations = {
      'en': {
        'Food': 'Food',
        'Transport': 'Transport',
        'Salary': 'Salary',
        'Housing': 'Housing',
        'Utilities': 'Utilities',
        'Entertainment': 'Entertainment',
        'Shopping': 'Shopping',
        'Health': 'Health',
        'Education': 'Education',
        'Subscriptions': 'Subscriptions',
        'Travel': 'Travel',
        'Investments': 'Investments',
        'Gifts': 'Gifts',
      },
      'es': {
        'Food': 'Comida',
        'Transport': 'Transporte',
        'Salary': 'Salario',
        'Housing': 'Vivienda',
        'Utilities': 'Servicios',
        'Entertainment': 'Entretenimiento',
        'Shopping': 'Compras',
        'Health': 'Salud',
        'Education': 'Educación',
        'Subscriptions': 'Suscripciones',
        'Travel': 'Viajes',
        'Investments': 'Inversiones',
        'Gifts': 'Regalos',
      },
      'ca': {
        'Food': 'Alimentació',
        'Transport': 'Transport',
        'Salary': 'Salari',
        'Housing': 'Habitatge',
        'Utilities': 'Subministraments',
        'Entertainment': 'Entreteniment',
        'Shopping': 'Compres',
        'Health': 'Salut',
        'Education': 'Educació',
        'Subscriptions': 'Subscripcions',
        'Travel': 'Viatges',
        'Investments': 'Inversions',
        'Gifts': 'Regals',
      },
    };

    final translations =
        categoryTranslations[lang] ?? categoryTranslations['en']!;

    final defaultCategoryConfigs = [
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813801',
        'key': 'Food',
        'icon': 'restaurant',
        'color': '#FF9800',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813802',
        'key': 'Transport',
        'icon': 'directions_car',
        'color': '#2196F3',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813803',
        'key': 'Salary',
        'icon': 'attach_money',
        'color': '#4CAF50',
        'type': CategoryType.income,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813804',
        'key': 'Housing',
        'icon': 'home',
        'color': '#9C27B0',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813805',
        'key': 'Utilities',
        'icon': 'lightbulb',
        'color': '#FFEB3B',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813806',
        'key': 'Entertainment',
        'icon': 'movie',
        'color': '#E91E63',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813807',
        'key': 'Shopping',
        'icon': 'shopping_bag',
        'color': '#E91E63',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813808',
        'key': 'Health',
        'icon': 'medical_services',
        'color': '#00BCD4',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813809',
        'key': 'Education',
        'icon': 'school',
        'color': '#3F51B5',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813810',
        'key': 'Subscriptions',
        'icon': 'subscriptions',
        'color': '#9C27B0',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813811',
        'key': 'Travel',
        'icon': 'flight',
        'color': '#009688',
        'type': CategoryType.expense,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813812',
        'key': 'Investments',
        'icon': 'trending_up',
        'color': '#8BC34A',
        'type': CategoryType.income,
      },
      {
        'id': 'c3b07384-d113-4c56-bf56-f0279d813813',
        'key': 'Gifts',
        'icon': 'card_giftcard',
        'color': '#FFC107',
        'type': CategoryType.income,
      },
    ];

    for (final config in defaultCategoryConfigs) {
      final id = config['id'] as String;
      final key = config['key'] as String;
      final icon = config['icon'] as String;
      final color = config['color'] as String;
      final type = config['type'] as CategoryType;
      final localizedName = translations[key]!;

      // 1. Check if the category exists by stable ID
      var dbCategory = await _categoryRepository.getCategoryById(id);

      // 2. If not found by stable ID, check if it exists by icon (migration step)
      if (dbCategory == null) {
        final hasIconMatch = existingCategories.any((c) => c.icon == icon);
        if (hasIconMatch) {
          final matchByIcon =
              existingCategories.firstWhere((c) => c.icon == icon);
          if (matchByIcon.id != id) {
            // Delete the old category with the non-stable ID
            try {
              await _categoryRepository
                  .deleteCategoryPermanently(matchByIcon.id);
            } catch (_) {}
          } else {
            dbCategory = matchByIcon;
          }
        }
      }

      if (dbCategory != null) {
        final updatedCat = dbCategory.copyWith(
          name: localizedName,
          isDeleted: false,
          modifiedAt: now,
        );
        try {
          await _categoryRepository.updateCategory(updatedCat);
        } catch (_) {}
      } else {
        final newCat = Category(
          id: id,
          name: localizedName,
          associatedType: type,
          icon: icon,
          color: color,
          isDeleted: false,
          createdAt: now,
          modifiedAt: now,
        );
        try {
          await _categoryRepository.createCategory(newCat);
        } catch (_) {}
      }
    }

    // ── Localized Tags Seeding ───────────────────────────────────────────────
    final existingTags = await _tagRepository.getAllTags();

    final tagTranslations = {
      'en': {
        'SummerTrip': 'Summer Trip',
        'Event': 'Event',
        'Project': 'Project',
        'Wedding': 'Wedding',
        'Birthday': 'Birthday',
        'BusinessTrip': 'Business Trip',
      },
      'es': {
        'SummerTrip': 'Viaje de verano',
        'Event': 'Evento',
        'Project': 'Proyecto',
        'Wedding': 'Boda',
        'Birthday': 'Cumpleaños',
        'BusinessTrip': 'Viaje de negocios',
      },
      'ca': {
        'SummerTrip': 'Viatge d\'estiu',
        'Event': 'Esdeveniment',
        'Project': 'Projecte',
        'Wedding': 'Casament',
        'Birthday': 'Aniversari',
        'BusinessTrip': 'Viatge de negocis',
      },
    };

    final transTags = tagTranslations[lang] ?? tagTranslations['en']!;

    final defaultTagConfigs = [
      {'key': 'SummerTrip', 'id': 'd3b07384-d113-4c56-bf56-f0279d813701'},
      {'key': 'Event', 'id': 'd3b07384-d113-4c56-bf56-f0279d813702'},
      {'key': 'Project', 'id': 'd3b07384-d113-4c56-bf56-f0279d813703'},
      {'key': 'Wedding', 'id': 'd3b07384-d113-4c56-bf56-f0279d813704'},
      {'key': 'Birthday', 'id': 'd3b07384-d113-4c56-bf56-f0279d813705'},
      {'key': 'BusinessTrip', 'id': 'd3b07384-d113-4c56-bf56-f0279d813706'},
    ];

    // Clean up old default tags and any duplicates created with random UUIDs
    final allDefaultNames = {
      ...tagTranslations['en']!.values,
      ...tagTranslations['es']!.values,
      ...tagTranslations['ca']!.values,
      'Essential',
      'Leisure',
      'Work',
      'Personal',
      'Recurring',
      'Subscription',
      'Esencial',
      'Ocio',
      'Trabajo',
      'Recurrente',
      'Suscripción',
      'Essencial',
      'Oci',
      'Treball',
      'Recurrent',
      'Subscripció',
    };

    for (final tag in existingTags) {
      final isNewStableId =
          defaultTagConfigs.any((config) => config['id'] == tag.id);
      if (allDefaultNames.contains(tag.name) && !isNewStableId) {
        try {
          await _tagRepository.deleteTagPermanently(tag.id);
        } catch (_) {}
      }
    }

    for (final config in defaultTagConfigs) {
      final key = config['key']!;
      final id = config['id']!;
      final localizedName = transTags[key]!;

      final existingDbTag = await _tagRepository.getTagById(id);
      if (existingDbTag != null) {
        final updatedTag = existingDbTag.copyWith(
          name: localizedName,
          isDeleted: false,
          modifiedAt: now,
        );
        try {
          await _tagRepository.updateTag(updatedTag);
        } catch (_) {}
      } else {
        final newTag = Tag(
          id: id,
          name: localizedName,
          isDeleted: false,
          createdAt: now,
          modifiedAt: now,
        );
        try {
          await _tagRepository.createTag(newTag);
        } catch (_) {}
      }
    }
  }
}
