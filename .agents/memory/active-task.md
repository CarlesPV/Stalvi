# Active Task: Phase 19 - Complex Cascades, Riverpod Reactivity & Deep UX Polish

## Current Status
- Phase 18 completed: Core UI, dynamic l10n, and basic CRUD are stable.
- Pending critical business rules regarding referential integrity (cascading deletes), complex transaction mapping (transfers), global state reactivity, and comprehensive localization coverage.

## Objectives for Current Phase
1. **Transfer Mirroring Logic:** A transfer must generate 2 linked transactions (origin account: negative amount, destination account: positive amount). Deleting or restoring one must apply the same action to its mirrored counterpart.
2. **UI Polish - Transaction Details:** Hide the "Notes" field if it is empty. The title of the modal must dynamically display the localized Transaction Type name, not a generic "Recent Transactions" string.
3. **Settings Reorganization:** Move "Categories & Tags" out of the "Profile & Security" screen and place it directly on the main Settings page, positioned exactly between "Statistics" and "Profile & Security".
4. **Inline Error Handling:** When attempting to delete the last remaining account, display the error directly inside the confirmation Dialog/Pop-up instead of a Snackbar hidden by the keyboard.
5. **Real-time Reactivity:** Ensure that creating, editing, or deleting a transaction forces an immediate invalidation/refresh of the Dashboard statistics and account balances.
6. **Cascading Account Deletion:** When an account is permanently deleted (or moved to trash), all associated transactions must logically follow the same state.
7. **Hard Delete Refresh:** Permanently deleting items from the Recycle Bin must trigger a global provider invalidation to refresh UI elements (statistics, category lists, accounts).
8. **App Wipe & System Kill:** Executing "Delete all data" must completely wipe the database and invoke `SystemNavigator.pop()` or `exit(0)` to force a cold restart of the application.
9. **Global Localization Audit:** Ensure all new strings, transaction types, error messages, and buttons are mapped in the `.arb` files (ca, es, en).

## Architectural Guidelines
- **Database Atomicity:** Mirrored transfer operations MUST be executed within a `db.transaction(() async { ... })` block.
- **State Invalidation:** Use `ref.invalidate()` or `ref.refresh()` in Notifiers immediately after a successful UseCase execution.
- **Direct Modification:** Agents must modify files directly without outputting code explanations in the chat.