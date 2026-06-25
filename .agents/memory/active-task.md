# Active Task: Phase 26 - Production Readiness, PDF Export Enhancement & Budgets/Goals UI

## Current Objective
Finalize the PDF export functionality with localized data, currency injection, and chart scales. Implement the Budgets and Savings Goals UI/State integration. Perform a complete QA pass for 3 languages, UI overflows, and CI/CD validation to ensure production readiness.

## Context
- The data layer for Budgets and Goals is complete, but the UI (`budgets_and_goals_screen.dart`) requires Riverpod state management integration.
- `export_monthly_pdf_use_case.dart` needs updates to handle localized text, dynamic currency formats, chart scales, and destination accounts for transfers.
- The app supports English, Spanish, and Catalan. Complete L10n coverage and UI overflow testing are mandatory before launch.

## Next Steps
1. **PDF Enhancements (Currency, Scales, Transfers):** Modify PDF generation logic to include default user currency, exact chart scales in the income vs. expense summary, and destination account details for transfers.
2. **PDF Localization (i18n):** Inject `AppLocalizations` into the PDF generation flow so all text, dates, and tables match the user's selected language.
3. **Budgets & Goals UI:** Implement the provider logic and complete the UI in `budgets_and_goals_screen.dart` respecting Clean Architecture.
4. **Holistic QA & CI/CD:** Validate 100% localization coverage in ARB files, fix any UI overflows, and ensure all unit/integration tests and GitHub Workflows pass successfully.