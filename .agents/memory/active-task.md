# Phase 55: Transaction UX Enhancements & Automatic Transaction Labels

## Status: COMPLETED
## Objective
Enhance the user experience of transaction forms by reordering Category and Label fields, implementing inline creation for both, and ensuring parity between manual and automatic transactions by adding Label support to the latter. Ensure all new data points are securely backed up.

## Tasks
- [x] 55.1: Update `AutomaticTransaction` entity, Drift schema, and DAOs to include an optional `labelId`. Create safe DB migration.
- [x] 55.2: Update Backup and Restore UseCases / DTOs to include the new `labelId` in JSON exports.
- [x] 55.3: Refactor `AddTransaction` and `AddAutomaticTransaction` forms to position the Label field directly below the Category field.
- [x] 55.4: Implement inline "Create New Category" and "Create New Label" options as the first items in the respective selectors. Ensure auto-save and auto-select behavior using Riverpod.
- [x] 55.5: Update translations (EN, ES, CA) for the new UI elements.
- [x] 55.6: Ensure 100% pass rate for unit, widget, and integration tests, verify CI/CD workflows without warnings, and update docs.

## Current Context
- **Architecture**: Clean Architecture + Riverpod + Drift (SQLCipher).
- **Strict Rule**: All agents MUST directly modify files. NO code snippets in chat output. Optimize token usage.