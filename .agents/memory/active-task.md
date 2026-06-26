# Active Task: Phase 28 - Financial Data Integrity & Polish

## Current Objective
Implement advanced CRUD operations, ensure reactive financial recalculations, fix PDF encoding, and polish i18n/legal documents.

## Context
- **Architecture:** Clean Architecture + Riverpod + Drift
- **Focus Areas:**
  1. UI/Domain connection for Editing Budgets and Savings Goals.
  2. Reactive Budget calculation integrating currency conversion upon transaction deletion.
  3. ACID transactions for soft-deleting/restoring Savings Goals (cascading to transfers and updating origin accounts balances).
  4. PDF Export unicode font embedding.
  5. Legal docs updates and full i18n coverage.

## Next Steps
1. Execute the atomic prompts to implement the logic layer by layer.
2. Run unit tests for the new complex cascading deletion logic.
3. Validate UI for overflow and localization correctness.
4. Update tests, workflows, and documentation.

## Rules
- All file modifications must be done directly via tools. NO code output in chat.
- Keep Clean Architecture boundaries strictly intact.