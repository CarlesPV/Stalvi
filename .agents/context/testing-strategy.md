# Testing Strategy

- **Framework:** `flutter_test`.
- **Mocks:** Use `mockito` or `mocktail`. Only mock external data sources, database connections, and secure storage. 
- **Coverage Target:** High coverage on the Domain layer (Use Cases, Entities) and Data mappings.
- **Structure:** Use the Arrange-Act-Assert (AAA) pattern for all test blocks.

## Key Testing Focus
- **Business Rules:** Verify that Transfers do not sum into Expenses. Verify that negative inputs are rejected.
- **Widget Tests:** Ensure "Anti-Blank Page Syndrome" UI states appear when there is no data.
- **Data Layer:** Verify that `is_deleted` items are successfully filtered out of default read queries.

## Example
test('should throw ValidationException if transaction amount is negative', () {
  // Arrange
  final useCase = AddTransactionUseCase(
    mockTransactionRepository,
    mockAccountRepository,
    mockProfileRepository,
    mockExchangeRateRepository,
  );
  final params = AddTransactionParams(
    id: 'test-id',
    amount: -5000, // in cents
    date: DateTime.now(),
    type: TransactionType.expense,
    accountId: 'account-id',
  );
  // Act & Assert
  expect(
    () => useCase.execute(params),
    throwsA(isA<ValidationException>()),
  );
});