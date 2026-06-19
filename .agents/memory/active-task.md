# Active Task: Phase 22 - Multi-Currency Snapshot, Auth Fallbacks & i18n Completeness

## Current Status
- **Phase:** 22
- **State:** Completed
- **Primary Focus:** Implement historical exchange rate snapshots per transaction, background sync for exchange rates, resolve biometric/PIN fallback logic, and complete full i18n coverage.

## Objectives
1. **Multi-Currency Immutability:**
   - `[x]` Update `Transaction` entity and `transaction_table` in Drift to store a snapshot of current exchange rates at creation time.
   - `[x]` Implement 24h background sync for exchange rates upon app opening (silent update).
2. **Account Initialization:**
   - `[x]` Modify initial profile setup to generate default account as "Mi Cartera" (localized) with 0 balance in the user's default currency.
   - `[x]` Ensure default currency changes in settings reflect instantly across the app state.
3. **UI & Data Presentation:**
   - `[x]` Remove positive/negative symbols (+/-) from Transfer transactions.
   - `[x]` Format Statistics based on Account currency or Default currency (if "All" is selected).
4. **Security & Auth UX:**
   - `[x]` Fix "Delete All Data" fallback: allow PIN authentication if biometrics are enabled but fail/cancelled.
   - `[x]` Add biometric opt-in prompt on the unlock screen if not previously activated.
5. **Localization (i18n):**
   - `[x]` Translate all missing loading, error, and feedback states into English, Spanish, and Catalan (`.arb` files).

## Files in Scope
- `lib/domain/entities/transaction.dart`
- `lib/data/database/tables/transaction_table.dart`
- `lib/presentation/providers/app_startup_provider.dart`
- `lib/domain/usecases/create_profile_usecase.dart`
- `lib/presentation/features/auth/auth_screen.dart`
- `lib/presentation/features/settings/profile_settings_controller.dart`
- `lib/core/l10n/app_*.arb`

## Strict Guidelines
- Maintain Clean Architecture and DRY principles.
- Ensure all new database migrations handle SQLCipher encryption properly.
- All operations must be covered by Unit Tests.
- Do not output code to the chat; write directly to the file system.