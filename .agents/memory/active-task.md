# Active Task: Phase 42 - Core Stabilization & Refinement

## Current Objectives
- [ ] **Data Layer**: Fix backup system (Import/Export) to properly serialize and deserialize the destination account (`destinationAccountId`) for Transfer transactions.
- [ ] **Domain Layer**: Refactor Budget calculations to filter transactions by both `categoryId` and the assigned `accountId` (Wallet).
- [ ] **Presentation/Export**: Update the PDF generation service to include an "Account" column in the Budgets table, placed between the Category and Date Range columns.
- [ ] **Infrastructure Layer**: Debug and fix background services for automatic/recurring transactions. Ensure triggers execute reliably at 0:00 UTC+2 and respect custom recurrence times.

## Architectural Constraints
- Maintain Clean Architecture separation of concerns.
- Ensure all Drift queries are optimized and SQLCipher encryption is intact.
- Background tasks must initialize their own dependency container (Riverpod ProviderContainer/Drift instance) safely.
- Maintain 100% unit test coverage for new business rules.

## Status
In Progress