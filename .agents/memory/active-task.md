# Phase 60: Full Tags/Labels Integration & Category Deletion Polish

## Objective
Restore and fully integrate the tags/labels functionality for standard transactions across the entire app (Database, Domain, UI, Filters, and Exports). Enhance the category deletion workflow by adding visual cues (icon and color) to the re-assignment selector.

## Tasks
- [x] **1. Database & Domain**: Bump `schemaVersion` to 12 in `app_database.dart`. Add `tag_id` (nullable) to `transaction_table.dart`. Update `Transaction` entity, `transaction_mapper.dart`, and migration logic.
- [x] **2. Use Cases & Providers**: Update `AddTransactionParams` and `AddTransactionUseCase` to accept `tagId`. Ensure `AddTransactionNotifier.submit()` passes the `tagId`. Refactor `TransactionDao.watchFiltered` to filter using the new `tagId` column instead of the legacy `notes` LIKE query.
- [x] **3. UI - Transactions**: Update `TransactionDetailsDialog` to show the tag/label (below Category) if it exists. Update `TransactionFilterSheet` to properly allow filtering by labels.
- [x] **4. UI - Category Reassignment**: Update the category deletion dialog so the fallback/re-assignment selector displays the category's icon and color.
- [x] **5. Exports & Backups**: Update `ExportServiceImpl` so CSV and PDF formats include the tag/label column. Update JSON backup mappings.
- [x] **6. QA & Docs**: Ensure all tests pass. Update `roadmap.md` and `roadmap-summary.md` marking Phase 60 as complete. Support `ca`, `en`, and `es`.