# Phase 59: Data Export Navigation, Asset Expansion, Legal Docs & Default Categories

## Context
Project: Stalvi (Financial Control App)
Architecture: Clean Architecture, Riverpod, Drift (SQLCipher)
Current Phase Status: In Progress

## Objectives
- Integrate an export button in the Account Statistics view routing to the Data Management section (CSV/PDF export).
- Expand UI assets: Add 15 new colors and 50 new icons for categories, plus 4 new icons for savings goals.
- Ensure Terms and Conditions & Privacy Policy include robust liability exemptions and full legal compliance in 3 languages.
- Update the default Drift database seed to include new default categories (Expenses: Pet, Personal Care, Sport; Income: Sale, Refund; Both: Investment).
- Ensure all 3 languages (English, Spanish, Catalan) are fully supported across all new features.
- Run and pass all tests, workflows, and CIs cleanly before updating documentation.

## Tasks
- [ ] **Task 1: Export Navigation Button**
  - Add an export button to the left of the date picker in account statistics.
  - Implement routing to the Data Management view.
- [ ] **Task 2: Asset Expansion (Colors & Icons)**
  - Add 15 new color constants.
  - Add 50 new icon options for Categories.
  - Add 4 new icon options for Savings Goals.
- [ ] **Task 3: Legal Documentation Review**
  - Update ToS and Privacy Policy for compliance and liability exemptions in 3 languages.
- [x] **Task 4: Default Categories, CI Validation & Docs**
  - [x] Update Drift database initialization to include the new default categories.
  - [x] Run `flutter analyze`, `flutter test`, and GitHub Actions workflows.
  - [x] Update `roadmap.md`, `README.md`, and `.agents/memory/active-task.md`.