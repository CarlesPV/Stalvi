# Active Task: Phase 22.1 - Multi-Currency Immutability & Profile Hydration Fixes

## Current Status
- **Phase:** 22.1 (Hotfixes & Refactoring)
- **State:** In Progress
- **Primary Focus:** Fix premature default account creation, implement exchange rate snapshot JSON injection on transactions, and refactor statistics to calculate historical values using snapshots.

## Objectives
1. **Profile Hydration Fix:** Prevent `InitializeDefaultDataUseCase` from creating the default account during app startup. Restrict account creation strictly to `CreateProfileUseCase`.
2. **Snapshot Injection:** Update `AddTransactionUseCase` to fetch the 24h local exchange rates and store them as a JSON string in `exchangeRateSnapshot`.
3. **Historical Math:** Refactor `StatisticsRepositoryImpl` and Dashboard summaries to perform aggregations in Dart (not SQL SUM) by decoding `exchangeRateSnapshot` and calculating the exact value at the time of the transaction.

## Files in Scope
- `lib/domain/usecases/initialize_default_data_usecase.dart`
- `lib/domain/usecases/create_profile_usecase.dart`
- `lib/presentation/providers/app_startup_provider.dart`
- `lib/domain/usecases/add_transaction_usecase.dart`
- `lib/data/repositories/statistics_repository_impl.dart`
- `lib/data/database/daos/statistics_dao.dart`

## Strict Guidelines
- Maintain Clean Architecture and DRY principles.
- Use Dart's `jsonDecode` for math calculations in Repositories.
- All operations must be covered by Unit Tests.
- Do not output code to the chat; write directly to the file system.