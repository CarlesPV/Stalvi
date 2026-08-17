# Stalvi Roadmap Summary

This document lists the completed phases of the Stalvi development roadmap, providing a concise summary of accomplishments and verification status for each milestone.

## Completed Phases

### Phase 1: Foundation & Security
* **Completion Date:** June 13, 2026
* **Objective:** Establish a secure, Clean Architecture foundation, set up encrypted local storage (SQLCipher + secure storage key management), and implement core presentation/domain utility classes.
* **Accomplishments:**
  - **Directory Structure:** Initialized clean architecture folders (`core`, `data`, `domain`, `presentation`).
  - **Native Setup:** Configured iOS `Podfile` (`use_frameworks!`) and Android `minSdkVersion` (21+) for compatibility with SQLCipher libs.
  - **Drift & SQLCipher:** Created `AppDatabase` utilizing SQLite / SQLCipher with automated key generation and hardware-backed storage via `SecureStorageManager` (Android Keystore / iOS Keychain).
  - **Core Utilities:**
    - Designed custom light and dark `ThemeData` featuring a deep navy blue brand identity and `ThemeExtension`-based financial colors (pastel green for income, pastel coral for expenses).
    - Structured the application's base custom exception hierarchy (`AppException`, `DatabaseException`, `ValidationException`, etc.).
    - Implemented `CurrencyFormatter` for robust formatting, compact representation, locale-specific parsing, and percentage formatting.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Integrated comprehensive unit tests (`test/unit/currency_formatter_test.dart`) showing 100% success rate under automated environments.

### Phase 2: Domain Modeling & Local Storage
* **Completion Date:** June 13, 2026
* **Objective:** Define domain models, repository interfaces, and use cases, implement storage tables in Drift database, write mappers to translate between Drift entities and domain models, and implement the onboarding presentation flow (Splash Screen -> Biometric Auth -> Dashboard).
* **Accomplishments:**
  - **Domain Entities & Interfaces:** Created domain entities (`Profile`, `Account`, `Category`, `Tag`) and defined repository interfaces (`IProfileRepository`, `IAccountRepository`, `ICategoryRepository`, `ITagRepository`).
  - **Drift Tables:** Implemented Drift storage tables (`Profiles`, `Accounts`, `Categories`, `Tags`) matching domain models.
  - **Mappers & Seeding:** Implemented mapping utilities (`ProfileMapper`, `AccountMapper`, `CategoryMapper`, `TagMapper`) to decouple the database from domain entities, and implemented database seeding logic for the default "Anonymous" profile, default "Mi Cartera" account, and default categories ("Food", "Transport", "Salary").
  - **Use Cases:** Implemented `CreateAccountUseCase` enforcing the business rule that a new account must have a valid initial balance.
  - **Presentation Layer:** Developed the onboarding flow consisting of `SplashScreen` (with high-quality animations), `AuthScreen` (biometric authentication using Riverpod and local_auth integration), and `DashboardScreen` skeleton.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Clean architecture unit tests covering `CreateAccountUseCase` (verifying initial balance constraint) and `AppDatabase` seeding (verifying initialization seeding of default entries) with a 100% success rate.
  - Widget and integration test covering the onboarding/startup flow rendering without crashing.

### Phase 3: Transaction Management (Core Engine)
* **Completion Date:** June 13, 2026
* **Objective:** Build the core database structures, repositories, use cases, and interactive presentation interfaces for creating and tracking transactions.
* **Accomplishments:**
  - **Drift Transactions Database & Repositories:** Implemented Drift storage for the `Transactions` table and the concrete implementation of `TransactionRepository` utilizing atomicity controls (executing transactions inside a Drift `transaction()` callback) to ensure accounts balances and transaction insertions synchronize or rollback safely.
  - **Clean Architectures Repositories:** Implemented and Decoupled `AccountRepository`, `CategoryRepository`, and `ProfileRepository` matching repository contracts.
  - **Usecases:** Created the `AddTransactionUseCase` with validations checking for positive amounts, non-future dates, and existing referenced accounts.
  - **Presentation State Notifier:** Created `AddTransactionNotifier` managing the form state inputs and validations while executing the domain layer boundaries.
  - **UI/UX implementation:** Built the premium `AddTransactionScreen` featuring sliding toggles (mint green / coral red accents), modal bottom sheets for account and category list selectors, notes, custom themed datepicker, progress indicator loading flows, and snackbars feedback. Exposed via a dynamic slide-up Floating Action Button on the Dashboard layout.
* **Verification:**
  - Standard static analysis checks (`flutter analyze` with 0 issues).
  - Integration repository tests covering `AccountRepository` and `CategoryRepository` using SQLite in-memory databases.
  - State management tests covering `AddTransactionNotifier` state transitions, validation boundaries, usecase bindings, and type-based category resets.
  - Fully passing automated test suite (`39 tests passed!`).

### Phase 4: Multi-Currency & Goals
* **Completion Date:** June 13, 2026
* **Objective:** Implement the multi-currency infrastructure, update movement creation with currency conversions, model Drift budget and goal tables, build the visual progress bars and budgets/goals listing tab UI screen, and establish automated test coverage.
* **Accomplishments:**
  - **Exchange Rate API Integration:** Created `ExchangeRate` entities, repository interface, and concrete data source using the Frankfurter API via strict HTTPS GET calls. All failures mapped to clean typed `NetworkException`s.
  - **Conversions:** Integrated conversions inside movement usecases keeping integer-based precision.
  - **Local Storage Tables:** Defined Drift tables `Budgets` and `SavingsGoals` with soft-delete controls, and mapped them to domain model representation.
  - **Reactive Stream Repositories:** Implemented stream-based repository contracts (`watchBudgets` and `watchSavingsGoals`) to listen to reactive query streams in Drift.
  - **Reusable ProgressBarWidget:** Built a capsule-style progress indicator that supports smooth tween entry animations and contextual colors (e.g. mint green on track, warning coral red when budget is exceeded).
  - **BudgetsAndGoalsScreen:** Built a beautiful tabbed screen presenting category details, remaining limits, and savings goal milestones. Handles all Riverpod async value states (loading, error, empty list views).
  - **Dashboard Wiring:** Exposed budgets and goals from the settings list inside the main dashboard scaffold.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Full AAA unit tests for Exchange Rate APIs and repository.
  - Mocked widget tests validating loading transitions, error handling, empty lists, progress animation styling, and calculations under varying locales.
  - Full regression test suite: **69 tests passed** successfully.

### Phase 5: Statistics, Filters, & Exports
* **Completion Date:** June 13, 2026
* **Objective:** Build robust analytical aggregations in SQLite, create interactive data visualizations using charts, build reactive filters, and implement secure data export services (PDF, CSV, encrypted JSON).
* **Accomplishments:**
  - **SQLite Aggregations:** Implemented high-performance Drift database queries utilizing `SUM` and `GROUP BY` inside a dedicated `StatisticsDao` to compute period summaries and top-expense/income categories.
  - **Interactive Charts (fl_chart):** Developed a sleek, custom visualizer featuring interactive pie charts with tap handlers, micro-animations, custom tooltips, dynamic surplus/deficit badges, and category legends.
  - **Reactive Filters:** Created Riverpod state providers for filters managing date range presets (This Month, Last 3/6 Months, This Year) and Custom Date Range pickers, automatically recalculating analytical graphs on state change.
  - **Secure Exports:** Implemented three secure export options in `ExportServiceImpl`:
    - **PDF:** Formats monthly financial statements with clean tabular layouts, summary boxes, and metadata labels.
    - **CSV:** Serializes transactions to formatted CSV text representation.
    - **Encrypted JSON:** Encrypts transaction backups using AES-256-CBC with keys derived via PBKDF2-HMAC-SHA256 from user-specified passwords, incorporating random salt and IV headers.
* **Verification:**
  - Fixed a Linux test loader path issue by adding the proper `setUpAll` override block in the database tests.
  - Resolved all lints and formatted the codebase with 0 errors/warnings on `flutter analyze`.
  - Added full test coverage for statistical DAOs, use cases, export encryption/decryption, PDF formatting, and the interactive UI layout.
  - Full regression test suite: **101 tests passed** successfully.

### Phase 6: Polish, Testing & Compliance
* **Completion Date:** June 14, 2026
* **Objective:** Achieve full production-readiness, localize UI/UX, implement advanced privacy controls, construct automated E2E integration test suites, and compile metadata compliance mappings.
* **Accomplishments:**
  - **Dynamic Localization (i18n):** Implemented support for English, Spanish, and Catalan via `flutter_localizations` and standard JSON mapping bundles, driven by a Riverpod-managed user setting.
  - **Advanced Privacy Protections:** Created the dynamic `LifecycleBlurWrapper` (which blurs the app automatically when it is moved into the background/task switcher) and a global "Discreet Mode" toggle to obfuscate sensitive financial figures under a secure mask (`ObfuscatedText`).
  - **Visual Polishing (Anti-Blank Page):** Integrated custom `EmptyStateWidget` implementations in Dashboard and Budgets pages ensuring premium, high-contrast, empty-state illustrations and actionable CTAs.
  - **E2E Integration Testing:** Coded a complete UI integration test (`integration_test/app_flow_test.dart`) covering authorization bypass, Floating Action Button taps, modal bottoms interaction, category selection, and state persistence confirmation.
  - **Compliance Documentation:** Created `docs/compliance/privacy_policy_data_map.md` and `docs/compliance/store_compliance.md` outlining the local-first zero-telemetry architecture, AES-256 database encryption, hardware key store integrations, and pre-composed App Privacy Nutrition labels.
* **Verification:**
  - Resolved unnecessary imports and deprecated `.withOpacity` references, achieving a completely warning-free `flutter analyze` report.
  - Eliminated build-time dependency namespace collisions by removing the redundant `sqlite3_flutter_libs` package.
  - Resolved Gradle build errors and verified that Android compiles successfully into a deployable APK (`app-debug.apk`).
  - Verified the entire automated test suite: **113 tests passed** successfully.

### Phase 7: Secure Onboarding, Initialization & UX
* **Completion Date:** June 14, 2026
* **Objective:** Implement the initial setup profile flow, secure hardware-backed biometric verification, automatic localized default wallets creation, and standardized empty states.
* **Accomplishments:**
  - **Profile Setup Flow:** Designed the profile creation UI featuring a 4-8 digit secure PIN input, dynamic dropdown language selection (English, Spanish, and Catalan), and explicit Terms & Conditions acceptance.
  - **Biometrics Integration:** Integrated biometric authentication (FaceID/TouchID) checking via `local_auth` with automatic prompt on startup and fallback capabilities.
  - **Default Wallet Creation:** Configured automatic creation of a localized default account ("Mi cartera" / "My Wallet") with a zero balance to ensure users do not start with a blank state.
  - **Standardized UI Empty States:** Enforced `EmptyStateWidget` styling across Transactions, Accounts, Budgets, and Statistics lists when no records exist.
* **Verification:**
  - Completed unit tests for `CreateProfileUseCase` and `InitializeDefaultDataUseCase`.
  - Added notifier tests verifying PIN lengths, matching validations, and terms acceptance rules.
  - Added biometric fallback/success service verification tests.
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - All automated test suite regressions run successfully: **151 tests passed**.

### Phase 8: Onboarding Improvements, Localization Polish & Bug Fixes
* **Completion Date:** June 15, 2026
* **Objective:** Resolve onboarding bugs, polish multi-language localization (EN, ES, CA), separate Terms & Conditions and Privacy Policy viewers, enable default currency selection, and refine direct routing flows.
* **Accomplishments:**
  - **Legal Document Split:** Implemented two distinct presentation views to display Terms & Conditions and Privacy Policy independently in the active locale, parsing local markdown assets. Accessible during registration and in settings.
  - **Default Currency Selector:** Added selector dropdown to the profile creation screen and persisted it in profile database configurations.
  - **First-Time Registration Fix:** Resolved the keychain/transient platform channel error during initial registration by introducing a retry-on-failure mechanism in secure storage operations.
  - **Direct Onboarding Routing:** Configured the setup profile flow to transition directly to `AuthStatus.authenticated`, bypassing the PIN screen, and prompting the user for biometric opt-in permission dialog immediately upon landing on the Dashboard.
  - **Default Seeding:** Seeded a default account ("Mi cartera" / "My Wallet" / "La meva cartera") with a 0.0 balance, 13 default typical categories, and 6 default typical tags localized in English, Spanish, and Catalan to prevent empty state screens and guide the user.
  - **Localization Polish:** Fully translated all user-facing strings, error labels, default account names, and seed categories in English, Spanish, and Catalan.
* **Verification:**
  - Refactored `auth_notifier_test.dart` and `biometric_opt_in_screen_test.dart` to match the direct authentication transitions.
  - Resolved compiler and import warnings, ensuring 0 errors and warnings on static analysis (`flutter analyze`).
  - Re-ran the full automated test suite: **166 tests passed** (100% success rate).

### Phase 9: Advanced Settings Management
* **Completion Date:** June 15, 2026
* **Objective:** Implement manual/system dark and light theme mode configuration, a 30-day Recycle Bin, settings list reorganization with top-right profile avatar removal, and a full localization translation audit.
* **Accomplishments:**
  - **Theme Mode Management:** Developed system, light, and dark mode selection controlled by a Riverpod notifier and persisted via `SharedPreferences`.
  - **Drift DB Update:** Added the `isDeleted` flag to the `Transactions` table and incremented the schema version to 4.
  - **TrashDao:** Built `TrashDao` for querying soft-deleted transactions, accounts, and categories.
  - **AutoPurgeUseCase & Hook:** Implemented `AutoPurgeUseCase` that finds and hard-deletes soft-deleted records older than 30 days from the database. Wired it securely into `AppStartupProvider` to execute on app launch.
  - **RecycleBinScreen UI:** Developed a new settings screen UI visualizing the items inside the Recycle Bin, their remaining days to expiration (using red text alerts for items expiring within 3 days), and actions to Restore (which switches `isDeleted` back to false) or Permanently Delete.
  - **Settings Reorganization:** Reordered settings options inside the settings tab for better user flow (Budgets/Goals, Statistics, Profile/Security, Theme Mode, Language, Terms, Privacy Policy), removed the language setting from `ProfileSettingsScreen` (keeping it solely under its dedicated settings tab tile), and removed the redundant top-right profile avatar from the Dashboard app bar.
  - **Full Translation Audit:** Removed hardcoded user-facing strings in `ProfileSettingsScreen` (such as the "Next" button in the PIN flow) and fully localized the Recycle Bin screen (including screen titles, empty states, tooltips, dialogs, and parameterized days-remaining messages) across English, Spanish, and Catalan.
* **Verification:**
  - Wrote comprehensive unit tests for `TrashDao` and `AutoPurgeUseCase` verifying soft-delete retrieval, restoration, and deletion threshold calculations (keeping 29-day-old records, deleting 31-day-old records).
  - Fixed the infinite shimmer animation timeout in the language settings widget tests by refactoring `pumpAndSettle` to discrete `pump` steps and adding `Consumer` widget binding for the active locale.
  - Standard static analysis pass (`flutter analyze`) with 0 errors/warnings on code modifications.
  - Re-ran the full automated test suite: **178 tests passed** successfully.

### Phase 10: Statistics Screen & Aggregation Query Robustness
* **Completion Date:** June 16, 2026
* **Objective:** Ensure robust SQLite data aggregation, prevent null reference errors on empty databases, map database results safely to domain models, update Statistics screen visual states, and cover logic with unit tests.
* **Accomplishments:**
  - **SQLite Aggregation Improvements:** Rewrote `StatisticsDao.getPeriodSummary` and `getTopCategories` queries using separate SELECT queries, explicit sum projections, and null-coalescing operations (`?? 0`) to prevent null reference and mapping failures when the database is empty.
  - **Entity Mapping:** Refactored domain mapping structures to match the updated database outputs for `CategoryStatistic` and `PeriodSummary`.
  - **UI/UX States:** Updated the `StatisticsScreen` layout to handle loading, error, and empty result states gracefully, showing the localized `EmptyStateWidget` if no transactions are recorded.
* **Verification:**
  - Added Drift in-memory database tests in `test/data/database/daos/statistics_dao_test.dart` to verify SQL execution on empty databases and correct grouping/aggregation logic.
  - Ran the full test suite and verified that all tests (including budget, dashboard, auth, and statistics tests) pass without errors.
  - Static analysis (`flutter analyze`) passes with 0 issues.
  - Verification test suite: **189 tests passed** successfully.

### Phase 11: Data Hydration & Empty State Handling
* **Completion Date:** June 16, 2026
* **Objective:** Ensure robust default data hydration during initial profile setup and prevent empty, unusable states when starting the app.
* **Accomplishments:**
  - **Data Hydration UseCase Try/Catch:** Wrapped `InitializeDefaultDataUseCase` execution in a robust try/catch block with logs so errors do not crash the onboarding process.
  - **Awaited Onboarding Setup:** Guaranteed that profile creation and data seeding are fully `await`ed before navigating to the main dashboard.
  - **Highly Visible Fallback in Dashboard:** Added a visible fallback "Empty State Widget" with an action button prompting the user to create an Account manually in case data hydration was interrupted.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - All automated test suites (including dashboard widget tests and initialization unit tests) pass successfully.

### Phase 12: Profile and Settings Consolidation
* **Completion Date:** June 16, 2026
* **Objective:** Remove the concept of a separate "Profile Account" main section by consolidating Theme, Language, Terms & Conditions, and Privacy Policy directly into the "Profile & Security" settings screen.
* **Accomplishments:**
  - **Settings Consolidation:** Moved Theme Mode, Language selection, Terms & Conditions, and Privacy Policy from the main Settings tab into the `ProfileSettingsScreen`.
  - **Recycle Bin Access:** Added a dedicated button for the `RecycleBinScreen` directly in the main Settings tab.
  - **Code Cleanup:** Simplified the `DashboardScreen`'s Settings tab builder to exclusively list top-level modules (Budgets & Goals, Statistics, Profile & Security, Recycle Bin).
* **Verification:**
  - Verified static analysis (`flutter analyze` with 0 issues).
  - Updated widget tests in `dashboard_screen_test.dart` to assert the presence of the Recycle Bin tile instead of the Language dropdown.
  - Ran full test suite, all tests passing successfully.

### Phase 13: SQLCipher FFI Binding & Isolate Crash Fix
* **Completion Date:** June 16, 2026
* **Objective:** Resolve dynamic library loading failure (`libsqlite3.so`) caused by isolate boundary FFI configuration issues in SQLCipher.
* **Accomplishments:**
  - **FFI Binding Fix:** Replaced `NativeDatabase.createInBackground` with the standard `NativeDatabase` constructor. This forces SQLCipher database connections to initialize on the main thread where the native library override (`open.overrideFor(OperatingSystem.android, openCipherOnAndroid)`) was configured.
  - **Thread-Safety & Performance:** Preserved Drift's asynchronous query architecture while ensuring library load operations run reliably without spawning thread contexts that fail to inherit native overrides.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Validated that the app launches successfully on Android without library loading failures.

### Phase 14: PIN UX, Dashboard Polish, Transaction Sorting, and Tag/Category Localization
* **Completion Date:** June 16, 2026
* **Objective:** Polish user settings flows (popup errors), dashboard layouts (flicker bug), transactions order (date and time sorting), default tags usability (event/organization categories), and dynamic database localization for the 3 supported languages.
* **Accomplishments:**
  - **PIN UX Improvement:** Refactored the PIN change flow to display "PINs do not match" inside the dialog popup instead of a floating Snackbar to match other input error notifications.
  - **Dashboard Loading Animation Fix:** Removed the flickering loading/skeleton trend trend box that remained permanently visible under some states on the dashboard.
  - **Transaction Sorting Order:** Updated the Drift transaction query sorting to order movements strictly by `date` (descending) and `createdAt` (descending) to avoid ordering issues for multiple transactions on the same day.
  - **Default Tags Redo:** Replaced the previous generic tags with purpose-driven tags for event and organization groupings (Summer Trip, Event, Project, Wedding, Birthday, Business Trip).
  - **Dynamic Localization & Seeding:**
    - Updated default categories and tags to use stable hardcoded UUIDs.
    - Implemented cleanup logic to purge old default tags and duplicates created under random UUIDs.
    - Updated app startup provider and locale setting transitions to invoke translation checks, translating default database category and tag entries dynamically to the active locale (English, Spanish, and Catalan) on the fly.
* **Verification:**
  - Added repository mock stubs and verified tests in `initialize_default_data_usecase_test.dart`.
  - Guarded locale database updates to prevent test suite compilation hangs under widget scopes.
  - Re-ran the full automated test suite: **201 tests passed** (100% success rate).
  - Verified compilation and static analysis (`flutter analyze` with 0 issues).

### Phase 15: Advanced Transaction Filtering & Statistics Eager Initialization
* **Completion Date:** June 17, 2026
* **Objective:** Implement a robust multi-dimensional transaction filtering state/engine and eliminate statistics screen load latency.
* **Accomplishments:**
  - **Transaction Filter State Management:** Developed the `TransactionFilter` model and `TransactionFilterNotifier` (Riverpod) managing concurrent parameters: Type, Category, Date Range, Amount Range, Tag, and Currency.
  - **Drift DB Filter Query Engine:** Added the repository layer method `watchFilteredTransactions(TransactionQueryFilter)` with custom helper mapping and dynamic logical-AND expression builders to enforce multiple filter constraints simultaneously in SQLite.
  - **Eager Statistics Loading (Pre-warming):** Refactored statistics future providers to auto-dispose, using `initState` post-frame callback bindings to eagerly read them, achieving sub-second initial loads on screen mount without visual lag.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Wrote a dedicated suite of 21 test scenarios in `test/data/database/daos/transaction_filter_query_test.dart` checking all concurrent permutations of filters against an in-memory database.
  - Verified that the entire regression test suite passes cleanly.

### Phase 16: UI, Localization, and Soft-Deleted Data Fixes
* **Completion Date:** June 17, 2026
* **Objective:** Fix validation error displays in dialogs, resolve ChoiceChip text layout clipping and update the generic "Other" type icon, support multi-language locale-aware date displays, implement dashboard account clicks for updates/deletion, and ensure soft-deleted database entities are excluded from statistical aggregates.
* **Accomplishments:**
  - **Validation Inline Errors:** Configured name inputs in `CreateAccountDialog` and `EditAccountDialog` to display validation failures inline via the standard `errorText` field.
  - **Account Types UI Polish:** Heightened choice chip containers to `56` to avoid vertical layout clipping. Replaced `Icons.more_horiz_rounded` with `Icons.monetization_on_rounded` for the "Other" account type choice.
  - **Account Details & Updates:** Integrated `EditAccountDialog` triggers directly on account tap list gestures from the primary dashboard scope, permitting full name/type/color customization and soft-deletes (Recycle Bin moves).
  - **Soft-Deleted Balance Synchronization:** Enforced database transaction logic in `TransactionRepository.deleteTransaction` and `TrashDao.restoreItem` to revert/re-apply financial amounts to parent accounts dynamically on delete or restore.
  - **Exclusions in Statistics:** Updated SQLite aggregation projections inside `StatisticsDao` to join with the `Accounts` table and filter out soft-deleted items across transactions, categories, and accounts.
* **Verification:**
  - Integrated dedicated tests inside `statistics_dao_test.dart` and `trash_dao_test.dart` verifying exclusions and balance restoration actions.
  - Regenerated code wrappers (`build_runner` and `gen-l10n`) cleanly.
  - Achieved 100% test pass rate with all 246 tests passing successfully.

### Phase 17: Multi-Account Statistics, Transaction Transfers, and Localization Polish
* **Completion Date:** June 18, 2026
* **Objective:** Support multi-account filtering on the Statistics screen, implement transaction transfer flows in the creation form, perform validation checks, and localize the dashboard multi-account summary text using pluralized `.arb` strings.
* **Accomplishments:**
  - **Multi-Account Statistics:** Configured `StatisticsFilterNotifier` to automatically load data for the `isDefault` account on startup, and added an account selector dropdown at the top of the Statistics screen to filter totals and top categories by account.
  - **Transaction Transfers UI:** Added support for the `Transfer` type in `AddTransactionScreen`. When selected, it dynamically displays "From Account" and "To Account" dropdown selectors.
  - **Transfer Validation:** Implemented validation preventing users from selecting the same account for both source and destination in a transfer.
  - **Dashboard Pluralization:** Wired the `acrossAccountsCount` localization key from the `.arb` bundles into the Dashboard balance card, replacing the hardcoded English text.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Resolved `dashboard_screen_test.dart` failures caused by multiple listeners on the single-subscription `transactionsStream` by converting it to a broadcast stream.
  - Achieved 100% test pass rate with all 314 tests passing successfully.

### Phase 18: Dynamic Initial Database Entity Localization & UI Polish
* **Completion Date:** June 18, 2026
* **Objective:** Dynamically localize the default database entities (e.g. default account/wallet name) on initialization to match the device's locale settings, ensuring Clean Architecture principles are followed by passing localized values from the presentation layer, and resolve layout widget constraints in widget test environments.
* **Accomplishments:**
  - **Dynamic Wallet Localization:** Refactored `InitializeDefaultDataUseCase` to accept a dynamic `walletName` argument rather than hardcoding.
  - **Clean Architecture Providers:** Updated `AppStartupProvider` and `AuthNotifier` to read the active locale, resolve the localized wallet name (e.g., using direct lookup of localization bundles `lookupAppLocalizations(locale).defaultWalletName` with appropriate Catalan, Spanish, and English fallbacks), and inject it into the initialization flow.
  - **Material Dialog Wrappers:** Wrapped bottom sheets in `Material` inside `CreateAccountDialog` and `EditAccountDialog` to prevent background ink splash errors/warnings when executing widget tests that render list tiles.
  - **Test Suite Updates:** Updated unit and widget tests (including `initialize_default_data_usecase_test.dart` and `auth_notifier_test.dart`) to mock and verify dynamic wallet name resolutions under Catalan, Spanish, and English environments.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Clean build generation and l10n compilation (`flutter gen-l10n`).
  - Achieved 100% test pass rate with all 322 tests passing successfully.

### Phase 19: Complex Cascades, Riverpod Reactivity & Deep UX Polish
* **Completion Date:** June 18, 2026
* **Objective:** Implement referential integrity (cascading deletes), double-entry transaction mirroring for transfers, real-time provider invalidations, system wipe and cold restart, UI/UX details refinements, dynamic menu structures, global localization coverage audit, and CI workflow compilation safety.
* **Accomplishments:**
  - **Transfer Mirroring Logic:** Built transfer creation logic generating paired database records linked by `transferId` (representing origin and destination accounts). Ensured that soft-deleting, hard-deleting, or restoring one leg of a transfer automatically performs the same action on the other leg.
  - **Reactivity & Provider Invalidation:** Ensured creating, editing, restoring, or deleting transactions/accounts immediately invalidates target providers (e.g. accountsListProvider, transactionsStreamProvider, periodSummaryProvider, categoriesListProvider) to guarantee real-time UI updates.
  - **UI/UX Refinements:**
    - Hidden empty "Notes" section inside the transaction details sheet.
    - Standardized modal sheets title to show the localized transaction type (Income, Expense, Transfer) instead of a generic header.
    - consistently formatted all inputs/errors inline.
  - **Reorganization of Settings:** Moved "Categories & Tags" out of "Profile & Security" screen and placed it directly as a main Settings page option, located between "Statistics" and "Profile & Security".
  - **Cascading Deletes:** Deleting or trashing an account cascades trashing to all associated transactions, automatically adjusting account balances and keeping totals synchronized.
  - **Recycle Bin Hard Delete Refresh:** Configured permanent deletes in the Recycle Bin to force a global provider refresh, updating accounts and statistics immediately.
  - **App Wipe and Cold Restart:** Modified "Delete all data" action to completely drop the database and call `SystemNavigator.pop()` to trigger a cold application exit.
  - **Global Localization Audit:** Fully localized the category/tag management sheets, delete error warnings, and reassign forms. Replaced all remaining hardcoded labels in `DashboardScreen`, `CategoriesTagsManagementScreen`, `EditAccountDialog`, `CreateAccountDialog`, and `TransactionDetailsDialog`.
  - **CI/CD Integration:** Integrated `flutter gen-l10n` build steps into the Stalvi Flutter CI (`ci.yml`) and Security Audit (`security.yml`) workflows.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Clean build generation and l10n compilation (`flutter gen-l10n`).
  - Fixed 54 auto-fixable lint issues (trailing commas) and cleaned up unused declarations/imports in tests.
  - Achieved 100% test pass rate with all 351 tests passing successfully.

### Phase 20: Advanced Localization Audit & Mobile Layout Robustness
* **Completion Date:** June 18, 2026
* **Objective:** Conduct a comprehensive audit of the core layout structures, ensure all text fields and labels adapt gracefully to tight mobile screen viewports, eliminate inline localization checks in the Transfer UI, and verify 100% automated test compliance.
* **Accomplishments:**
  - **Localization Refactoring:** Replaced hardcoded inline language code checks in `AddTransactionScreen` for "From Account", "To Account", "Select Source Account", and "Select Destination Account" with fully localized keys (`labelFromAccount`, `labelToAccount`, `selectSourceAccount`, `selectDestinationAccount`) in `app_en.arb`, `app_es.arb`, and `app_ca.arb`.
  - **Layout Constraints & Overflow Prevention:**
    - Modified `_FormSelectorTile` inside `AddTransactionScreen` to restrict text fields using `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
    - Enhanced `_AccountItem` and `_TransactionItem` inside `DashboardScreen` by wrapping trailing balance and amount columns/texts in `Flexible` controls and setting truncation parameters on the account types and dates.
    - Updated `_PieChartWithLegend` and `_TouchedCategoryInfo` in `StatisticsScreen` to wrap category name labels in `Flexible` widgets and enforce single-line truncation to handle long category names elegantly.
  - **Code Generation:** Re-ran `flutter gen-l10n` to successfully compile the newly added localization keys across all targets.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Executed the full automated test suite containing 352 unit and widget tests with a 100% success rate.

### Phase 21: Transfer Flow Polish, Recycle Bin Refinements & Validation
* **Completion Date:** June 19, 2026
* **Objective:** Polish transfer movements, ensure exact record counts, update recycle bin behaviors, and verify that balance calculations are correct when deleting/restoring transactions.
* **Accomplishments:**
  - **Transfer Flow Polish:**
    - Cleared note field default value on transfer creation forms to start empty.
    - Implemented database-level mirroring for transfers. Exactly 1 leg of a transfer is shown in the global lists, while filtered account lists show the correct leg without duplicates.
    - Standardized list tile transfer icons to consistently show `Icons.swap_horiz_rounded` regardless of whether they represent an incoming or outgoing leg.
    - Integrated a raw transaction query stream (`watchRawTransactions`) in `TransactionRepository` and created `rawTransactionsStreamProvider`. This is used in `TransactionDetailsDialog` to retrieve the mirror transaction leg, dynamically identifying and displaying both origin and destination accounts correctly.
  - **Recycle Bin Polish:**
    - Disabled "Delete All / Empty Sweep" option inside the recycle bin to avoid accidental deletion.
    - Enforced automatic provider auto-disposal to refresh the Recycle Bin screen whenever users enter the view.
    - Modified delete mirroring so deleting a transfer places exactly 1 consolidated item inside the recycle bin list.
    - Structured additional metadata fields (`amount`, `txType`, `currency`) in `TrashDao` for `TrashItem` instances. Refactored the Recycle Bin list tiles to dynamically render items formatted as `<Note/Type> - <Amount>` using localized translations.
  - **Robust Calculations:**
    - Ensured that trashing, restoring, or hard-deleting a transaction (including mirrored transfers) properly reverts or re-applies the financial balances for both accounts.
* **Verification:**
  - Run full suite of 352 unit and widget tests ensuring a 100% pass rate.
  - Static analysis (`flutter analyze`) returns 0 issues and 0 warnings.

### Phase 22: Multi-Currency Snapshot, Auth Fallbacks & i18n Completeness
* **Completion Date:** June 19, 2026
* **Objective:** Implement historical exchange rate snapshots per transaction, add background synchronization of exchange rates, resolve fallback PIN authentication when biometric authentication fails or is cancelled in sensitive flows, and complete full internationalization (i18n) coverage.
* **Accomplishments:**
  - **Multi-Currency Snapshot & Sync:**
    - Modified the `Transactions` table and entity to include `exchangeRateSnapshot` for storing exchange rates at transaction creation time.
    - Implemented background synchronization (`SyncExchangeRatesUseCase`) running on app startup to keep currency exchange rates up-to-date in the database.
  - **Auth & Onboarding UX:**
    - Updated profile registration and startup flows to resolve localized wallet names ("My Wallet", "Mi cartera", "La meva cartera") dynamically.
    - Refactored `AuthScreen` PIN fallback logic to allow entering the PIN if biometric authentication fails, is locked out, or is cancelled, ensuring users can delete all data or access sensitive areas securely.
  - **100% Localization Coverage:**
    - Conducted a comprehensive audit of missing UI states. Extracted and localized all loading, error, and progress feedback states across English, Spanish, and Catalan.
    - Updated `AppLocalizations` definitions and regenerated l10n bindings cleanly.
* **Verification:**
  - Clean run of static analysis (`flutter analyze` with 0 issues).
  - Executed the entire suite of 357 unit, integration, and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 22.1: Multi-Currency Immutability & Background Sync
* **Completion Date:** June 19, 2026
* **Objective:** Ensure financial accuracy by saving local JSON exchange rate snapshots inside transactions, isolating default wallet initialization to the onboarding registration flow, and calculating statistics and dashboard summaries using historical snapshot math instead of pure SQL database sums.
* **Accomplishments:**
  - **Local Exchange Rate Caching**: Created ExchangeRate entity, local/remote data sources, and database table.
  - **Historical Rate Snapshots**: Added `exchangeRateSnapshot` text column to the `Transactions` table to persist historical exchange rates as a JSON string when transactions are created.
  - **Registration-scoped Initialization**: Isolated the default wallet creation to onboarding registration only, avoiding premature wallet initialization on app start.
  - **Dynamic Snapshot Calculations**: Refactored `StatisticsDao` and `StatisticsRepositoryImpl` to query the list of transactions in a period and aggregate the sums in the Dart layer by parsing the `exchangeRateSnapshot` JSON, ensuring correct currency calculations even if default profile currencies change.
* **Verification:**
  - Fixed test assertion issues in `profile_settings_screen_test.dart` and aligned biometrics fallback verification string.
  - Updated `statistics_dao_test.dart` to assert transaction queries on the updated DAO methods.
  - Clean pass of static analysis (`dart analyze`) with 0 errors/warnings on edited code.
  - Executed the full automated test suite (361 tests passed successfully!).

### Phase 22.2: Localization Completeness, Unused Translation Cleanup, and Layout Polish
* **Completion Date:** June 21, 2026
* **Objective:** Audit the translation catalog to remove unused keys, localize hardcoded budget spent formatting, polish UI layouts to avoid text overflows, map validation errors to localized keys, and ensure all tests and lint checks pass cleanly.
* **Accomplishments:**
  - **Unused Key Cleanup**: Audited the three `.arb` localization files (`app_en.arb`, `app_es.arb`, `app_ca.arb`) and removed 15 unused translation keys (`authAuthenticate`, `authCheckingBiometrics`, `authSetupTermsCheckbox`, `authSkip`, `authVerifyIdentity`, `authVerifying`, `createAccountSuccess`, `defaultWallet`, `defaultWalletName`, `errorAuth`, `errorDatabase`, `errorGeneric`, `errorNetwork`, `myWallet`) to keep the localization bundles clean and minimal.
  - **Budget Spent Localization**: Extracted the hardcoded budget progress spent string format (previously `'$spentStr of $targetStr'`) into a new localizable key `budgetSpentOf` across all three supported languages (English, Spanish, Catalan), adapting the format to `{spent} of {target}` / `{spent} de {target}` dynamically.
  - **Validation Error Mapping**: Linked the `INVALID_NAME` `ValidationException` code inside `EditAccountDialog` to return the localized `createAccountErrorName` message, ensuring dynamic localization for validation errors.
* **Verification:**
  - Standard static analysis pass (`flutter analyze`) with 0 errors on modified files.
  - Executed the full automated test suite containing 361 unit and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 23: Backups, and Import/Export Validations
* **Completion Date:** June 22, 2026
* **Objective:** Design and implement a secure, encrypted local backup system using AES-256-CBC, validate imports/exports cross-platform, clean up formatting, resolve static analysis, and verify all tests pass successfully.
* **Accomplishments:**
  - **Encrypted Local Backups**: Added cryptographic JSON exports/imports using user-defined passwords. Derived keys via PBKDF2-HMAC-SHA256 from user-specified passwords, incorporating random salt and IV headers.
  - **Database Restoration**: Implemented `IImportService` and `ImportServiceImpl` to decrypt, validate, parse, and restore full database snapshots (Accounts, Categories, Tags, and Transactions).
  - **Atomic Transaction Import**: Ensured that the database is atomically wiped (transactions, accounts, categories, tags) inside a single Drift transaction block and re-populated in foreign-key safe order. Kept user profiles intact during import.
  - **Launcher Icons & Splash Screen**: Configured `flutter_launcher_icons` and `flutter_native_splash` utilizing rounded rectangle (squircle) logos, conforming to light/dark themes (`#F8FAFC` / `#0B0F19`) and Android 12+ guidelines.
  - **Test Suite expansion**: Created unit test suite for `ImportServiceImpl` utilizing `mocktail` (4 new unit tests), verifying decryption errors, parsing exceptions, unsupported versions, and successful database restoration.
* **Verification:**
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Executed the entire suite of 359 unit, integration, and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 24: Financial Immutability, Export Engine & UI Polish
* **Completion Date:** June 24, 2026
* **Objective:** Ensure historical transaction data integrity, improve data export capabilities (PDF/CSV/JSON), and fix critical UI/UX overflows and layout issues.
* **Accomplishments:**
  - **Financial Immutability**: Added an `exchangeRateSnapshot` field to transactions and updated database mapping logic to store snapshots at creation time, preserving historical balance integrity. Calculate all Statistics (dashboard summaries and top categories) dynamically in real-time, performing live currency conversions based on unrounded integer cents across multi-currency accounts.
  - **Export Engine Enhancements**: Enhanced CSV and PDF generation to export complete data fields (including historical rates), formatted totals using active local currency symbols, and appended timestamps to filenames. Fully localized PDF strings (`AppLocalizations`) and appended `pw.PieGrid` charts for top income and expense categories.
  - **Data Import Flow**: Modified the backup import pipeline to invalidate Riverpod providers, purge memory caches, and trigger a clean application restart via the navigator key to prevent transient state issues after data restoration.
  - **UI/UX Polish**: Removed the redundant "Net Balance" summary from the Accounts tab, leaving a clean "Statistics" section header and entry point. Centered the transaction amount initially in the "Add Transaction" screen, allowing it to dynamically expand leftwards on large inputs. Fix the missing visibility toggle (eye icon) on the backup confirmation password field and resolved global UI overflows.
* **Verification:**
  - Resolved BuildContext async gap warnings (`use_build_context_synchronously`) in `data_management_screen.dart`.
  - Deleted unnecessary scratch file `test_downloads.dart`.
  - 100% passing rate on code analysis (`flutter analyze` with 0 issues).
  - 100% success rate on the complete 363 tests suite (`flutter test`).

### Phase 25: Currency Engine Optimization, Reactivity, and Advanced Reports
* **Completion Date:** June 25, 2026
* **Objective:** Optimize the currency exchange engine, ensure real-time dashboard and statistics reactivity on currency updates, implement multi-currency cross-account transfers, generate advanced localized PDF reports with pie charts/visual statistics, implement direct file opening capabilities via `open_filex`, and perform a UI/UX audit for overflow issues.
* **Accomplishments:**
  - **Yuan Integration:** Fully integrated Chinese Yuan (CNY) into default currency options, models, localizations, and calculations.
  - **Currency Cache Optimization:** Updated `ExchangeRateRemoteDataSource` to store rate data locally for 24 hours, restricting outbound queries to only the 8 supported currencies to minimize network overhead.
  - **Dynamic Reactivity:** Refactored Riverpod provider hierarchies so statistics and dashboard summaries immediately recalculate and update when default currency configurations are changed.
  - **Cross-Currency Transfers:** Upgraded `AddTransactionUseCase` to detect transfer requests across different currencies, querying dynamic exchange rate snapshots to calculate accurate destination amounts.
  - **Advanced PDF Reports:** Rewrote PDF monthly exports to include beautiful income/expense pie charts, category breakdown percentages, and detailed summaries all converted to the default currency.
  - **Direct File Opening:** Added the `open_filex` dependency and integrated interactive "Open" actions on success Snackbars when exporting CSV/PDF reports in the Data Management Screen.
* **Verification:**
  - Fixed issue in PDF pie charts rendering logic that caused rendering overflows for very small slices.
  - Resolved minor static analysis warnings regarding package dependency constraints in `pubspec.yaml`.
  - Executed tests showing 100% success rate for all unit and widget tests (381 tests passed successfully!).

### Phase 26: QA/Layout Readiness and Production Audit
* **Completion Date:** June 27, 2026
* **Objective:** Audit layout widgets for potential overflows, add defensive size limits, shrink resources, secure Git dependencies, and prepare build bundles for initial Play Store release tracks.
* **Accomplishments:**
  - **Layout Constraints & Ellipsis:** Audited all UI files for layout safety under extreme screen scales. Added single-line constraints, `TextOverflow.ellipsis`, and `Flexible` controls on account item balances, statistics widgets, transaction amounts, and dashboard header total texts.
  - **Custom ObfuscatedText Settings:** Exposed text alignment, overflow, soft-wrap, and max-lines limits inside the custom `ObfuscatedText` widget to match general typography adjustments.
  - **Asset Optimization**: Deleted unused large legal documents in Markdown format inside `assets` directory to shrink compile sizes.
  - **Build Setup Audit**: Configured Proguard rules for code obfuscation and resource shrinking (`shrinkResources true`) in `android/app/build.gradle`.
  - **Automated Tests**: Completed validation of widget behaviors under different viewport shapes (simulating small screens/keyboards).
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed tests showing 100% success rate for all unit and widget tests (381 tests passed successfully!).

### Phase 27: UI Constraints for Budgets, Goals, and Recycle Bin
* **Completion Date:** June 30, 2026
* **Objective:** Implement input rules for budgets/goals sheets, enable active savings goals selection inside transfers, render soft-deleted budgets and savings goals inside the trash lists, and ensure full localization.
* **Accomplishments:**
  - **Edit-mode locks**: Restricted Budgets and Savings Goals edits so `Target Amount` and `Currency` cannot be modified post-creation to ensure financial history consistency.
  - **Required Selection**: Enforced account selection requirement when creating a budget to prevent orphan budgets.
  - **Transfer Target Routing**: Added active Savings Goals into the destination selector dropdown inside the Transfer creation form, allowing users to transfer funds directly from standard wallets into active savings goals.
  - **Soft-deleted Budgets/Goals**: Configured `TrashDao` and the Recycle Bin lists to query and display soft-deleted Budgets and Savings Goals, supporting full Restore and Permanent Delete commands.
  - **Parity in Localization**: Localized all dialog messages, empty states, and action sheets in English, Catalan, and Spanish.
* **Verification:**
  - Fixed compile failures in test files caused by constructor updates on drift mocks.
  - Standard static analysis pass (`flutter analyze` with 0 issues).
  - Executed tests showing 100% success rate for all unit and widget tests (393 tests passed successfully!).

### Phase 28: Financial Integrity, Editing, and Final Polish
* **Completion Date:** July 5, 2026
* **Objective:** Implement update operations, budget spent recalculation, database triggers for savings goals restoration, Roboto font embeddings for unicode characters in PDF exports, update legal assets, and verify CI/CD pipelines.
* **Accomplishments:**
  - **Update Operations**: Added update logic in UI and Domain for Budgets and Savings Goals.
  - **Dynamic Spent Recalculations**: Connected transaction updates and deletions to trigger reactive budget spent progress adjustments, correctly converting currencies when transactions are in a different currency.
  - **Trash Integrity**: Configured deletion of a Savings Goal to soft-delete it and automatically refund its current progress amount back to the origin account. Restoring a Savings Goal from the Recycle Bin re-applies the balance.
  - **Roboto Font Embed**: Embedded Roboto TTF fonts into the PDF exporter to correctly render currency symbols (e.g. €, $, £, ¥) across all locales.
  - **Legal Documents Update**: Rewrote Privacy Policy and Terms and Conditions in English, Spanish, and Catalan to reflect multi-currency calculation limits and liability disclaimers.
* **Verification:**
  - Resolved static analysis errors and widget test warnings.
  - Executed tests showing 100% success rate for all unit and widget tests (393 tests passed successfully!).

### Phase 29: Release Preparation and UI Optimization
* **Completion Date:** July 10, 2026
* **Objective:** Alleviate onboarding friction, remove outdated menu triggers, purge translation key discrepancies, test builds, and verify store listing setups.
* **Accomplishments:**
  - **Dashboard Simplification**: Removed long-press guestures for default account updates, replacing with straightforward tap-to-edit interactions.
  - **ARB Cleanup**: Safely deleted unused translation keys and developer comments from Catalan, Spanish, and English files.
  - **Build Verification**: Compiled release AAB and iOS IPA bundles. Aligned localized store graphics and metadata assets.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 30: UI Polish, Translations, and Launch Readiness
* **Completion Date:** July 11, 2026
* **Objective:** Implement category deletion safety and dynamic transaction reassignment flows, unify app branding with a single app icon asset, audit translations, and prepare store deployments.
* **Accomplishments:**
  - **Safe Category Deletion**: Prevented orphan transactions by prompting users to reassign transactions to a different category before deleting a category.
  - **Reassignment Rules**: Filtered target selection categories strictly by type (Expense to Expense/Custom, Income to Income/Custom, Custom to all).
  - **Unified Branding**: Standardized the use of `assets/icon/app_icon.png` across all onboarding and app views.
  - **Deployments**: Uploaded release packages to Google Play Console and App Store Connect testing tracks.
* **Verification:**
  - Added unit test cases for category deletion reassignment rules.
  - Clean run of static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 31: Automatic Transactions, Inline Validation, & Rolling 30-Day Stats
* **Completion Date:** July 12, 2026
* **Objective:** Implement recurring transaction templates, inline error clearing on inputs, rolling 30-day stats on dashboard, and localization.
* **Accomplishments:**
  - **Recurring Transactions**: Created database tables and evaluation engine for automatic transaction generation based on custom day intervals.
  - **Form Validation UX**: Configured text input fields to clear their validation error badges in real-time as users start typing.
  - **Rolling 30-Day Stats**: Programmed the statistics calculator to compile summaries using a rolling 30-day window on the dashboard rather than hard calendar months.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 32: Stabilization & Auto-Transactions
* **Completion Date:** July 13, 2026
* **Objective:** Polish automatic transaction UI sheets, verify gitignore security rules, resolve static analysis, and secure CI pipelines.
* **Accomplishments:**
  - **UI Polish**: Refactored automatic transaction settings and fields layout.
  - **Security Auditing**: Confirmed that `.gitignore` correctly prevents tracking of `.env` files and local backups.
  - **CI Verification**: Ran build checks inside GitHub Actions configurations.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 33: UI Polish, Real-Time Reactivity, and Soft-Delete Refinement
* **Completion Date:** July 13, 2026
* **Objective:** Enhance onboarding splash UI, implement reactive streams for statistics summaries, localize automatic transactions, and link templates to the Recycle Bin.
* **Accomplishments:**
  - **Splash Screen Upgrade**: Updated onboarding logo container to render the logo inside a premium rounded square.
  - **Reactive Statistics**: Converted `StatisticsScreen` queries to live reactive streams so charts update in real-time.
  - **Recurring Templates Trash**: Added soft-delete capabilities to automatic transaction templates, sending them to the Recycle Bin and stopping generation until restored.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 34: Final i18n Audit & Project Documentation Updates
* **Completion Date:** July 13, 2026
* **Objective:** Complete full localization of presentation screens, clean up ARB files, and synchronize documentation.
* **Accomplishments:**
  - **I18n Audit**: Replaced all remaining hardcoded strings in widgets.
  - **ARB Synchronization**: Verified matching key counts across English, Spanish, and Catalan.
  - **Docs Sync**: Updated README and roadmap to represent the latest feature set.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 35: Domain Resilience, Compliance Warnings & Splash Polish
* **Completion Date:** July 14, 2026
* **Objective:** Handle calendar recurrence clamping boundary edge cases, add liability disclaimers to legal text, and unify native splash screens.
* **Accomplishments:**
  - **Recurrence Date Clamping**: Programmed calendar calculations to safely handle recurrence execution dates during short months (e.g. monthly schedules executing on 30th/31st clamp to 28th/29th in February).
  - **Legal Updates**: Added explicit disclaimers regarding developer liability for currency market fluctuations.
  - **Native Splash Screen**: Synced native splash configurations to use `assets/icon/splash_icon.png` across Android and iOS themes.
* **Verification:**
  - Added unit test coverage for short-month recurrence boundaries and leap years.
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 36: PDF Export and About Screen
* **Completion Date:** July 14, 2026
* **Objective:** Add date range options to PDF exports, and implement the Markdown About screen.
* **Accomplishments:**
  - **PDF Export Date Range**: Prompted users to choose between 'Last 30 Days' or 'Current Month' when exporting reports.
  - **About Me Screen**: Created a localized Markdown About view with external developer contact links.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 37: Production Readiness, Background Tasks & UX Polish
* **Completion Date:** July 14, 2026
* **Objective:** Implement dashboard currency consolidation, background Workmanager scheduling, ARB cleanup, and docs sync.
* **Accomplishments:**
  - **Dashboard Balance Conversion**: Mapped dashboard total balances to automatically convert and summarize all accounts under the default currency.
  - **Background Workmanager**: Configured background tasks using `workmanager` to trigger automatic transaction updates daily.
  - **Localization Cleanup**: Cleaned up orphan translation keys.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All tests passed successfully.

### Phase 38: UI/UX Text Overflow Safeguards & i18n Verification
* **Completion Date:** July 14, 2026
* **Objective:** Polish button layouts, prevent text overflows, verify ARB parity, and fix test warnings.
* **Accomplishments:**
  - **Horizontal fitted boxes**: Wrapped dialog and bottom-sheet action labels in FittedBox to handle varying text lengths.
  - **ARB Parity**: Synced key counts exactly across English, Spanish, and Catalan.
* **Verification:**
  - Fixed pre-existing widget test warning and unused imports.
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed tests showing 100% success rate for all unit and widget tests (464 tests passed successfully!).

### Phase 39: UI Localization Polish, Test Stability, and Expanded Overflow Protection
* **Completion Date:** July 14, 2026
* **Objective:** Localize recurrence warnings and About Me buttons, add scale protections to action layouts, and fix analyzer warnings.
* **Accomplishments:**
  - **Localization**: Localized recurrence warning labels and About Me buttons.
  - **FittedBox Scale Protection**: Added horizontal scaling protection to tabs, actions, and custom recurrence button layouts.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed tests showing 100% success rate for all unit and widget tests.

### Phase 40: Legal Compliance, Security Finalization & Quality Assurance
* **Completion Date:** July 14, 2026
* **Objective:** Complete legal document rewrites, update currency logic in exports, organize ARB files, and run tests.
* **Accomplishments:**
  - **Compliance legal rewrites**: Updated Terms and Privacy Policy to comply with GDPR/LOPDGDD.
  - **Multi-currency PDF exports**: Respect original currencies of Budgets and Savings Goals in exports, and format transfers cleanly as `Source -> Destination`.
  - **ARB Organization**: Sorted all ARB file keys alphabetically.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed tests showing 100% success rate for all unit and widget tests.

### Phase 41: Read-Only Padlock Indicators
* **Completion Date:** July 14, 2026
* **Objective:** Improve detail screen UX by visually indicating read-only/non-editable fields using padlock icons, matching the design of the Accounts/Wallets detail views, and ensure 100% test and static analysis compliance.
* **Accomplishments:**
  - **Read-Only Padlock Icons**: Identified and appended a trailing padlock icon to all non-editable/read-only input fields (excluding date fields) on the Budgets (Target Amount, Currency, Account, Category) and Savings Goals (Goal Name, Target Amount, Currency) detail sheets.
  - **Design Styling Matching**: Modeled the padlock and border design to perfectly match the existing layout implemented in the Accounts/Wallets detail dialog (using `Icons.lock_outline_rounded` of size 18, color `colorScheme.onSurfaceVariant.withValues(alpha: 0.5)`, and outline borders colored `colorScheme.outline.withValues(alpha: 0.3)`).
  - **Static Analysis & Testing**: Validated that all 495 automated unit/widget tests and strict static analysis check (`flutter analyze --fatal-infos --fatal-warnings`) pass successfully with zero warnings/errors.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All 495 automated unit and widget tests pass cleanly.

### Phase 42: PDF Export Transfer Resolution Fix
* **Completion Date:** July 15, 2026
* **Objective:** Resolve the issue where transfer destinations in PDF exports were not correctly resolved as "Source Account -> Destination Account" due to transaction de-duplication in the default repository watch.
* **Accomplishments:**
  - **Raw Transaction Resolution**: Modified `ExportMonthlyPdfUseCase` to load raw transactions (using `watchRawTransactions()`) for transfer destination lookups, which preserves both legs of transfer pairs, enabling correct resolution of source and destination accounts.
  - **Test Suite Integration**: Stubbed `watchRawTransactions` in `export_monthly_pdf_use_case_test.dart` to match, correcting the test mock structure and ensuring both common mocks and manual setups are completely stubbed.
  - **Static Analysis & Testing**: Ensured 100% test pass rate (all 508 tests passing) and a clean static analysis report (0 errors, 0 warnings, 0 infos).
* **Verification:**
  - 100% clean static analysis (`flutter analyze --fatal-infos --fatal-warnings` with 0 issues).
  - All 508 automated unit and widget tests pass cleanly with a 100% success rate.

### Phase 43: Backup Username Update & Filename Customization
* **Completion Date:** July 18, 2026
* **Objective:** Ensure restoration updates the active user's profile name, standardize filename prefixes based on document type (Stalvi_Backup, Stalvi_Table, Stalvi_Overview), and confirm 100% build health.
* **Accomplishments:**
  - **Profile Restoration Sync**: Updated `ImportServiceImpl` to overwrite the active user's profile name in the database with the one preserved in the backup JSON.
  - **Filename Customization**: Standardized export filenames to append `yyyyMMdd_HHmmss` timestamps prefixed with `Stalvi_Backup_`, `Stalvi_Table_`, and `Stalvi_Overview_`.
  - **CI & Build Validation**: Executed all tests (508) and verified 0 warnings/infos on static analysis.
* **Verification:**
  - 100% clean static analysis (`flutter analyze --fatal-infos --fatal-warnings` with 0 issues).
  - All 508 automated unit and widget tests pass cleanly with a 100% success rate.

### Phase 44: Exact UTC+2 Calculations & Dual-Execution Background Strategy with Idempotency
* **Completion Date:** July 19, 2026
* **Objective:** Prevent timezone discrepancies in recurring transactions by forcing exact UTC+2 calculations, implement a robust dual-execution background strategy (at 00:00 and 01:00 UTC+2), and prevent duplicate creations with UUID v5 URL-based idempotency keys.
* **Accomplishments:**
  - **Exact UTC+2 Boundaries**: Reconfigured date calculations for automatic transactions to operate strictly within the UTC+2 timezone, truncating time to exact date boundaries.
  - **Dual Background Strategy**: Implemented dual Daily execution triggers (00:00 and 01:00 UTC+2) to verify and execute pending transactions, preventing Doze mode or task interruption drops.
  - **UUID v5 Idempotency**: Employed Uuid v5 URL-based deterministic keys generated from transaction cycle and ID, checking if a transaction exists before creating it, enforcing strict idempotency.
  - **Robust Testing**: Expanded `execute_recurring_transactions_usecase_test.dart` to cover both calculations under leap years and short months, and strict idempotency checks simulating multiple firings.
* **Verification:**
  - 100% clean static analysis (`flutter analyze --fatal-infos --fatal-warnings` with 0 issues).
  - Clean build generation and `build_runner` code generation.
  - Executed tests showing 100% success rate for all unit and widget tests.

### Phase 45: Package Upgrades, Riverpod 3.0 Migration & QA Pass
* **Completion Date:** July 19, 2026
* **Objective:** Upgrade outdated dependencies (including `share_plus`, `workmanager`, and replacing `flutter_markdown` with `flutter_markdown_plus`), configure compilation for Java 17 compatibility, migrate providers to Riverpod 3.x generator annotations, clear deprecations/warnings, and achieve 100% test pass rate.
* **Accomplishments:**
  - **Dependency & Gradle Upgrades**: Upgraded dependencies (`share_plus`, `workmanager`, replacing `flutter_markdown` with `flutter_markdown_plus`) and set Android targets/Kotlin JVM compile options to Java 17.
  - **Riverpod 3.x Migration**: Migrated the state management controllers and providers to Riverpod 3.x `@riverpod` annotations generator syntax.
  - **Deprecation Cleanup**: Replaced deprecated `bytes` with `readAsBytes()` on `PlatformFile`, and removed deprecated `encryptedSharedPreferences` configuration.
  - **Static Analysis**: Resolved 37 code analyzer warnings, warnings on unnecessary const keywords, formatting issues in theme API doc comments, and unused variables.
  - **Test Suite Optimization**: Solved test timer leaks, mock interface issues, layout constraints, and auto-dispose timing bugs, achieving 100% pass rate.
* **Verification:**
  - 100% clean static analysis (`flutter analyze --fatal-infos --fatal-warnings` with 0 issues).
  - All 498 automated unit and widget tests pass cleanly with a 100% success rate.

### Phase 46: Core Bug Fixes & Launch Readiness
* **Completion Date:** July 21, 2026
* **Objective:** Perform final quality assurance, resolve file export issues across all devices, fix cross-currency balance conversion accuracy, stabilize background automatic transactions with periodic checks and startup fallbacks, add local notifications, and verify 100% test pass rate and static analysis.
* **Accomplishments:**
  - **Export Integrity:** Fixed file exporting issues across device storage systems (Downloads folder and Scoped Storage) for PDF, CSV, and encrypted JSON backups.
  - **Currency Conversion Accuracy:** Enforced accurate multi-currency conversions during balance recalculations on Income, Expense, and Transfer transactions.
  - **Background Execution Reliability:** Transitioned Workmanager to a reliable 2-hour periodic background service paired with an asynchronous app startup fallback to guarantee automatic transaction triggers.
  - **Local Push Notifications:** Integrated `flutter_local_notifications` to dispatch localized push notifications ("Transaction [name] completed successfully") when automatic transactions execute.
  - **QA & Final Polish:** Achieved 100% test suite pass rate, clean static analysis (`flutter analyze` with 0 warnings/infos), and automated code formatting with `dart format`.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Clean code formatting pass across all files (`dart format .`).
  - All unit and widget tests in the test suite pass with a 100% success rate.

### Phase 51: Cross-Platform Background Execution & Recurrence Engine Refactoring
* **Completion Date:** July 25, 2026
* **Objective:** Abstract background execution logic into a dedicated domain interface (`BackgroundSyncService`), connect Workmanager directly to recurring transaction use cases, and implement offline currency exchange fallbacks.
* **Accomplishments:**
  - **Background Sync Abstraction:** Abstracted background execution logic into a dedicated domain interface (`BackgroundSyncService`), enabling clean cross-platform task invocation.
  - **Idempotent Background Tasks:** Connected background execution via `workmanager` directly to `ExecuteRecurringTransactionsUseCase` to evaluate scheduled automatic transactions reliably.
  - **Offline Currency Fallback System:** Implemented local fallback exchange rates in the infrastructure layer (`FallbackExchangeRates`) to populate database tables on initialization when network access is unavailable.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All unit, widget, and integration tests pass with a 100% success rate.

### Phase 52: Legal Compliance Integration & Production CI/CD Finalization
* **Completion Date:** July 28, 2026
* **Objective:** Draft and integrate GDPR/store-compliant legal terms, clean up static analysis warnings, and synchronize GitHub Actions CI/CD workflows for release.
* **Accomplishments:**
  - **Store-Ready Legal Compliance:** Drafted and integrated GDPR and App Store/Google Play compliant Terms & Conditions and Privacy Policy across English, Spanish, and Catalan (`assets/legal/terms_*.md`, `assets/legal/privacy_*.md`), reflecting SQLCipher AES-256 local encrypted storage and zero-telemetry architecture.
  - **Static Analysis & Test Suite Integrity:** Resolved all static analyzer issues (`flutter analyze` with 0 warnings, 0 errors) and updated mock/unit tests to achieve a 100% test pass rate.
  - **CI/CD Workflow Synchronization:** Verified and synchronized GitHub Actions CI/CD workflows for Android and iOS automated builds and test runs.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - 100% pass rate across all unit and widget tests.

### Phase 53: Recurrence Precision, Input Rules & Process Exit Reliability
* **Completion Date:** August 1, 2026
* **Objective:** Ensure past missed recurring transactions generate with exact historical dates, enforce input validation rules (max 25 chars without emojis), fix database close deadlocks during data wipes, and synchronize CI/CD workflows.
* **Accomplishments:**
  - **Automatic Recurrence Date Precision:** Ensured missing past transactions (e.g., app not opened for multiple days/weeks) generate all pending transaction instances with their exact historical dates rather than today's date.
  - **Profile & User Name Input Rules:** Enforced a strict max length of 25 characters for name and username inputs during account creation, preventing emojis and special characters while permitting standard accented letters.
  - **Cold Application Restart & Database Release:** Fixed database connection deadlock during "Wipe All Data" by introducing a 500ms timeout on database `close()`, allowing clean database deletion and reliable application exit/restart on physical iOS and Android devices.
  - **CI/CD Workflow Alignment:** Synchronized GitHub Actions workflows (`ci.yml` and `security.yml`) for `main` and `develop` branches, ensuring `pod install` and simulator iOS builds pass cleanly.
* **Verification:**
  - 100% test pass rate across 530 unit, widget, and integration tests with zero static analyzer warnings or errors (`flutter analyze --fatal-infos --fatal-warnings`).

### Phase 54: Reactive Budgets & Goals Notifications and Code Cleanup
* **Completion Date:** August 3, 2026
* **Objective:** Implement reactive budget/goal updates and automated push notifications upon transaction creation, execute a comprehensive codebase cleanup, and maintain 100% test coverage.
* **Accomplishments:**
  - **Reactive Budgets & Goals:** Implemented a reactive system where budget and savings goals are automatically updated and validated upon every transaction creation.
  - **Automated Push Notifications:** Implemented an automated trigger for multi-language push notifications when budget thresholds or savings goals are met.
  - **Comprehensive Code Cleanup:** Performed a comprehensive code cleanup across `lib/` and `test/` directories, removing dead code, unused files, orphan translation keys, and obsolete comments.
* **Verification:**
  - 100% test pass rate across unit, widget, and integration tests with zero static analysis issues.

### Phase 55: Transaction UX Enhancements & Automatic Transaction Labels
* **Completion Date:** August 5, 2026
* **Objective:** Add optional `labelId` support to automatic transactions, position Label fields below Categories in forms, implement inline "Create New Category/Label" options, and add localization keys across EN, ES, CA.
* **Accomplishments:**
  - **Label Support in Automatic Transactions:** Updated `AutomaticTransaction` entity, Drift schema, DAOs, and Backup/Restore UseCases/DTOs to include optional `labelId` support with safe DB migration.
  - **Form UI & Inline Entity Creation:** Refactored `AddTransactionScreen` and `CreateEditAutomaticTransactionScreen` forms to position the Label field directly below the Category field. Implemented inline "Create New Category" and "Create New Label" dropdown options as top items in selectors with auto-save and auto-select behavior.
  - **Localization & Test Suite:** Added localized translation strings (`createNewCategory`, `createNewLabel`, `createNewTag`) in English, Spanish, and Catalan.
* **Verification:**
  - 100% test pass rate across unit, widget, and integration tests, clean static analysis (`0` issues).

### Phase 56: CI/CD Stabilization and Domain Refinement
* **Completion Date:** August 7, 2026
* **Objective:** Upgrade `workmanager` dependency and Gradle configurations, eliminate mandatory "Uncategorized" category fallbacks, unify category selector UI/UX, and ensure 100% build health.
* **Accomplishments:**
  - **CI/CD & Gradle Upgrades:** Upgraded `workmanager` package to latest supported release and realign Gradle/Kotlin build script configurations (`build.gradle.kts`) to fix Android CI build failures (`WorkmanagerPlugin`).
  - **Domain & UI Unification:** Refactored transaction domain logic to eliminate mandatory "Uncategorized" category fallbacks, enforcing explicit category selection across all standard and recurring transactions. Unified category selector UI/UX.
* **Verification:**
  - 100% test pass rate across 548 unit, widget, and integration tests, clean static analysis (`0` warnings/errors on `flutter analyze`).

### Phase 57: Play Store Build Optimization & R8 Code/Resource Shrinking
* **Completion Date:** August 8, 2026
* **Objective:** Optimize the Android production build for Play Store release by removing overly permissive ProGuard keep rules, configuring resource shrinking for supported languages, and enabling R8 full mode.
* **Accomplishments:**
  - **ProGuard / R8 Rules Refinement:** Removed blanket `-keep` rules for Flutter embedding and AndroidX libraries (`androidx.work`, `androidx.room`, `androidx.security`, `androidx.biometric`, `androidx.startup`) in `android/app/proguard-rules.pro`, enabling R8 deep tree-shaking via library consumer rules.
  - **Resource Shrinking & Language Stripping:** Configured `resourceConfigurations += setOf("en", "es", "ca")` in `android/app/build.gradle.kts` to purge unused localization strings and drawables from external dependencies.
  - **R8 Full Mode:** Declared `android.enableR8.fullMode=true` in `android/gradle.properties` for aggressive code optimization.
  - **Verification:** Successfully compiled release App Bundle (`app-release.aab`) with clean build health and verified that native security, FFI, and background modules function without crashes.
* **Verification:**
  - 100% clean release App Bundle compilation (`flutter build appbundle --release`).

### Phase 58: PIN Lockout Timer Update & Transaction Amount Field Cursor Alignment
* **Completion Date:** August 8, 2026
* **Objective:** Fix the 30-second PIN lockout countdown update on the authentication screen and reposition the text input cursor to the left side of the currency symbol in transaction forms.
* **Accomplishments:**
  - **Dynamic PIN Lockout Timer:** Refactored `_PinLockoutContent` in `auth_screen.dart` to a `StatefulWidget` equipped with an internal `Timer.periodic`, ensuring the 30-second countdown ticks visually and dynamically down to zero.
  - **Transaction Amount Input Alignment:** Updated `textAlign: TextAlign.left` on amount input text fields in `add_transaction_screen.dart` and `create_edit_automatic_transaction_screen.dart`.
  - **Improved Cursor UX:** Placed the text cursor at the left side immediately following the currency symbol, avoiding visual confusion with decimal inputs.
* **Verification:**
  - 100% test pass rate across unit, widget, and integration tests, clean static analysis (`0` warnings/errors on `flutter analyze`).

## Recent Updates
- Finalized Phase 57 (Play Store Build Optimization & R8 Code/Resource Shrinking), eliminating overly broad ProGuard rules, restricting unused localization resources to EN/ES/CA, enabling R8 full mode, and verifying release App Bundle builds.
- Completed Phase 56 (CI/CD Stabilization and Domain Refinement), upgrading workmanager, fixing Android CI Gradle builds, removing uncategorized fallbacks, and unifying category UI selectors.
- Completed Phase 55 (Transaction UX Enhancements & Automatic Transaction Labels), adding labelId support in automatic transactions, inline entity creation dropdowns, and ARB localizations.
- Completed Phase 54 (Reactive Budgets & Goals Notifications and Code Cleanup), enabling reactive budget/goal updates and automated notification triggers.
- Finalized Phase 53 (Recurrence Precision, Input Rules & Process Exit Reliability), ensuring past missed recurring transactions generate with historical dates, enforcing 25-character name limits without emojis, fixing database close deadlocks during data wipes with a 500ms timeout for clean app process restarts, aligning CI/CD workflows for iOS pod installs, and passing all 530 tests with 0 analyzer warnings.
- Completed Phase 52 (Legal Compliance Integration & Production CI/CD Finalization), integrating GDPR/store compliance legal docs and synchronizing GitHub Actions CI/CD workflows.
- Completed Phase 51 (Cross-Platform Background Execution & Recurrence Engine Refactoring), abstracting background sync interfaces and implementing offline fallback exchange rates.
- Performed final QA and launch readiness pass for Phase 46, ensuring 100% test pass rate, clean static analysis, local push notification triggers, 2-hour periodic background processing, and accurate cross-currency balance calculations.
- Upgraded dependencies, migrated providers to Riverpod 3.x annotations, cleared static analysis warnings, and resolved all test suite timer leaks and mock interface crashes (Phase 45).
- Implemented exact UTC+2 calculations and a dual-execution background strategy (00:00 and 01:00 UTC+2) with UUID v5 URL-based idempotency checks for recurring transactions (Phase 44).
- Fixed backup import username update and standardized export filename prefixes (Phase 43).
- Resolved transfer transaction resolution bugs in PDF export by querying raw transactions for destination matching (Phase 42).
- Added padlock icons trailing read-only input fields in Budgets and Savings Goals detail sheets (Phase 41).
- Completed detailed GDPR/LOPDGDD compliance legal documents rewrite across Catalan, English, and Spanish (Phase 40).
- Reorganized ARB localization files to be valid, comment-free JSON sorted alphabetically (Phase 40).
- Updated PDF exports to preserve original currencies for budgets and savings goals, and format transfer routes cleanly (Phase 40).
- Added missing localizations (`recurrenceUtcWarning`, `aboutMeGithubButton`) to Settings and About Me screens, and expanded text overflow protection with FittedBox/Flexible layouts (Phase 39).
- Resolved undefined identifier analyzer errors and stabilized dynamic test assertions inside the automated test suites (Phase 39).
- Implemented UI/UX overflow safeguards, wrapping button text inside dialogs and bottom sheets in FittedBox to handle multi-language length differences (Phase 38).
- Synchronized all translation keys perfectly across English, Spanish, and Catalan localizations (Phase 38).
- Fixed pre-existing widget test issues and unused imports, achieving a completely warning-free/error-free static analysis (`flutter analyze`) and 100% pass rate on 464 tests (Phase 38).
- Refactored PDF monthly report date configurations and developed the localized Markdown About Me screen (Phase 36).
- Implemented multi-currency balance consolidation on dashboard and Workmanager-based background synchronization (Phase 37).
- Resolved recurring transaction calendar edge cases (safe end-of-month clamping) and added thorough unit test coverage.
- Implemented Automatic Transactions, Inline validations, and rolling 30-day stats (Phase 31).
- Implemented Safe Category Deletion business logic, filtering rules, UI dialogs, and expanded test coverage (Phase 30).
- Completed release preparation and UI optimization (Phase 29).
- Populated legal documentation in English, Spanish, and Catalan inside `assets/legal/`.
- Implemented user consent dialog on onboarding and "Delete Account" in settings.
- Hardened Android builds with code obfuscation, resource shrinking, and minimal permissions.
- Purged unused code, debug prints, and sanitized the git history.
- Enabled editing and update operations for Budgets and Savings Goals.
- Added dynamic budget progress spent recalculation when transactions are modified/deleted.
- Implemented cascading soft-delete/restore for Savings Goals with balance refunds.
- Added full Unicode font support in PDF exports using Roboto font assets to fix currency symbol placeholders.
- Updated Terms and Privacy policy legal markdown assets for Catalan, English, and Spanish.
- Integrated export navigation in statistics, expanded category colors (15) & icons (50), seeded new default categories (Phase 59).
- Restored & integrated tags/labels functionality across standard transactions (DB, Domain, UI, Filters, Exports) and polished category deletion dialog with visual cues (Phase 60).
- Achieved a completely clean static analysis check with 0 issues on `flutter analyze` and 100% test pass rate.
