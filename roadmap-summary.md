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

#### Phase 19: Complex Cascades, Riverpod Reactivity & Deep UX Polish
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
  - **Financial Immutability**: Added an `exchangeRateSnapshot` field to transactions and updated database mapping logic to store snapshots at creation time, preserving historical balance integrity. Calculate all Statistics (dashboard summaries and top categories) dynamically in real-time, performing live currency conversions based on full unrounded integer cents across multi-currency accounts.
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
  - **UI/UX & Translation Audit:** Wrapped sensitive input forms (e.g. `AddTransactionScreen` and `ProfileSettingsScreen` PIN/currency selections) inside `SafeArea` and `SingleChildScrollView` widgets to guarantee zero `BottomOverflow` keyboard rendering bugs. Audited and synchronized the translation ARB catalogs for English, Spanish, and Catalan.
* **Verification:**
  - Zero issues on static analysis (`flutter analyze`).
  - All automated tests pass successfully: **368 tests passed** (including mock repository verifications and widget layout assertions).

### Phase 26: QA/Layout Readiness and Production Audit
* **Completion Date:** June 25, 2026
* **Objective:** Audit layout widgets for potential overflows, resolve deprecations, clean unused assets, and verify that CI/CD and analyzer pass 100% cleanly.
* **Accomplishments:**
  - **Layout Constraints & Overflow Prevention:**
    - Exposed text formatting options (overflow, maxLines, softWrap) in `ObfuscatedText` to safely wrap or truncate obfuscated text.
    - Implemented text overflow safeguards on balance total, balance amount, statistics cards (label/values), account item balance value, and transaction item amount value across Dashboard and Budgets & Goals screens.
  - **Code Polish & Deprecation Removal:**
    - Resolved trailing comma warnings across the budgets screen and export monthly PDF tests.
    - Cleaned deprecated properties in `DropdownButtonFormField` (replaced `value` with `initialValue`).
    - Removed unused imports in `profile_settings_controller.dart`.
    - Removed redundant mock methods from tests repository fake implementation classes.
  - **Asset Optimization:**
    - Cleaned up unused legal assets (`privacy.md` and `terms.md`) from `assets/legal` directory to save app package space.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Clean `flutter test` execution: all 381 tests pass successfully.

### Phase 27: UI Constraints for Budgets, Goals, and Recycle Bin
* **Completion Date:** June 25, 2026
* **Objective:** Implement input locking constraints on budget and savings goal forms, require account mapping on budget creation, embed savings goals as transfer destinations, and display soft-deleted budgets and savings goals inside the Recycle Bin with complete English, Spanish, and Catalan localization.
* **Accomplishments:**
  - **Edit-Mode Lockdowns:** Locked Currency and Target Amount fields in Edit mode for Budgets and Savings Goals sheets to preserve financial settings integrity.
  - **Account Mapping Requirement:** Enforced mandatory Account selection during Budget creation.
  - **Transfer Target Integration:** Extended the Transfer destination selector to display active Savings Goals alongside standard Accounts.
  - **Recycle Bin Expansion:** Added support to display soft-deleted Budgets and Savings Goals inside the Recycle Bin list, rendering localized titles and metadata.
  - **Full Translation Alignment:** Localized all new components and messages in English, Spanish, and Catalan, ensuring complete i18n parity.
  - **Test Suite Updates:** Updated mock classes and database models inside the testing suite to align with constructor modifications.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed the full automated test suite containing 393 unit and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 28: Financial Integrity, Editing, and Final Polish
* **Completion Date:** June 26, 2026
* **Objective:** Ensure data consistency in complex operations (cascading deletions), enable editing of financial goals/budgets, fix document export encoding for currency symbols, and polish internationalization/static analysis.
* **Accomplishments:**
  - **Entity Editing:** Enabled update operations (Update) in UI and Domain for Budgets and Savings Goals, allowing editing directly from detailed screens.
  - **Dynamic Recalculation:** Implemented reactive budget recalculation including currency conversion when transactions are modified or deleted.
  - **Trash Integrity:** Implemented cascading soft-delete and restore for Savings Goals, automatically reverting and reapplying balances to origin accounts.
  - **PDF Unicode Support:** Embedded TTF fonts (Roboto) in the PDF export service to properly render currency symbols without placeholders.
  - **Legal Update:** Reviewed and updated `privacy_*.md` and `terms_*.md` in Catalan, English, and Spanish to reflect the latest features.
  - **UI/UX & Static Analysis Polish:** Automated formatting corrections via `dart fix --apply`, achieving 100% translation coverage and warning-free logs.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed the full automated test suite containing 396 unit and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 29: Release Preparation and UI Optimization
* **Completion Date:** June 29, 2026
* **Objective:** Prepare build bundles, finalize store assets, sanitize the repository, configure production-ready security controls, and audit app compliance.
* **Accomplishments:**
  - **Store Compliance & Legal Documentation:** Standardized and formatted full legal documents (Terms & Conditions and Privacy Policy) in English, Spanish, and Catalan under `assets/legal/`. Implemented a compliant user consent dialog for first launch data collection and added an explicit "Delete Account" option in the UI settings.
  - **Android Obfuscation & Hardening:** Enabled ProGuard/R8 code obfuscation and resource shrinking in `build.gradle`, cleaned up application permissions (stripped unnecessary hardware permissions), and ran a secret scanner audit.
  - **Git Sanitation:** Sanitized the repository's git history using helper scripts to ensure no private/sensitive keys or variables are stored in the historical tree.
  - **Codebase Optimization & Refactoring:** Deleted all unused classes, methods, imports, and debug logs. Standardized static analysis compliance across all files with 0 warnings on `flutter analyze`.
  - **Dashboard Simplification:** Removed the long-press context menu on the dashboard.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed the full automated test suite containing 396 unit and widget tests, achieving a 100% success rate.

### Phase 30: Safe Category Deletion & Launch Preparation
* **Completion Date:** June 30, 2026
* **Objective:** Implement safe category deletion logic to prevent dangling database references, enforce category type-based filtering during transaction reassignment, build UI prompts, and verify integration via unit tests.
* **Accomplishments:**
  - **Safe Category Deletion Domain Logic:** Updated the `DeleteAndReassignCategoryUseCase` logic to enforce type constraints: Expense categories can only be reassigned to other Expense or Custom categories; Income to Income or Custom; Custom categories can be reassigned to all other categories.
  - **UI Prompts and Dialogs:** Configured settings category deletion checks to identify if a category is actively in use by transactions. If true, the app prompts the user with an `AlertDialog` containing a filtered list of eligible replacement categories to execute the transaction reassignment atomically before deleting.
  - **Comprehensive Verification:** Wrote robust unit tests in `delete_and_reassign_category_usecase_test.dart` to cover the new filtering behaviors.
### Phase 31: Automatic Transactions, Inline Validation, & Rolling 30-Day Stats
* **Completion Date:** July 1, 2026
* **Objective:** Implement recurring transaction evaluation engine and database tables for automatic transactions, develop interactive UI sheets, refactor transaction forms to support real-time inline validations, and calculate rolling 30-day dashboard summaries.
* **Accomplishments:**
  - **Automatic Transactions Engine:** Created new Drift database tables, models, and mappers. Developed a core evaluation use case scheduler evaluating next execution dates to generate transactions and auto-advance recurrence dates.
  - **Inline Validation:** Refactored form inputs to trigger real-time inline validations, displaying distinct localized messages and dynamically clearing/resetting field errors as inputs change.
  - **Rolling 30-Day Statistics:** Configured period summaries and balance trend statistics to evaluate over a rolling 30-day window for instant dashboard trends.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed the full unit and widget test suite with all 414 tests passing successfully.

### Phase 32: Stabilization & Auto-Transactions
* **Completion Date:** July 1, 2026
* **Objective:** Ensure maximum code quality, resolve all static analysis issues, validate tracking of sensitive data, and verify CI/CD pipelines.
* **Accomplishments:**
  - **Static Analysis & Testing:** Resolved all static analysis errors, dead code, unused imports, and `avoid_print` warnings. Verified absolutely no widget overflow errors and achieved 100% success on all automated tests.
  - **Security & CI/CD Validation:** Validated `.gitignore` to prevent tracking of `.env`, keystores, and sensitive files. Verified `ci.yml` and `security.yml` GitHub actions for automated tests and builds.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - Executed the full automated test suite containing 427 unit and widget tests, achieving a 100% success rate.

### Phase 33: UI Polish, Real-Time Reactivity, and Soft-Delete Refinement
* **Completion Date:** July 1, 2026
* **Objective:** Polish initial branding assets, implement real-time statistics query streams, enable complete localization for recurring transaction settings and form validations, fix keyboard occlusion layout issues, integrate soft-delete functionality for automatic transactions, and eliminate remaining widget overflows and static analysis warnings.
* **Accomplishments:**
  - **Branding Assets:** Updated the splash icon to display the Stalvi app logo within a rounded square.
  - **Real-Time Statistics:** Replaced future-based analytics providers with reactive Drift query streams (`watchPeriodSummary`, `watchTopCategories`), allowing charts and summary cards to update instantly when underlying database transactions change.
  - **Trilingual Localization:** Localized the entire automatic/recurring transactions configuration forms and all dynamic input validation states across Catalan, English, and Spanish.
  - **Layout & Occlusion:** Addressed layout and viewport constraint issues to ensure error validation logs remain visible above the keyboard.
  - **Soft-Delete for Auto-Transactions:** Built soft-deletion logic for automatic transactions. Trashed templates are moved to the Recycle Bin, disabled from generating new transactions, and purged after 30 days.
  - **Overflow Resolutions:** Fixed remaining ChoiceChip clippings, text truncations, and dialog window layout overflows on small mobile devices.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - Executed the full automated test suite containing 446 unit and widget tests, achieving a 100% success rate (all tests passed!).

### Phase 34: Final i18n Audit & Project Documentation Updates
* **Completion Date:** July 1, 2026
* **Objective:** Audit translation catalog coverage in presentation components, clean up unused localization strings, sync English, Spanish, and Catalan ARB bundles, and update project documentation (`README.md`, `roadmap.md`, `roadmap-summary.md`) to reflect release-ready state.
* **Accomplishments:**
  - **Localization Audit**: Replaced all remaining hardcoded strings in presentation files with dynamic localizations.
  - **Unused Translation Cleanup**: Removed redundant localization keys (`incomes`, `deleteAccountHasAutomaticTransactions`, `recurrenceDaysLabel`, `nextExecution`, `autoTxRecurrenceInvalidRange`) from translation files and rebuilt localizations cleanly.
  - **Documentation Updates**: Updated `README.md` and roadmaps to reflect all completed features, architecture, and verification stats.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - Fully passing automated test suite (all 455 tests passed successfully!).

### Phase 35: Domain Resilience, Compliance Warnings & Splash Polish
* **Completion Date:** July 1, 2026
* **Objective:** Address recurring transaction calendar edge cases with safe end-of-month date clamping, append liability disclaimers regarding currency data for compliance across all translation assets, upgrade splash icon to a unified squircle branding, and expand unit test coverage.
* **Accomplishments:**
  - **Safe End-of-Month Recurrence**: Added recurrence clamping logic (`calculateNextExecutionDate`) in the automatic transaction entity to gracefully handle months with fewer days (e.g. Feb/30th/31st scenarios) and subsequently restore execution to target days on longer months.
  - **Compliance & Disclaimer Updates**: Updated Terms & Conditions and Privacy Policy across Catalan, English, and Spanish with disclaimers highlighting the approximate nature of conversions, calculations, and statistics to protect developer liability.
  - **Splash Screen Rebranding**: Updated splash configurations and code assets to display the high-quality rounded logo (`splash_icon.png`) uniformly across light, dark, and Android 12+ scopes.
  - **Recurrence Validation Tests**: Developed comprehensive unit tests covering intervals, short months, leap years (February 29th vs 28th), and month-to-month clamping recovery.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - Fully passing automated test suite (all 455 tests passed successfully!).

### Phase 36: PDF Export and About Screen
* **Completion Date:** July 2, 2026
* **Objective:** Refactor PDF Export to prompt for 'Last 30 Days' or 'Current Month', and implement the 'About Me' localized Markdown screen with an external link.
* **Accomplishments:**
  - **PDF Export Refactoring**: Upgraded PDF export flow to support selecting custom date range presets ('Last 30 Days' or 'Current Month') before generation.
  - **About Me Screen**: Developed a localized Markdown About Me screen displaying detailed developer info and including working links to external sources.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - All automated tests pass successfully.

### Phase 37: Production Readiness, Background Tasks & UX Polish
* **Completion Date:** July 2, 2026
* **Objective:** Implement multi-currency conversion for total balances on the dashboard, fix the splash screen icon border-radius, enhance Automatic Transactions UI to display localized recurrence strings, implement background execution via workmanager, perform an exhaustive cleanup of .arb files, and fix all CI/CD, analyzer warnings, and update documentation.
* **Accomplishments:**
  - **Multi-Currency Total Balances**: Upgraded the dashboard total balance card to dynamically convert and display the consolidated sum in the profile's default currency.
  - **Splash Screen Polish**: Fixed the splash screen icon border-radius to align with branding guidelines.
  - **Background Workmanager Sync**: Integrated background execution via `workmanager` to sync rates and evaluate recurring transactions periodically.
  - **Localizations Cleanup**: Cleaned up unused translation keys and comments in the `.arb` files to minimize footprint.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - Fully passing automated test suite.

### Phase 38: UI/UX Text Overflow Safeguards & i18n Verification
* **Completion Date:** July 2, 2026
* **Objective:** Audit and fix all potential text overflow issues across UI screens (Auth, Budgets, Goals, Settings, Dashboard, Transactions), wrap button labels in responsive widgets, and verify complete key synchronization across all three ARB localizations.
* **Accomplishments:**
  - **UI Overflow Safeguards**: Wrapped dialog and bottom sheet button label widgets inside `FittedBox` (with scale down fit) to prevent horizontal layout overflows under long Catalan/Spanish translations.
  - **Layout Constraints**: Resolved constraints on the `_AccountItem` balance and default label text elements, preventing clipping on tight viewports.
  - **Localization Sync Audit**: Verified 100% key synchronization across `app_en.arb`, `app_es.arb`, and `app_ca.arb` (all containing exactly 339 translation keys with matching placeholders).
  - **Warning-Free Environment**: Resolved all static analysis warnings, unused imports, and print statements, achieving a completely clean `flutter analyze` report with 0 issues, and fixed failing widget tests.
* **Verification:**
  - 100% clean static analysis (`flutter analyze`) with 0 issues.
  - All 464 automated unit and widget tests pass cleanly with a 100% success rate.

### Phase 39: UI Localization Polish, Test Stability, and Expanded Overflow Protection
* **Completion Date:** July 2, 2026
* **Objective:** Integrate missing localizations into the UI screens (settings, about me), expand layout safeguards against text overflows across tabs and action buttons, and ensure full test stability and static analysis compliance.
* **Accomplishments:**
  - **Integrated Localizations**: Added `AppLocalizations.of(context).recurrenceUtcWarning` to the automatic transaction recurrence selector sheet and replaced hardcoded GitHub button text with `AppLocalizations.of(context).aboutMeGithubButton` on the About Me screen.
  - **Expanded Overflow Protections**: Secured Expense/Income toggle tabs, custom recurrence apply buttons, and global transaction save buttons by wrapping text in `FittedBox` (scaleDown) and wrapping key buttons in `Flexible` inside row layouts.
  - **Static Analysis Compliance**: Fixed undefined references by declaring `colorScheme` inside recurrence selector functions, yielding a completely warning-free/error-free `flutter analyze` environment.
  - **Test Suite Updates**: Refactored `about_me_screen_test.dart` to query localized button assertions dynamically, resolving failing cases and guaranteeing a 100% pass rate.
* **Verification:**
  - All 465 automated unit and widget tests pass cleanly with a 100% success rate.

### Phase 40: Legal Compliance, Security Finalization & Quality Assurance
* **Completion Date:** July 3, 2026
* **Objective:** Ensure robust GDPR/LOPDGDD compliance in legal texts, reorganize and sort translation catalogs, enhance PDF export services with original currencies and transfer routing format, and verify complete quality assurance with zero static analysis warnings and 100% test pass rate.
* **Accomplishments:**
  - **GDPR & LOPDGDD Legal Compliance**: Wrote detailed legal agreements (Privacy Policy and Terms & Conditions) with explicit liability disclaimers, data erasure/export guidelines, and calculations disclosures across English, Spanish, and Catalan.
  - **ARB Reorganization & Cleanup**: Reorganized ARB localization files into alphabetical blocks and removed legacy comment markers, ensuring valid JSON formatting.
  - **PDF Export Updates**: Refactored the PDF export service to respect the original currency of Budgets and Savings Goals instead of forcing default profile currency, and formatted transfer operations visually as `Source Account -> Destination Account`.
  - **Test Suite Stability**: Verified that the entire suite of 465 unit and widget tests passes successfully with a 100% success rate.
* **Verification:**
  - 100% clean static analysis (`flutter analyze` with 0 issues).
  - All 465 automated unit and widget tests pass cleanly.

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

#### Phase 43: Backup Username Update & Filename Customization
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

## Recent Updates
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
- Achieved a completely clean static analysis check with 0 issues on `flutter analyze` and 100% test pass rate.
\n- [x] Fixed backup system to save the username and include the destination account for transfers.\n- [x] Improved backup format validation on import.
