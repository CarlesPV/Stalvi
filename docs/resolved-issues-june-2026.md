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




