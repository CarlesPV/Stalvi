# Functional Specifications & Business Rules

## Epic 1: Onboarding & Accounts
**User Story 1.1:** As a new user, I want the app to initialize with a default account and categories so I can start logging transactions immediately.
* **Acceptance Criteria:** * App creates "Mi Cartera" (My Wallet) automatically.
  * App generates a baseline tree of common categories.
  * Initial balance must be mandatory upon manual account creation.

## Epic 2: Transactions & Movements
**User Story 2.1:** As a user, I want to transfer money between accounts without affecting my global income/expense statistics.
* **Acceptance Criteria:**
  * Transfer movements require both a source and destination account.
  * Transfers are strictly excluded from "Total Expense" and "Total Income" calculations.

**User Story 2.2:** As a user, I want to delete a transaction safely so I can recover it if I make a mistake.
* **Acceptance Criteria:**
  * Deleting a transaction sets `is_deleted` to true (Soft Delete).
  * Soft-deleted items disappear from charts and balances.
  * Items in the Trash are permanently purged only after 30 days.

## Epic 3: Privacy & Security
**User Story 3.1:** As a privacy-conscious user, I want my financial data protected when I switch apps.
* **Acceptance Criteria:**
  * The app UI must blur immediately when entering the OS background/multitasking view.
  * Re-entering the app requires PIN or Biometrics if the timeout threshold is reached.

## Epic 4: Multi-Currency Handling
**User Story 4.1:** As a traveler, I want to log an expense in a foreign currency and see its value accurately reflected in my default currency.
* **Acceptance Criteria:**
  * App fetches daily exchange rates via free API.
  * Transactions save the local currency, original amount, and the exchange rate at the time of creation.
  * Summation for charts only uses the converted default currency value.