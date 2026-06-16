# Active Task: Phase 14 - Security Hardening, UX Polish & Localization

## Current Objective
Implement critical security validations, input sanitization, dynamic privacy controls, and comprehensive localization fixes to ensure strict production-readiness before proceeding with network/cloud features.

## Sub-tasks
1. **Input Sanitization & Limits**: Implement plain-text sanitization for all text inputs. Enforce a strict 20-character limit on transaction notes at the UI and Domain level.
2. **Dashboard Discreet Mode**: Refactor Dashboard balance, income, and expense widgets to be blurred by default on every load. Add a toggleable eye icon to reveal the numbers temporarily.
3. **Transaction Form Enhancements**: 
   - Add a Currency selector (defaulting to user settings) and a Tag selector.
   - Enforce mandatory fields: Value, Account, Category, Date, Currency.
   - Set optional fields (Notes, Tag) with an explicit "(Optional)" localized placeholder.
   - Remove hardcoded "Income"/"Expense" fallbacks and replace them with fully localized strings based on the active locale.
4. **Authentication & PIN UX**: Add state tracking for remaining PIN attempts during unlock and PIN changes. Fix the settings UI bug by moving error messages inside the popup/dialog to prevent keyboard overlap.
5. **Formatting & 100% L10n**: Update `CurrencyFormatter` to display currency symbols (e.g., €, $) globally, reserving ISO codes (EUR, USD) exclusively for settings. Conduct a complete audit to eliminate any remaining hardcoded text.

## Context Notes
- **Architecture**: Clean Architecture + Riverpod + Drift (SQLCipher) offline-first.
- **Project State**: Overriding old Phase 14 to prioritize offline security, privacy features, and UI/UX stability.