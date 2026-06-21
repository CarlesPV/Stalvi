# Active Task: Phase 23 - Multi-Currency Stabilization, Localization & Branding Fixes

## Current Objective
Resolve critical business logic flaws regarding multi-currency calculations, account initialization, complete the 3-language internationalization (l10n), and configure app branding (icons).

## Scope of Work
- **Domain/Business Logic:** - Restrict editing of `balance` and `currency` for existing Accounts/Wallets.
  - Refactor initial default account creation to execute *after* profile creation, using the user's localized language for the account name and their default currency.
  - Implement real-time currency conversion logic for Account balances and Main Screen Statistics based on the user's default currency or the specific account's currency using saved exchange rates.
- **Localization (l10n):** - Audit all UI files, error handlers, and messages to replace hardcoded English text with keys mapped to `app_en.arb`, `app_es.arb`, and `app_ca.arb`.
- **UI/Branding:** - Configure the main app icon and splash screen using local assets (`assets/icon/`), and display it in the top-left corner of the main app bar.

## Status
- [ ] Account immutability rules (balance/currency).
- [ ] Profile-dependent default account creation logic.
- [ ] Full localization audit (EN, ES, CA).
- [ ] Dynamic currency conversion for account balances.
- [ ] Dynamic currency conversion for global/specific statistics.
- [ ] App icon and splash screen configuration.

## Active Files
- `lib/domain/usecases/create_profile_usecase.dart`
- `lib/presentation/features/settings/edit_account_dialog.dart` (or equivalent)
- `lib/presentation/providers/statistics_providers.dart`
- `lib/domain/use_cases/statistics/get_period_summary_use_case.dart`
- `lib/core/l10n/app_*.arb`
- `pubspec.yaml`