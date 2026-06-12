# Domain Glossary

Use these specific terms when naming variables, functions, or database columns:

- **Movement:** A financial transaction. Never use `transaction` to avoid confusion with database transactions.
- **Account:** A financial source (Wallet, Bank, Savings).
- **Category:** A classification for a Movement (e.g., Food, Salary).
- **Transfer:** A specific type of Movement between two internal Accounts that does not affect global income/expense statistics.
- **Soft Delete:** The action of setting `is_deleted = true` instead of dropping the record from the database.
- **Trash:** The conceptual area where soft-deleted items stay for 30 days.