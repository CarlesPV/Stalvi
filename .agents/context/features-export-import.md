# Export & Import Requirements

## Export Formats & Rules
1. **CSV / Excel (.xlsx):**
   - Required Columns: Date, Type, Category, Source Account, Destination Account, Concept, Description, Amount, Currency.
2. **PDF (Password Protected):**
   - The PDF MUST be locked with a password (user-defined or default profile PIN).
   - Required Content: Username, Title, Date Range, Applied Filters, Result Graph, Full List of transactions, and Generation Date.
3. **JSON Backup:**
   - Must be fully encrypted and password protected.
   - Contains a complete dump of all database tables.

## Import Rules
- Support CSV/Excel and Encrypted JSON backups.
- Validate data compatibility (correct columns, valid dates, existing categories) before inserting into the local DB.