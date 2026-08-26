# Functional Specifications & Business Rules

## Epic 1: Onboarding & Accounts
**User Story 1.1:** As a new user, I want the app to initialize with a default account, categories, and tags so I can start logging transactions immediately.
* **Acceptance Criteria:**
  - App automatically seeds a default account (e.g., "Mi cartera" / "My Wallet" / "La meva cartera") with a balance of exactly 0.0.
  - App generates a baseline set of 13 typical categories and 6 event/organization-based default tags (Summer Trip, Event, Project, Wedding, Birthday, Business Trip).
  - Initial balance must be mandatory upon manual account creation.
  - All default seeded entities (account name, category names, tag names) must be localized in the selected app language (EN, ES, CA) and dynamically translated when the language is changed.

**User Story 1.2: Legal Documents Review:** As a user, I want to view the Terms & Conditions and the Privacy Policy separately, in my app's language, during registration or in the settings screen.
* **Acceptance Criteria:**
  - Terms & Conditions and Privacy Policy must be distinct documents and checkbox items.
  - Both documents must be fully localized in English, Spanish, and Catalan.
  - Both documents must be accessible from links during profile creation and via settings.

**User Story 1.3: Default Currency Selector:** As a new user, I want to select my default currency when creating my profile.
* **Acceptance Criteria:**
  - The profile creation form must display a dropdown selector for the default currency.
  - The chosen currency must be persisted in the user profile and used as the base currency for all conversions/calculations.

**User Story 1.4: Seamless Direct Entry & Biometrics Opt-In:** As a new user, I want to access the app immediately after profile creation without entering my PIN, and choose whether to enable biometric unlock.
* **Acceptance Criteria:**
  - The app must bypass the login screen immediately after successful profile creation and navigate directly to the Dashboard.
  - A biometric opt-in prompt/dialog must appear on the Dashboard for first-time users.
  - Opt-in preference (enable/disable biometric unlock) must be saved securely.

## Epic 2: Transactions & Movements
**User Story 2.1:** As a user, I want to transfer money between accounts without affecting my global income/expense statistics.
* **Acceptance Criteria:**
  * Transfer movements require both a source and destination account.
  * Transfers are strictly excluded from "Total Expense" and "Total Income" calculations.
  * Transfer amounts are displayed in neutral/black (`colorScheme.onSurface`) in transaction lists and details to reflect zero net impact on net worth.

**User Story 2.2:** As a user, I want to delete a transaction safely so I can recover it if I make a mistake.
* **Acceptance Criteria:**
  * Deleting a transaction sets `is_deleted` to true (Soft Delete).
  * Soft-deleted items disappear from charts and balances.
  * Items in the Trash are permanently purged only after 30 days.

**User Story 2.3: Automatic Background Processing:** As a user, I want scheduled recurring transactions and exchange rates processed automatically in the background with minimal battery impact.
* **Acceptance Criteria:**
  * Background periodic processing is scheduled every 12 hours via WorkManager.
  * Recurring transactions and daily exchange rates are evaluated safely offline-first.

## Epic 3: Privacy & Security
**User Story 3.1:** As a privacy-conscious user, I want my financial data protected when I switch apps.
* **Acceptance Criteria:**
  * The app UI must blur immediately when entering the OS background/multitasking view.
  * Re-entering the app requires PIN or Biometrics if the timeout threshold is reached.

## Epic 4: Multi-Currency Handling
**User Story 4.1:** As a traveler, I want to log an expense in a foreign currency and see its value accurately reflected in my default currency.
* **Acceptance Criteria:**
  * App fetches daily exchange rates via free API, caching only the 8 supported target currencies (EUR, USD, GBP, JPY, CAD, AUD, CHF, CNY) locally for up to 24 hours.
  * Transactions save the local currency, original amount, and the exchange rate snapshot (JSON encoded string) at the time of creation to ensure financial immutability.
  * Summation for charts only uses the converted default currency value, reactively recalculating and updating statistics immediately upon settings modifications (such as changing the default currency).

**User Story 4.2: Cross-Currency transfers:** As a user, I want to transfer money between accounts with different currencies and see correct balances on both sides.
* **Acceptance Criteria:**
  * Transfers between accounts with different currencies calculate the destination leg using the exchange rate active at transaction creation.
  * Origin leg reduces the source balance by the sent amount. Destination leg increases the target balance by the converted amount.

## Epic 5: Consolidated Settings & Profile & Security
**User Story 5.1:** As a user, I want all configuration, layout, and compliance options organized under a unified settings layout, consolidating profile-related settings under 'Profile & Security' and placing system-wide utilities like the Recycle Bin at the top level of the Settings tab.
* **Acceptance Criteria:**
  - Theme Mode, Language selection, Terms & Conditions, and Privacy Policy options are housed under the "Profile & Security" settings menu.
  - The Recycle Bin is accessible directly via a dedicated tile on the primary Settings tab list.
  - Redundant or standalone Profile navigation options and avatars are removed from the main AppBar and screens to focus on a clean dashboard structure.

## Epic 6: File Exports & Native View Access
**User Story 6.1:** As a user, I want to quickly view exported CSV or PDF reports using my system's default viewer.
* **Acceptance Criteria:**
  - When a CSV or PDF report is exported successfully, the system displays a confirmation snackbar showing the export folder/file path.
  - The snackbar includes a functional "Open" action button which launches the file natively via the OS handler (using `open_filex`).