# Project Overview: Stalvi

**Name:** Stalvi
**Objective:** A local-first, highly secure financial application to track income, expenses, budgets, and savings goals.
**Tech Stack:** Flutter (Dart), Riverpod, Drift (SQLite), SQLCipher.

## Core Rules
- **Privacy First (Zero-Knowledge):** All data must remain on the device. No cloud synchronization of financial data.
- **Security:** Local database must be encrypted at rest using SQLCipher. 
- **Performance:** Heavy calculations (global balances, monthly summaries) must be executed at the SQLite level using aggregations (`SUM()`, `GROUP BY`), avoiding Dart memory overload.
- **Integrity:** Use soft deletes (`is_deleted` flag, 30-day trash) to protect against accidental data loss.