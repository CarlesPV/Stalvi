# Known Issues & Workarounds

Do not attempt to fix or refactor these known development environment issues unless explicitly asked:

- **Drift Code Generation Conflicts:** If `build_runner` fails due to conflicting outputs when moving files, you must run `dart run build_runner clean` before running the build command again.
- **SQLCipher iOS Build:** `sqlcipher_flutter_libs` requires the iOS project to use frameworks. If Pods fail, ensure `use_frameworks!` is present in `ios/Podfile`.
- **Analyzer Warnings on Generated Files:** Files ending in `.g.dart`, `.freezed.dart`, and `.drift.dart` might show linter warnings. Ignore them; they are excluded in `analysis_options.yaml`.