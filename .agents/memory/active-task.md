# Active Task: Phase 48 - Background Resilience & Final Polish

## 🎯 Objective
Finalize production readiness by fixing background task execution for automated transactions, implementing notification toggles with permission handling, refining file export paths, and ensuring 100% test coverage and CI/CD success.

## 🏗️ Architecture & Core Components
*   **Clean Architecture:** Domain rules for transactions, Infrastructure for Workmanager, Notifications, and File System.
*   **State Management:** Riverpod for Settings/Notification toggles.
*   **Background Tasks:** Workmanager executing every 3 hours reliably.
*   **Localization:** EN, ES, CA support for new settings.

## ✅ Task Checklist
- [x] **Optional Notifications:** Add a toggle in Profile & Security (Settings) between Language and T&C to enable/disable notifications. Default is ON. Check and request system permissions when toggling ON. Fully translated to EN, ES, CA.
- [x] **Fix Automatic Transactions:** Fix the "Day X of month" transaction logic. Configure Workmanager to reliably check for pending transactions every 2-3 hours in the background.
- [x] **Export Priorities:** Refactor export logic to attempt saving to the `Downloads` folder first, falling back to `Documents` if it fails.
- [x] **Quality Assurance:** Ensure the app compiles with 0 warnings, passes all unit/integration tests, and the CI/CD workflows are green.
- [x] **Documentation Update:** Update README.md, roadmap.md, and code comments to reflect the final production-ready state.