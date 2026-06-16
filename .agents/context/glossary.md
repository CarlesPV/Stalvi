# Domain Glossary

Use these specific terms when naming variables, functions, or database columns:

- **Transaction:** A financial movement representing an income, expense, or transfer. The code utilizes `Transaction` (and the `Transactions` Drift table) to represent these entities, while database transactions are used for SQL atomicity.
- **Account:** A financial source (Wallet, Bank, Savings).
- **Category:** A classification for a Transaction (e.g., Food, Salary).
- **Transfer:** A specific type of Transaction between two internal Accounts that does not affect global income/expense statistics.
- **Soft Delete:** The action of setting `is_deleted = true` instead of dropping the record from the database.
- **Trash / Recycle Bin:** The area where soft-deleted items stay for 30 days before permanent automatic purging.