# Testing Strategy (Depends on the project)

- **Framework:** Jest.
- **Mocks:** Only mock external services (APIs, Databases). Do not mock internal domain logic.
- **Coverage Target:** 80% for `src/core/` and 100% for `src/shared/`.
- **Structure:** Use the Arrange-Act-Assert (AAA) pattern for all test blocks.

## Example
```typescript
it('should return false if stock is insufficient', () => {
  // Arrange
  const inventory = new Inventory(10);
  // Act
  const result = inventory.reserve(15);
  // Assert
  expect(result).toBe(false);
});