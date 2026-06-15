# Active Task: Phase 7 - Secure Onboarding, Initialization & UI Polish

## Objective
Implement the secure user registration flow, biometric authentication integration, default data generation, and enforce empty states across the UI.

## Context
Phases 1-6 are complete (Clean Architecture core, Riverpod state, Drift+SQLCipher DB). The app now needs to handle the very first launch experience: creating a secure profile, asking for biometric permissions, and setting up the initial account so the user is not left with a blank slate.

## Current Sub-tasks
- [x] **Task 7.1: Profile Setup Flow.** Update `auth_screen` to handle account creation (4-8 digit PIN, language selection, terms acceptance).
- [x] **Task 7.2: Biometric Integration.** Prompt for biometric authentication after PIN creation. Fallback to PIN if rejected or unavailable.
- [x] **Task 7.3: Default Wallet Creation.** Automatically create an account named "Mi cartera" (localized) with 0 balance upon successful profile creation.
- [x] **Task 7.4: UI Empty States.** Integrate `EmptyStateWidget` into Dashboard, Transactions, and Accounts lists when no data is available.

## Architecture Guidelines
- **UI:** Flutter + Riverpod for state.
- **Security:** Use `secure_storage_manager.dart` for sensitive flags and Drift `profile_table` for non-sensitive preferences.
- **Domain:** Create specific UseCases for initialization (`CreateInitialWalletUseCase`).
- **Testing:** 100% coverage required for new UseCases and Notifiers.