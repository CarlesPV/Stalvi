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
* `amount` (Integer - Stored in cents, e.g. 1000 for 10.00, must be positive)
* `date` (DateTime)
* `categoryId` (String/UUID/Optional)
* `tagId` (String/UUID/Optional - Tag/Label ID)
* `notes` (String/Optional)
* `originalCurrency` (String)
* `convertedAmount` (Integer/Optional)
* `exchangeRate` (Double/Optional)
* `exchangeRateSnapshot` (String/JSON string/Optional - Historical rate snapshot dictionary at transaction time)
* `accountId` (String/UUID - Parent Account)
* `transferId` (String/UUID/Optional - Shared UUID linking paired legs of a transfer movement)
* `createdAt` (DateTime)
* `modifiedAt` (DateTime)
* `isDeleted` (Boolean - Default: false)


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