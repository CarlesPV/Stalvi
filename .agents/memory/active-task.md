# Active Task: Phase 26 - Multi-Currency Engine & Export Refinement

## Context
The project is structurally solid, utilizing Riverpod, Drift, and Clean Architecture. However, advanced business rules regarding multi-currency interactions and complex PDF reporting require refinement. Although `CurrencyConverter` includes 'CNY' in its supported list, full system integration (UI, l10n, default seed) is incomplete.

## Objectives
1. **Multi-Currency Balances:** Refactor account balance calculations to compute the exact value of each transaction converted to the target account's currency, handling transfers (origin deduction, destination addition) seamlessly.
2. **Yuan (CNY) Integration:** Ensure CNY is fully operational across UI selectors, localized files (.arb), and symbol rendering.
3. **PDF Reporting Fidelity:** - Display original currencies and amounts in the transaction history table.
   - Restrict user-default currency conversions to the summary block (Income, Expenses, Net Balance).
   - Enhance PDF pie charts: externalize labels (arrows/side positioning) and add a detailed legend table (color, category name, percentage).

## Current Status
- [ ] Implement robust multi-currency calculation for account balances and transfers.
- [ ] Add missing CNY localization and UI wiring.
- [ ] Refactor `export_monthly_pdf_use_case.dart` for original currency transaction tables.
- [ ] Enhance PDF charts with external labels and descriptive legend tables.

## Architecture Guidelines
- Maintain strict Clean Architecture boundaries.
- Ensure all calculations rely on `CurrencyConverter` and handle potential null rates gracefully.
- Write unit tests for the new balance calculation rules.