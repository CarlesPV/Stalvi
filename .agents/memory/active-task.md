# Active Task: Phase 30 - UI/UX Stabilization & Data Integrity

## Objective
Refine user interface consistency, resolve layout overflows, enhance form validation UX, and implement safe entity deletion workflows for categories.

## Context
The core architecture (Clean Architecture + Riverpod + Drift/SQLCipher) is stable. This phase focuses on resolving critical UX friction points reported in Phase 29, specifically around asset management, visibility of sensitive data, error handling, and data reassignment.

## Current State
- **Status**: IN_PROGRESS
- **Priority**: HIGH

## Tasks
- [ ] **Asset Unification:** Remove redundant cropped app icons. Use a single primary logo and scale/crop dynamically via Flutter widgets.
- [ ] **Dashboard UX:** Increase the size and hit target of the "Eye" visibility toggle icon for balance and statistics.
- [ ] **Validation UI:** Refactor error messaging globally (especially auth/registration) to show inline below input fields instead of snackbars/popups.
- [ ] **Overflow Resolution:** Audit and fix layout overflows across all screens, specifically the currency selector in the registration flow.
- [ ] **Transaction Details:** Update `transaction_details_dialog.dart` to display the specific Transaction Type in the header/title.
- [ ] **Category Reassignment Logic:** Enhance `delete_and_reassign_category_usecase.dart` and the settings UI to force reassignment of existing transactions when a category is deleted. Enforce filtering: Expense -> Expense/Custom, Income -> Income/Custom, Custom -> All.
- [ ] **Custom Category Icons:** Ensure custom icons map and render correctly across all lists (transactions, savings goals, etc.).

## Next Steps
Execute the atomic prompts defined for Phase 30 sequentially to complete these tasks.