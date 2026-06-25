# Resolved Issues Documentation - June 2026

This document provides a detailed breakdown of the bugs resolved in the Stalvi mobile application in June 2026, including their causes, technical solutions, and design guidelines for future reference.

---

## 1. Splash Screen Layout Issue (Cut-off Width)

### Problem Description
Upon launching the application, the Stalvi loading/splash content was displayed in a narrow vertical column spanning only about 1/3 of the screen width and aligned to the left side, instead of filling the entire screen width.

### Root Causes
1. **Loose Constraints in MaterialApp Builder**:
   The root widget of the application was wrapped in a custom `LifecycleBlurWrapper` designed to blur the interface when the app moves to the background. This wrapper implemented a standard Flutter `Stack` which defaults to `fit: StackFit.loose`. Under a loose stack, the incoming constraints are loosened (min width/height set to `0`), allowing the child `Navigator` to size itself smaller than the screen.
2. **Column Size Collapse**:
   The `_SplashContent` widget returned a raw `Column` containing the logo badge, wordmark, tagline, and progress indicator. By default, a Flutter `Column` occupies the maximum vertical space but collapses width-wise to the width of its widest child (in this case, the tagline text, which is about 200px). Because there was no alignment or expand widget enforcing full-width, the `Column` collapsed and aligned to the default top-left (`topStart`) corner of the loose `Stack`.

### Solution Applied
1. **Stack Fit Constraint Expansion**:
   Updated `LifecycleBlurWrapper` (in [lifecycle_blur_wrapper.dart](file:///home/carlesp/Proyectos/Stalvi/lib/presentation/widgets/lifecycle_blur_wrapper.dart)) to use `fit: StackFit.expand` on its `Stack` widget. This forces the child `Navigator` and subsequent app views to occupy the full dimensions of the screen.
2. **Explicit Splash Bounds**:
   Wrapped the `Column` widget inside the `_SplashContent` build method (in [splash_screen.dart](file:///home/carlesp/Proyectos/Stalvi/lib/presentation/features/splash/splash_screen.dart)) in a `SizedBox.expand`. This forces the splash screen body to expand to the full screen width and height, centering the logo and text horizontally.

### Future Prevention Guideline
- Always wrap screen-level root widgets or views inside `Scaffold` bodies in widgets that occupy the full width (e.g., `SizedBox.expand` or `Center` with a width constraint) if the widgets inside utilize collapsing components like `Column` or `Row`.
- When custom decorators or wrapping overlays are placed in the `builder` of `MaterialApp`, ensure they use `StackFit.expand` if they contain the main app `Navigator`.

---

## 2. local_auth Android Activity Crash

### Problem Description
When running on Android and attempting biometric login at startup, the app failed with the message:
`Authentication Error: local_auth plugin requires activity to be a FragmentActivity`.

### Root Cause
The `local_auth` Flutter plugin uses native Android APIs to present biometrics dialogs. Because these dialogs rely on modern Android jetpack components, the host `Activity` class must be a `FragmentActivity` rather than the standard `FlutterActivity`.

### Solution Applied
Modified the Kotlin entrypoint [MainActivity.kt](file:///home/carlesp/Proyectos/Stalvi/android/app/src/main/kotlin/com/example/stalvi/MainActivity.kt) to inherit from `FlutterFragmentActivity` instead of `FlutterActivity`.

### Future Prevention Guideline
- Keep `MainActivity` subclassed from `FlutterFragmentActivity` as long as biometric verification (`local_auth`) is a feature in the application.

---

## 3. Comprehensive Multi-Language Localization (English, Spanish, Catalan)

### Problem Description
The application had multiple hardcoded strings in the splash page, biometric login interface, overview tab, budget cards, and transaction forms, violating the requirements of full internationalization (i18n).

### Solution Applied
1. **Key Extraction**:
   Created and updated key-value pairs representing all user-visible headings, tooltips, validation messages, and buttons in:
   - [app_en.arb](file:///home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_en.arb)
   - [app_es.arb](file:///home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_es.arb)
   - [app_ca.arb](file:///home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_ca.arb)
2. **Clean UI Replacement**:
   Integrated `AppLocalizations.of(context)!` across all screens to resolve text entries dynamically based on the current locale.
3. **Domain Error Translation**:
   Created a private mapping helper (`_getLocalizedError`) in `add_transaction_screen.dart` that intercepts exception codes (e.g. `INVALID_AMOUNT`, `ACCOUNT_REQUIRED`) thrown from cleaner architecture boundaries and returns localized validation errors to show in the Snackbar.
4. **Dynamic Date Rendering**:
   Removed hardcoded "June 2026" text on the dashboard balance card and replaced it with dynamic localized dates using `DateFormat.yMMMM(locale)` formatted from `Localizations.localeOf(context).toString()`.
5. **Widget Test Stabilization**:
   Configured all widget tests to initialize localization delegates (`localizationsDelegates` and `supportedLocales` in test `MaterialApp` wrappers) so they build correctly without throwing null check exceptions.

### Future Prevention Guideline
- Always add strings to the three language `.arb` templates and run `flutter gen-l10n` to rebuild localizations before using them in code.

---

## 4. Statistics Screen Aggregation Queries and Empty Database Null Reference Errors

### Problem Description
When the database was fresh or empty (no transactions recorded), navigating to the Statistics screen would throw null reference errors or fail to load data, causing a bad user experience. Additionally, mapping between raw database aggregation outputs and domain entities was error-prone when SQL aggregations returned null values.

### Root Causes
1. **Drift SQLite Aggregations on Empty Tables**:
   Running a `selectOnly` query with `sum()` projection on Drift tables without any matches returns a single row containing a `null` value for the projection. Attempting to parse or read this value directly without null-safety fallbacks led to runtime mapping errors.
2. **Missing UI State Handling**:
   The `StatisticsScreen` was not prepared to handle empty dataset results or loading/error states properly, which could result in blank pages or infinite loader spinners when no transaction data existed.

### Solution Applied
1. **Robust Aggregation in StatisticsDao**:
   - Rewrote `getPeriodSummary` to perform isolated `SUM` queries on income and expense transactions. Incorporated a null-coalescing operator (`?? 0`) on the result of `read(sum)` projection to guarantee that an integer of `0` is returned when no matching rows are found.
   - Refactored `getTopCategories` query to fetch sums grouped by category and gracefully fall back to default values for null fields.
2. **Standardized Empty States and Loader States in UI**:
   - Integrated check in `StatisticsScreen` showing a localized `EmptyStateWidget` if the period summary has both 0 income and 0 expenses.
   - Updated the Riverpod `AsyncValue` bindings to handle loading (`CircularProgressIndicator`) and error (`Center(child: Text(error))`) states correctly.
3. **Database Integration Testing**:
   - Added in-memory Drift database tests validating correct grouping, category sorting by total amount, and validation on empty databases.

### Future Prevention Guideline
- Always anticipate that SQL aggregates like `SUM`, `AVG`, or `0` can return `null` on empty databases or zero matches. Always use null-coalescing fallbacks (`?? 0` or `.read(sum) ?? 0`) when processing aggregate results.
- Always implement an explicit empty state layout utilizing `EmptyStateWidget` when displaying listings or analytical details that rely on user-generated data.

---

## 5. Onboarding Data Hydration & Registration Stability

### Problem Description
Onboarding could occasionally fail or hang when creating the initial profile if the background default data initialization task crashed or took too long, leaving the database empty and causing subsequent dashboard loading screens to fail because no default wallet, tags, or categories existed.

### Root Causes
1. **Unprotected DB Initialization**:
   `InitializeDefaultDataUseCase` ran without standard exception shielding. If a platform channel latency occurred or the database connection was temporarily locked, the initialization failed, interrupting the onboarding process and preventing dashboard navigation.
2. **Missing Await on Startup Initialization**:
   The transition from registration to the dashboard didn't strictly guarantee that the default wallet and localized categories had finished writing, leading to race conditions where the UI rendered the dashboard before the default wallet was ready.

### Solution Applied
1. **Try-Catch Shielding with Robust Logging**:
   Wrapped the core database execution block of `InitializeDefaultDataUseCase` in a try/catch, logging initialization exceptions but allowing the registration flow to complete safely.
2. **Strict Awaiting on Onboarding Setup**:
   Guaranteed that both profile creation and database data hydration are fully `await`ed before changing the authentication status provider state.
3. **Dashboard Fallback Empty State**:
   Added a fallback "Empty State Widget" with an action button prompting the user to create an Account manually in case the automatic data hydration was interrupted.

---

## 6. Profile and Settings Consolidation

### Problem Description
The user interface had scattered configuration panels (e.g. standalone profile views, language selectors directly under settings, legal document buttons under general profiles). This resulted in redundant menus, unnecessary appBar actions (like a profile avatar leading to a separate page), and fragmented settings configurations.

### Root Cause
1. **Fragmented UI Structure**:
   The app designed standalone navigation paths for profiles, security settings, legal documentation, and appearance preferences.
2. **Redundant Avatar Obfuscation**:
   The main dashboard displayed a top-right profile avatar that duplicated the settings tab navigation.

### Solution Applied
1. **Settings consolidation inside ProfileSettingsScreen**:
   Integrated Theme Mode selector, Language selector, Terms & Conditions, and Privacy Policy directly into the "Profile & Security" menu.
2. **Direct Settings Recycle Bin Access**:
   Placed the "Recycle Bin" option directly in the main Settings tab tile list for faster access.
3. **AppBar Cleanup**:
   Removed the redundant profile avatar from the dashboard's main AppBar.

### Future Prevention Guideline
- Strive for consolidated, feature-grouped settings panels rather than nested, scattered views. Always ensure compliance and configuration tools (Theme, Locale, Legal) are located under settings or profile groups.

---

## 7. SQLCipher Isolate FFI Binding Dynamic Library Load Crash

### Problem Description
When starting the application, the app would crash with the error:
`failed to load dynamic library libsqlite3.so`
on Android devices, preventing the database from loading and blocking app launch.

### Root Causes
1. **Isolate Boundary for FFI Configurations**:
   The app previously used `NativeDatabase.createInBackground` to initialize the database in a background isolate.
2. **Override Configuration Loss**:
   The native library override logic `open.overrideFor(OperatingSystem.android, openCipherOnAndroid)` was configured on the main thread. Because dynamic library override settings are isolate-specific, when Drift spawned the background isolate, that isolate did not inherit the `open.overrideFor` configuration and fell back to loading the default SQLite library, failing to find `libsqlite3.so` (as only SQLCipher is bundled).

### Solution Applied
- Replaced the asynchronous initialization `NativeDatabase.createInBackground` with the standard `NativeDatabase` constructor in `_openEncryptedDatabase` inside [app_database.dart](file:///home/carlesp/Proyectos/Stalvi/lib/data/database/app_database.dart).
- Running on the main thread guarantees the FFI overrides are correctly applied. Drift's queries will still be run asynchronously, maintaining high performance while ensuring a stable SQLCipher initialization.

### Future Prevention Guideline
- Do not initialize database connections inside background isolates (`createInBackground`) when using custom native FFI library overrides like SQLCipher, unless overrides are explicitly set up inside the spawned isolate's initialization phase.

---

## 8. Complex Cascades, Riverpod Reactivity, and Deep UX Polish (Phase 19)

### Problem Description
1. **Transfer Transaction Mismatch**: Creating a transfer only updated a single account or required manual synchronization, leading to duplicate records or asymmetric accounting.
2. **Orphaned Transactions**: Deleting an account left associated transactions in the database, breaking referential integrity and leading to incorrect statistics.
3. **Stale UI States**: Mutating transactions or accounts did not consistently refresh screens or update analytical charts immediately.
4. **Hardcoded UI Copy**: Remaining dialog titles, buttons, and error messages had hardcoded values, causing partial English/Spanish text overlays on Spanish or Catalan locales.
5. **CI/CD Build Pipeline Failures**: The automated CI workflows lacked localization generation (`flutter gen-l10n`), causing integration build tasks to fail.

### Solutions Applied
1. **Transfer Mirroring Logic**:
   - Implemented an atomic dual-movement insertion for transfers.
   - Linked origin and destination transactions via a shared `transferId`.
   - Updated `TrashDao` and `TransactionRepository` to automatically cascade soft-deletes, hard-deletes, and restorations to the mirror transaction.
2. **Cascading Account Deletion**:
   - Programmed Drift to cascade the trashing/deletion of an account to all of its child transactions, automatically recalculating financial balances.
3. **Real-time Reactivity**:
   - Wired Riverpod invalidations to force refresh statistics, account lists, and filtered transactions lists immediately upon any mutation.
4. **App Wipe & Cold Restart**:
   - Implemented a secure database deletion utility that wipes the database file and calls `SystemNavigator.pop()` to terminate the app safely, allowing a cold restart.
5. **Localization Sweep**:
   - Audited all files and translated categories, tag dialogs, delete alerts, and screen headers.
   - Configured `flutter gen-l10n` inside CI pipelines (`ci.yml` and `security.yml`).

### Future Prevention Guideline
- Always link dual-entry movements like transfers via unique shared identifiers in the database.
- Use explicit provider invalidations when mutating entities that affect global statistics or filtered watch streams.
- Ensure any new UI copy uses `AppLocalizations` and that CI configurations include the localization generator.

---

## 9. Transfer Flow Polish, Recycle Bin Refinements & Layout Bug Fixes (Phase 21)

### Problem Description
1. **Default Transfer Note**: Creating a transfer auto-populated the note field with "Transfer" instead of leaving it empty.
2. **Duplicate/Mirrored Transfer display**: Transfers were either duplicated in global listings, or did not display correctly for both accounts under filters, or spawned duplicate entries inside the Recycle Bin when deleted.
3. **Transaction Details for Transfers**: Tapping on a transfer failed to retrieve and display the destination account details in the transaction details modal.
4. **Recycle Bin Operations & UI**:
   - The Recycle Bin UI had a bulk "delete all/empty sweep" button which could cause accidental permanent data loss.
   - The Recycle Bin screen list did not automatically refresh or dispose when entering/exiting.
   - Trashed items in the Recycle Bin did not display transaction details/amounts localized in all 3 languages, and instead printed in English.
5. **Transfer Icon Asymmetry**: Dashboard transaction rows displayed standard transaction icons instead of a dedicated transfer icon.
6. **Mobile Viewport Overflow**: Certain buttons and text fields overflowed when constraints or input keyboards changed.

### Root Causes
1. **Default Note Initial Value**: `AddTransactionUseCase` automatically set the note field string to "Transfer" when it was null or empty.
2. **Transfer Deduplication Filter**: `watchAllTransactions` in `TransactionRepository` filtered out mirrored transactions. However, this also blocked detail lookups in the UI dialog which queried `watchAllTransactions`, meaning only the origin account could be found.
3. **Recycle Bin State Retention**: The Riverpod provider for the Recycle Bin did not auto-dispose, keeping stale lists when navigated to.
4. **Recycle Bin Localized Metadata**: The Recycle Bin list items only retrieved basic properties, omitting the transaction amount, currency, and type.
5. **Layout constraints**: Certain containers used hardcoded sizes or lacked `Flexible` wrappers to handle dynamic text wrapping.

### Solutions Applied
1. **Transfer Form & Notes Polish**: Removed the default "Transfer" fallback text inside the transaction use case. Standardized transfer list tiles to use `Icons.swap_horiz_rounded`.
2. **Raw Transaction Watch Stream**: Created `watchRawTransactions()` in `TransactionRepository` and exposed it via `rawTransactionsStreamProvider`. This unfiltered stream is used specifically by the details dialog to search for both legs of a transfer, allowing the dialog to display both the origin and destination accounts correctly.
3. **Recycle Bin Enhancements**:
   - Removed the "Empty All / Delete Sweep" button from the AppBar.
   - Appended `amount`, `txType`, and `currency` fields into the `TrashItem` metadata dictionary in `TrashDao`.
   - Updated the Recycle Bin UI list tiles to read metadata and format the title as `<Note/Type> - <Amount>` using localized strings.
   - Refactored `recycleBinProvider` to `autoDispose` so it re-fetches deleted items on every entry.
   - Ensured deleting a transfer mirrors properly, adding only 1 item to the Recycle Bin.
4. **Calculations & Balance Reversals**: Verified that soft-deleting, restoring, or permanently deleting transactions correctly recalculates and updates the balance of both origin and destination accounts.
5. **Mobile Viewport Polish**: Wrap long text lines in `Flexible` widgets and remove restrictive ellipsis rules to allow text to flow naturally without layout overflows.

### Future Prevention Guideline
- Use unfiltered raw transaction queries when checking for mirrors or paired relations, and use filtered queries for lists where duplicate visibility must be avoided.
- Add metadata to generic audit/trash tables if localized representation is required without direct joins.
- Use `autoDispose` for providers that monitor transient screen lists (like trash bins) to prevent caching stale items.

---

## 10. Refactoring Statistics & Dashboard Aggregations to Use Historical Exchange Rate Snapshots

### Problem Description
Previously, `StatisticsDao` performed database-level aggregation using raw SQLite `SUM()` commands. This bypassed transaction-specific historical exchange rates (stored as JSON string in `exchangeRateSnapshot` table column). When a user changed their default currency or loaded statistics, the calculations failed to reflect historical exchange rates dynamically, resulting in financial inaccuracies or falling back to static current rates.

### Root Cause
SQL-based database aggregation is incapable of parsing dynamic JSON objects (specifically the JSON-encoded `exchangeRateSnapshot` rates) inline on standard sqlite configurations. As a result, calculating accurate localized figures for multi-currency transactions requires moving the aggregation and conversion calculations from the SQLite database engine to the application's Dart repository layer.

### Solution Applied
1. **DAO Layer Refactoring**:
   - Replaced custom aggregate database queries (`getPeriodSummary` and `getTopCategories`) in [statistics_dao.dart](file:///home/carlesp/Proyectos/Konta/lib/data/database/daos/statistics_dao.dart) with data-fetching methods: `getTransactionsForPeriod` and `getTransactionsWithCategoryForPeriod`.
   - These methods retrieve the full list of matched `Transaction` and joined `TransactionWithCategory` records rather than raw SQL aggregate sums.
2. **Repository Layer Aggregation**:
   - Modified `StatisticsRepositoryImpl` in [statistics_repository_impl.dart](file:///home/carlesp/Proyectos/Konta/lib/data/repositories/statistics_repository_impl.dart) to parse the `exchangeRateSnapshot` JSON dictionary dynamically for each transaction.
   - Performed the conversion from the transaction's `originalCurrency` to the active target currency (either the selected account's currency, or the user's default currency fallback) utilizing the transaction's historical rate snapshot.
   - Handled cases where the snapshot is missing, corrupt, or does not contain the target rate, falling back safely.
3. **Tests Refactoring**:
   - Rewrote `statistics_dao_test.dart` to assert correct transaction retrieval, filtering, and exclusion behaviors for the new DAO methods.
   - Wrote rigorous unit tests in `statistics_repository_impl_test.dart` to mock repository dependencies, feed custom exchange rate JSON snapshots, and assert that income/expense sums and category aggregates map correctly with exact currency conversions.

### Future Prevention Guideline
- Whenever a database column contains structured JSON properties (such as dynamic snapshots or metadata logs) that dictate financial calculations, perform the mathematical aggregation in the Dart domain/repository layer instead of using database-level SQL functions.

---

## 11. Currency Engine Optimization, Reactivity, and Advanced Reports (Phase 25)

### Problem Description
1. **Network Sync Overhead**: The currency sync downloaded exchange rate data for unnecessary global currencies on every launch, increasing payload size and latency.
2. **Reactivity Deficit on Base Currency Changes**: When the user updated their default currency in settings, statistics and dashboard overview components failed to redraw in real-time, requiring a manual application restart.
3. **Inaccurate Cross-Currency Transfers**: Transfer movements between accounts configured in different currencies (e.g. USD to EUR) used static base values instead of dynamically calculating the destination conversion leg.
4. **Export Report Completeness**: PDF exports lacked visual category distributions, percentages, or localized translations.
5. **Form bottom overlaps & UX limits**: On tight viewports or when opening the OS soft-keyboard, forms like `AddTransactionScreen` and `ProfileSettingsScreen` threw `BottomOverflow` rendering errors, and files exported successfully gave no direct action to view/open them.

### Root Causes
1. **Unconstrained API Payload**: `ExchangeRateRemoteDataSource` synced all 32+ global currencies without caching.
2. **State Decoupling**: Riverpod statistics providers did not watch the default user profile currency configuration state, missing rebuild triggers when configuration settings changed.
3. **Static Transfer calculations**: `AddTransactionUseCase` added dual transaction records with identical unadjusted amounts even if target accounts had differing currencies.
4. **Form Viewport Limits**: Form layouts did not use scrolling wrappers, causing constraints to overflow when height shrunk due to the keyboard.

### Solutions Applied
1. **Target Currency Caching**: Restricted exchange rate sync to the 8 supported currencies, and cached results in local database tables with a 24-hour expiration check.
2. **Provider State Coupling**: Refactored `statisticsProviders` to watch profile state configurations, ensuring automatic, immediate recalculations on default currency changes.
3. **Cross-Currency Transfer Math**: Updated transfer logic in `AddTransactionUseCase` to detect differing currencies, retrieve the appropriate snapshot rate, and compute the correct adjusted amount for the destination account.
4. **Advanced Localized PDF Generation**: Injected category breakdown summaries, percentages, and `pw.PieGrid` pie charts to the monthly statement export PDF.
5. **Direct File Open action**: Integrated the `open_filex` package, adding interactive "Open" buttons on success export snackbars.
6. **Form Scroll Layouts**: Audited forms, wrapping parent layout views in `SafeArea` and `SingleChildScrollView` to prevent keyboard-related layout crashes.

### Future Prevention Guideline
- Always watch configuration settings (e.g., locale, currency, mode) in down-stream providers that compute data summaries.
- Use `SingleChildScrollView` or layout-wrapping scroll components for any page containing input text fields to safely support soft keyboards.






