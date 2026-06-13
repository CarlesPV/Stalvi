# Active Task Memory

## Current Task
Implement base Drift database with SQLCipher encryption and setup core utilities (Theme, Errors, Formatters).

## Execution Plan
- [x] Step 1: Create `SecureStorageManager` to handle the SQLCipher encryption key using `flutter_secure_storage`.
- [x] Step 2: Initialize `AppDatabase` (Drift) in `lib/data/database/app_database.dart` with the secure connection setup (no tables yet).
- [x] Step 3: Create `AppTheme` in `lib/core/theme/` with pastel aesthetic definitions for Light and Dark modes.
- [x] Step 4: Create custom error classes (`AppExceptions`) and a currency formatter utility.

## Progress & Notes
- Clean Architecture folders initialized.
- **Step 1 done**: `SecureStorageManager` created at `lib/core/security/secure_storage_manager.dart`. Uses `Random.secure()` CSPRNG for 256-bit key generation, hex-encoded storage, hardened platform options (EncryptedSharedPreferences on Android, first_unlock_this_device Keychain on iOS).
- **Step 2 done**: `AppDatabase` created at `lib/data/database/app_database.dart`. Async factory pattern retrieves cipher key before constructing `NativeDatabase`. `PRAGMA key` applied as first statement; key verified via `SELECT count(*) FROM sqlite_master`. No tables defined yet. `app_database.g.dart` generated successfully.
- **Step 3 done**: `AppTheme` created in `lib/core/theme/app_theme.dart`. Implements light/dark themes with a financial-trust aesthetic (Deep Navy Blue primary, pastel Mint Green for positive/income, pastel Coral Red for negative/expenses) and soft charcoal (`#121212`) for dark mode background. Includes a custom `FinancialColors` `ThemeExtension` and `BuildContext` helper.
- **Step 4 done**: Custom exceptions (`DatabaseException`, `ValidationException`, `AuthException`, `NetworkException`, `NotFoundException`) created in `lib/core/errors/app_exceptions.dart`. `CurrencyFormatter` created in `lib/core/utils/currency_formatter.dart` with robust formatting, parsing, and percentage helpers. Added comprehensive unit tests at `test/unit/currency_formatter_test.dart` and verified that they pass.


## Vulnerability & Security Logs
- Encryption key must be generated securely and never logged in plain text.