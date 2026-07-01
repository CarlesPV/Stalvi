# Active Task: Phase 35 - Stabilization, Reactive Calculations, Bugfixing, and Final Polish

## Context
Stalvi has reached Phase 34, completing core functionalities. The current focus is strictly on app stabilization, ensuring absolute real-time data consistency across all screens (especially with currency conversions), fixing existing UI/UX and database bugs in automatic transactions, and achieving a zero-warning codebase.

## Current Objectives
1. **Splash Screen Fix:** Ensure the app compiles with `splash_icon.png` as the native initial loading screen.
2. **Reactive Financial Calculations:** Refactor Riverpod providers to listen to Drift Streams. All balances, total incomes, total expenses, and statistics must update instantly globally when any transaction is created, updated, or deleted, automatically applying currency conversions.
3. **Automatic Transactions UI/UX:** Reorder the creation form (Name field between Amount and Account). Fix the recurrence radio button state mismatch (Custom vs. Standard options).
4. **SQLite Bugfix:** Resolve the `SqliteException(1)` occurring during automatic transaction creation.
5. **Quality Assurance:** Ensure 100% passing tests and completely clean outputs for `flutter analyze` (0 errors, 0 warnings, 0 info).
6. **Documentation & Cleanup:** Update `roadmap.md`, `README.md`, and all inline documentation. Perform a deep cleanup of unused files, comments, and translation strings to optimize app size.

## Actionable Steps
- [ ] Execute native splash screen generation with `splash_icon.png`.
- [ ] Implement reactive stream combinations (Drift + CurrencyConverter) in Riverpod providers for Dashboard and Accounts screens.
- [ ] Refactor `CreateEditAutomaticTransactionScreen` UI layout and state management.
- [ ] Debug and fix `automatic_transaction_dao.dart` or related mapper/entity logic causing the SQLite insert error.
- [ ] Run `flutter analyze` and `flutter test`, fixing all issues recursively.
- [ ] Clean up unused code/assets and update documentation files.
- [ ] Final validation pipeline execution.