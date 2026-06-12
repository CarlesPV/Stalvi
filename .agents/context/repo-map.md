# Repository Map

The `lib/` directory is structured by layers, and inside by features:

```text
lib/
 ├── core/
 │    ├── errors/          # Custom exceptions and failure classes
 │    ├── theme/           # Light/Dark mode definitions, pastel aesthetics
 │    ├── utils/           # Helper functions, formatters (currency, dates)
 │    └── security/        # flutter_secure_storage handlers, biometric lock
 ├── data/
 │    ├── database/        # Drift database setup, tables, DAOs
 │    ├── models/          # DTOs (Data Transfer Objects)
 │    ├── repositories/    # Implementation of domain repository interfaces
 │    └── network/         # Currency API services
 ├── domain/
 │    ├── entities/        # Core business models (Account, Movement, etc.)
 │    ├── repositories/    # Abstract interfaces
 │    └── usecases/        # Business logic operations (e.g., AddMovementUseCase)
 ├── presentation/
 │    ├── providers/       # Riverpod global/feature providers
 │    ├── widgets/         # Reusable UI components (buttons, custom charts)
 │    └── features/        # Screens grouped by feature (e.g., /home, /movements)
 └── main.dart             # Entry point, provider scope, app initialization
 ```