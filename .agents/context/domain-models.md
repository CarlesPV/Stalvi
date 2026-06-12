# Domain Models & Database Schema

The database relies on SQLite (via Drift) with SQLCipher for encryption. 

## 1. Profile
* `id` (String/UUID)
* `name` (String)
* `username` (String)
* `password` (String - Hashed/Encrypted)
* `created_at` (DateTime)
* `modified_at` (DateTime)

## 2. Account
* `id` (String/UUID)
* `user_id` (String)
* `name` (String)
* `type` (Enum: Cash, Bank, Savings, Card)
* `initial_balance` (Double)
* `currency` (String)
* `color` (String - Hex)
* `icon` (String)
* `is_default` (Boolean)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

## 3. Category
* `id` (String/UUID)
* `name` (String)
* `associated_type` (Enum/Optional: Income, Expense)
* `icon` (String)
* `color` (String - Hex)
* `parent_category_id` (String/UUID/Optional)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

## 4. Tag
* `id` (String/UUID)
* `name` (String)
* `is_deleted` (Boolean - Default: false)
* `created_at` (DateTime)
* `modified_at` (DateTime)

## 5. Movement (Transaction)
* `id` (String/UUID)
* `type` (Enum: Income, Expense, Transfer, Other)
* `title` (String)
* `amount` (Double - Must be positive; type dictates math)
* `date_time` (DateTime)
* `description` (String/Optional)
* `category_id` (String/UUID)
* `tag_id` (String/UUID/Optional)
* `account_id` (String/UUID - Source)
* `destination_account_id` (String/UUID/Optional - Required if type is Transfer)
* `currency` (String)
* `exchange_rate` (Double)
* `is_recurring` (Boolean)
* `created_at` (DateTime)
* `modified_at` (DateTime)
* `is_deleted` (Boolean - Default: false)

## 6. Budget / Savings Goal
* `id` (String/UUID)
* `associated_id` (String/UUID - Links to Category ID or Account ID)
* `type` (Enum: Budget, Goal)
* `name` (String)
* `target_amount` (Double)
* `deadline` (DateTime)
* `is_active` (Boolean - Default: true)
* `created_at` (DateTime)
* `modified_at` (DateTime)