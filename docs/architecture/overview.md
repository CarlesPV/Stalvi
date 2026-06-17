# Stalvi - Financial Management App
## Project Documentation

### 1. Overview
Stalvi is a local-first financial application designed to help users track their income, expenses, budgets, and savings goals. It supports multiple currencies, provides detailed statistics, and focuses heavily on data security, performance, and an intuitive user experience.

---

### 2. General Guidelines & UI/UX Requirements
* **Supported Languages:** Catalan, Spanish, and English.
* **Theming:** Must support both Light and Dark modes.
* **Responsiveness:** The UI must be fully responsive across different screen sizes.
* **Usability:** Highly intuitive interface with clear, user-friendly error messages and notifications.
* **Anti-Blank Page Syndrome:** The app will initialize with a default account named "Mi Cartera" (My Wallet) at 0.0 balance, 13 typical default categories, and 6 typical default tags in the user's locale to prevent empty states and guide new users.
* **Development Standards:** * Use the latest stable and secure technologies (avoiding unstable betas).
    * Future-proof architecture allowing easy modifications and feature additions.
    * All code documentation, variables, functions, and comments must be in **English**.
    * Keep comments minimal, clear, and comprehensive; rely on self-explaining variable and function names.

---

### 3. Architecture & Tech Stack
The application strictly follows **Clean Architecture** to separate concerns and ensure maintainability.

#### 3.1. Clean Architecture Layers
* **Data Layer:** Models, Data Sources, Repositories.
* **Domain Layer:** Entities, Use Cases, Repository Interfaces. *(Note: This layer interacts with data without knowing its encrypted state, keeping business logic clean and isolated).*
* **Presentation Layer:** UI, State Management.

#### 3.2. Tech Stack (Local-First Approach)
* **Frontend Framework:** Flutter
* **State Management:** Riverpod
* **Local Database & Storage:** SQLite
* **ORM / Flutter Interface:** Drift
* **Data Security:** SQLCipher (Transparent real-time encryption at the connection layer)
* **Key Management & Biometrics:** `flutter_secure_storage`, `local_auth`
* **Charts & Data Visualization:** `fl_chart`
* **File Exporting:** CSV/Excel plugins, PDF generation, `path_provider`
* **Currency API:** A 100% free API will update exchange rates once a day to the user's default currency.

#### 3.3. Optimization Strategy
* **Strategic Indexing:** Database indexes applied to frequently filtered columns.
* **Grouped DB Queries:** Heavy calculations (total balances, remaining budgets, daily averages) are delegated to SQLite using native aggregation functions (`SUM`, `GROUP BY`).

---

### 4. Data Models Structure

#### Profile
* `id` (String/Int)
* `name` (String)
* `username` (String)
* `password` (String - Encrypted/Hashed)
* `created_at` (DateTime)
* `modified_at` (DateTime)

#### Account
* `id` (String/Int)
* `user_id` (String/Int)
* `name` (String)
* `type` (Enum: Cash, Bank, Savings, Card)
* `initial_balance` (Double)
* `currency` (String)
* `color` (String/Hex)
* `icon` (String)
* `is_default` (Boolean - Only one account can be default)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

#### Category
* `id` (String/Int)
* `name` (String)
* `associated_type` (Enum/Optional - e.g., Electricity = Expense)
* `icon` (String)
* `color` (String/Hex)
* `parent_category_id` (String/Int/Optional - e.g., Home is parent of Water)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

#### Tag
* `id` (String/Int)
* `name` (String)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

#### Movement (Transaction)
* `id` (String/Int)
* `type` (Enum: Income, Expense, Transfer, Other [Error, lost money, found money, commission])
* `title` (String)
* `amount` (Double)
* `date_time` (DateTime - Default: Current)
* `description` (String/Optional)
* `category_id` (String/Int)
* `tag_id` (String/Int/Optional)
* `account_id` (String/Int)
* `destination_account_id` (String/Int/Optional - Only for Transfers)
* `currency` (String - Default: User's selected default)
* `exchange_rate` (Double - Current conversion to default currency)
* `is_recurring` (Boolean)
* `created_at` (DateTime)
* `modified_at` (DateTime)
* `is_deleted` (Boolean - For soft deletes)

#### Budget & Savings Goals
* `id` (String/Int)
* `associated_id` (String/Int - Budget = Category ID; Goal = Account ID)
* `name` (String)
* `target_amount` (Double)
* `deadline` (DateTime)
* `is_active` (Boolean - Default: true)
* `created_at` (DateTime)
* `modified_at` (DateTime)

---

### 5. Core Features

#### 5.1. Movements & Transactions
* **Registrations:** Log income, expenses, lost money, and transfers.
* **Transfers:** Moving money between accounts does *not* count as an expense or income in global statistics.
* **Recurring Movements:** Create rules (e.g., salary on the 1st, subscription on day X). The app must generate these automatically.
* **Soft Deletion:** Implementing a Trash system using `is_deleted`. Movements are hidden from the UI and statistics but kept for 30 days before permanent deletion to prevent accidental data loss and maintain referential integrity.
* **Extras:** Duplicate existing movements, filter by amount, order by categories.

#### 5.2. Budgets & Savings Goals
* **Budgets:** Set limits (e.g., Food = 300€/month). Show spent amount, remaining amount, spent percentage, and trigger push notifications if exceeded.
* **Savings Goals:** Set targets (e.g., Summer Trip = 1200€). Show current savings, remaining amount, and target date.

#### 5.3. Search & Filters
* Filter by Account, Date (1 Week, 1 Month, 1 Year, Custom), Type, Category, Tag.
* **Saved Filters (Favorites):** Save custom filter combinations (e.g., "Monthly Food": 1 Month + Expense + Food Category).

#### 5.4. Data Import & Export
* **Export:**
    * *CSV / Excel (.xlsx):* Columns: Date, Type, Category, Source Account, Destination Account, Concept, Description, Amount, Currency.
    * *PDF:* Must include Username, Title, Date Range, Applied Filters, Result Graph, Full List, and Generation Date. Protected with a password.
    * *Backup:* Encrypted JSON (password protected).
* **Import:** Support for CSV/Excel, Encrypted Backup, and Legacy App Versions. Must validate data compatibility before saving.

#### 5.5. Statistics & Views
* Must be visually appealing and easy to understand.
* Includes: Income vs. Expenses, Global Balance, Spent by Category, Top Categories (3 Expenses, 3 Incomes), Daily Average Spend, Current vs. Previous Month, Highest Spend Day.
* **Dynamic Filtering:** When applying filters, totals (Income, Expense, Balance, Average) must recalculate dynamically.
* **Calendar View:** Monthly calendar layout for transactions.
* **Automated Summaries:** Automatic generation of weekly and monthly summaries.

---

### 6. Security Protocol
* **Initial Lock:** PIN or Biometric authentication.
* **Data Encryption:** All local data is encrypted at rest (SQLCipher).
* **Privacy:** UI blurring when the app is in the background/multitasking view.
* **Discreet Mode:** Total balance is hidden by default; user must tap to reveal it.
* **Protected Exports:** Backups and PDF exports must be password protected.

---

### 7. Critical Errors to Prevent (Validation Rules)
1.  **Transfer Miscalculation:** Never count transfers as regular expenses or income to avoid breaking global statistics.
2.  **Uncontrolled Deletion:** Prevent accidental permanent deletion (enforce the 30-day Trash rule).
3.  **Missing Initial Balance:** Accounts must mandate an initial balance to ensure financial ledgers match reality.
4.  **Currency Ignorance:** Always factor in the exchange rate to the default currency; direct summation of different currencies will break totals.
5.  **Missing Validations:** Prevent negative amounts, transfers with the same origin and destination, invalid dates, and categories that conflict with the transaction type.