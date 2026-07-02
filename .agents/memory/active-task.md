# Active Task: Phase 39 - Cross-State Stabilization, Localization, and UI Polish

## Objective
Fix critical UI anomalies, implement robust state invalidation across independent Riverpod providers, and complete 100% localization support without UI overflows.

## Context
Stalvi is currently facing state synchronization issues (currency changes not reflecting in dashboard stats immediately) and incomplete localization strings in various screens (PDF exports, About Me, Recurrence settings). Additionally, the native splash screen uses the wrong asset.

## Tasks Checklist
- [ ] **Splash Screen Fix:** Update `flutter_native_splash.yaml` to use `splash_icon.png` instead of `app_icon.png` and regenerate the native splash.
- [ ] **Localization Expansion:** Add missing strings across `app_en.arb`, `app_es.arb`, and `app_ca.arb` (PDF date ranges, UTC+2 warning, About Me button).
- [ ] **PDF Export Logic:** Refactor the PDF generation service/usecase to display either the current month name or "Last 30 days" dynamically based on the user's filter.
- [ ] **Currency State Invalidation:** Update `ProfileSettingsController` so changing the default currency strictly recalculates/invalidates Dashboard statistics (total balance, expenses, income).
- [ ] **Automatic Transactions UI:** Add a localized subtitle indicating "UTC+2 reference time" under the recurrence selector in the create/edit screen.
- [ ] **About Me UI:** Localize the GitHub link button and ensure responsive layouts.
- [ ] **Global Overflow & L10n Audit:** Apply `Flexible`, `Expanded`, `SingleChildScrollView`, and `FittedBox` globally where dynamic translated text might cause render overflows.

## Current Phase Restrictions
- Follow Clean Architecture.
- Do not bypass Riverpod state management rules.
- Run `flutter gen-l10n` after ARB modifications.
- Modify files directly. Do NOT output code in the chat.