# Privacy Policy & Data Map - Stalvi Mobile Application

**Document Version:** 1.1.0  
**Effective Date:** September 18, 2026  
**Status:** Approved  

This document provides a comprehensive mapping of data handling, storage mechanisms, encryption, and network communication in the Stalvi mobile application. It serves as the source of truth for store compliance, privacy policy disclosures, and security audits.

---

## 1. Core Privacy Architecture

Stalvi is designed as a **local-first, zero-knowledge** application. 
- The developers of Stalvi do not maintain any central servers for user accounts or financial ledger data.
- The developers and third parties have no technical ability to access, view, or modify user financial records, account lists, budgets, or profiles.

---

## 2. Data Map & Inventory

All application state and user data are categorized below, detailing their storage location and encryption status.

| Data Category | Data Elements | Storage Location | Encryption (At Rest) |
| :--- | :--- | :--- | :--- |
| **User Profile** | Nickname, default currency preference, app theme settings | Local Device Storage | Yes (SQLCipher) |
| **Financial Accounts** | Account names, balances, account types, currencies | Local Device Storage | Yes (SQLCipher) |
| **Transactions** | Amounts, transaction dates, categories, tags, notes, payees | Local Device Storage | Yes (SQLCipher) |
| **Budgets** | Budget limits, categories linked to budgets, budget periods | Local Device Storage | Yes (SQLCipher) |
| **Recycle Bin (Trash)** | Soft-deleted accounts, categories, and transactions pending permanent purge (30-day retention) | Local Device Storage | Yes (SQLCipher) |
| **Biometric State** | App lock preferences, passcode hash | Local Device Storage | Yes (Keychain / Keystore) |
| **Home Screen Widget Cache** | Aggregated 30-day income and expense totals, localized metric labels | Local Device Storage (Android `SharedPreferences` / iOS App Group `UserDefaults`) | No (OS sandbox isolation; non-sensitive aggregated numeric totals only) |
| **Exchange Rates** | Static currency exchange rates cached for offline use | Local Device Storage | No (Non-sensitive cache) |

---

## 3. Data Storage & Encryption

### 3.1. Local Storage Engine (Drift + SQLCipher)
All core user data (including profiles, accounts, transactions, budgets, and recycle bin items) is stored on the physical device.
* **Storage Engine:** [Drift](https://drift.simonbinder.eu/) (formerly Moor), a reactive persistence library for Flutter.
* **Encryption Technology:** **SQLCipher** (AES-256-CBC) compiled into the database driver. 
* **Key Derivation:** PBKDF2 key derivation is applied to the raw key before it is used to encrypt/decrypt database pages.

### 3.2. Secure Key Management
The encryption key for the local Drift database is generated randomly upon the first launch of the application. It is never exposed to the user or stored in plain text.
* **iOS Integration:** The encryption key is saved in and retrieved from the **iOS Keychain**. This is backed by the Apple Secure Enclave and is not included in standard unencrypted backups.
* **Android Integration:** The encryption key is stored using the **Android Keystore system**. Keys are stored in hardware-backed cryptographic providers when available, preventing extraction from the device.

### 3.3. Native Widget Storage
When the user adds a Stalvi widget to their home screen:
* **Android:** Aggregated 30-day income and expense figures are saved into application-private `SharedPreferences`.
* **iOS:** Figures are saved into the app group suite `group.com.peirov.stalvi` via `UserDefaults`.
* **Data Minimization:** No personal identifiers, transaction payees, category notes, or account specifics are stored in widget storage.

---

## 4. Network Data Flow

### 4.1. Financial Data Transmission
* **Absolute Zero Transmission:** **NO financial data is transmitted to external servers**. There is no cloud synchronization, backend database integration, or telemetry collection of financial entries.

### 4.2. Exchange Rate API Queries
The only network activity initiated by the app is query traffic to fetch live or historical currency exchange rates.
* **Endpoint:** Public Exchange Rate API (**Frankfurter API** - `https://api.frankfurter.app/`).
* **Request Protocol:** HTTPS GET.
* **Data Transmitted:** No identifiable user data, account details, or transactional information is sent in these requests. The payload is strictly limited to query parameters specifying the base currency and desired conversion target currency.
  * *Example request:* `GET https://api.frankfurter.app/latest?from=USD&to=EUR`
* **PII Protection:** Because no authentication token, email, name, IP-tracking header, or device ID is attached to the request, the query is entirely anonymous.

---

## 5. Data Deletion and Portability

* **Application Uninstallation:** Uninstalling the Stalvi application from the device deletes the local database file as well as the database key stored in the iOS Keychain or Android Keystore, plus all widget shared preferences. This permanently renders all data unrecoverable.
* **Recycle Bin & Automatic Purge:** Deleted transactions, categories, and accounts are placed in an encrypted local recycle bin for 30 days before irreversible automated purge, allowing manual restoration or immediate permanent deletion by the user.
* **Data Portability:** Users can trigger a manual export of their financial records (encrypted database backup, structured PDF reports, or CSV spreadsheets). This export is processed entirely locally on the device.

---

## 6. Compliance Certification

We certify that:
1. Financial entries are never processed, cached, or transferred through any server owned or controlled by Stalvi or its third-party processors.
2. The user holds sole ownership and custody of their financial logs.