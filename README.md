# Stalvi - Financial Management App

Stalvi is a premium, local-first personal finance application built with Flutter. It is designed to empower users with full control over their financial data through comprehensive tracking, advanced statistics, and zero-telemetry local-first storage. It features state-of-the-art security, multi-currency support with dynamic conversion, and full localization in three languages.

---

## Architecture Design

Stalvi is designed and developed following strict **Clean Architecture** principles and a modular directory structure to ensure isolation of concerns, high testability, and robust scalability.

```
lib/
├── core/               # App-wide configurations, constants, theme, utilities
│   ├── errors/         # Centralized error hierarchy and custom exceptions
│   ├── l10n/           # Localization arb configuration and lookup tools
│   ├── security/       # Hardware keystore integration and encryption keys
│   └── theme/          # Premium custom pastel design tokens
├── data/               # Concrete data sources, SQLite database, mappers, repositories
│   ├── database/       # Drift ORM definition, tables, DAOs, migration scripts
│   ├── mappers/        # Translators between DB entities and domain models
│   ├── network/        # Exchange rate Frankfurter API interface (HTTPS only)
│   └── repositories/   # Implementations of domain repository interfaces
├── domain/             # Business logic layer (independent of frameworks/DBs)
│   ├── entities/       # Pure data structures (Transaction, Budget, Account)
│   ├── repositories/   # Interfaces defining contract requirements
│   └── usecases/       # Atomic business logic modules (AddTransaction, AutoPurge)
└── presentation/       # UI layer (screens, components, and controllers)
    ├── features/       # Screen views organized by functional area (Dashboard, Settings)
    ├── providers/      # Riverpod state management and dependency injection
    └── widgets/        # Reusable custom UI components (ObfuscatedText, EmptyStateWidget)
```

- **Presentation Layer:** Built with **Riverpod** for reactive state management, asynchronous data loading, and real-time dependency injection.
- **Domain Layer:** Contains the core business rules, entities, and use cases, remaining fully independent of external frameworks, libraries, and databases.
- **Data Layer:** Handles all database transactions, networking, data caching, serialization, and encrypted storage.

---

## Core Features

### 💰 Movement & Transaction Engine
- **Income, Expense, & Transfers:** Record and categorize financial movements.
- **Atomic Transfers:** Double-entry transfers link origin and destination accounts securely. Deleting or restoring one leg of a transfer automatically mirrors the action on the other leg.
- **30-Day Recycle Bin (Trash):** Soft-deleted transactions, budgets, and savings goals are moved to a temporary trash. Balances are recalculated in real time. Items older than 30 days are automatically purged on startup.
- **Immutability:** Saves currency exchange rate snapshots within each transaction at creation time to preserve historical balance integrity.
- **Safe Category Deletion:** Prompts users to reassign transactions to a new target category when attempting to delete a category that is in active use. Reassignment targets are strictly filtered based on the category type (Expense to Expense/Custom, Income to Income/Custom, Custom to all).

### 📊 Advanced Budgets & Savings Goals
- **Budgets:** Set category-specific monthly spending limits mapped to specific accounts, with automatic locks on currency and target amounts post-creation.
- **Savings Goals:** Track financial progress with dedicated targets. Savings goals can be selected directly as destinations in transfers.
- **Dynamic Recalculation:** Progress bars and spent percentages dynamically recalculate in real-time when transactions are added, edited, or deleted.

### 🔍 Concurrent Filters & Analytical Charts
- **Multi-Dimensional Search:** Filter transactions simultaneously by transaction type, category, date range, amount range, tag, and currency using reactive Drift query builders.
- **Eager Statistics Pre-Warming:** Analytics future providers pre-warm on screen initialization, eliminating loading latency when navigating to the Statistics screen.
- **Visual Analytics:** Premium interactive charts (pie/donut and bar charts) with legends, category percentages, color swatches, and tap-interaction tooltips.

### 📥 Compliant Exports & JSON Backups
- **Enhanced CSV/Excel:** Export detailed spreadsheets containing all movement details and historical snapshots.
- **Premium PDF Reports:** Generates clean tabular monthly statements, summary boxes, and category distribution pie charts.
- **Encrypted JSON Backups:** Export full database backups encrypted with AES-256-CBC using PBKDF2-HMAC-SHA256 key derivation from a user-specified password.

---

## Trilingual Support & Localization

Stalvi is fully localized in three languages, ensuring that all user-facing strings, error states, and dynamically generated system entities adapt to the active language:
- 🇬🇧 **English**
- 🇪🇸 **Spanish**
- 🏴 **Catalan**

### Dynamic Database Translation
- On application launch or language switch, default database entities (such as "My Wallet" / "Mi cartera" / "La meva cartera" and default categories/tags) are dynamically updated in the SQLite tables using stable UUID mapping. This prevents duplicate entries and ensures a consistent native language experience.

---

## Robust Security Measures

Stalvi places user privacy and data security above all else. Because the app is **local-first and zero-telemetry**, your financial information never leaves your device.

- **Database Encryption at Rest:** The SQLite database file is encrypted utilizing **SQLCipher (AES-256)**.
- **Hardware-Backed Key Generation:** The database cipher key is generated using a secure CSPRNG and stored in the device's hardware-backed secure storage via `flutter_secure_storage` (Android Keystore / iOS Keychain).
- **Secure Authentication:** Protection via a custom 4-to-8 digit PIN and **Biometric Lock** (Face ID / Touch ID) on startup. Includes brute-force lockout protection (lockout cooldown timer persisted in secure storage).
- **Background UI Blurring:** The application window is blurred dynamically using a native app lifecycle wrapper when placed in the background or app switcher to prevent unauthorized visual capture.
- **Discreet Mode:** Toggle button in the app bar instantly masks all financial balances, amounts, and trends across the application under a custom secure obfuscation font.
- **Delete Account (Right to Be Forgotten):** An explicit option in the settings menu drops all database tables, purges all secure storage keychain credentials, and performs a cold application restart to guarantee complete data deletion.