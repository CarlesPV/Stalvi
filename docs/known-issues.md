# Known Issues

This document tracks known issues in the Konta application that require resolution.

## Active Issues
*No active runtime issues are currently known.*

## Resolved Issues

### 1. Onboarding / First-Time Login Error
* **Symptom:** When a user creates a new profile or attempts to log in for the very first time, an error is triggered, forcing the user to try again. On the second attempt, it succeeds.
* **Resolution:** Implemented a retry-on-failure mechanism for write/read/delete operations in `SecureStorageManager` to handle transient platform channel/keychain synchronization latency during first-time writes. All subsequent initialization stages now complete reliably without requiring a retry.

