# Active Task: Phase 38 - Data Integrity, Serialization Expansion, and UI/UX Polish

## Objective
Enforce strict business rules for data deletion across relational entities, expand full-data backup capabilities, and polish UI/i18n implementations to guarantee a production-ready user experience.

## Status: In Progress

## Sub-tasks
- [ ] **UI/UX:** Fix the splash screen dark mode configuration so the app icon renders with normal brightness, avoiding the darkened overlay.
- [ ] **Business Logic (Categories):** Prevent category deletion if linked to active automatic/recurring transactions. Enforce reassignment or block deletion with a clear UI message.
- [ ] **Business Logic (Accounts):** Prevent account/wallet deletion if linked to automatic/recurring transactions. Show a post-confirmation error pop-up (with a close button) blocking the action.
- [ ] **Data Serialization:** Update the backup/restore mechanism (JSON export/import) to fully include Savings Goals, Budgets, and Automatic Transactions.
- [ ] **Localization & UI Polish:** Ensure 100% synchronization across English, Spanish, and Catalan (`app_en.arb`, `app_es.arb`, `app_ca.arb`). Resolve all text overflows (buttons, dialogs, selectors) and avoid truncation ("...").

## Context Notes
- Follow Clean Architecture principles (Use Cases handle the constraint logic).
- Update unit tests for all modified Use Cases and Repositories.
- Use Riverpod for state updates reflecting the new constraints.
- Modify files directly without outputting code to the chat interface.