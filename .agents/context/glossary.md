# Domain Glossary (Depends on the project)

Use these specific terms when naming variables, functions, or database columns:

- **SKU (Stock Keeping Unit):** The unique identifier for an item. Never use `itemId` or `productId`.
- **Reservation:** A temporary lock on inventory items pending payment. Never use `hold` or `lock`.
- **Warehouse:** The physical location storing the stock. Never use `store` or `location`.