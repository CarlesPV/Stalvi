# Terms and Conditions

Welcome to Stalvi. These Terms and Conditions govern your use of the Stalvi offline mobile application. By creating a profile and using this application, you agree to these terms.

## 1. Local-First Storage
* **Local Data**: Stalvi stores all your financial data, accounts, transactions, recurrent transactions, budgets, and categories locally on your device.
* **Security & Encryption**: Your data is secured on-device using SQLCipher database encryption and Flutter Secure Storage. The database encryption key is stored in the device's OS-level secure storage (iOS Keychain / Android Keystore) and is never transmitted or accessible to Stalvi or third parties.

## 2. Biometric Authentication
* **Purpose**: Stalvi offers biometric authentication (Fingerprint, Face ID) as a convenient and secure way to access your data. Enabling this feature stores a preference flag in secure storage; actual biometric matching is performed entirely by the device OS.
* **Opt-In**: Biometric authentication is strictly opt-in. You may use your PIN as an alternative at any time.
* **Fallback**: If biometric authentication fails or is unavailable, you can always authenticate using your device PIN.

## 3. Data Export & Import
* **Export Formats**: Stalvi supports exporting your data as an encrypted backup file, a CSV spreadsheet, or a monthly PDF report.
* **Encrypted Backups**: Backup files are encrypted with AES-256 using a password you create. You are solely responsible for keeping this password safe. Lost passwords cannot be recovered and will make backups permanently inaccessible.
* **Import / Restore**: Importing a backup will permanently overwrite all existing on-device data. This action cannot be undone. Verify backups before restoring.
* **No Server Involvement**: All export and import operations happen locally. Files are never uploaded to any server by Stalvi.

## 4. User Responsibility
* **Device Backup**: Since Stalvi is a local-first application and does not upload your data to any remote server, you are solely responsible for backing up your device and database files.
* **Loss of Data**: If you lose your device or reset it without a backup, your financial records cannot be recovered.

## 5. Privacy
We do not collect, transmit, or sell your personal or financial data. Your data belongs entirely to you.

## 6. Disclaimer of Liability
All financial calculations, statistics, and exchange rate conversions provided by the application are for informational purposes only. They are approximate and may vary over time due to currency fluctuations. The developer assumes no responsibility for financial decisions made based on this data.

## 7. Updates to Terms
We reserve the right to update these terms at any time. Your continued use of the application constitutes acceptance of any updated terms.
