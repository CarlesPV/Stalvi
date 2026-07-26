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

- [x] **Phase 36: PDF Export and About Screen**
  - [x] Refactor PDF Export to prompt for 'Last 30 Days' or 'Current Month'.
  - [x] Implement the 'About Me' localized Markdown screen with an external link.

- [x] **Phase 37: Production Readiness, Background Tasks & UX Polish**
  - [x] Implement multi-currency conversion for total balances on the dashboard and fix the splash screen icon border-radius.
  - [x] Enhance Automatic Transactions UI to display localized recurrence strings and implement background execution via `workmanager`.
  - [x] Perform an exhaustive cleanup of `.arb` localization files (remove unused keys/comments).
  - [x] Fix all CI/CD, analyzer warnings, and update documentation (`roadmap.md`, `README.md`).

- [x] **Phase 38: UI/UX Text Overflow Safeguards & i18n Verification**
  - [x] Wrap dialog and bottom sheet button label widgets inside `FittedBox` to prevent horizontal text overflows under English, Spanish, and Catalan.
  - [x] Resolve layout constraints on `_AccountItem` balance and default label text elements.
  - [x] Audit and verify complete key synchronization across `app_en.arb`, `app_es.arb`, and `app_ca.arb` (all matching exactly with 339 translation keys).
  - [x] Resolve all static analysis warnings, info messages, and ensure all unit/widget tests pass cleanly.

- [x] **Phase 39: UI Localization Polish, Test Stability, and Expanded Overflow Protection**
  - [x] Integrate missing localized strings (`recurrenceUtcWarning`) into the Automatic Transaction Recurrence selection sheet.
  - [x] Localize the GitHub profile button (`aboutMeGithubButton`) on the About Me screen.
  - [x] Implement horizontal scaling protection (`FittedBox` scaleDown) for Expense/Income tabs, Action Buttons, and Custom Recurrence Apply button.
  - [x] Resolve dynamic layout constraints by wrapping custom recurrence apply actions in `Flexible`.
  - [x] Update test assertions in `about_me_screen_test.dart` to verify localized button labels dynamically, maintaining a 100% test pass rate.
  - [x] Fix static analysis errors by defining `colorScheme` inside recurrence selector widgets, guaranteeing 0 warnings and 0 errors on `flutter analyze`.

- [x] **Phase 40: Legal Compliance, Security Finalization & Quality Assurance**
  - [x] Complete detailed rewrite of legal documents (Privacy Policy and Terms & Conditions) with strict GDPR and LOPDGDD compliance across English, Spanish, and Catalan.
  - [x] Add explicit exemption of liability clauses and data immutability/calculation clarifications for currency exchange.
  - [x] Update PDF Export service: respect the original currency of Budgets and Savings Goals instead of defaulting to the profile currency.
  - [x] Update PDF Export service: format transfer transactions in the account column as "Source Account -> Destination Account".
  - [x] Reorganize localization ARB files into logical blocks sorted alphabetically for maintainability.
  - [x] Achieve 100% test pass rate on all unit and widget tests.
  - [x] Run static analysis (`flutter analyze`) and ensure 0 warnings and 0 infos.

- [x] **Phase 41: Read-Only Padlock Indicators**
  - [x] Identify and add padlock icons to read-only/non-editable fields (excluding date fields) on the Budgets and Savings Goals detail sheets.
  - [x] Match padlock design and disabled border styling with the Accounts/Wallets detail views.
  - [x] Run static analysis and tests to ensure 100% compliance.

- [x] **Phase 42: PDF Export Transfer Resolution Fix**
  - [x] Fix transfer destination account resolution in PDF export by querying raw transactions instead of de-duplicated transactions, ensuring mirror legs are correctly resolved and formatted as "Source Account -> Destination Account".
  - [x] Update unit tests to stub raw transaction queries and verify correct behavior.
  - [x] Maintain 100% build health, static analysis compliance, and test pass rate.

- [x] **Phase 43: Backup Username Update & Filename Customization**
  - [x] Ensure restoration updates the active user's profile name in the database with the one preserved in the backup.
  - [x] Standardize export filenames to append `yyyyMMdd_HHmmss` timestamps prefixed with `Stalvi_Backup_`, `Stalvi_Table_`, and `Stalvi_Overview_`.
  - [x] Maintain 100% build health, static analysis compliance, and test pass rate.

- [x] **Phase 44: Exact UTC+2 Calculations & Dual-Execution Background Strategy with Idempotency**
  - [x] Implement exact UTC+2 calculations for recurring transaction trigger dates to avoid timezone discrepancies.
  - [x] Set up dual-execution background strategy executing at 00:00 and 01:00 UTC+2 daily.
  - [x] Introduce UUID v5 URL-based keys for robust idempotency checks, preventing duplicate transaction creation on multiple runs.
  - [x] Write comprehensive unit tests verifying calculation logic across leap years, short months, and idempotency.

- [x] **Phase 45: Package Upgrades, Riverpod 3.0 Migration & QA Pass**
  - [x] Upgrade dependencies including `share_plus`, `workmanager`, and replace `flutter_markdown` with `flutter_markdown_plus`.
  - [x] Upgrade Android build environment to Java 17 compile compatibility.
  - [x] Migrate state providers to Riverpod 3.0 generator annotation syntax.
  - [x] Resolve deprecation warnings (`encryptedSharedPreferences`, `PlatformFile.bytes` usage) and code static analysis warnings.
  - [x] Fix and stabilize unit and widget test suite (timer leaks, platform interface mocks, view bounds, snackbar overflows).

- [x] **Phase 46: Core Bug Fixes & Launch Readiness**
  - [x] **Export Integrity:** Resolve file export issues (PDF, CSV, Backups) on all devices by using proper Scoped Storage (Downloads folder) or robust FileProvider implementations.
  - [x] **Currency Conversion Accuracy:** Enforce correct cross-currency conversions when updating Wallet/Account balances on Incomes, Expenses, and Transfers.
  - [x] **Background Execution Reliability:** Implement a dual strategy (2h Workmanager periodic check + App startup fallback) to ensure Automatic Transactions never fail to create.
  - [x] **Notifications:** Integrate `flutter_local_notifications` to push a localized success message when an automatic transaction fires.
  - [x] **QA & Final Polish:** Guarantee 100% test coverage, 0 lint warnings, and full CI/CD success for app store readiness.

- [x] **Phase 47: Export UX & Directory Optimization**
  - [x] Refactor export services to target public mobile locations adhering to strict directory priority rules (`Download` -> `Downloads` -> `Documents` -> `Stalvi` -> application documents fallback) avoiding app-private `Android/data` paths.
  - [x] Add iOS file sharing keys (`UIFileSharingEnabled` & `LSSupportsOpeningDocumentsInPlace`) to `Info.plist` to expose exports in iOS Files app Recents.
  - [x] Remove `share_plus` dependencies from the project to eliminate third-party share pop-ups.
  - [x] Clean up code architecture, passing all CI/CD, security workflows, tests, and static analysis without warnings.

- [x] **Phase 48: Background Resilience, Optional Notifications & File Export Priorities**
  - [x] **Optional Push Notifications:** Added a user-configurable push notifications toggle in Profile & Security settings (between Language and T&C options, defaulting to ON) with runtime OS permission requests and full localization in English, Spanish, and Catalan.
  - [x] **Workmanager Background Engine:** Configured Workmanager to execute pending automatic transaction evaluations every 3 hours (`Duration(hours: 3)`) in the background, paired with Dashboard load fallback execution and exact UTC+2 date calculation.
  - [x] **File Export Prioritization:** Standardized file saving to target system `Download` -> `Downloads` -> `Documents` -> `Stalvi` directories sequentially before emergency fallback, preventing access errors on various Android versions.
  - [x] **Production Readiness & QA:** Ensured 0 static analysis warnings, 100% test pass rate across all unit and widget tests, and green CI/CD build status.

- [x] **Phase 49: Strict Notification Permissions Workflow, Legal Compliance & Technical Debt Cleanup**
  - [x] **Strict Opt-In Notification Workflow:** Refactored push notification toggle to default to `false` (OFF) for strict user opt-in consent. Integrated native OS permission verification (`isPermissionGranted`, `isPermissionPermanentlyDenied`, `requestPermissions`).
  - [x] **OS Settings Integration:** Implemented system settings redirection dialog (`openAppSettings()`) when notification permissions are permanently denied, providing clear user feedback in English, Spanish, and Catalan.
  - [x] **Store-Ready Legal Compliance:** Updated localized Terms and Conditions (`assets/legal/terms_*.md`) to explicitly detail SQLCipher local encryption, zero-telemetry architecture, minimal exchange rate API connection footprint, GDPR/LOPDGDD compliance, and financial liability disclaimers.
  - [x] **Code Quality & Technical Debt Cleanup:** Cleaned up unused imports, dead code paths, obsolete test files, and orphan translation keys across English, Spanish, and Catalan `.arb` bundles.
  - [x] **QA & Verification:** Maintained 100% test pass rate across unit, widget, and integration tests with zero analyzer warnings (`flutter analyze`).

- [x] **Phase 50: Store-Ready Legal Overhaul**
  - [x] **Legal Content Overhaul:** Overhauled Terms & Conditions and Privacy Policy markdown assets across English, Spanish, and Catalan (`assets/legal/terms_*.md`, `assets/legal/privacy_*.md`) with store-compliant legal provisions including "As-Is" clauses, financial disclaimers, acceptable use policies, and local data non-recovery disclosures.
  - [x] **UI Scrollability Integrity:** Verified UI integrity for large markdown documents in `TermsAndConditionsViewer`, ensuring `SingleChildScrollView` layout rendering prevents overflows across mobile screen sizes.
  - [x] **Static Analysis & Testing:** Ensured 0 static analyzer warnings/infos (`flutter analyze`) and verified 100% automated unit/widget test suite pass rate (`flutter test`).
  - [x] **CI/CD Workflow Readiness:** Verified GitHub Actions CI/CD pipeline compatibility for release deployment.

- [x] **Phase 51: Cross-Platform Background Execution & Recurrence Engine Refactoring**
  - [x] **Background Sync Abstraction:** Abstracted background execution logic into a dedicated domain interface (`BackgroundSyncService`), enabling clean cross-platform task invocation.
  - [x] **Idempotent Background Tasks:** Connected background execution via `workmanager` directly to `ExecuteRecurringTransactionsUseCase` to evaluate scheduled automatic transactions reliably.
  - [x] **Offline Currency Fallback System:** Implemented local fallback exchange rates in the infrastructure layer (`FallbackExchangeRates`) to populate database tables on initialization when network access is unavailable.

- [x] **Phase 52: Legal Compliance Integration & Production CI/CD Finalization**
  - [x] **Store-Ready Legal Compliance:** Drafted and integrated GDPR and App Store/Google Play compliant Terms & Conditions and Privacy Policy across English, Spanish, and Catalan (`assets/legal/terms_*.md`, `assets/legal/privacy_*.md`), reflecting SQLCipher AES-256 local encrypted storage and zero-telemetry architecture.
  - [x] **Static Analysis & Test Suite Integrity:** Resolved all static analyzer issues (`flutter analyze` with 0 warnings, 0 errors) and updated mock/unit tests to achieve a 100% test pass rate.
  - [x] **CI/CD Workflow Synchronization:** Verified and synchronized GitHub Actions CI/CD workflows for Android and iOS automated builds and test runs.

- [x] **Phase 53: Recurrence Precision, Input Rules & Process Exit Reliability**
  - [x] **Automatic Recurrence Date Precision:** Ensured missing past transactions (e.g., app not opened for multiple days/weeks) generate all pending transaction instances with their exact historical dates rather than today's date.
  - [x] **Profile & User Name Input Rules:** Enforced a strict max length of 25 characters for name and username inputs during account creation, preventing emojis and special characters while permitting standard accented letters (tildes in EN, ES, CA).
  - [x] **Cold Application Restart & Database Release:** Fixed database connection deadlock during "Wipe All Data" by introducing a 500ms timeout on database `close()`, allowing clean database deletion and reliable application exit/restart on physical iOS and Android devices.
  - [x] **CI/CD Workflow Alignment:** Synchronized GitHub Actions workflows (`ci.yml` and `security.yml`) for `main` and `develop` branches, ensuring `pod install` and simulator iOS builds pass cleanly.
  - [x] **100% Test Pass Rate & Static Analysis:** Verified all 530 unit, widget, and integration tests pass with zero static analyzer warnings or errors (`flutter analyze --fatal-infos --fatal-warnings`).


---

## Post-Launch / Maintenance

Future ideas, enhancements, and post-release maintenance goals:
- [ ] **Cloud-Encrypted WebDAV / Drive Backup Sync:** Optional opt-in sync to user's private WebDAV server or Google Drive / iCloud keeping zero-telemetry and end-to-end user encryption.
- [ ] **Custom Category Icon & Color Creator:** Allow users to define custom icons and palette colors for categories and accounts.
- [ ] **Advanced Financial Forecasting & AI Insights:** Localized predictive analytics for projected monthly balances and spending pattern anomalies based on historical movements.
- [ ] **Interactive CSV Import Wizard:** Column mapping interface allowing users to import transactions from external banking CSV files.
- [ ] **Wearable Companion App:** Apple Watch and Wear OS glance widgets for quick expense entry and daily balance previews.


