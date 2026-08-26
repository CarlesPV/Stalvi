# Phase 69: Semantic Visuals, PDF Fixes & Background Optimization

## Objective
Refine the semantic color coding of transactions across the UI and PDF exports (setting transfers and zero-balances to a neutral color) and optimize the background task trigger frequency to preserve device battery.

## Current Context
- The app uses `financialColors.positive` (green) and `financialColors.negative` (red). Transfers should use `colorScheme.onSurface` (neutral/black) to reflect zero impact on net worth.
- Background automatic transactions are evaluated every 4 hours via `WorkManager`.
- The PDF export incorrectly colors a `0` balance as positive (green).

## Tasks
- [x] 1. Update `_TransactionItem` (Dashboard), `automatic_transactions_screen.dart`, and `transaction_details_dialog.dart` so that Transfer amounts render in `colorScheme.onSurface` instead of red/green.
- [x] 2. Update `background_execution_service.dart` to change the WorkManager frequency from 4 hours to 12 hours.
- [x] 3. Update `export_service_impl.dart` so that if `(totalIncome - totalExpense) == 0`, the net balance text color in the PDF uses `PdfColors.black` instead of green or red.
- [x] 4. Run `flutter analyze --fatal-infos --fatal-warnings` and `flutter test` to ensure 0 regressions.
- [x] 5. Update `roadmap.md` by adding Phase 69 to the completed list, update documentation, and clear this active task.