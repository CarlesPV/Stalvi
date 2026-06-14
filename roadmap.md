# Konta Development Roadmap

This document outlines the development phases for Konta. Every feature developed by the AI Agent MUST follow the strict lifecycle detailed below to ensure Clean Architecture, Security, and Quality.

## The Development Lifecycle (per feature)
For every task, the agent must perform the following cycle:
1. **Analyze:** Read context files (`business-rules.md`, `domain-models.md`). Identify edge cases.
2. **Code (Domain Layer):** Create Entities, Repository Interfaces, and Use Cases. Include validation rules here.
3. **Code (Data Layer):** Create Drift Models/Tables, DAOs, and implement Repositories using Mappers.
4. **Code (Presentation Layer):** Create Riverpod Providers and Flutter Widgets. Ensure UI handles `AsyncValue` (loading, error, data).
5. **Test:** Write Unit Tests for Domain/Use Cases (AAA pattern) and Widget Tests for empty states.
6. **Document:** Update `.agents/memory/active-task.md` and log any architectural decisions.

---

## Phase 1: Foundation & Security (Completed)
- [x] Initialize directory structure (Clean Architecture).
- [x] Dependency resolution and native environment setup for SQLCipher.
- [x] Base Drift database setup and `flutter_secure_storage` key generation.
- [x] Core utilities: Theme definitions (Pastel aesthetics), custom error classes, and currency formatters.

## Phase 2: Domain Modeling & Local Storage (Completed)
- [x] Implement `Profile` and `Account` tables in Drift.
- [x] Create `Account` Entities and Use Cases (mandatory initial balance).
- [x] Implement `Category` and `Tag` tables and seed default categories.
- [x] Develop Presentation layer for Onboarding (Splash -> Biometric Auth -> Dashboard).

## Phase 3: Transaction Management (Core Engine) (Completed)
- [x] Implement `Transaction` tables and Use Cases (Income, Expense).
- [x] Enforce atomic balance updates within a Drift database transaction.
- [x] Implement Soft Delete mechanism (`is_deleted` flag) on Account and Category.
- [x] Build the "Add Transaction" UI screen with numeric input and customized selectors.

## Phase 4: Multi-Currency & Goals (Completed)
- [x] Integrate external Exchange Rate API (HTTPS GET only) in Data Layer.
- [x] Update Movement creation to save converted default currency values.
- [x] Implement `Budget` and `Savings Goal` tables.
- [x] Build visual progress bars for budgets and goals in the UI.

## Phase 5: Statistics, Filters, & Exports (Completed)
- [x] Build SQLite aggregation queries (`SUM`, `GROUP BY`) for dashboard totals.
- [x] Implement `fl_chart` for Income vs Expense and Top Categories.
- [x] Create dynamic filtering logic (Account, Date Range, Category).
- [x] Implement secure PDF, CSV/Excel, and encrypted JSON export functionality.

## Phase 6: Polish, Testing & Compliance (Completed)
- [x] Complete E2E testing of the application flow.
- [x] Validate "Discreet Mode" and App Lifecycle blurring features.
- [x] Prepare App Store & Google Play compliance files (Privacy mappings).
- [x] Final UI/UX review (Anti-blank page syndrome check, Dark Mode contrast).