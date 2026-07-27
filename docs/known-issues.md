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

### 4. Application Exit Freeze During "Wipe All Data"
* **Symptom:** When wiping all application data from the settings screen on a physical device, the application cleared all data successfully but failed to exit/close, remaining stuck on the settings screen.
* **Resolution:** Identified that calling `_appDatabase.close()` while active Riverpod UI stream listeners were attached caused `close()` to hang indefinitely. Added a 500ms timeout to `close()` in `WipeAllDataUseCase` to prevent deadlocking, and delegated process termination (`SystemNavigator.pop()` and `exit(0)`) to the UI layer after data purge completion.




