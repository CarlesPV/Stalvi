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

## Phase 2: Domain Modeling & Local Storage (Current)
- [ ] Implement `Profile` and `Account` tables in Drift.
- [ ] Create `Account` Entities and Use Cases (mandatory initial balance).
- [ ] Implement `Category` and `Tag` tables and seed default categories.
- [ ] Develop Presentation layer for Onboarding (Splash -> Biometric Auth -> Dashboard).

## Phase 3: Transaction Management (Core Engine)
- [ ] Implement `Movement` tables and Use Cases (Income, Expense, Transfer).
- [ ] Enforce transfer business rules (exclusion from global stats).
- [ ] Implement Soft Delete mechanism (`is_deleted` flag) and 30-day Trash logic.
- [ ] Build the "Add Movement" BottomSheet UI with numeric keypad priority.

## Phase 4: Multi-Currency & Goals
- [ ] Integrate external Exchange Rate API (HTTPS GET only) in Data Layer.
- [ ] Update Movement creation to save converted default currency values.
- [ ] Implement `Budget` and `Savings Goal` tables.
- [ ] Build visual progress bars for budgets and goals in the UI.

## Phase 5: Statistics, Filters, & Exports
- [ ] Build SQLite aggregation queries (`SUM`, `GROUP BY`) for dashboard totals.
- [ ] Implement `fl_chart` for Income vs Expense and Top Categories.
- [ ] Create dynamic filtering logic (Account, Date Range, Category).
- [ ] Implement secure PDF, CSV/Excel, and encrypted JSON export functionality.

## Phase 6: Polish, Testing & Compliance
- [ ] Complete E2E testing of the application flow.
- [ ] Validate "Discreet Mode" and App Lifecycle blurring features.
- [ ] Prepare App Store & Google Play compliance files (Privacy mappings).
- [ ] Final UI/UX review (Anti-blank page syndrome check, Dark Mode contrast).