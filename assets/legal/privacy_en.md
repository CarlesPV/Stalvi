# Privacy Policy

**Effective Date:** August 17, 2026

## 1. Introduction
Welcome to **Stalvi** ("we", "our", or "the Application"). Stalvi is a local-first, privacy-by-design personal financial management application. We are committed to protecting your privacy and ensuring your financial data remains confidential, secure, and under your exclusive control.

This Privacy Policy details our data handling practices, security architecture, and regulatory compliance standards, including:
- **General Data Protection Regulation (GDPR)** of the European Union (Regulation (EU) 2016/679).
- Spanish **Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD 3/2018)**.
- **California Consumer Privacy Act (CCPA)**, as amended by the **California Privacy Rights Act (CPRA)**.
- **Apple App Store Review Guidelines** (Section 5.1 - Privacy, Data Collection & Storage).
- **Google Play Developer Policies** (User Data, Financial Services, and Prominent Disclosure requirements).

By using Stalvi, you acknowledge and accept the privacy practices described herein.

---

## 2. Zero Telemetry & Zero Data Harvesting
Stalvi operates on a strict **Zero Telemetry** model:
- **No Developer Data Harvesting:** We do not collect, store, track, harvest, process, or sell any of your personal, financial, or behavioral data.
- **No User Registration:** Stalvi requires no account creation, email registration, phone number verification, or cloud service sign-in.
- **No Third-Party Analytics or Tracking SDKs:** The Application contains zero third-party telemetry, crash reporting aggregators (e.g., Firebase Analytics, Sentry, Mixpanel), advertising frameworks, or behavioral profiling tools.

---

## 3. Local-First Architecture & SQLCipher Encryption (AES-256)
All data entered or generated within Stalvi—including financial transactions, account balances, budgets, recurring rules, categories, tags, and preferences—is stored exclusively on your physical device.

- **SQLCipher AES-256 Database Encryption:** The underlying SQLite database is encrypted at rest using **SQLCipher with AES-256 bit encryption**. Your financial data is unreadable without the cryptographic key.
- **Hardware Security Key Management:** Cryptographic keys and access credentials are isolated and managed securely using the device's native KeyStore (Android) or Keychain (iOS) via secure system storage interfaces (`flutter_secure_storage`).
- **Biometric & PIN Authentication:** Access to the Application is protected on-device by biometric mechanisms (Face ID, Touch ID, Fingerprint) or a user-defined Personal Identification Number (PIN).
- **Absolute Data Isolation:** Because no data is transmitted to external servers, your information is protected against remote data breaches, server hacks, network sniffing, and corporate data mining.

---

## 4. On-Device Background Task Execution
Stalvi utilizes native system background schedulers (**WorkManager** on Android, **BGTaskScheduler** on iOS) to maintain financial records without user intervention.

- **Purpose of Background Tasks:** Background execution is limited strictly to:
  1. Evaluating scheduled recurring transactions idempotently to prevent duplicate entries.
  2. Refreshing offline currency exchange rate fallbacks when network connectivity is available.
  3. Firing local push notifications for upcoming bill reminders or scheduled payments.
- **Local-Only Operation:** All background operations execute **100% locally on your device**. Background tasks do not collect, log, or exfiltrate any telemetry, device identifiers, or financial data to remote servers.

---

## 5. Internet Connectivity & Anonymous Open APIs
Stalvi is engineered to function entirely offline. The **only** scenario where the Application initiates an outbound network request is to retrieve public currency exchange rates.

- **Anonymous Exchange Rate Requests:** When currency rates are updated, Stalvi queries a public third-party exchange rate API over encrypted HTTPS.
- **No Identifiers Transmitted:** These requests contain strictly standard HTTP parameters required to retrieve public rate tables (e.g., base and target currency codes). **No** user credentials, device IDs, IP-linked tokens, transaction amounts, or account balances are ever sent.
- **No Advertising or Data Brokers:** We do not partner with advertisers, affiliate networks, tracking providers, or data brokers.

---

## 6. Data Ownership, Control & Rights Compliance

### 6.1. EU / UK & Spanish Rights (GDPR & LOPDGDD 3/2018)
Under GDPR and LOPDGDD, data subjects have rights regarding access, rectification, erasure, restriction, objection, and data portability:
- **Direct Rights Execution:** Because all processing occurs locally under your physical control, you exercise all data subject rights directly within the Application UI (e.g., modifying transactions, exporting files, or purging databases).
- **No Developer Data Access:** Because we do not hold, transmit, or store your data on any server, we cannot access, produce, alter, or delete your personal data on your behalf.

### 6.2. California Residents (CCPA / CPRA)
- **Do Not Sell or Share:** Stalvi **does not sell, rent, or share** your personal information with any third party for monetary or other valuable consideration.
- **Right to Know and Delete:** You exercise your right to know and delete all stored personal financial data directly through the local Application interface.

---

## 7. Data Retention & Permanent Deletion
- **Data Export:** You can export your data at any time into standard formats (encrypted backup files or CSV spreadsheets) for personal backup or migration.
- **Permanent Purge:** You can trigger a **"Delete All Data"** action in the Application settings. This permanently wipes all encrypted local database files and cached preferences from your device. Uninstallation of the Application also removes all local database files.

---

## 8. Children's Privacy
Stalvi is not directed to children under 16 (or 13 under COPPA). We do not knowingly collect personal data from minors. Since all data resides locally on the device, parents and guardians maintain full oversight of device usage.

---

## 9. App Store & Google Play Developer Policy Compliance
- **Apple App Store Review Guidelines (5.1.1 & 5.1.2):** Stalvi discloses all data usage, limits collection to zero, and provides full data control to the user.
- **Google Play Developer Policies:** Stalvi complies with Google Play User Data policies, Financial Services policies, and background WorkManager disclosures by maintaining strict local processing and zero data sharing.

---

## 10. Policy Updates & Contact Information
We may update this Privacy Policy to reflect software updates or regulatory changes. Updates will be incorporated in app releases and published in the repository.

For privacy inquiries, contact the developer:
- **GitHub Repository & Support:** [https://github.com/CarlesPV](https://github.com/CarlesPV)
