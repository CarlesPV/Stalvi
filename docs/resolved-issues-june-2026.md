# Resolved Issues Documentation - June 2026

This document provides a detailed breakdown of the bugs resolved in the Konta mobile application in June 2026, including their causes, technical solutions, and design guidelines for future reference.

---

## 1. Splash Screen Layout Issue (Cut-off Width)

### Problem Description
Upon launching the application, the Konta loading/splash content was displayed in a narrow vertical column spanning only about 1/3 of the screen width and aligned to the left side, instead of filling the entire screen width.

### Root Causes
1. **Loose Constraints in MaterialApp Builder**:
   The root widget of the application was wrapped in a custom `LifecycleBlurWrapper` designed to blur the interface when the app moves to the background. This wrapper implemented a standard Flutter `Stack` which defaults to `fit: StackFit.loose`. Under a loose stack, the incoming constraints are loosened (min width/height set to `0`), allowing the child `Navigator` to size itself smaller than the screen.
2. **Column Size Collapse**:
   The `_SplashContent` widget returned a raw `Column` containing the logo badge, wordmark, tagline, and progress indicator. By default, a Flutter `Column` occupies the maximum vertical space but collapses width-wise to the width of its widest child (in this case, the tagline text, which is about 200px). Because there was no alignment or expand widget enforcing full-width, the `Column` collapsed and aligned to the default top-left (`topStart`) corner of the loose `Stack`.

### Solution Applied
1. **Stack Fit Constraint Expansion**:
   Updated `LifecycleBlurWrapper` (in [lifecycle_blur_wrapper.dart](file:///home/carlesp/Proyectos/Konta/lib/presentation/widgets/lifecycle_blur_wrapper.dart)) to use `fit: StackFit.expand` on its `Stack` widget. This forces the child `Navigator` and subsequent app views to occupy the full dimensions of the screen.
2. **Explicit Splash Bounds**:
   Wrapped the `Column` widget inside the `_SplashContent` build method (in [splash_screen.dart](file:///home/carlesp/Proyectos/Konta/lib/presentation/features/splash/splash_screen.dart)) in a `SizedBox.expand`. This forces the splash screen body to expand to the full screen width and height, centering the logo and text horizontally.

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
Modified the Kotlin entrypoint [MainActivity.kt](file:///home/carlesp/Proyectos/Konta/android/app/src/main/kotlin/com/example/konta/MainActivity.kt) to inherit from `FlutterFragmentActivity` instead of `FlutterActivity`.

### Future Prevention Guideline
- Keep `MainActivity` subclassed from `FlutterFragmentActivity` as long as biometric verification (`local_auth`) is a feature in the application.

---

## 3. Comprehensive Multi-Language Localization (English, Spanish, Catalan)

### Problem Description
The application had multiple hardcoded strings in the splash page, biometric login interface, overview tab, budget cards, and transaction forms, violating the requirements of full internationalization (i18n).

### Solution Applied
1. **Key Extraction**:
   Created and updated key-value pairs representing all user-visible headings, tooltips, validation messages, and buttons in:
   - [app_en.arb](file:///home/carlesp/Proyectos/Konta/lib/core/l10n/app_en.arb)
   - [app_es.arb](file:///home/carlesp/Proyectos/Konta/lib/core/l10n/app_es.arb)
   - [app_ca.arb](file:///home/carlesp/Proyectos/Konta/lib/core/l10n/app_ca.arb)
2. **Clean UI Replacement**:
   Integrated `AppLocalizations.of(context)!` across all screens to resolve text entries dynamically based on the current locale.
3. **Domain Error Translation**:
   Created a private mapping helper (`_getLocalizedError`) in `add_transaction_screen.dart` that intercepts exception codes (e.g. `INVALID_AMOUNT`, `ACCOUNT_REQUIRED`) thrown from cleaner architecture boundaries and returns localized validation errors to show in the Snackbar.
4. **Dynamic Date Rendering**:
   Removed hardcoded "June 2026" text on the dashboard balance card and replaced it with dynamic localized dates using `DateFormat.yMMMM(locale)` formatted from `Localizations.localeOf(context).toString()`.
5. **Widget Test Stabilization**:
   Configured all widget tests to initialize localization delegates (`localizationsDelegates` and `supportedLocales` in test `MaterialApp` wrappers) so they build correctly without throwing null check exceptions.

### Future Prevention Guideline
- Never use hardcoded string literals for user-facing UI text in screen or widget implementations.
- Always add strings to the three language `.arb` templates and run `flutter gen-l10n` to rebuild localizations before using them in code.
