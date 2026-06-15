# Konta Project Roadmap

## Completed Phases
- [x] **Phase 1:** Initial project setup, Clean Architecture structure, and Riverpod.
- [x] **Phase 2:** Encrypted Local Database implementation (Drift + SQLCipher).
- [x] **Phase 3:** Definition of Domain Models and Business Entities.
- [x] **Phase 4:** Use Case logic and Dependency Injection configuration.
- [x] **Phase 5:** Development of Management Screens (Transactions, Accounts, Budgets).
- [x] **Phase 6:** Statistics Module and Data Export/Import Engine.

- [x] **Phase 7: Secure Onboarding, Initialization & User Experience (UX)**
  - [x] Implement initial profile account creation (4-8 digit PIN, language selection, terms and conditions).
  - [x] Integrate biometric authentication request and validation (FaceID/TouchID).
  - [x] Automatic generation of the default account ("Mi cartera" / "My Wallet" with 0.0 balance) after registration.
  - [x] Apply and standardize `EmptyStateWidget` across all screens with empty lists.

## Current Phase
- [ ] **Phase 8: Advanced Settings Management (Manual/system dark/light mode, 30-day recycle bin)**

## Upcoming Phases
- [ ] **Phase 9:** Synchronization, Backups, and Import/Export Validations.
- [ ] **Phase 10:** Integration Testing (E2E), final security audit, and store preparation.