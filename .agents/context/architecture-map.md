# Architecture Map (Depends on the project)

## Pattern: Hexagonal Architecture (Ports and Adapters)

- **Domain Layer:** Core entities and domain services. Isolated from everything.
- **Application Layer:** Use cases. Orchestrates the flow of data but does not know about HTTP or SQL.
- **Infrastructure Layer:** Implements interfaces defined by the Application layer (e.g., PostgreSQL repositories, external payment APIs).

## Data Flow
Client -> API Route -> Controller -> Use Case -> Domain Entity -> Use Case -> Repository (DB) -> Response