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
  - [x] Separate Terms & Conditions and Privacy Policy viewers, localized in the active language.
  - [x] Enable default currency selection in profile setup flow.
  - [x] Resolve the onboarding bug where first-time login/registration fails.
  - [x] Implement direct onboarding routing to Dashboard with prompt for biometric opt-in.
  - [x] Pre-populate default account, categories, and tags localized in English, Spanish, and Catalan.

- [x] **Phase 9: Advanced Settings Management**
  - [x] Enforce system, light, and dark mode theme selection with persistence.
  - [x] Build the 30-day Recycle Bin with TrashDao, AutoPurgeUseCase, and RecycleBinScreen UI.
  - [x] Reorganize settings screen list and remove redundant top-right profile avatar.
  - [x] Localize all Recycle Bin and PIN flow strings in English, Spanish, and Catalan.

- [x] **Phase 10: Statistics Screen & Aggregation Query Robustness**
  - [x] Rewrote SQLite aggregation queries in `StatisticsDao` (using explicit isolated SUM statements and null-coalescing operators) to prevent null reference errors on empty databases.
  - [x] Refactored mapping between database results and domain entities (`CategoryStatistic` and `PeriodSummary`).
  - [x] Updated the Statistics UI to handle `AsyncError` and `AsyncLoading` states and render `EmptyStateWidget` when no transactions are recorded.
  - [x] Added unit tests for `StatisticsDao` using an in-memory Drift database with mock transaction data and grouping validations.

- [x] **Phase 11: Data Hydration & Empty State Handling**
  - [x] Wrap default data initialization in robust try/catch blocks with detailed logging.
  - [x] Await database and seed data initialization before dashboard routing.
  - [x] Implement highly visible empty-state fallbacks with user action buttons for manual account creation.

- [x] **Phase 12: Profile and Settings Consolidation**
  - [x] Remove standalone profile tab and consolidate Theme, Language, Terms, and Privacy Policy settings into a single "Profile & Security" screen.
  - [x] Move Recycle Bin trigger directly to the primary Settings tab list.
  - [x] Clean up dashboard screens, menus, and appBar actions to streamline configuration settings.

- [x] **Phase 13: SQLCipher FFI Binding & Isolate Crash Fix**
  - [x] Resolve Android launch crash caused by `NativeDatabase.createInBackground` isolate boundary issues.
  - [x] Revert to main-thread `NativeDatabase` initialization to preserve `open.overrideFor` FFI configuration for SQLCipher loading.
  - [x] Ensure performance remains high while stabilizing database connection establishment.

## Current Phase
- [ ] **Phase 14: Synchronization, Backups, and Import/Export Validations**
  - [ ] Implement cloud synchronization options.
  - [ ] Add encrypted automatic local backup features.
  - [ ] Validate cross-platform imports/exports.

## Upcoming Phases
- [ ] **Phase 15: Integration Testing (E2E), final security audit, and store preparation.**