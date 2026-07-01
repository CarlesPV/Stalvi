# Active Task: Phase 33 - UI Polish, Real-Time Reactivity, and Soft-Delete Refinement

**Date:** July 2026
**Context:** The core application (Stalvi) is functional with Clean Architecture, Riverpod, and Drift. We are currently addressing critical UI/UX bugs, enforcing full i18n, and completing data management flows (soft-delete) before final release readiness.

## Objectives
- [x] **Splash Screen:** Update the initial loading splash icon to display the app logo within a rounded square.
- [x] **Real-Time Statistics:** Refactor statistics calculations (dashboard, account sections) to use reactive streams so they update instantly upon data changes.
- [x] **Complete Localization (i18n):** Ensure the entire app, specifically the Automatic/Recurring Transactions section, is fully available in English, Spanish, and Catalan.
- [x] **UI/Error Visibility:** Fix layout issues where error messages (e.g., custom recurrence in automatic transactions) are hidden behind pop-ups or blocked by the keyboard.
- [x] **Automatic Transactions Soft-Delete:** Implement a soft-delete mechanism for recurring transactions with a confirmation pop-up. Soft-deleted items must go to the Recycle Bin, be disabled from generating new transactions, and be auto-purged after 30 days.
- [x] **Overflow Resolution:** Audit and fix all text/widget overflow issues and unintended omissions ("...") across the app, especially in Settings and Data Management pop-ups.
- [x] **Final QA & Cleanup:** Ensure all tests pass, CI/CD workflows succeed, `flutter analyze` is clean, logs/unnecessary files are removed, `.gitignore` is secure, and update all documentation (Roadmap, README, etc.).

## Current Status
- **Completed:** Prompt 1 (Splash & Overflows)
- **Completed:** Prompt 2 (Real-Time Stats & i18n)
- **Completed:** Prompt 3 (Soft-Delete & Error UI)
- **Completed:** Prompt 4 (QA, Tests & Docs)