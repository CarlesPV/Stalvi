# Active Task: Phase 15 - Security Hardening, UX Refinement & Localization

## Objective
Consolidate phase 14 by resolving pending UI/UX rules, reinforcing security measures (brute-force protection, sensitive action confirmation), and ensuring 100% localization consistency across platform dialogs, dates, and default entities.

## Context
The core infrastructure (Drift, SQLCipher, Riverpod, Clean Architecture) is functional. However, several business rules regarding state management (statistics auto-refresh, filtering, contextual FAB), security (auth retries, wipe confirmation), and i18n (biometric prompts, date formats, default account naming) are missing or incomplete.

## Execution Steps

- [ ] **Step 1: Security & Auth Hardening**
  - Implement a 30-second lockout after maximum failed PIN attempts in `auth_notifier.dart` and `auth_screen.dart`.
  - Require PIN/Biometric validation before executing the "Wipe All Data" action in `profile_settings_screen.dart`.

- [ ] **Step 2: i18n & Formatting Consistency**
  - Update `biometric_auth_service.dart` to accept localized strings for iOS/Android native prompts.
  - Fix date formatting to respect the current app locale in `add_transaction_screen.dart`.
  - Ensure the default account created during initialization uses localized names and inherits the profile's default currency.

- [ ] **Step 3: UX Interactions & State Navigation**
  - Make the `FloatingActionButton` (+) contextual in `dashboard_screen.dart` (creates Accounts if on the Accounts tab, Transactions otherwise).
  - Implement a transaction details pop-up with a "Soft Delete" action trigger.

- [ ] **Step 4: Advanced State Management (Filtering & Stats)**
  - Implement a complex filter state (type, category, date, amount, tags, currency) for the transaction list.
  - Refactor `statistics_screen.dart` to trigger an immediate data refresh upon entering the view (avoiding the need to manually toggle filters).

## Current Status
- Pending Step 1 execution.