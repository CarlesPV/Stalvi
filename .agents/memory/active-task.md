# Active Task: Phase 21 - Transfer Flow Polish, Recycle Bin Refinements & Validation

## Current Status
- All E2E bugs, transfer details lookup failures, and recycle bin localization issues have been resolved.
- Full automated test suite (352 tests) and static analysis pass cleanly.
- Documentation, roadmap, and resolved issues logs have been updated.

## Completed Objectives
1. **Empty Note Default**: Cleared note field default value on transfer creation forms to start empty.
2. **Transfer Deduplication**: Paired transfers are deduplicated in global lists but display correctly for both accounts under filters.
3. **Transaction Details Lookup**: Created `watchRawTransactions()` and `rawTransactionsStreamProvider` to search both legs of a transfer, allowing the details modal to show the origin and destination accounts correctly.
4. **Recycle Bin Operations & i18n**:
   - Disabled bulk "delete all/empty sweep" to avoid accidental deletions.
   - Added metadata tracking to `TrashItem` (`amount`, `txType`, `currency`) in `TrashDao`.
   - Updated Recycle Bin list tiles to dynamically render items formatted as `<Note/Type> - <Amount>` using localized translations.
   - Ensured deleting a transfer places exactly 1 item in the Recycle Bin.
   - Wired Recycle Bin provider to `autoDispose` for automatic refresh on entry.
5. **Icon & Balance Synchronization**:
   - Standardized transfer icons on the dashboard.
   - Ensured trashing, restoring, or hard-deleting transactions (including mirrored transfers) properly reverts or re-applies account balances for both accounts.
6. **UI Overflow Sweep**: Audited all screen layouts to ensure no overflows or truncated ellipsis ("...") occur under dynamic screens.

## Architectural Guidelines
- **Clean Architecture:** Pass parameters to the Domain layer and use repository/use-case bounds for transactions logic.
- **Unfiltered Streams:** Use raw unfiltered streams for detail dialog queries to verify related entity pairs (e.g. transfers), and filtered streams for general listings to prevent duplicate visibility.
- **Reactivity:** Use Riverpod invalidations to force refresh state upon mutations.