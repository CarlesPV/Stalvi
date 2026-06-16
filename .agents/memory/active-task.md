# Active Task: Documentation & Validation Pass

## Current Objective
Perform a final comprehensive documentation, architecture, and roadmap update, ensuring all tests, lints, and static analysis pass perfectly across the repository.

## Sub-tasks
1. **Settings Consolidation Documentation**: Ensure `roadmap.md`, `roadmap-summary.md`, `overview.md`, and business rules reflect the removal of the standalone profile section and the introduction of the unified "Profile & Security" settings screen and Recycle Bin layout.
2. **Glossary Clean Up**: Align glossary terms with actual codebase symbols (e.g. `Transaction` instead of `Movement`).
3. **Lint & Style Fixes**: Clean up any remaining trailing comma issues or static analysis lints in consolidated widgets.
4. **Automated Testing Validation**: Re-run the full Flutter test suite (190+ tests) to guarantee 100% test passing rate before release.

## Context Notes
- **Architecture**: Clean Architecture + Riverpod + Drift (SQLCipher) offline-first database.
- **Project State**: Completed Phase 12 (Profile and Settings Consolidation), transitioning to Phase 13 (Synchronization & Backups).