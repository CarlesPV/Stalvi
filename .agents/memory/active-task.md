# Phase 56: CI/CD Stabilization and Domain Refinement

## Context
Project: Stalvi (Financial Control App)
Architecture: Clean Architecture, Riverpod, Drift (SQLCipher)
Current Phase Status: Completed

## Objectives
- Resolve the Android Build failure in CI related to `workmanager_android` and the Kotlin Gradle Plugin (KGP).
- Refactor the transaction creation/edit domain rules to completely remove the default "Uncategorized" (Sin categoría) option.
- Unify the category selector UI/logic for standard transactions to match the recurring/automatic transactions selector.
- Ensure 100% success rate on all unit tests, integration tests, and GitHub Actions (CI workflows).
- Maintain robust localization across the 3 supported languages.

## Tasks
- [x] **Task 1: DevOps & Build Stabilization**
  - Update `workmanager` and Gradle/Kotlin configurations to fix the `cannot find symbol class WorkmanagerPlugin` error.
- [x] **Task 2: Business Logic & UI Refactor**
  - Remove "Uncategorized" category logic.
  - Update Riverpod providers and UI so standard transactions use the exact same category selector as recurring ones.
- [x] **Task 3: Testing & Documentation**
  - Run all tests and workflows to verify everything passes without warnings/errors.
  - Update `roadmap.md`, `README.md`, and this `active-task.md` document upon success.