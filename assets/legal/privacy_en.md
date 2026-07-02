# Privacy Policy

Your privacy is extremely important to us. This Privacy Policy explains how Stalvi handles your information.

## 1. Zero Data Collection
* **Personal Data**: We do not collect any personal data such as name, username, or contact information.
* **Financial Data**: All transaction logs, recurrent transactions, account balances, and budgets are kept strictly on your device. We have no backend server and no access to your financial data.

## 2. Security
* **Biometric Authentication**: Stalvi uses device biometric authentication (Fingerprint or Face ID) as a primary login method, in conjunction with a secure PIN. Biometric credentials are managed exclusively by the device's operating system (Android Keystore / iOS Secure Enclave) and are never read or transmitted by the app.
* **Encrypted Local Storage**: The local database is encrypted using SQLCipher. The cryptographic key is generated on first launch and stored securely in the device's keychain (iOS) or Keystore (Android). No data leaves the device in an unencrypted form.
* **Device PIN**: A user-defined PIN (4–8 digits) serves as a fallback and additional security layer, stored using Flutter Secure Storage backed by platform-level encryption.

## 3. Data Export & Import
* **Export**: Stalvi allows you to export your financial data in several formats (encrypted backup, CSV, PDF). Encrypted backups are protected with an AES-256 password you choose. You are solely responsible for the security and confidentiality of exported files and passwords.
* **Import / Restore**: You may import a previously exported encrypted backup to restore your data. Importing will overwrite all current on-device data. Stalvi never uploads, syncs, or shares exported files with any server.
* **Your Ownership**: All exported data belongs entirely to you. Stalvi does not retain any copy.

## 4. Third-Party Services
We do not use any tracking tools, analytics, or third-party advertising SDKs that collect or share your data.

## 5. Disclaimer of Liability
All financial calculations, statistics, and exchange rate conversions provided by the application are for informational purposes only. They are approximate and may vary over time due to currency fluctuations. The developer assumes no responsibility for financial decisions made based on this data.

## 6. Contact Us
If you have any questions or feedback regarding our privacy practices, you can contact us at privacy@stalvi.app.
