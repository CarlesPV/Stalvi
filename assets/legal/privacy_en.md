# Privacy Policy

**Effective Date:** July 22, 2026

## 1. Introduction
Welcome to **Stalvi** ("we", "our", or "the Application"). Stalvi is an offline-first personal finance management application designed with a privacy-by-design philosophy. We are strongly committed to protecting your privacy and ensuring that your financial data remains confidential, secure, and under your exclusive control.

This Privacy Policy explains our practices regarding data privacy, security, and compliance with global privacy regulation standards, including:
- The **General Data Protection Regulation (GDPR)** of the European Union (Regulation (EU) 2016/679).
- The Spanish **Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD 3/2018)**.
- The **California Consumer Privacy Act (CCPA)**, as amended by the **California Privacy Rights Act (CPRA)**.

By using Stalvi, you acknowledge the privacy practices described in this document.

---

## 2. Zero Telemetry & Zero Personal Data Collection
Stalvi operates on a strict **Zero Telemetry** model. 
- **No Developer Collection:** We, as the application developers, do **not** collect, store, transmit, process, or sell any of your personal or financial data.
- **No User Registration:** Stalvi does not require user accounts, email registration, phone numbers, or cloud logins.
- **No Analytics or Tracking:** The Application contains **zero** third-party tracking SDKs, telemetry, crash report aggregators (e.g., Firebase Analytics, Google Analytics, Sentry), advertising software, or behavioral profiling tools.

---

## 3. Local Data Storage & Advanced Encryption (AES-256)
All data created or managed within Stalvi—including financial transactions, account balances, budgets, custom categories, tags, and user preferences—is stored exclusively on your physical device.

- **SQLCipher AES-256 Encryption:** The underlying SQLite database is encrypted at rest using **SQLCipher with AES-256 bit encryption**. This ensures that even if physical access to your device's filesystem is obtained, your financial data remains unreadable without your encryption key.
- **Biometric & PIN Protection:** Access to the Application is safeguarded by your device's native biometric authentication mechanisms (Fingerprint, Touch ID, or Face ID) and a custom Personal Identification Number (PIN).
- **Data Isolation:** Because data never leaves your device to be hosted on our servers, your information is protected against remote server breaches, data leaks, network sniffing, and corporate data mining.

---

## 4. Internet Connectivity & Third-Party Open APIs
Stalvi is designed to work fully offline. The **only** instance where the Application initiates an internet connection is to fetch current currency exchange rates.

- **Anonymous Exchange Rate Requests:** When you update currency conversion rates, Stalvi queries a public third-party open exchange rate API via secure HTTPS.
- **Privacy Guarantees:** These API requests are strictly anonymous. The request contains **only** standard HTTP request parameters required to retrieve public rate tables (e.g., base and target currency symbols). **No** user identifiers, IP-linked personal tokens, device identifiers, account details, or transaction amounts are ever transmitted.
- **No Advertising or Data Brokers:** We do not partner with advertisers, affiliate networks, or data brokers.

---

## 5. Absolute User Data Control & Data Portability
You maintain 100% ownership and control over your financial records and data backups.

- **Data Export & Portability:** You can export your financial records at any time into standard format files (such as encrypted backup archives or unencrypted CSV spreadsheets) to transfer your data or perform manual backups.
- **Data Import & Restoration:** You decide when and where to restore your encrypted database backups.
- **Data Erasure:** You can permanently delete individual transactions, reset categories, or trigger a full **"Delete All Data"** operation from the Application settings. Performing this action permanently purges all encrypted local databases and cached application settings from your device.

---

## 6. Regulatory Rights (GDPR, LOPDGDD & CCPA/CPRA)

### 6.1. EU / UK & Spanish Rights (GDPR / LOPDGDD)
Under the GDPR and LOPDGDD, data subjects have rights regarding access, rectification, erasure, restriction, object, and data portability:
- Because all processing occurs locally on your device under your direct physical control, you exercise all data subject rights directly within the Application's UI (e.g., editing records, exporting data, or purging local databases).
- Since we do not possess or host your data, we cannot access, produce, modify, or delete your personal data on your behalf.

### 6.2. California Residents (CCPA / CPRA)
- **Do Not Sell or Share Personal Information:** Stalvi does **not** sell, rent, release, disclose, disseminate, make available, transfer, or otherwise communicate your personal information to third parties for monetary or other valuable consideration.
- **Right to Know and Delete:** California users can exercise their right to know what data exists and delete all stored personal financial data directly through the local application interface.

---

## 7. Children's Privacy
Stalvi is not directed to children under the age of 14 (or 13 in jurisdictions governed by COPPA). We do not knowingly collect personal data from children. Because all data is created locally by the device operator, parents and guardians maintain full physical oversight of device usage.

---

## 8. Changes to this Privacy Policy
We may update this Privacy Policy periodically to reflect app updates or legal compliance standards. Updated versions will be included in Application releases and published in our source code repository. Your continued use of Stalvi after an update constitutes acceptance of the updated terms.

---

## 9. Contact Information
If you have questions, feedback, or legal inquiries regarding this Privacy Policy, you can reach out to the project maintainer via GitHub:
- **Repository / Support:** [https://github.com/CarlesPV](https://github.com/CarlesPV)
