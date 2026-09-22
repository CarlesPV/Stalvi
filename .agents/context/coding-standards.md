# Architecture & Coding Standards

## 1. Architectural Pattern
The application strictly enforces **Clean Architecture** to guarantee testability and separation of concerns.
* **Data Layer:** Contains Drift database definitions, DAO classes, API network calls, and data mappers.
* **Domain Layer:** Contains raw Entities (Framework agnostic), Use Cases (Business logic), and Repository Interfaces. *Validation rules (e.g., prohibiting negative amounts) live here.*
* **Presentation Layer:** Flutter Widgets, UI Layouts, and Riverpod Providers.

## 2. Tech Stack Overview
* **Framework:** Flutter (Dart).
* **State Management:** Riverpod (`flutter_riverpod`, `riverpod_generator`).
* **Database:** SQLite via Drift (`drift`, `drift_dev`).
* **Security:** `sqlcipher_flutter_libs` (At-rest DB encryption), `flutter_secure_storage` (Key/PIN storage), `local_auth` (Biometrics).
* **Routing:** GoRouter (Recommended) or native Navigator 2.0.

## 3. Coding Guidelines
* **Language:** All variables, functions, and inline comments MUST be in English.
* **Immutability:** Use `freezed` or pure Dart immutable classes for all UI states.
* **Error Handling:** Use functional paradigms (e.g., `fpdart`'s Either) or custom Result classes for Repository returns. Do not throw unhandled exceptions to the UI.
* **Performance:** Offload heavy math (e.g., "Total Balance across 10,000 transactions") to SQLite `SUM()` and `GROUP BY` queries rather than doing it in Dart memory.

## 4. Security Rules for Agents
* Never hardcode secrets. Read from `.env`.
* Ensure `is_deleted` is checked in every read query to enforce the soft-delete trash pattern.

## 5. Accessibility (a11y) Standards
* **Semantic Merging (`MergeSemantics`):** Wrap multi-line tiles, summary cards, and complex list items with `MergeSemantics` so title, dates, and amounts are announced coherently.
* **MergeSemantics Boundaries:** NEVER wrap a `ListTile` with `MergeSemantics` if its `trailing` contains interactive widgets (`DropdownButton`, `IconButton`). The trailing widget must remain individually focusable.
* **Color/Icon Selectors:** All `GestureDetector` or `InkWell` widgets used as selection buttons MUST be wrapped with `Semantics(button: true, selected: isSelected, label: localizedName)`.
* **Modal Focus:** Every `showModalBottomSheet` and `showDialog` must set `autofocus: true` on the first TextField or wrap the title with `Focus(autofocus: true)`.
* **Form Errors:** All inline validation error `Text` widgets MUST be wrapped with `Semantics(liveRegion: true)`.
* **Reduce Motion:** All `AnimationController.repeat()` and `TweenAnimationBuilder` must check `MediaQuery.disableAnimationsOf(context)` and skip to final state when true.
* **Decorative Icons:** Purely decorative icons (chevrons, logos, warning symbols) must be wrapped with `ExcludeSemantics`.
* **Progress Indicators:** All `CircularProgressIndicator` must include a `semanticsLabel`.
* **Live Regions (`Semantics(liveRegion: true)`):** Wrap asynchronous or dynamic validation error text in live regions for prompt TalkBack/VoiceOver announcement.
* **Native Text Fields:** Never wrap `TextField` with artificial semantic value overrides that block native cursor and word-by-word reading.
* **Icons & Tooltips:** Ensure all interactive icon pickers (e.g. `CategoryIconPicker`) and buttons provide localized semantic labels and tooltips in EN, ES, and CA.
* **Touch Targets & Contrast:** Maintain minimum 48x48dp interactive boundaries and at least 4.5:1 WCAG contrast ratios.