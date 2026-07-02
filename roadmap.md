# Stalvi Project Roadmap

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

- [x] **Phase 14: PIN UX, Dashboard Polish, Transaction Sorting, and Tag/Category Localization**
  - [x] Integrate inline error notifications inside the Change PIN popup.
  - [x] Remove the flickering skeletal trend loader block to resolve the visual loading bug on Dashboard.
  - [x] Enforce date and createdAt order sorting for transactions list.
  - [x] Redo default tags to represent event and organization use cases (Summer Trip, Event, Project, Wedding, Birthday, Business Trip).
  - [x] Implement dynamic database category/tag translation updates on app startup and locale changes, using stable IDs and cleaning up duplicate/old entries.

- [x] **Phase 15: Advanced Transaction Filtering & Statistics Eager Initialization**
  - [x] Implement multi-dimensional `TransactionFilter` model and provider state notifier.
  - [x] Create domain-level `TransactionQueryFilter` supporting concurrency across 6 fields (Type, Category, Date Range, Amount Range, Tag, Currency).
  - [x] Implement database-level `watchFilteredTransactions` using Drift expressions.
  - [x] Pre-warm statistics future providers on screen mounting (`initState`) to eliminate initialization latency.
  - [x] Write comprehensive suite of 21 tests covering concurrent filter combinations.

- [x] **Phase 16: UI, Localization, and Soft-Deleted Data Fixes**
  - [x] Implement local inline validation error message display on Name field for Create/Edit Account Dialogs.
  - [x] Fix Account Type selector text clipping by increasing height constraint, and update the "Other" type icon to a context-related monetization coin.
  - [x] Exclude soft-deleted transactions, accounts, and categories from period summary and top categories statistics aggregations.
  - [x] Enforce automated account balance updates when deleting and restoring transactions (reverting/re-applying financial impacts).
  - [x] Fix compilation issues and achieve 100% automated test suite pass rate.

- [x] **Phase 17: Multi-Account Statistics, Transaction Transfers, and Localization Polish**
  - [x] Default the statistics view to the `isDefault` account, with an option to select other accounts.
  - [x] Add an account selector dropdown at the top of the Statistics screen.
  - [x] Support `Transfer` transaction type in the creation UI with "From Account" and "To Account" dropdowns.
  - [x] Validate that the source and destination accounts in a transfer cannot be the same.
  - [x] Enforce localized pluralized `.arb` strings for the dashboard multi-account text.
  - [x] Fix widget tests and achieve 100% automated test suite pass rate.

- [x] **Phase 18: Dynamic Initial Database Entity Localization & UI Polish**
  - [x] Dynamically localize the default wallet name based on active locale ("La meva cartera" / "Mi cartera" / "My Wallet").
  - [x] Refactor usecase and initialization data flow to inject dynamic localized strings from presentation providers (Clean Architecture).
  - [x] Resolve `ListTile` theme ancestor dependency issues in test runs by adding `Material` wrappers to dialog layouts.
  - [x] Complete sweeping UI checks and fix all unit tests to achieve 100% pass rate.

- [x] **Phase 19: Complex Cascades, Riverpod Reactivity & Deep UX Polish**
  - [x] Implement transfer mirroring logic (atomic dual-movement pairs with linked transferId).
  - [x] Polish transaction details UI modal (hide empty notes and display dynamic localized titles).
  - [x] Reorganize Settings tab screen modules (Categories & Tags placement).
  - [x] Display delete last account error inline in the dialog.
  - [x] Enforce real-time reactivity with Riverpod invalidations on transaction mutations.
  - [x] Cascade account deletion to all child transactions.
  - [x] Implement app wipe database purge and cold app restart via SystemNavigator.
  - [x] Complete global localization audit and replace all remaining hardcoded texts in Spanish, English, and Catalan.
  - [x] Update CI/CD pipelines to run `flutter gen-l10n` on build.

- [x] **Phase 20: Advanced Localization Audit & Mobile Layout Robustness**
  - [x] Standardize 7 global currencies across the app and localization files.
  - [x] Improve transfer details and calculations to handle both origin and destination accounts securely.
  - [x] Enforce fallback localized transfer titles on the dashboard.
  - [x] Perform sweeping UI checks removing maxLines and TextOverflow.ellipsis to use responsive layouts.
  - [x] Ensure perfect translation coverage for English, Spanish, and Catalan.
  - [x] Verify that all tests pass successfully.

- [x] **Phase 21: Transfer Flow Polish, Recycle Bin Refinements & Validation**
  - [x] Default the transfer notes field to empty instead of auto-populating "Transfer".
  - [x] Deduplicate transfers to display only 1 record in global listings, while correctly displaying the corresponding leg for both origin and destination accounts when filtered.
  - [x] Ensure deleting a transfer mirrors properly, adding only 1 item to the recycle bin.
  - [x] Refactor recycle bin to remove bulk empty options, auto-dispose state when exiting, and dynamically format items as `<Note/Type> - <Amount>` localized in all 3 languages using stored metadata.
  - [x] Implement raw transaction query streams to successfully fetch and display both origin and destination accounts inside transaction detail sheets.
  - [x] Standardize transfer list icons to use transfer-specific iconography.
  - [x] Run full automated testing (352 tests) and static analysis to ensure 100% build health and lint correctness.

- [x] **Phase 22: Multi-Currency Snapshot, Auth Fallbacks & i18n Completeness**
  - [x] Implement historical exchange rate snapshots per transaction, stored in the database.
  - [x] Integrate background synchronization of exchange rates on application startup.
  - [x] Refactor registration profile setup to utilize dynamic localized wallet names.
  - [x] Resolve fallback PIN authentication when biometric authentication fails or is cancelled in sensitive flows.
  - [x] Complete 100% internationalization (i18n) coverage for loading, error, and feedback states in English, Spanish, and Catalan.
  - [x] Ensure all 357 unit/widget tests and static analysis pass cleanly.

- [x] **Phase 22.1: Multi-Currency Immutability & Background Sync**
  - [x] Create ExchangeRate entities and Local/Remote data sources.
  - [x] Add `exchangeRateSnapshot` field to `Transaction` entity.
  - [x] **Fix:** Isolate default Wallet creation to Profile Registration flow only.
  - [x] **Fix:** Inject 24h exchange rate snapshot as JSON into new Transactions.
  - [x] **Fix:** Calculate Statistics & Dashboard summaries using historical snapshot math instead of pure SQL sums.

- [x] **Phase 22.2: Localization Completeness, Unused Translation Cleanup, and Layout Polish**
  - [x] Conduct a complete translation audit and remove 15 unused translation keys (`authAuthenticate`, `authCheckingBiometrics`, etc.) from all three ARB files (`app_en.arb`, `app_es.arb`, `app_ca.arb`).
  - [x] Localize the budget progress spent string by replacing hardcoded `'of'` with a new translation key `budgetSpentOf` across English, Spanish, and Catalan.
  - [x] Map `ValidationException` code `INVALID_NAME` to `l10n.createAccountErrorName` inside `EditAccountDialog` to ensure localized validation errors are shown.
  - [x] Compile and verify 100% passing rate on the complete 361 tests suite and static analysis checks.

- [x] **Phase 23: Backups, and Import/Export Validations**
  - [x] Add encrypted automatic local backup features using AES-256-CBC with keys derived via PBKDF2-HMAC-SHA256 from user-defined passwords.
  - [x] Implement complete database restoration from encrypted JSON backups (`IImportService` and `ImportServiceImpl`), mapping to categories, tags, accounts, and transactions.
  - [x] Ensure atomic table wipes (transactions, accounts, categories, tags) inside single Drift database transactions before importing, keeping profiles intact.
  - [x] Validate cross-platform imports/exports with comprehensive test suites covering CSV parsing, encryption/decryption envelopes, PDF statements, and full DB restorations.
  - [x] Ensure 100% build health, clean lint checks (0 issues on `flutter analyze`), and successfully compile and execute all 360+ tests suite.

- [x] **Phase 24: Financial Immutability, Export Engine & UI Polish**
  - [x] Update `Transaction` entity and Drift database schema to store a snapshot of currency exchange rates at the time of creation.
  - [x] Remove the redundant "Net Balance" summary from the Accounts tab, leaving a clean "Statistics" section header and entry point.
  - [x] Center the transaction amount initially in the "Add Transaction" screen, allowing it to dynamically expand leftwards on large inputs.
  - [x] Calculate all Statistics (dashboard summaries and top categories) dynamically in real-time, performing live currency conversions based on full unrounded integer cents across multi-currency accounts.
  - [x] Fix the missing visibility toggle (eye icon) on the backup confirmation password field.
  - [x] Resolve global UI overflows, text truncation ("..."), and visual alignment issues across buttons and error messages.
  - [x] Modify export services (PDF, CSV, JSON) to append timestamps (`yyyyMMdd_HHmmss`) to filenames.
  - [x] Enhance PDF generation: Fully localize strings (`AppLocalizations`), format amounts with the default user currency, and append `pw.PieGrid` charts for top income and expense categories.
  - [x] Enhance CSV generation to include all newly added transaction data (e.g., historical exchange rates).
  - [x] Modify import service: Force a complete memory clear, background state flush, and app restart upon successful data import.
  - [x] Standardize 100% build health, clean lint checks (0 issues on `flutter analyze`), and successfully compile and execute all 363 tests in the test suite.

- [x] **Phase 25: Currency Engine Optimization, Reactivity, and Advanced Reports**
  - [x] Integrate Chinese Yuan (CNY) into supported currencies.
  - [x] Optimize `exchange_rate_remote_data_source.dart` to cache (24h) and limit requests to only the 8 supported currencies.
  - [x] Refactor providers (`statistics_providers.dart`) to automatically recalculate upon detecting changes in the default currency.
  - [x] Modify `add_transaction_usecase.dart` to calculate and apply dynamic exchange rates in transfers between accounts with different currencies.
  - [x] Expand and refactor `export_monthly_pdf_use_case.dart` and `export_service_impl.dart` to support original transaction currencies, clean pie charts without inline labels, and a comprehensive table legend with color swatches, category percentages, and values.
  - [x] Rename export filename prefixes from "Konta_Export" to "Stalvi_Export" across CSV, PDF, and backup formats.
  - [x] Implement the "Open file" action using `open_filex` after exporting CSV/PDF.
  - [x] UI Audit: Prevent overflows (keyboard/small screens) and review ARB files (ES, EN, CA).

- [x] **Phase 26: QA/Layout Readiness and Production Audit**
  - [x] Audit layout widgets for potential overflows, adding Expanded, Flexible, ellipsis, and maxLines limits.
  - [x] Expose text formatting options (overflow, maxLines, softWrap) in ObfuscatedText.
  - [x] Apply layout safeguards to balance total label, balance amount value, statistics card (label/values), account item balance value, and transaction item amount value across Dashboard and Budgets & Goals screens.
  - [x] Resolve trailing comma and deprecation warnings across all code and tests.
  - [x] Clean unused legal markdown assets (privacy.md and terms.md) from assets directory to optimize space.
  - [x] Ensure 100% build health, clean lint checks (0 issues on `flutter analyze`), and successfully execute all 381 tests.

- [x] **Phase 27: UI Constraints for Budgets, Goals, and Recycle Bin**
  - [x] Implement edit-mode locks (read-only states) for Currency and Target Amount fields in Budgets and Savings Goals sheets.
  - [x] Require Account selection when creating a Budget.
  - [x] Include active Savings Goals in the Destination selector dropdown for Transfer transactions alongside standard Accounts.
  - [x] Render soft-deleted Budgets and Savings Goals inside the Recycle Bin (Trash) lists.
   - [x] Localize all new UI elements and options in English, Spanish, and Catalan, ensuring 100% localization parity.
   - [x] Fix compilation issues across test mocks, unit tests, and widget tests (393/393 passing).
 
 - [x] **Phase 28: Financial Integrity, Editing, and Final Polish**
   - [x] **Entity Editing:** Enable update operations (Update) in UI and Domain for Budgets and Savings Goals.
   - [x] **Dynamic Recalculation:** Implement reactive budget recalculation including currency conversion when transactions are modified or deleted.
   - [x] **Trash Integrity:** Cascading soft-delete and restore for Savings Goals, reverting and reapplying balances to origin accounts.
   - [x] **PDF Unicode Support:** Embed TTF fonts (e.g., Roboto) in the PDF export service to properly render currency symbols.
   - [x] **Legal Update:** Review and update `privacy_*.md` and `terms_*.md` in ES, EN, CA to reflect the latest features.
   - [x] **UI/UX & i18n QA:** Complete review to fix RenderFlex overflows and achieve 100% translation coverage in `.arb` files.
   - [x] **CI/CD Validation:** Ensure all unit tests pass and GitHub Actions workflows complete successfully.

- [x] **Phase 29: Release Preparation and UI Optimization**
  - [x] Optimize dashboard by removing the long press context menu for setting default accounts.
  - [x] Perform a full translation/code cleanup to remove unused arb keys and comments to optimize space.
  - [x] Generate release Android App Bundle (AAB) and iOS IPA.
  - [x] Verify store listing assets (localized descriptions, screenshots).
  - [x] Conduct pre-release test flight and internal Google Play tracks tests.
  - [x] Final production compliance check.

- [x] **Phase 30: UI Polish, Translations, and Launch Readiness**
  - [x] Implement safe category deletion business logic (reassigning transactions when deleting active categories).
  - [x] Define reassignment target filtering rules (Expense to Expense/Custom, Income to Income/Custom, Custom to all).
  - [x] Build category deletion reassignment popup dialog/ModalBottomSheet.
  - [x] Write and run unit test suites for deletion reassignment.
  - [x] Consolidate app branding by exclusively using `assets/icon/app_icon.png` across all screens (Splash, Auth, Dashboard), scaling dynamically.
  - [x] Audit and review translations across English, Spanish, and Catalan to ensure 100% accuracy.
  - [x] Publish apps to production tracks.
  - [x] Monitor crash rates and performance metrics.
  - [x] Establish feedback loop for post-launch adjustments.

- [x] **Phase 31: Automatic Transactions, Inline Validation, & Rolling 30-Day Stats**
  - [x] Implement recurring transaction evaluation engine and database tables for automatic transactions.
  - [x] Develop interactive UI sheets for adding, editing, and evaluating automatic transactions.
  - [x] Refactor transaction creation form notifier to execute inline validations, clearing and resetting field errors dynamically as inputs change.
  - [x] Implement rolling 30-day stats in statistics calculations for dashboard summaries.
  - [x] Fully localize validation errors and automatic transactions elements in English, Spanish, and Catalan.
  - [x] Fix compilation issues and test mocks, ensuring all unit and integration tests pass successfully.
  
- [x] **Phase 32: Stabilization & Auto-Transactions**
  - [x] Ensure maximum code quality and resolve all static analysis issues.
  - [x] Validate `.gitignore` contents and prevent tracking of sensitive data.
  - [x] Guarantee CI/CD pipeline tests complete correctly.
  - [x] Resolve all overflow issues in UI and widgets.
  - [x] Create project documentation updates.

- [x] **Phase 33: UI Polish, Real-Time Reactivity, and Soft-Delete Refinement**
  - [x] Update the initial loading splash icon to display the app logo within a rounded square.
  - [x] Refactor statistics calculations (dashboard summaries and top categories) to use reactive streams, updating instantly in real-time on data changes.
  - [x] Complete localization (i18n) of the Automatic/Recurring Transactions section, including validation states, in English, Spanish, and Catalan.
  - [x] Resolve keyboard occlusion and layout viewport constraints for form error messages.
  - [x] Implement a soft-delete mechanism for recurring/automatic transactions, linking them to the Recycle Bin with dynamic metadata and a 30-day auto-purge cycle.
  - [x] Conduct UI audit to fix text/widget overflows and unintended truncations across Settings and Data Management pop-ups.
  - [x] Resolve all static analysis issues and ensure 100% automated test suite pass rate.

- [x] **Phase 34: Final i18n Audit & Project Documentation Updates**
  - [x] Complete 100% localization (i18n) coverage in `lib/presentation/` by replacing all remaining hardcoded strings.
  - [x] Synchronize ARB files (`app_en.arb`, `app_es.arb`, `app_ca.arb`) with the newly added translation keys.
  - [x] Update project documentation (`README.md` and `roadmap.md`) to reflect the current feature set.

- [x] **Phase 35: Domain Resilience, Compliance Warnings & Splash Polish**
  - [x] Implement safe end-of-month recurrence clamping logic for automatic transactions (February/30th/31st edge cases).
  - [x] Update Terms and Conditions & Privacy Policy across English, Spanish, and Catalan with currency disclaimer warnings to protect developer liability.
  - [x] Reconfigure native splash screen to utilize the rounded-edge icon (`assets/icon/splash_icon.png`) for all themes and platforms.
  - [x] Develop comprehensive unit tests verifying recurrence date calculations under various calendars, short months, and leap years.

