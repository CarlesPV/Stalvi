# Known Issues

This document tracks known issues in the Stalvi application that require resolution.

## Active Issues
*No active runtime issues are currently known.*

## Resolved Issues

### 1. Onboarding / First-Time Login Error
* **Symptom:** When a user creates a new profile or attempts to log in for the very first time, an error is triggered, forcing the user to try again. On the second attempt, it succeeds.
* **Resolution:** Implemented a retry-on-failure mechanism for write/read/delete operations in `SecureStorageManager` to handle transient platform channel/keychain synchronization latency during first-time writes. All subsequent initialization stages now complete reliably without requiring a retry.

### 2. SQLCipher Isolate FFI Binding Crash (Android)
* **Symptom:** The application crashes at launch with `failed to load dynamic library libsqlite3.so` on Android.
* **Resolution:** Replaced `NativeDatabase.createInBackground` with the standard `NativeDatabase` constructor. This ensures that the FFI dynamic library overrides configured via `open.overrideFor` on the main thread are properly applied when opening the SQLCipher database, rather than being lost across an isolate boundary.

### 3. Recurring Transaction End-of-Month Recurrence Logic Edge Cases
* **Symptom:** The automatic/recurring transaction generation engine failed to handle months with fewer days correctly when scheduling transactions on specific days of the month (e.g. 30th or 31st), resulting in potential execution delays or errors during short months.
* **Resolution:** Refactored execution date calculation to apply safe end-of-month clamping logic (e.g. executing a transaction scheduled for the 31st on February 28th/29th or April 30th) and subsequently restoring to the target day on future longer months.



