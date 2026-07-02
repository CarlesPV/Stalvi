# Active Task: Phase 36 - Stabilization, Domain Resilience, and QA Cleanup

## 🎯 Current Objective
Execute a comprehensive polishing phase focused on domain logic correction, UI consistency, legal compliance, and extreme codebase optimization. Ensure 100% test passing and 0 static analysis warnings.

## 📝 Context & Priorities
- **Splash Screen**: Unify the visual identity using the existing rounded-corner icon (`splash_icon.png`).
- **Domain Logic (Recurring Transactions)**: Fix the edge-case in recurrence dates. Specifically, handle end-of-month overflows (e.g., executing a transaction scheduled for the 30th on February 28th/29th).
- **Legal & Compliance**: Update Terms & Conditions and Privacy Policy across all supported languages (EN, ES, CA). Add disclaimers regarding currency fluctuations and non-binding calculations.
- **Documentation Sync**: Align `README.md`, `roadmap.md`, and architecture diagrams with the current stabilized state.
- **Deep Cleanup**: Purge dead code, unused translations, unnecessary comments, and orphaned assets to minimize APK/IPA footprint.
- **Strict QA**: Enforce a "zero tolerance" policy for analyzer warnings or test failures following the cleanup.

## 🛠️ Step-by-Step Execution Plan
1. **[UI]** Reconfigure `flutter_native_splash.yaml` and regenerate native splash assets.
2. **[Domain]** Refactor `RecurrenceType` logic and `EvaluateAutomaticTransactionsUseCase`. Add robust unit tests for leap years and short months.
3. **[Compliance]** Overhaul `/assets/legal/` markdown files.
4. **[Documentation]** Update root and `/docs/` repository files.
5. **[Cleanup]** Run static analysis, remove unused resources, and format code.
6. **[Validation]** Execute full test suite and CI workflows locally.