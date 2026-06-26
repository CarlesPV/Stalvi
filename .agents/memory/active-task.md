# Active Task: Phase 27 - Advanced Budgets, Goals, and Reporting

## Current State
The core Clean Architecture structure, Riverpod state management, and encrypted local database (Drift) are implemented up to Phase 26. We are now integrating complex business rules linking accounts, budgets, goals, and strictly formatting the PDF exports.

## Objectives
1. **Reporting Enhancements**: 
   - Modify PDF export to adjust the Income vs Expense chart (remove text scale, use 4 reference lines with localized currency values on the left).
   - Display the destination account/wallet for Transfer-type transactions in the PDF.
   - Append active Budgets and Savings Goals tables at the end of the PDF, localized in EN, ES, and CA.
2. **Budgets & Goals Domain Rules**:
   - Implement soft-delete (30-day trash retention) for Budgets and Savings Goals.
   - Lock currency and target amounts upon creation for both Budgets and Goals.
   - Bind Budgets to a specific account upon creation. If the account is deleted, fallback automatically to the user's default account.
   - Auto-calculate and update Budget spent amounts when a transaction occurs, applying real-time currency conversion if the transaction currency differs from the budget currency.
3. **Savings Goals Funding Rules**:
   - Allow Savings Goals to be the destination of Transfer transactions.
   - Automatically mark a Savings Goal as completed when the target is reached, enabling hard-delete options.
   - If a Savings Goal is soft-deleted, trigger a rollback workflow to refund the collected money back to the origin accounts.

## Architecture Guidelines
- Strict Clean Architecture separation (Domain -> Data -> Presentation).
- Use `CurrencyConverter` for all multi-currency calculations.
- Maintain soft-delete logic consistently within DAOs and Use Cases.
- Ensure all new strings are added to `.arb` files for i18n support.