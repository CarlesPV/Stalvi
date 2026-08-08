# Phase 58: PIN Lockout Timer Update & Transaction Amount Field Cursor Alignment

## Context
Project: Stalvi (Financial Control App)
Architecture: Clean Architecture, Riverpod, Drift (SQLCipher)
Current Phase Status: Completed

## Objectives
- Fix the 30-second PIN lockout countdown display to dynamically update on the lock screen.
- Reposition the text cursor on transaction amount entry fields to start at the left side, directly after the currency symbol.
- Ensure all tests, CI checks, and static analysis pass cleanly in English.

## Tasks
- [x] **Task 1: Lockout Timer Refresh**
  - Convert `_PinLockoutContent` to a `StatefulWidget` with a `Timer.periodic` ticker calling `setState()`.
- [x] **Task 2: Amount Cursor Alignment**
  - Set `textAlign: TextAlign.left` in amount input fields in `add_transaction_screen.dart` and `create_edit_automatic_transaction_screen.dart`.
- [x] **Task 3: Verification & Documentation**
  - Verify static analysis (`flutter analyze`) and tests (`flutter test`).
  - Update `roadmap.md`, `roadmap-summary.md`, `.agents/context/roadmap-summary.md`, `docs/known-issues.md`, and `active-task.md`.