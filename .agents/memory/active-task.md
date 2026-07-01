# Active Task: Phase 34 - Reactive State Consolidation, UI/UX Refinement, and Production Readiness

## Current Objective
Finalize the application state management to ensure real-time statistic calculations across all modules, implement advanced recurrence logic for automatic transactions, polish UI elements (Splash screen, Recycle Bin), achieve 100% i18n coverage (EN, ES, CA), and optimize the codebase for zero CI/CD errors.

## Sub-Tasks
- [ ] **UI Polish**: Update splash screen to use `splash_icon.png` (rounded edges). 
- [ ] **UI Polish**: Reorder Recycle Bin item subtitles (Expiration date first, then item type).
- [ ] **Business Logic**: Upgrade automatic/recurring transactions to support Weekly (7 days), Monthly (30 days), Yearly (365 days), and Custom (Specific day of the month OR every X days).
- [ ] **UI Logic**: Position custom field error messages directly below the input field inside the recurring transaction popup to prevent keyboard overlap.
- [ ] **Reactive State**: Ensure all statistics (total balance, wallet balances, account stats) react instantly to any CRUD operation (including recycle bin restores/deletes) while respecting currency conversions.
- [ ] **Localization**: Verify and complete missing translations across `app_en.arb`, `app_es.arb`, and `app_ca.arb` for all texts, buttons, and errors.
- [ ] **Quality Assurance**: Ensure 100% passing rate for all unit/integration tests, GitHub Actions CI workflows, and `flutter analyze` (0 errors, 0 warnings, 0 info).
- [ ] **Documentation**: Update `roadmap.md`, `README.md`, and inline documentation to reflect the final production-ready state.
- [ ] **Optimization**: Execute a deep code cleanup (remove unused files, dead code, redundant comments, and orphan localization keys) to minimize app footprint. Re-verify tests post-cleanup.

## Context
- **Architecture**: Clean Architecture
- **State Management**: Riverpod
- **Database**: Drift + SQLCipher
- **Current Status**: Pre-production polish. Code modifications must be written directly to the file system.