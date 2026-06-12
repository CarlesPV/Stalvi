# Architecture & Coding Standards

## 1. Architectural Pattern
The application strictly enforces **Clean Architecture** to guarantee testability and separation of concerns.
* **Data Layer:** Contains Drift database definitions, DAO classes, API network calls, and data mappers.
* **Domain Layer:** Contains raw Entities (Framework agnostic), Use Cases (Business logic), and Repository Interfaces. *Validation rules (e.g., prohibiting negative amounts) live here.*
* **Presentation Layer:** Flutter Widgets, UI Layouts, and Riverpod Providers.

## 2. Tech Stack Overview
* **Framework:** Flutter (Dart).
* **State Management:** Riverpod (`flutter_riverpod`, `riverpod_generator`).
* **Database:** SQLite via Drift (`drift`, `drift_dev`).
* **Security:** `sqlcipher_flutter_libs` (At-rest DB encryption), `flutter_secure_storage` (Key/PIN storage), `local_auth` (Biometrics).
* **Routing:** GoRouter (Recommended) or native Navigator 2.0.

## 3. Coding Guidelines
* **Language:** All variables, functions, and inline comments MUST be in English.
* **Immutability:** Use `freezed` or pure Dart immutable classes for all UI states.
* **Error Handling:** Use functional paradigms (e.g., `fpdart`'s Either) or custom Result classes for Repository returns. Do not throw unhandled exceptions to the UI.
* **Performance:** Offload heavy math (e.g., "Total Balance across 10,000 transactions") to SQLite `SUM()` and `GROUP BY` queries rather than doing it in Dart memory.

## 4. Security Rules for Agents
* Never hardcode secrets. Read from `.env`.
* Ensure `is_deleted` is checked in every read query to enforce the soft-delete trash pattern.