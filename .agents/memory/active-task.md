# Active Task: Phase 17 - Domain Refinement, Advanced Filters, and Metadata Management

## Current Status
- **Phase:** 18
- **Focus:** Synchronization, Backups, and Import/Export Validations.
- **Architecture:** Clean Architecture + Riverpod + Drift + SQLCipher.

## Objectives
1. **Localization & Initialization:**
   - [x] Fix multi-account text display ("A rosa X accounts") in main page to use proper localized pluralization.
   - [x] Localize the default Account/Wallet name upon initial app installation based on user's selected language.
   - [x] Ensure the Recycle Bin is completely empty upon app initialization.
2. **Domain & Data Enhancements:**
   - [x] Add `Transfer` transaction type (moving funds between accounts).
   - [x] Add `is_default` boolean to Account entity/table (ensuring only one default exists at a time).
   - [x] Rename initial balance UI field from "SALDO INICIAL" to "SALDO".
   - [x] Implement advanced dynamic filtering in Transactions (by account, type, category, date range, min-max amount, tags, currency).
3. **Statistics & Settings:**
   - [x] Default the Statistics view to the `is_default` account, with an option to select other accounts.
   - [x] Add "Categories and Tags" management section in Settings (CRUD operations).
   - [x] Implement "Soft Delete" for Categories/Tags with a mandatory reassignment flow if the entity is currently in use.
   - [x] Refactor "Wipe All Data" use case to guarantee a 100% clean state (factory reset equivalent).

## Next Steps
- Implement cloud synchronization options.
- Add encrypted automatic local backup features.
- Validate cross-platform imports/exports.