# Known Issues & Workarounds

Do not attempt to fix or refactor these known development environment issues unless explicitly asked:

- **Drift Code Generation Conflicts:** If `build_runner` fails due to conflicting outputs when moving files, you must run `dart run build_runner clean` before running the build command again.
- **SQLCipher iOS Build:** `sqlcipher_flutter_libs` requires the iOS project to use frameworks. If Pods fail, ensure `use_frameworks!` is present in `ios/Podfile`.
- **Analyzer Warnings on Generated Files:** Files ending in `.g.dart`, `.freezed.dart`, and `.drift.dart` might show linter warnings. Ignore them; they are excluded in `analysis_options.yaml`.

---

## Resolved Issues

The following historically known development and layout issues have been fully resolved:

- **UI Overflows & Layout Clipping:** All layout overflow issues (clipping in choice chips, dashboard totals, transaction and account list tiles, statistics visual legends) have been resolved. They have been secured using `Expanded`, `Flexible`, responsive safe sizing constraints, `SafeArea` configurations, and `SingleChildScrollView` wrappers for keyboard view safety.
- **Dead Code & Debug Statements:** Cleaned up all unused variables, functions, redundant imports, and diagnostic print statements to optimize app code size. Full codebase passes static analysis checks with 0 errors and warnings.
- **Recurring Transaction End-of-Month Clashing:** Implemented safe clamping logic for recurring/automatic transaction calendars during short months and February, resolving issues with schedules set on the 29th, 30th, or 31st and ensuring proper recovery on subsequent months.
- **Android Build Gradle Compatibility:** Resolved Gradle script compilation errors caused by deprecated extensions and `kotlinOptions` blocks in AGP 9.0 and Kotlin 2.3+ by migrating the project configuration to use `CommonExtension` and modern `compilerOptions` properties.