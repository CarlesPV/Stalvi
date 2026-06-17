# App Store & Google Play Compliance - Stalvi Mobile Application

**Document Version:** 1.0.0  
**Effective Date:** June 14, 2026  
**Status:** Approved  

This document serves as the guide for answering the App Store Connect App Privacy Questionnaire and the Google Play Console Data Safety Form for the Stalvi mobile application.

---

## 1. Apple App Store Compliance

### 1.1. App Privacy Questionnaire (Nutrition Labels)

When submitting or updating Stalvi on App Store Connect, complete the **App Privacy** section as follows:

| Questionnaire Section | Required Selection / Answer | Compliance Justification |
| :--- | :--- | :--- |
| **Data Collection** | **No, we do not collect data from this app** | All financial transactions, account data, budgets, and user profiles are stored locally on the user's device. No data is sent to external servers or developers. |
| **Third-Party Partners** | **No** | The application does not integrate third-party software development kits (SDKs) that track users or collect data (such as advertising networks or analytics trackers). |

> [!NOTE]
> Since we answer "No" to data collection, a simplified Privacy Nutrition Label will show that "No Data is Collected" when users view Stalvi on the App Store.

### 1.2. Device Permissions Justification

| Permission | Usage Purpose | App Store Description String (`Info.plist`) |
| :--- | :--- | :--- |
| `NSFaceIDUsageDescription` | Required to securely unlock the app when Biometric Lock is enabled. | "Stalvi uses Face ID to securely unlock your financial data and protect your privacy." |

### 1.3. Export Compliance (ITSAppUsesNonExemptEncryption)

Stalvi uses SQLCipher, which implements AES-256 encryption for protecting the database at rest.
* **Recommendation:** Set `ITSAppUsesNonExemptEncryption` to `NO` in `ios/Runner/Info.plist`.
* **Justification:** Under US Export Administration Regulations (EAR), apps that use encryption limited to intellectual property protection, user authentication, or security of personal/financial data stored locally on the device (and not exported/transmitted to servers) are exempt from export registration.

---

## 2. Google Play Store Compliance

### 2.1. Data Safety Questionnaire

When submitting or updating Stalvi in the Google Play Console, answer the **Data Safety** form with the following selections:

#### Section 1: Data Collection and Sharing
* **Does your app collect or share any of the required user data types?**  
  * **Answer:** **No**
  * *Reasoning:* The app does not transmit user data to external servers. The local database is contained entirely within the app's sandboxed storage.

#### Section 2: Security Practices
* **Is all user data encrypted in transit?**  
  * **Answer:** **N/A** (No user data is collected or shared; therefore, data is not transmitted).
  * *Note:* The only network requests made are HTTPS queries to the Frankfurter API for exchange rate data. These queries do not contain user-specific or financial data.
* **Do you provide a way for users to request that their data be deleted?**  
  * **Answer:** **Yes**
  * *Instruction:* Since all data is stored locally, users can delete all of their data immediately by deleting the application or clearing the application's data under device settings.

#### Section 3: Data Types Collected/Shared
* Check **None** for all categories (e.g., Personal Info, Financial Info, Health and Fitness, Photos and Videos, Contacts, Device IDs).

### 2.2. Device Permissions Justification

| Permission | Usage Purpose | Android Manifest Declaration |
| :--- | :--- | :--- |
| `android.permission.USE_BIOMETRIC` | Enables biometric authentication (fingerprint/face unlock) on compatible Android devices. | `<uses-permission android:name="android.permission.USE_BIOMETRIC" />` |

---

## 3. Compliance Summary Table

The following table summarizes the privacy posture of the Stalvi app across both platforms:

| Privacy / Security Check | App Store Status | Google Play Status | Technical Implementation Details |
| :--- | :--- | :--- | :--- |
| **Data Collection** | No | No | None. No cloud database, no crash/analytics reporting. |
| **Data Sharing** | No | No | None. No third-party data tracking. |
| **Encryption in Transit** | N/A | N/A | No user data is transmitted over the network. Exchange rate queries are HTTPS. |
| **Encryption at Rest** | Yes | Yes | Drift Database encrypted using SQLCipher (AES-256-CBC). |
| **Key Management** | Yes | Yes | Apple Keychain (iOS) / Android Keystore (Android). |
| **User Data Deletion** | Yes | Yes | Instantly deleted via App Uninstall or Clear Storage. |