import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'package:konta/core/l10n/app_localizations.dart';
import 'package:konta/domain/entities/account.dart';
import 'package:konta/domain/entities/account_type.dart';
import 'package:konta/domain/repositories/i_account_repository.dart';

/// Use case that automatically initializes a user's default data.
///
/// Specifically, it creates a default account ("wallet") if the user
/// has no existing accounts.
import 'package:konta/domain/entities/category.dart';
import 'package:konta/domain/entities/category_type.dart';
import 'package:konta/domain/repositories/i_category_repository.dart';

/// Use case that automatically initializes a user's default data.
///
/// Specifically, it creates a default account ("wallet") and typical
/// localized categories if they do not exist yet.
class InitializeDefaultDataUseCase {
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;

  InitializeDefaultDataUseCase(
      this._accountRepository, this._categoryRepository);

  /// Executes the default data initialization.
  Future<void> execute({
    required String userId,
    required String currency,
    String? walletName,
    String? locale,
  }) async {
    final existingAccounts =
        await _accountRepository.getAccountsByUserId(userId);
    if (existingAccounts.isNotEmpty) {
      return;
    }

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
    await _accountRepository.createAccount(defaultAccount);

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
      },
      'es': {
        'Food': 'Comida',
        'Transport': 'Transporte',
        'Salary': 'Salario',
        'Housing': 'Vivienda',
        'Utilities': 'Servicios',
        'Entertainment': 'Entretenimiento',
      },
      'ca': {
        'Food': 'Alimentació',
        'Transport': 'Transport',
        'Salary': 'Salari',
        'Housing': 'Habitatge',
        'Utilities': 'Subministraments',
        'Entertainment': 'Entreteniment',
      }
    };

    final lang = locale ?? 'en';
    final translations =
        categoryTranslations[lang] ?? categoryTranslations['en']!;

    final defaultCategoryConfigs = [
      {
        'key': 'Food',
        'icon': 'restaurant',
        'color': '#FF9800',
        'type': CategoryType.expense
      },
      {
        'key': 'Transport',
        'icon': 'directions_car',
        'color': '#2196F3',
        'type': CategoryType.expense
      },
      {
        'key': 'Salary',
        'icon': 'attach_money',
        'color': '#4CAF50',
        'type': CategoryType.income
      },
      {
        'key': 'Housing',
        'icon': 'home',
        'color': '#9C27B0',
        'type': CategoryType.expense
      },
      {
        'key': 'Utilities',
        'icon': 'lightbulb',
        'color': '#FFEB3B',
        'type': CategoryType.expense
      },
      {
        'key': 'Entertainment',
        'icon': 'movie',
        'color': '#E91E63',
        'type': CategoryType.expense
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
        await _categoryRepository.updateCategory(updatedCat);
      } else {
        await _categoryRepository.createCategory(match);
      }
    }
  }
}
