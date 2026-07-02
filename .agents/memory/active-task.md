# Active Task: Phase 37 - Production Readiness, Background Tasks & UX Polish

## Objective
Finalize system polishing by implementing background workers for automatic transactions, refining cross-currency aggregations, completing the final UI flows (PDF options, About Me), and performing a strict localization and CI/CD cleanup.

## Current Sub-tasks
- [x] 37.1: Implement multi-currency conversion for total balances on the dashboard and fix the splash screen icon border-radius.
- [x] 37.2: Enhance Automatic Transactions UI to display localized recurrence strings and implement background execution (cron-like at 0:00 UTC+2) via `workmanager`.
- [x] 37.3: Refactor PDF Export to prompt for 'Last 30 Days' or 'Current Month' and implement the 'About Me' localized Markdown screen with an external link.
- [x] 37.4: Perform an exhaustive cleanup of `.arb` localization files (remove unused, ensure 3 languages complete), fix all CI/CD, analyzer warnings, and update documentation (`roadmap.md`, `README.md`).

## Context & Rules
- Strictly adhere to Clean Architecture (Domain, Data, Presentation).
- All strings must be localized in `app_en.arb`, `app_es.arb`, and `app_ca.arb`.
- Background execution must securely access the Drift database.
- DO NOT hallucinate files. Modify existing files where possible.
- All tasks must pass existing unit tests, and new business logic requires new tests.