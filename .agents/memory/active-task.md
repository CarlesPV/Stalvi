# Phase 67: Account Statistics Transfers, Cash Flow Integration & Recycle Bin Chronological Sorting

## Objective
Enhance account-level financial statistics to include transfer inflows and outflows using raw transaction streams, recalculate cash flow net balance, add a dedicated Transfers summary card, enforce strict surplus/deficit badge rendering, order the recycle bin chronologically by most recently deleted first (`deletedAt` descending), and maintain full trilingual parity across English, Spanish, and Catalan.

## Tasks
- [x] **1. Raw Transaction Streams in Statistics:** Watched `rawTransactionsStreamProvider` across `periodSummaryProvider`, `dashboardPeriodSummaryProvider`, and top categories providers to prevent premature transfer deduplication on destination accounts.
- [x] **2. Cash Flow & Transfers Domain/DAO:** Extended `PeriodSummary` entity and `StatisticsDao` with `totalTransfersIn` and `totalTransfersOut` SQLite aggregation fields, and updated `_NetBalanceCard` to compute accurate cash flow (`Income - Expense + Transfers In - Transfers Out`).
- [x] **3. Strict Surplus/Deficit Badges:** Render `▲ Surplus` strictly when `net > 0`, `▼ Deficit` strictly when `net < 0`, and omit badges when `net == 0`.
- [x] **4. Dedicated Transfers UI Card:** Implemented a new `_SummaryCard` for Transfers (`statisticsTransfers`) displayed conditionally when an account filter is active.
- [x] **5. Recycle Bin Chronological Sorting:** Updated `TrashDao.getTrashItems()` and `RecycleBinNotifier` to sort soft-deleted items by most recently deleted first (`b.deletedAt.compareTo(a.deletedAt)`).
- [x] **6. Trilingual Localization:** Synchronized `statisticsTransfers` across `app_en.arb`, `app_es.arb`, and `app_ca.arb` and regenerated localization classes (`flutter gen-l10n`).
- [x] **7. Tests & Static Analysis:** Added unit and widget tests for origin/destination transfer stats, zero-balance badges, and recycle bin sorting. All 569 tests passing with 0 `flutter analyze` issues.
- [x] **8. Documentation & Memory:** Updated `roadmap.md`, `roadmap-summary.md`, `docs/resolved-issues-june-2026.md`, `.agents/context/roadmap-summary.md`, and `.agents/memory/active-task.md`.