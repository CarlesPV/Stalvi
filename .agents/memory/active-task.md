# Active Task: Phase 41 - Background Automation & Export/UI Polish

## Status
- [ ] In Progress

## Objectives
1. **Background Automation & Bug Fixes:** Implement a reliable background worker to process automatic transactions at 00:00 UTC+2, even when the app is terminated. Fix the bug preventing custom recurrence transactions from firing. Ensure currency conversions are applied.
2. **PDF Export Enhancements:** Update the PDF generation service to format transfer transactions as "Origin -> Destination" (e.g., "Cuenta Principal -> Cartera Física"). Change the table header for Budgets/Savings Goals to "Valor máximo". Update the document title to include the User's name and ensure full localization (i18n) across all 3 supported languages.
3. **UI Polish:** Add a padlock icon to read-only fields in the Budget and Savings Goal detail screens to match the UX of the accounts/wallets screens.

## Technical Constraints
- **Architecture:** Clean Architecture.
- **State/DI:** Riverpod.
- **Database:** Drift with SQLCipher.
- **Testing:** All business rules and use cases must be covered by unit tests. CI workflows must pass with 0 warnings/errors.
- **Background Execution:** Must use reliable native scheduling (e.g., `workmanager`) ensuring the Riverpod container and encrypted Drift DB are safely initialized in the background isolate.

## Pending Atomic Tasks
- [ ] Task 41.1: Fix custom recurrence logic and implement UTC+2 background worker.
- [ ] Task 41.2: Refactor PDF Export Use Cases for transfers, headers, and localized titles.
- [ ] Task 41.3: Update UI for Budgets & Savings Goals detail views with read-only padlocks.