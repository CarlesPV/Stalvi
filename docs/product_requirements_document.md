# Product Requirements Document (PRD): Konta

## 1. Overview
Konta is a local-first, highly secure financial application designed to help users track their income, expenses, budgets, and savings goals. It focuses heavily on data privacy, multi-currency support, performance, and an intuitive user experience with minimalist pastel aesthetics.

## 2. Target Audience
Individuals who want complete control over their personal finances without relying on cloud synchronization, prioritizing privacy, offline access, and detailed statistical analysis.

## 3. Core Objectives
- **Privacy First:** 100% local storage with robust encryption (SQLCipher).
- **Comprehensive Tracking:** Handle incomes, expenses, transfers, and custom categories.
- **Financial Planning:** Integrated budgeting and goal-tracking systems.
- **Data Portability:** Secure export and import functionalities (CSV, Excel, PDF, JSON).
- **Frictionless Onboarding:** Overcome "blank page syndrome" with default accounts and categories.

## 4. Key Features
- **Movements:** Fast entry of transactions with support for recurring payments and soft deletion (30-day trash).
- **Budgets & Goals:** Real-time visual tracking of monthly limits and savings targets.
- **Advanced Filtering:** Dynamic statistical recalculations based on custom filters.
- **Multi-Currency:** Automatic daily exchange rate updates mapping back to a user-defined default currency.
- **Security:** PIN/Biometric lock, background UI blurring, and discreet mode (hidden balances).

## 5. Non-Functional Requirements
- **Platforms:** iOS and Android (via Flutter).
- **Performance:** Instantaneous database queries utilizing SQLite aggregate functions.
- **Localization:** Support for English, Spanish, and Catalan.