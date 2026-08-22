# Phase 68: Statistics Transfers, Default Account Constraints & Form UX Improvements

## Objective
Ensure that statistics filtering by account correctly displays transfer data. Enforce strict domain constraints to guarantee the app always has exactly one active default account. Improve User Experience across all forms (screens and popups) by configuring the keyboard to automatically jump to the next input field upon pressing 'Enter' or 'Next'. Ensure 100% test coverage and trilingual localization parity.

## Tasks
- [x] **1. Fix Statistics Account Filtering:** Updated `isEmpty` check in `statistics_screen.dart` to include transfers.
- [x] **2. Enforce Default Account Constraints:** Updated `UpdateAccountUseCase` to throw `DEFAULT_ACCOUNT_REQUIRED` and `CreateAccountUseCase` to force `isDefault = true` for the first account.
- [x] **3. UI & Localization Updates:** Added `errorDefaultAccountRequired` to `.arb` files and handled the error in `edit_account_dialog.dart`.
- [x] **4. Form UX - Keyboard Focus Navigation:** Update `TextField` and `TextFormField` widgets across the app (`add_transaction_screen`, `create_account_dialog`, `edit_account_dialog`, `create_edit_budget_sheet`, `create_edit_savings_goal_sheet`, `create_edit_automatic_transaction_screen`, `categories_tags_management_screen`, `data_management_screen`, etc.) to use `textInputAction: TextInputAction.next` (and `done` for the final field). Implement `FocusNode` state and `onSubmitted` logic so the keyboard jumps to the next logical field automatically and closes on the last one without triggering premature confirmation.
- [x] **5. Testing:** Verify form submissions and focus jumps don't break existing widget tests. Ensure `flutter test` and `flutter analyze` pass.
- [x] **6. Documentation & Memory:** Update `roadmap.md`, `roadmap-summary.md`, and `.agents/memory/active-task.md` upon successful completion.