# <img src="assets/icon/app_icon.png" width="48" height="48" align="center" alt="Stalvi Logo"/> Stalvi

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![SQLCipher](https://img.shields.io/badge/Encryption-AES--256-green?style=for-the-badge)](https://www.zetetic.net/sqlcipher/)
[![License: All Rights Reserved](https://img.shields.io/badge/License-All_Rights_Reserved-red.svg?style=for-the-badge)](#license)

Stalvi is a premium, local-first personal finance control mobile application built with Flutter. It is designed to empower users with full control over their financial data through comprehensive tracking, advanced statistics, and zero-telemetry, offline-first local storage. 

It features state-of-the-art security, multi-currency support, local encryption (SQLCipher), Clean Architecture, and is fully localized in 3 languages (English, Spanish, and Catalan).

## 📱 App Overview

Stalvi bridges the gap between premium design aesthetics and absolute privacy. By adopting a **zero-telemetry, offline-first** approach, your sensitive financial information never leaves your device. Database entries are encrypted at rest, and access keys are generated securely using hardware-backed keystores.

Designed with strict **Clean Architecture** principles, the project ensures isolated testing, maintainable modular layers, and high-performance queries directly at the SQLite level using robust database aggregation with Drift.

## ✨ Features

- **Local-First & Zero-Telemetry**: Your data belongs to you. No data is sent to external servers.
- **Robust Encryption**: SQLite database file is encrypted utilizing **SQLCipher (AES-256)**.
- **Multi-Currency**: Comprehensive multi-currency support with offline historical exchange rates.
- **Trilingual Support**: Fully localized in English (🇬🇧), Spanish (🇪🇸), and Catalan (🏴).
- **Categories & Tags**: Explicitly categorize movements and use optional tags/labels for multi-dimensional filtering.
- **Automated Transactions**: Built-in engine to generate scheduled recurring transactions with UTC+2 precision.
- **Budgets & Savings Goals**: Set monthly limits and track your financial targets dynamically.
- **Advanced Statistics**: Reactive charts and filters utilizing Drift streams.
- **Secure Exports & Backups**: Premium PDF/CSV exports and AES-256 encrypted JSON backups.
- **Biometric Security**: Hardware-backed Key Generation and Face ID / Touch ID authentication with PIN fallbacks.

## 🛠️ Tech Stack 

- **Core Framework**: Flutter (Dart)
- **Architecture**: Clean Architecture (Presentation, Domain, Data)
- **State Management**: Riverpod (`flutter_riverpod`, `riverpod_generator`)
- **Database / ORM**: Drift (`drift`) + SQLite
- **Encryption**: SQLCipher (`sqlcipher_flutter_libs`)
- **Security**: `flutter_secure_storage`, `local_auth`
- **Background Sync**: `workmanager`
- **Charts**: `fl_chart`

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (`>=3.2.0 <4.0.0`)
- Android Studio / Xcode
- CocoaPods (iOS)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/CarlesPV/Stalvi.git stalvi
   cd stalvi
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Code (Drift / Riverpod):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```
   *Alternatively, use the helper script `./run_Stalvi.sh`.*

## 🧪 Testing Guidelines

Stalvi strictly enforces high test coverage across its domain and presentation layers. 

To execute the automated test suite (Unit, Widget, and Architecture tests):
```bash
flutter test
```
Or use the automated shell script:
```bash
./generate_tests.sh
```

To run static analysis and check for linting errors:
```bash
flutter analyze
```
All tests must pass and static analysis must result in `0` warnings/errors before pushing changes.

---
## 📄 License
Copyright © 2026 Carles / Stalvi. All rights reserved.

This source code is made available publicly strictly for personal portfolio, code review, and evaluation purposes. No permission is granted to copy, modify, distribute, sublicense, or publish this software or any part of it for commercial or non-commercial use.
