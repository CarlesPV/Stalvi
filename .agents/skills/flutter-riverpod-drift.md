# Skill: Flutter, Riverpod, and Drift

When generating code for Stalvi using Flutter, Riverpod, and Drift, follow these strict rules:

## 1. Riverpod (State Management)
- **Use `@riverpod` annotations:** Always use the code-generation approach (`riverpod_generator`). Avoid manual `Provider` or `StateNotifierProvider` definitions unless strictly necessary.
- **AsyncData:** Always handle `AsyncValue` states (`data`, `loading`, `error`) in the UI gracefully.
- **Provider Ref:** Keep providers focused. Use `ref.watch` to reactively rebuild, and `ref.read` only inside callbacks (e.g., `onPressed`).

## 2. Drift (SQLite)
- **Schema:** Define tables extending `Table`.
- **Primary Keys:** Always explicitly declare `IntColumn get id => integer().autoIncrement()();` or a string UUID equivalent.
- **Queries:** Keep complex queries (like grouping and sum for statistics) inside the Drift DAOs (Data Access Objects) to utilize SQLite's native performance.
- **Code Generation:** Remind the user or system to run `dart run build_runner build --delete-conflicting-outputs` whenever you modify a `.dart` file containing Drift tables, Riverpod annotations, or Freezed classes.

## 3. Clean Architecture Implementation
- **Data Layer:** Drift generated databases, API clients (if any). Returns `Model` objects.
- **Repository Pattern:** Converts `Model` (Data) to `Entity` (Domain).
- **Presentation Layer:** Riverpod providers call the Repositories/Use Cases and hold the UI state.