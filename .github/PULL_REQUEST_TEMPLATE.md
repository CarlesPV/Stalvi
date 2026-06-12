## Description
## Type of change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Refactoring (improving code structure without changing behavior)

## Clean Architecture Checklist
- [ ] Domain layer is independent of Data and Presentation.
- [ ] Models and DTOs are mapped to Entities before reaching the Domain.
- [ ] Providers (Riverpod) only hold state and call Use Cases/Repositories.
- [ ] Code is entirely in English (variables, comments, docs).
- [ ] UI is responsive and supports Light/Dark mode.

## Testing
- [ ] Unit tests added/updated.
- [ ] App compiles and runs properly on local emulator.