# Konta Project Roadmap

## Completed Phases
- [x] **Phase 1: Foundation & Security**
  - [x] Initialize directory structure (Clean Architecture).
  - [x] Dependency resolution and native environment setup for SQLCipher.
  - [x] Base Drift database setup and `flutter_secure_storage` key generation.
  - [x] Core utilities: Theme definitions (Pastel aesthetics), custom error classes, and currency formatters.

- [x] **Phase 2: Domain Modeling & Local Storage**
  - [x] Implement `Profile` and `Account` tables in Drift.
  - [x] Create `Account` Entities and Use Cases (mandatory initial balance).
  - [x] Implement `Category` and `Tag` tables and seed default categories.
  - [x] Develop Presentation layer for Onboarding (Splash -> Biometric Auth -> Dashboard).

- [x] **Phase 3: Transaction Management (Core Engine)**
  - [x] Implement `Transaction` tables and Use Cases (Income, Expense).
  - [x] Enforce atomic balance updates within a Drift database transaction.
  - [x] Implement Soft Delete mechanism (`is_deleted` flag) on Account and Category.
  - [x] Build the "Add Transaction" UI screen with numeric input and customized selectors.

- [x] **Phase 4: Multi-Currency & Goals**
  - [x] Integrate external Exchange Rate API (HTTPS GET only) in Data Layer.
  - [x] Update Movement creation to save converted default currency values.
  - [x] Implement `Budget` and `Savings Goal` tables.
  - [x] Build visual progress bars for budgets and goals in the UI.

- [x] **Phase 5: Statistics, Filters, & Exports**
  - [x] Build SQLite aggregation queries (`SUM`, `GROUP BY`) for dashboard totals.
  - [x] Implement `fl_chart` for Income vs Expense and Top Categories.
  - [x] Create dynamic filtering logic (Account, Date Range, Category).
  - [x] Implement secure PDF, CSV/Excel, and encrypted JSON export functionality.

- [x] **Phase 6: Polish, Testing & Compliance**
  - [x] Complete E2E testing of the application flow.
  - [x] Validate "Discreet Mode" and App Lifecycle blurring features.
  - [x] Prepare App Store & Google Play compliance files (Privacy mappings).
  - [x] Final UI/UX review (Anti-blank page syndrome check, Dark Mode contrast).

- [x] **Phase 7: Secure Onboarding, Initialization & User Experience (UX)**
  - [x] Implement initial profile account creation (4-8 digit PIN, language selection, terms and conditions).
  - [x] Integrate biometric authentication request and validation (FaceID/TouchID).
  - [x] Automatic generation of the default account ("Mi cartera" / "My Wallet" with 0.0 balance) after registration.
  - [x] Apply and standardize `EmptyStateWidget` across all screens with empty lists.

- [x] **Phase 8: Onboarding Improvements, Localization Polish & Bug Fixes**
  - [x] **Legal Document Split:** Separate Terms & Conditions and Privacy Policy viewers, localized in the app's language, accessible during onboarding and in settings.
  - [x] **Default Currency Selector:** Allow choosing the default currency during the profile creation flow.
  - [x] **First-Time Registration Fix:** Resolve the initialization bug where the first login/registration attempt fails and requires a retry.
  - [x] **Direct Onboarding Routing:** Bypass the PIN screen immediately after profile creation, redirecting to Dashboard, and prompt for biometric opt-in permissions.
  - [x] **Default Seeding:** Pre-populate a default account ("Mi cartera" / "My Wallet" / "La meva cartera") at 0.0 balance, 13 typical default categories, and 6 default typical tags localized in English, Spanish, and Catalan to prevent empty states.
  - [x] **3-Language Coverage:** Ensure complete translation of all text, buttons, errors, default categories, and initial account name in English, Spanish, and Catalan.

- [x] **Phase 9: Advanced Settings Management (Manual/system dark/light mode, 30-day recycle bin, app language selection, and settings reorganization)**
  - [x] **Theme Mode Management:** Enforce selectable system, light, and dark mode settings with state persistence via SharedPreferences.
  - [x] **30-day Recycle Bin:** Track soft-deleted transactions, accounts, and categories via a dedicated `TrashDao`, purge older database records (>30 days) automatically on startup, and build a Recycle Bin management screen.
  - [x] **Settings Reorganization:** Remove the redundant top-right profile avatar from the dashboard screen, remove language settings from the Profile screen, and reorganize the settings list into a cleaner, prioritized order.
  - [x] **Recycle Bin & PIN Flow Localization:** Audit and fully localize all hardcoded strings (Recycle Bin, PIN settings) across all three supported languages (English, Spanish, Catalan).

## Current Phase
- [ ] **Phase 10:** Synchronization, Backups, and Import/Export Validations.

## Upcoming Phases
- [ ] **Phase 11:** Integration Testing (E2E), final security audit, and store preparation.