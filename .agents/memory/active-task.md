# Phase 61: Category Reassignment Logic & PDF Export Polish

## Objective
Convert the "Investment" category to function as a custom category, eliminating the "both" category type. Refine category reassignment logic during deletion to strictly filter by type (matching type + custom categories). Improve PDF export styling by centering specific column data.

## Tasks
- [x] **1. Database & Domain (Investment Category & 'Both' Type Removal):** Update database seed logic so the "Investment" category is created as a custom user category rather than a system category of type "both". Remove the "both" category type from domain entities, enums, and DB schemas.
- [x] **2. Domain & UI (Category Reassignment Filtering):** Modify the category deletion reassignment selector. If the deleted category is an income, show only income + custom categories. If expense, show expense + custom categories. If custom, show all categories.
- [x] **3. UI / Export (PDF Styling):** Update the `ExportServiceImpl` (or PDF generation usecase) to center-align the text within the columns for: Transaction Type, Account, Category, and Tag.
- [x] **4. QA, CI & Documentation:** Update unit and widget tests to reflect the removed "both" type and the new reassignment rules. Verify PDF generation tests. Ensure 100% CI pass rate, update `roadmap.md` and `roadmap-summary.md`. Ensure full compatibility with EN, ES, and CA translations.