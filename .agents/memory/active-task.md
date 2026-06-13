# Active Task Memory

## Current Task
Execute Phase 3: Transaction Core & Financial Operations. Implement the `Transaction` domain entity, Drift database table, repositories, core use cases (with atomic account balance updates), and the Presentation UI for creating transactions.

## Execution Plan
- [x] Step 1: Implement `Transaction` Domain Entity, `ITransactionRepository` interface, Drift `Transactions` table, and `TransactionMapper`.
- [x] Step 2: Implement the Drift-based `TransactionRepository` and the `AddTransactionUseCase`. Enforce the business rule: saving a transaction MUST atomically update the associated `Account` balance within a database transaction block. Write AAA Unit Tests.
- [x] Step 3: Develop `AddTransactionScreen` (Presentation) and its Riverpod controller (`add_transaction_notifier`). Include form validation (amount > 0, valid date) and category/account dropdown selectors. Update Dashboard skeleton with a Floating Action Button.

## Progress & Notes
- Phase 1 (Foundation & Security) is fully completed and verified.
- Phase 2 (Domain Modeling & Local Storage) is fully completed and verified.
- Phase 3 (Transaction Core) is fully completed and verified.
- Strict adherence to Clean Architecture is maintained.

## Vulnerability & Security Logs
- Financial precision: All transaction amounts must use integer-based calculations (e.g., storing minor units/cents) to prevent floating-point calculation vulnerabilities.
- Data Integrity: Database insertions for transactions and balance updates must be executed within a Drift `transaction()` callback to ensure rollback if any step fails.