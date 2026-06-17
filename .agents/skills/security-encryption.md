# Skill: Handling Secure Data

Stalvi is a financial app where security is paramount.

## 1. Local Authentication
- Use `local_auth` to request biometrics/PIN before allowing access to the main dashboard.
- Check `canCheckBiometrics` and `isDeviceSupported()` before enforcing biometrics.

## 2. Database Encryption
- Stalvi uses `sqlcipher_flutter_libs` alongside Drift to encrypt the SQLite database.
- **Key Generation:** Generate a strong random key upon first app launch.
- **Key Storage:** Store the generated database encryption key in `flutter_secure_storage`. NEVER store this key in plaintext or shared preferences.
- **Implementation:** Pass the encryption key to the Drift database constructor connection.

## 3. Memory & Logging
- NEVER `print()` or log passwords, database keys, or balances to the console in production mode.
- Use `kDebugMode` from `flutter/foundation.dart` if logging is absolutely necessary for debugging.