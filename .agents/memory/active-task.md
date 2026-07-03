# Active Task: Phase 40 - UI/UX Polish, Data Reactivity, and Legal Compliance

## Objective
Address critical UI/UX gaps (splash screen), ensure cross-provider reactivity for currency changes, refine PDF export logic, and standardize localization and legal documents.

## Current Context
The app features robust Clean Architecture with Riverpod and Drift. However, there are pending tasks regarding the native splash screen, real-time currency conversion across the app when the default currency changes, specific formatting rules for PDF exports (preserving original currencies for budgets/goals and showing transfer routes), and structural organization of ARB/legal files.

## Tasks
- [ ] Fix native splash screen to display `assets/icon/splash_icon.png` in both light and dark themes instead of a blank screen.
- [ ] Implement reactive currency conversion calculations on the Dashboard/Statistics so that changing the default profile currency updates all displayed amounts instantly using cached exchange rates.
- [ ] Update PDF Export service: respect the original currency of Budgets and Savings Goals instead of defaulting to the profile currency.
- [ ] Update PDF Export service: format transfer transactions in the account column as "Source Account -> Destination Account".
- [ ] Refactor `.arb` localization files: group by logical blocks and sort alphabetically within each block across en, es, and ca.
- [ ] Overhaul Terms & Conditions and Privacy Policy markdown files in `assets/legal/` to be comprehensive and legally robust for a financial tracker app.

## Architecture Guidelines
- Maintain strict separation of concerns.
- Ensure PDF formatting logic is tested via unit tests in the domain/data layer.
- Ensure Riverpod providers correctly use `ref.watch` to trigger UI updates upon profile currency changes.
- **Agent Instruction:** Always modify files directly and silently; do not print generated code or content in the chat.