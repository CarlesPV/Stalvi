# Architecture Map: Stalvi (Flutter Clean Architecture)

The application strictly enforces Clean Architecture. The flow of dependencies is unidirectional: Presentation -> Domain <- Data.

## 1. Presentation Layer
- **UI:** Flutter Widgets, pages, and routing (GoRouter).
- **State Management:** Riverpod (`@riverpod` generated providers).
- **Responsibility:** Captures user input, displays states (AsyncData, AsyncLoading, AsyncError), and calls Use Cases or Repositories.

## 2. Domain Layer
- **Entities:** Pure Dart classes, framework-agnostic.
- **Use Cases:** Business logic (e.g., `AddMovementUseCase`, `CalculateBudgetUseCase`).
- **Repositories (Interfaces):** Abstract definitions of data operations.
- **Responsibility:** The core of Stalvi. Contains all financial validation rules (no negative amounts, transfer rules).

## 3. Data Layer
- **Models / DTOs:** Classes that map to database rows or API responses.
- **Repositories (Implementation):** Implements Domain interfaces.
- **Data Sources:** - *Local:* Drift ORM (SQLite) with SQLCipher.
  - *Remote:* Currency exchange API.
- **Responsibility:** Fetching, storing, and encrypting data. Maps Data Models to Domain Entities before returning them.

## Data Flow
User Input -> Riverpod Provider -> Domain Use Case -> Repository Interface -> Repository Implementation -> Drift DAO (SQLite) -> Return Entity -> UI Update