# Product Requirements Document (PRD): Stalvi

## 1. Overview
Stalvi is a local-first, highly secure financial application designed to help users track their income, expenses, budgets, and savings goals. It focuses heavily on data privacy, multi-currency support, performance, and an intuitive user experience with minimalist pastel aesthetics.

## 2. Target Audience
Individuals who want complete control over their personal finances without relying on cloud synchronization, prioritizing privacy, offline access, and detailed statistical analysis.

## 3. Core Objectives
- **Privacy First:** 100% local storage with robust encryption (SQLCipher).
- **Comprehensive Tracking:** Handle incomes, expenses, transfers, and custom categories.
- **Financial Planning:** Integrated budgeting and goal-tracking systems.
- **Data Portability:** Secure export and import functionalities (CSV, Excel, PDF, JSON).
- **Frictionless Onboarding:** Overcome "blank page syndrome" with default localized accounts (initialized with a 0.0 balance) and baseline categories. Direct navigation to the Dashboard after profile creation with post-registration biometric prompt.

## 4. Key Features
- **Movements:** Fast entry of transactions with support for recurring payments, soft deletion (30-day trash), and cascading soft-delete logic for associated entities.
- **Budgets & Goals:** Real-time visual tracking of monthly limits and savings targets, including full editing capabilities of existing budgets and savings goals directly from their detailed views.
- **Advanced Filtering:** Dynamic statistical recalculations based on custom filters.
- **Multi-Currency:** Selection of default currency during profile creation and automatic daily exchange rate updates mapping back to the user-defined base currency.
- **Security:** PIN/Biometric lock, background UI blurring, and discreet mode (hidden balances). Post-registration biometric opt-in prompt without requiring password/PIN re-entry.
- **Legal Compliance:** Separate visual access to Terms & Conditions and Privacy Policy documents, fully localized in the active language of the app, available both during registration and within settings.
- **Data Portability:** Secure export and import functionalities (CSV, Excel, PDF, JSON), with full Unicode font support in PDF exports to guarantee accurate rendering of all currency symbols without placeholder characters.

## 5. Non-Functional Requirements
- **Platforms:** iOS and Android (via Flutter).
- **Performance:** Instantaneous database queries utilizing SQLite aggregate functions. Reliable first-time account initialization and login.
- **Localization:** 100% localization in English, Spanish, and Catalan, covering all user-interface text, buttons, errors, default category names, and default account titles.