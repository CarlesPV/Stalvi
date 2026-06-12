# Privacy Policy & Data Map

## 1. Core Privacy Principle
Konta is built on a **Zero-Knowledge, Local-First** architecture. We do not have servers, we do not collect personal data, and we do not have access to your financial information.

## 2. Data Map & Flow
Because data does not leave the device, the data map is strictly internal:

* **User Input (UI) -> Domain Layer -> Encrypted Repository (Drift + SQLCipher)**
* **Database Key -> OS Secure Enclave (Keychain/Keystore)**
* **External API (Exchange Rates) -> HTTPS GET -> Local Database** *(No user PII is sent to this API).*

### 2.1. Data Stored Locally
* Profile Name / Username.
* Financial transactions (amounts, descriptions, dates).
* Custom categories and tags.
* App preferences (Theme, default currency).

### 2.2. Data Shared with Third Parties
* **None.** Absolutely no financial data is transmitted to analytics providers, advertisers, or developers.
* *Note on Crashlytics (If implemented later):* Must be strictly opt-in and only collect stack traces, scrubbing any user input or database variables.

## 3. Data Retention & Deletion
* Data remains on the device indefinitely until the user deletes the app or manually clears the data.
* "Deleted" transactions remain in a local Trash bin for 30 days before permanent erasure from the device storage.

## 4. Exported Data Security
When a user explicitly exports data (PDF, JSON Backup), it is protected via a user-defined password. The security of this exported file outside the app environment becomes the responsibility of the user.