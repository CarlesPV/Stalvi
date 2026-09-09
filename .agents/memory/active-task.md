# Phase 70: Case-Insensitive Sorting & Historical PDF Month Export

## Objective
Ensure all categories and tags are consistently sorted alphabetically across the app while strictly ignoring case sensitivity. Empower users to export PDF reports for any specific historical month (from 2021 up to the current date) preventing future date selections.

## Current Context
- Categories and tags currently sort using SQLite's default case-sensitive engine, placing 'Z' before 'a'.
- PDF exports only support "Current Month" and "Last 30 Days" via the `PdfExportDateRange` enum.

## Tasks
- [x] 1. Refactor `CategoryRepository` and `TagRepository` to map database rows and apply Dart-side `.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));` guaranteeing case-insensitive ordering on all futures and streams.
- [x] 2. Expand `app_en.arb`, `app_es.arb`, and `app_ca.arb` to include `exportPdfSelectMonth` and `btnSelect`, then run `flutter gen-l10n`.
- [x] 3. Update `PdfExportDateRange` enum with a `selectMonth` option, and update `export_monthly_pdf_use_case.dart` and `profile_settings_controller.dart` to accept and process an optional `selectedMonth` parameter.
- [x] 4. Build a new Material 3 `MonthYearPickerDialog` in `lib/presentation/widgets/` safely bounding selection between 2021 and the current system date.
- [x] 5. Integrate the new dialog into `data_management_screen.dart` as a third export option.
- [x] 6. Ensure 100% test coverage by updating UseCase and Repository tests.
- [x] 7. Run `flutter analyze --fatal-infos --fatal-warnings` and `flutter test` to ensure zero regressions.
- [x] 8. Mark Phase 70 as completed in `roadmap.md` and clear this active task.