# Stalvi - Financial Management App

Stalvi is a local-first financial application designed to help users track their income, expenses, budgets, and savings goals. It supports multiple currencies, provides detailed statistics, and focuses heavily on data security, performance, and an intuitive user experience.

## Core Features
- **Movements & Transactions:** Track income, expenses, and transfers. Supports recurring movements and soft deletion (30-day trash).
- **Budgets & Savings Goals:** Set monthly limits and target goals with visual tracking and notifications.
- **Advanced Filtering & Statistics:** Concurrently filter transactions by multiple dimensions (type, category, date range, amount range, tag, currency) using reactive Drift query builders. Render interactive pie/donut charts with dynamic totals and eager statistics data pre-warming on screen initialization to eliminate loading latency.
- **Import & Export:** Export to CSV/Excel and password-protected PDF/JSON backups.
- **High Security:** PIN/Biometric lock, SQLCipher database encryption, discreet mode, and background UI blurring.

## Tech Stack
- **Frontend Framework:** Flutter
- **Architecture:** Clean Architecture
- **State Management:** Riverpod
- **Local Database:** SQLite (Drift ORM) + SQLCipher
- **Security:** `flutter_secure_storage`, `local_auth`
- **Charts:** `fl_chart`

## Development & AI Agents
This repository uses AI Agents for development assistance. Please review the `.agents/context/` directory for strict coding standards and the repository map before contributing. All development must strictly adhere to English documentation and Clean Architecture principles.