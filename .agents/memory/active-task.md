# Active Task: Phase 24 - Financial Immutability, Export Engine & UI Polish

## Objective
Ensure historical transaction data integrity, improve data export capabilities (PDF/CSV/JSON), and fix critical UI/UX overflows and layout issues.

## Scope
- **Domain/Data Layer:** - Update `Transaction` entity and Drift database schema to store a snapshot of currency exchange rates at the time of creation.
  - Write database migration scripts to handle existing transactions.
- **Presentation Layer:**
  - Relocate the Statistics section from Settings to the top of the Accounts/Wallets view with proper visual separation.
  - Fix the missing visibility toggle (eye icon) on the backup confirmation password field.
  - Resolve global UI overflows, text truncation ("..."), and visual alignment issues across buttons and error messages.
- **Infrastructure/Services Layer:**
  - Modify export services (PDF, CSV, JSON) to append timestamps (`yyyyMMdd_HHmmss`) to filenames.
  - Enhance PDF generation: Include user's default currency symbols on all totals and generate summary charts below the transaction table.
  - Enhance CSV generation to include all newly added transaction data (e.g., historical exchange rates).
  - Modify import service: Force a complete memory clear, background state flush, and app restart upon successful data import.

## Constraints
- Ensure all translations (English, Spanish, Catalan) are updated for any new UI text.
- Maintain Clean Architecture boundaries.
- Database migrations must not cause data loss for existing users.