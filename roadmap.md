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

- [x] **Phase 8: Onboarding Improvements, Localization Polish & Bug Fixes**
  - [x] **Legal Document Split:** Separate Terms & Conditions and Privacy Policy viewers, localized in the app's language, accessible during onboarding and in settings.
  - [x] **Default Currency Selector:** Allow choosing the default currency during the profile creation flow.
  - [x] **First-Time Registration Fix:** Resolve the initialization bug where the first login/registration attempt fails and requires a retry.
  - [x] **Direct Onboarding Routing:** Bypass the PIN screen immediately after profile creation, redirecting to Dashboard, and prompt for biometric opt-in permissions.
  - [x] **Default Seeding:** Pre-populate a default account at 0.0 balance and basic typical categories to prevent empty states.
  - [x] **3-Language Coverage:** Ensure complete translation of all text, buttons, errors, default categories, and initial account name in English, Spanish, and Catalan.

## Current Phase

## Upcoming Phases
- [ ] **Phase 9: Advanced Settings Management (Manual/system dark/light mode, 30-day recycle bin)**
- [ ] **Phase 10:** Synchronization, Backups, and Import/Export Validations.
- [ ] **Phase 11:** Integration Testing (E2E), final security audit, and store preparation.