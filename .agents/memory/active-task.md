# Active Task: Phase 10 - Default Data Seeding & UX Improvements

## Objective
Implement improvements to the default seeding logic during onboarding, ensuring the user is provided with a localized default account, multiple default typical transaction categories, and multiple default typical tags in English, Spanish, and Catalan, preventing the "empty screen" syndrome on startup.

## Current Context
Phases 1-9 are fully completed. Advanced settings, Recycle Bin, dynamic onboarding PIN validation, and biometric auth are all implemented and verified. We have expanded the default seeding logic to populate a default zero-balance wallet, 13 typical transaction categories, and 6 typical tags in the user's selected language.

## Atomic Steps
1. **Repository Implementation for Tags**:
   - Create a `TagRepository` implementing `ITagRepository` contract using Drift.
   - Register `tagRepositoryProvider` in `repository_providers.dart`.

2. **Seeding Logic Extension**:
   - Update `InitializeDefaultDataUseCase` to take `ITagRepository` as a dependency.
   - Expand `categoryTranslations` and `defaultCategoryConfigs` with new typical categories: Shopping, Health, Education, Subscriptions, Travel, Investments, Gifts.
   - Add default tags seeding (Essential, Leisure, Work, Personal, Recurring, Subscription) localized in English, Spanish, and Catalan.
   - Ensure the default wallet name resolves to the correct locale-specific name with 0.0 balance.

3. **Verify and Test**:
   - Update `initialize_default_data_usecase_test.dart` to mock the tag repository and assert that 13 categories and 6 tags are seeded correctly in Spanish.
   - Resolve existing Linux test environment failures (missing sqlite3 dynamic library loading overrides).
   - Ensure all 177 unit tests in the codebase pass.

## Rules
- Maintain Clean Architecture strictly.
- Perform all seeding in English, Spanish, and Catalan.
- Keep tests updated to cover new dependencies and scenarios.