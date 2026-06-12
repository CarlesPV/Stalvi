# App Store & Google Play Compliance Guide

This document tracks the requirements for publishing Konta while adhering to our strict privacy model.

## 1. Apple App Store Compliance

### 1.1. Export Compliance (Cryptography)
Because Konta uses SQLCipher (which utilizes AES-256 encryption), we are subject to U.S. Export Administration Regulations (EAR).
* **Action Required:** In `Info.plist`, set `ITSAppUsesNonExemptEncryption` to `NO` if we qualify for an exemption, OR set it to `YES` and submit a Self-Classification Report to the US Government (BIS) annually.
* *Justification for Exemption:* Often, apps using encryption strictly for local data storage and authentication can claim exemption, but this must be verified by the Release Agent before deployment.

### 1.2. Privacy Nutrition Labels
* **Data Collection:** Select "No data collected from this app". (Since we do not transmit data off-device).

### 1.3. Permissions Justification
* `NSFaceIDUsageDescription`: Required for the biometric app lock. Must explain clearly: "Konta uses Face ID to securely unlock your financial data."

## 2. Google Play Store Compliance

### 2.1. Data Safety Form
* **Does your app collect or share any of the required user data types?** No.
* **Is all user data encrypted in transit?** N/A (Data doesn't travel, except API calls which are HTTPS).
* **Do you provide a way for users to request data deletion?** Yes (Users can delete app/clear storage).

### 2.2. Permissions Justification
* `USE_BIOMETRIC`: Required for app lock.
* No storage permissions are needed for standard SQLite. For exporting files (PDF/CSV) to the Downloads folder, use `MediaStore` API or Storage Access Framework to avoid requesting broad `READ_EXTERNAL_STORAGE` permissions.