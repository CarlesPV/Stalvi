# Active Task: Phase 18 - UX/UI Polish, Edge-Case Business Rules & Dynamic L10n

## Current Status
- Clean Architecture, Riverpod, and Drift (SQLCipher) implementation stable.
- Core CRUD operations for transactions, accounts, and categories are functional.
- Pending UX/UI standardization, translation dynamic injection, and complex deletion rules.

## Objectives for Current Phase
1. **Settings Reorganization:** Move "Categories & Tags" outside and above the "Profile & Security" section in `profile_settings_screen.dart`.
2. **Transfer Entity UI:** Enforce the transfer icon strictly for all transfer transactions. Show Origin, Destination, Amount, Date, and Notes in `transaction_details_dialog.dart`.
3. **Category Reassignment Logic:** Upon deleting an in-use category, prompt reassignment matching the transaction type (income/expense) + all user-created categories.
4. **Category Icon Management:** Implement an icon picker in category edition/creation with a strict selection of 128 unique, finance/lifestyle relevant Material icons.
5. **Filter UX:** Update the clear filter icon to a broom (`Icons.cleaning_services` or similar).
6. **Dynamic L10n Initialization:** Translate the default wallet name ("La meva cartera", "Mi cartera", "My wallet") dynamically during user creation in `initialize_default_data_usecase.dart`.
7. **Account Management Rules:** Allow setting an account as 'Default' (warning user). Prevent deletion of the last account. Auto-reassign default status to the oldest available account if the current default is deleted.
8. **App Wipe & Exit:** Ensure "Delete all data" cleans the database completely and forces app closure (`SystemNavigator.pop()` or `exit(0)`).
9. **Global L10n Check:** Verify complete translation across ca, es, en.

## Architectural Guidelines
- **Strict Clean Architecture:** UI must not contain business logic. Deletion and reassignment rules belong in UseCases.
- **Direct Modification:** Agents must modify files directly without outputting code explanations in the chat.