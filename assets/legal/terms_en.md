# Terms and Conditions of Use

**Effective Date:** August 17, 2026

Please read these Terms and Conditions ("Terms", "Agreement") carefully before downloading, installing, accessing, or using the Stalvi mobile application (the "Application" or "App").

This Agreement constitutes a legally binding contract between you (the "User", "you", or "your") and the developers and operators of Stalvi ("Stalvi", "we", "us", or "our").

By downloading, installing, opening, accessing, or using the Application, you explicitly acknowledge, represent, and warrant that you have read, understood, and agree to be bound by all terms, conditions, disclaimers, and obligations set forth herein. If you do not agree to all of these Terms, you are not authorized to access or use the Application, and you must immediately uninstall and permanently remove the Application from your device.

---

## 1. Description of Service & Core Functionality
Stalvi is a privacy-focused, local-first personal financial management tool designed to enable users to record, categorize, monitor, and analyze their personal income, expenses, budgets, savings targets, and recurring transactions strictly on their personal mobile devices.

---

## 2. Local-First Architecture & SQLCipher Encryption
- **Local-Only Storage:** Stalvi operates on a strict **local-first architecture**. All transaction logs, account balances, budgets, categories, PIN hashes, and custom preferences are stored exclusively on your device. Stalvi does not transmit, back up, sync, store, or process your financial data on external servers or cloud services.
- **SQLCipher AES-256 Encryption:** The underlying SQLite database is encrypted at rest using **SQLCipher with AES-256 bit encryption**. Cryptographic keys are protected using native hardware-backed secure storage interfaces (Android KeyStore / iOS Keychain via `flutter_secure_storage`).
- **No Remote Access or Backdoors:** The developers have zero access to your device, your PIN, your encryption keys, or your database.

---

## 3. Background Processing & Automated WorkManager Tasks
- **On-Device Background Execution:** Stalvi relies on system background execution mechanisms (**WorkManager** on Android, **BGTaskScheduler** on iOS) to execute automated tasks locally without requiring the user to open the app.
- **Scope of Background Work:** Background execution is limited to:
  1. Idempotently processing scheduled recurring transactions to update ledger records without duplicate creation.
  2. Refreshing offline currency conversion fallbacks when an active Internet connection is detected.
  3. Scheduling local push notifications for due payments or bill reminders.
- **OS Scheduling Disclaimers:** Background task timing is governed by the operating system's battery optimization and job scheduling policies. Stalvi makes no warranty regarding the exact minute-level execution of background tasks.

---

## 4. Financial, Tax, and Currency Disclaimer (Zero Liability)

### 4.1. Informational & Personal Tracking Tool Only
STALVI IS PURELY AN INFORMATIONAL, PERSONAL DATA RECORDING AND STATISTICAL TRACKING APPLICATION. STALVI IS NOT A BANK, FINANCIAL INSTITUTION, INVESTMENT ADVISOR, CERTIFIED PUBLIC ACCOUNTANT, OR TAX ADVISORY SERVICE.

NEITHER THE APPLICATION NOR ITS DEVELOPERS PROVIDE LEGAL, TAX, ACCOUNTING, INVESTMENT, MORTGAGE, LOAN, OR FINANCIAL ADVICE OF ANY KIND. NO CONTENT, COMPUTATION, SUMMARY, CHART, REPORT, OR STATISTIC PRODUCED BY THE APPLICATION SHOULD BE CONSTRUED AS FINANCIAL PLANNING OR PROFESSIONAL ADVICE.

### 4.2. Zero Liability for Financial Losses, Data Loss & Miscalculations
YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT THE DEVELOPERS, MAINTAINERS, AND OWNERS OF STALVI ASSUME **ZERO LIABILITY AND ZERO RESPONSIBILITY** UNDER ANY CIRCUMSTANCE FOR ANY:
- FINANCIAL LOSSES, UNEXPECTED EXPENSES, OVERDRAFTS, BANK FEES, DEBTS, INACCURATE BUDGET ESTIMATES, OR POOR INVESTMENT DECISIONS RESULTING DIRECTLY OR INDIRECTLY FROM YOUR USE OF OR RELIANCE UPON THE APPLICATION;
- DATA LOSS, CORRUPTION, OR INACCESSIBILITY OF YOUR DATABASE DUE TO DEVICE FAILURE, FORGOTTEN PIN, SOFTWARE BUGS, OR FAILURE TO MAINTAIN BACKUPS;
- CALCULATION DISCREPANCIES, ROUNDING ERRORS, ALGORITHMIC MISCALCULATIONS, OR COMPUTATIONAL ERRORS IN TRANSACTION TOTALS, BALANCES, RECURRING EXPENSES, OR STATISTICAL PROJECTIONS;
- TAX ISSUES, INCORRECT TAX DEDUCTION ESTIMATES, OMISSIONS, OR MISREPORTING TO ANY TAX AUTHORITY;
- INACCURACIES, LAGS, OR DISCREPANCIES IN CURRENCY CONVERSIONS, EXCHANGE RATES, DUAL-CURRENCY COMPUTATIONS, OR HISTORICAL RATE CALCULATIONS.

YOU ARE SOLELY RESPONSIBLE FOR VERIFYING THE ACCURACY OF ALL TRANSACTIONS, CALCULATIONS, AND FINANCIAL DATA AGAINST OFFICIAL STATEMENTS ISSUED BY YOUR BANK OR FINANCIAL INSTITUTION.

---

## 5. User Responsibility & Data Backup
- **Forgotten PIN / Biometrics:** Because all data is encrypted on-device with keys managed by your device credentials, forgetting your PIN or losing biometric access will render your database unreadable. **The developers cannot reset your PIN or recover your encrypted data.**
- **Device Loss or Corruption:** If your device is lost, damaged, stolen, factory reset, or if the App is uninstalled without exporting an encrypted backup file, your financial data is permanently lost.
- **Backup Responsibility:** You are solely responsible for creating regular encrypted database backups or CSV exports and transferring them to secure off-device storage.

---

## 6. Acceptable Use Policy & Prohibited Conduct
You agree to use the Application only for lawful, personal purposes and in compliance with all applicable local, national, and international laws.

You explicitly agree **NOT** to:
1. Use the Application for unlawful, fraudulent, or unauthorized financial activities, including money laundering, sanctions evasion, or tax fraud;
2. Decompile, reverse engineer, disassemble, decrypt, attempt to derive source code, or modify the Application, except as allowed by applicable open-source licenses;
3. Circumvent, disable, or tamper with security features of the Application, including PIN verification, biometric protection, database encryption, or export mechanisms;
4. Introduce viruses, Trojan horses, malware, or malicious code that compromises device or database integrity;
5. Rent, lease, lend, sell, sublicense, distribute, or commercially exploit the Application or any portion thereof.

---

## 7. License Grant and Intellectual Property
Stalvi grants you a revocable, non-exclusive, non-transferable, limited, personal license to install and use the Application on compatible devices owned or controlled by you.

All intellectual property rights, titles, and interests in the Application—including code, software architecture, UI/UX design, visual themes, graphics, icons, logos, and documentation—remain the exclusive property of Stalvi and its licensors. All rights not expressly granted are reserved.

---

## 8. Disclaimer of Warranties ("AS-IS" and "AS-AVAILABLE")
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE APPLICATION IS PROVIDED STRICTLY ON AN **"AS-IS"** AND **"AS-AVAILABLE"** BASIS, WITH ALL FAULTS AND DEFECTS, AND WITHOUT WARRANTY OF ANY KIND.

STALVI DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. STALVI DOES NOT WARRANT THAT THE APPLICATION WILL OPERATE UNINTERRUPTED, SECURELY, OR ERROR-FREE.

---

## 9. Limitation of Liability
TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL STALVI, ITS DEVELOPERS, AFFILIATES, OFFICERS, AGENTS, OR SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, EXEMPLARY, OR CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING LOSS OF PROFITS, DATA, REVENUE, SAVINGS, BUSINESS INTERRUPTION, OR FINANCIAL MISCALCULATIONS) ARISING OUT OF OR IN CONNECTION WITH YOUR USE OR INABILITY TO USE THE APPLICATION.

---

## 10. App Store & Google Play Store Platform Terms
- **Apple App Store Terms:** You acknowledge that this Agreement is concluded between you and Stalvi only, and not with Apple Inc. Apple is not responsible for the Application or its content, maintenance, or support services. Apple has no obligation whatsoever to furnish any maintenance or support services with respect to the Application. To the maximum extent permitted by applicable law, Apple will have no warranty obligation whatsoever with respect to the Application. Apple and Apple's subsidiaries are third-party beneficiaries of this Agreement and will have the right to enforce this Agreement against you.
- **Google Play Store Terms:** You acknowledge that Google LLC is not responsible for providing maintenance, support, or resolving claims regarding the Application.

---

## 11. Governing Law and Dispute Resolution
These Terms and your use of the Application shall be governed by and construed in accordance with the laws of Spain and the regulations of the European Union. Any dispute or claim arising out of or in connection with this Agreement shall be submitted to the exclusive jurisdiction of the competent courts of Spain.

---

## 12. Severability, Modifications & Contact
- **Severability:** If any provision of these Terms is held invalid or unenforceable, that provision will be modified to the minimum extent necessary, and the remaining provisions will remain in full force.
- **Modifications:** We reserve the right to update these Terms at any time. Continued use of the App following changes constitutes acceptance of modified Terms.
- **Contact:** For legal inquiries, contact the developer via GitHub at:  
  [https://github.com/CarlesPV](https://github.com/CarlesPV)
