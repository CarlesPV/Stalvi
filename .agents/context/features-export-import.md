# Export & Import Requirements

## Export Formats & Rules
1. **CSV:**
   - Format: UTF-8 with BOM (`\uFEFF`), delimited by semicolon (`;`), with RFC-compliant quote escaping.
   - Columns: Date; Type; Account; Category; Label; Amount; Currency; Notes; converted_amount; exchange_rate; exchange_rate_snapshot; id; created_at; modified_at; transfer_id; source_account; destination_account.
2. **PDF (Overview & Monthly Report):**
   - Content: Username, Title, Date Range, Applied Filters, Balance Summary, Result Graphs, Transactions List with colored Type badges (Income in green, Expense in red, Transfer neutral), Multi-line centered Transfer routes (`Origin\n↓\nDestination`), Budgets & Savings Goals breakdown, and Generation Date.
3. **JSON Backup:**
   - Must be fully encrypted and password protected (`.kbak` with PBKDF2 + AES-256-CBC).
   - Contains a complete dump of all database tables including user profile and username.

## Import Rules
- Support CSV/Excel and Encrypted JSON backups.
- Validate data compatibility (correct columns, valid dates, existing categories) before inserting into the local DB.