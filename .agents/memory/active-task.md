# Active Task: Phase 8 - Core Integration & Settings Refinement

## Current Objective
Resolve critical integration bugs preventing the app from functioning correctly, fix infinite loading states, and refine the Security & Profile settings.

## Sub-tasks
1. **Profile Currency**: Add currency selection to `Profile` entity, DB table, mapper, and UI.
2. **i18n Biometrics & Errors**: Update `.arb` files to include biometric prompts and security error messages (EN, ES, CA). Inject localizations into the biometric service.
3. **PIN Flow Refactor**: Modify the PIN change logic in `profile_settings_screen` and its controller to validate the old PIN sequentially.
4. **App Hydration Fix**: Debug and fix `initialize_default_data_usecase.dart` and `dashboard_screen.dart` providers. Ensure the default wallet and categories are created and displayed. Fix statistics screen rendering errors.

## Context Notes
- **Architecture**: Clean Architecture + Riverpod + Drift (SQLCipher).
- **Rules**: Always write unit tests for UseCases and Providers. Ensure UI correctly watches `StreamProvider` without getting stuck in `AsyncLoading`.