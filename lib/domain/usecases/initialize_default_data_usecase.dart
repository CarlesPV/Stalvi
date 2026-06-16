import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';
import 'package:konta/domain/entities/tag.dart';
import 'package:konta/domain/repositories/i_tag_repository.dart';

/// Use case that automatically initializes a user's default data.
///
/// Specifically, it creates a default account ("wallet"), typical
/// localized categories, and typical localized tags if they do not exist yet.
class InitializeDefaultDataUseCase {
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final ITagRepository _tagRepository;

  InitializeDefaultDataUseCase(
    this._accountRepository,
    this._categoryRepository,
    this._tagRepository,
  );

  /// Executes the default data initialization.
  Future<void> execute({
    required String userId,
    required String currency,
    String? walletName,
    String? locale,
  }) async {
    final existingAccounts =
        await _accountRepository.getAccountsByUserId(userId);
    if (existingAccounts.isEmpty) {
      String resolvedWalletName = walletName ?? 'Mi cartera';
      if (walletName == null && locale != null) {
        try {
          final appLoc = lookupAppLocalizations(Locale(locale));
          resolvedWalletName = appLoc.defaultWalletName;
        } catch (_) {
          if (locale == 'es') resolvedWalletName = 'Mi cartera';
          if (locale == 'ca') resolvedWalletName = 'La meva cartera';
        }
      }

      final now = DateTime.now();

      final defaultAccount = Account(
        id: const Uuid().v4(),
        userId: userId,
        name: resolvedWalletName,
        type: AccountType.cash,
        initialBalance: 0.0,
        currency: currency,
        color: '#4CAF50',
        icon: 'wallet',
        isDefault: true,
        isDeleted: false,
        createdAt: now,
        modifiedAt: now,
      );
      try {
        await _accountRepository.createAccount(defaultAccount);
      } catch (_) {}
    }

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
        'key': 'Food',
        'icon': 'restaurant',
        'color': '#FF9800',
        'type': CategoryType.expense,
      },
      {
        'key': 'Transport',
        'icon': 'directions_car',
        'color': '#2196F3',
        'type': CategoryType.expense,
      },
      {
        'key': 'Salary',
        'icon': 'attach_money',
        'color': '#4CAF50',
        'type': CategoryType.income,
      },
      {
        'key': 'Housing',
        'icon': 'home',
        'color': '#9C27B0',
        'type': CategoryType.expense,
      },
      {
        'key': 'Utilities',
        'icon': 'lightbulb',
        'color': '#FFEB3B',
        'type': CategoryType.expense,
      },
      {
        'key': 'Entertainment',
        'icon': 'movie',
        'color': '#E91E63',
        'type': CategoryType.expense,
      },
      {
        'key': 'Shopping',
        'icon': 'shopping_bag',
        'color': '#E91E63',
        'type': CategoryType.expense,
      },
      {
        'key': 'Health',
        'icon': 'medical_services',
        'color': '#00BCD4',
        'type': CategoryType.expense,
      },
      {
        'key': 'Education',
        'icon': 'school',
        'color': '#3F51B5',
        'type': CategoryType.expense,
      },
      {
        'key': 'Subscriptions',
        'icon': 'subscriptions',
        'color': '#9C27B0',
        'type': CategoryType.expense,
      },
      {
        'key': 'Travel',
        'icon': 'flight',
        'color': '#009688',
        'type': CategoryType.expense,
      },
      {
        'key': 'Investments',
        'icon': 'trending_up',
        'color': '#8BC34A',
        'type': CategoryType.income,
      },
      {
        'key': 'Gifts',
        'icon': 'card_giftcard',
        'color': '#FFC107',
        'type': CategoryType.income,
      },
    ];

    for (final config in defaultCategoryConfigs) {
      final key = config['key'] as String;
      final icon = config['icon'] as String;
      final color = config['color'] as String;
      final type = config['type'] as CategoryType;
      final localizedName = translations[key]!;

      // Find by icon to check if it already exists
      final match = existingCategories.firstWhere(
        (c) => c.icon == icon,
        orElse: () => Category(
          id: const Uuid().v4(),
          name: localizedName,
          associatedType: type,
          icon: icon,
          color: color,
          isDeleted: false,
          createdAt: now,
          modifiedAt: now,
        ),
      );

      if (existingCategories.any((c) => c.id == match.id)) {
        final updatedCat = match.copyWith(
          name: localizedName,
          modifiedAt: now,
        );
        try {
          await _categoryRepository.updateCategory(updatedCat);
        } catch (_) {}
      } else {
        try {
          await _categoryRepository.createCategory(match);
        } catch (_) {}
      }
    }

    // ── Localized Tags Seeding ───────────────────────────────────────────────
    final existingTags = await _tagRepository.getAllTags();

    final tagTranslations = {
      'en': {
        'Essential': 'Essential',
        'Leisure': 'Leisure',
        'Work': 'Work',
        'Personal': 'Personal',
        'Recurring': 'Recurring',
        'Subscription': 'Subscription',
      },
      'es': {
        'Essential': 'Esencial',
        'Leisure': 'Ocio',
        'Work': 'Trabajo',
        'Personal': 'Personal',
        'Recurring': 'Recurrente',
        'Subscription': 'Suscripción',
      },
      'ca': {
        'Essential': 'Essencial',
        'Leisure': 'Oci',
        'Work': 'Treball',
        'Personal': 'Personal',
        'Recurring': 'Recurrent',
        'Subscription': 'Subscripció',
      },
    };

    final transTags = tagTranslations[lang] ?? tagTranslations['en']!;

    final defaultTagConfigs = [
      'Essential',
      'Leisure',
      'Work',
      'Personal',
      'Recurring',
      'Subscription',
    ];

    for (final key in defaultTagConfigs) {
      final localizedName = transTags[key]!;

      // Find by name to check if it already exists
      final match = existingTags.firstWhere(
        (t) => t.name == localizedName,
        orElse: () => Tag(
          id: const Uuid().v4(),
          name: localizedName,
          isDeleted: false,
          createdAt: now,
          modifiedAt: now,
        ),
      );

      if (existingTags.any((t) => t.id == match.id)) {
        final updatedTag = match.copyWith(
          name: localizedName,
          modifiedAt: now,
        );
        try {
          await _tagRepository.updateTag(updatedTag);
        } catch (_) {}
      } else {
        try {
          await _tagRepository.createTag(match);
        } catch (_) {}
      }
    }
  }
}
