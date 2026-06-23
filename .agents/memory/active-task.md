# Active Task: Phase 24 - Core Robustness, Branding, and Data Integrity

## Objective
Refine the app's branding to "Stalvi", fix critical UI/UX flows in the settings and splash screen, correct the currency conversion engine across the app, and resolve data integrity issues in the Import/Export backup system.

## Current State
Phase 23 completed. The core architecture (Clean Architecture, Riverpod, Drift) is functional, but specific bugs have been identified regarding currency calculations, backup restorations (missing accounts), and file export destinations. 

## Sub-Tasks

### 1. Branding & Splash Screen Polish
- [ ] Update the Android and iOS splash screens to display the app icon with a rounded-corner square background (matching the top-left inner app icon), scaled and centered.
- [ ] Globally replace the name "Konta" with "Stalvi" across all export strings, backup file names, and user-facing texts.

### 2. Currency Conversion Engine
- [ ] Refactor currency calculation logic.
- [ ] Ensure transactions retain their original currency immutably.
- [ ] Implement robust conversion logic in UseCases/Providers so that stats, account balances, and totals accurately calculate the exchange rate from the transaction's source currency to the current profile's target currency.

### 3. Settings UI Restructuring
- [ ] Extract the Import/Export functionality from Profile/Security.
- [ ] Create a dedicated "Data Management" (Import/Export) section in the Settings screen, positioned between "Profile & Security" and the "Recycle Bin".

### 4. File System Integration & Backup Integrity
- [ ] Modify the Export functionality to save files directly to the device's standard "Downloads" folder, removing the immediate "Share" sheet trigger.
- [ ] Fix the Backup JSON Serialization/Deserialization logic.
- [ ] Ensure `Accounts` (and other relational entities like Categories/Tags) are correctly exported.
- [ ] Ensure the `ImportService` restores `Accounts` before `Transactions` to prevent foreign key constraint failures, ensuring wallets are not empty upon restoration.

## Next Steps
Execute the atomic prompts assigned to this phase to systematically implement these fixes ensuring tests pass and Clean Architecture principles are maintained.