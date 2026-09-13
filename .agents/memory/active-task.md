# Phase 71: Home Screen Widget & Comprehensive Accessibility (a11y)

## Objective
Implement a 2x1 horizontal home screen widget displaying the income and expenses of the last 30 days in the default currency, ensuring it syncs automatically whenever financial data changes. Additionally, adapt the entire application for visually impaired users by complying with screen reader and a11y standards. Maintain 100% test coverage and ensure all CI/CD pipelines pass.

## Current Context
- The app uses Riverpod for state management and Drift (SQLCipher) for secure persistence.
- Home widgets require data sharing between the Flutter isolate and Native OS environments (since native code cannot easily read the encrypted SQLite DB).
- Supported languages: EN, ES, CA.

## Tasks
- [x] 1. Set up the `home_widget` package in `pubspec.yaml` and configure native Android (AppWidgetProvider/Glance) and iOS (WidgetKit) scaffolding for a 2x1 horizontal layout.
- [x] 2. Create `WidgetUpdateService` in the Application layer that calculates the 30-day income/expense in the default currency, and pushes this data to the native widget storage.
- [x] 3. Hook the `WidgetUpdateService` into Riverpod's transaction notifiers so the widget updates immediately upon CRUD operations or currency changes.
- [x] 4. Implement semantic accessibility (a11y) across the app using `Semantics`, `MergeSemantics`, and `ExcludeSemantics`. Add screen-reader-specific translations to `app_en.arb`, `app_es.arb`, and `app_ca.arb`.
- [x] 5. Write and update unit/widget tests for the new service and modified UI components.
- [x] 6. Run `flutter analyze --fatal-infos --fatal-warnings` and `flutter test` to ensure zero regressions.
- [x] 7. Update `roadmap.md` and documentation reflecting the completion of Phase 71.