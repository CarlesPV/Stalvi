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


