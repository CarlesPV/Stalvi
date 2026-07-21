# Active Task: Phase 46 - Core Bug Fixes & Launch Readiness

## 🎯 Objective
Fix critical bugs preventing the app from being production-ready: file export issues on some devices, incorrect currency conversions in account balances, unreliable automatic transaction triggers, and missing push notifications for automated actions. Ensure all CI/CD pipelines and tests pass 100%.

## 🏗️ Architecture & Core Components
*   **Clean Architecture:** Strict separation between background execution (Infrastructure) and business rules (Domain).
*   **Local DB:** Drift with SQLCipher.
*   **Background Tasks:** Workmanager and local app-start triggers for fallback transaction creation.
*   **Notifications:** Local push notifications for background execution feedback.

## ✅ Task Checklist
- [x] **Fix Exporting Files:** Ensure exporting PDF, CSV, and Backups works seamlessly on all devices by saving directly to public system Documents and Downloads folders (visible in system file manager Recents) without third-party share pop-ups.
- [x] **Wallet Currency Conversions:** Fix balance calculations so that Incomes, Expenses, and Transfers accurately convert amounts based on the account's currency vs the transaction's currency.
- [x] **Stabilize Automatic Transactions:** Fix the background trigger (Workmanager) to be reliable. Implement a 2-hour periodic check or a fallback that executes on app startup to guarantee execution even if the OS kills the background task.
- [x] **Local Push Notifications:** Implement `flutter_local_notifications` to send a translated local push notification ("Transaction [name] completed successfully" in EN, ES, CA) whenever an automatic transaction is created.
- [x] **Testing & Quality Assurance:** Ensure 100% test pass rate, 0 static analysis warnings, and CI/CD workflow success for the final launch candidate.

## 🧪 Testing & CI/CD
- Test currency conversion logic in `AccountDao` or UseCases with different currencies.
- Ensure automated background triggers and notification logic are tested.
- CI/CD workflows must pass with 0 warnings, 0 errors, and 0 failures.