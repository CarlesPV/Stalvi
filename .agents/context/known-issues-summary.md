# Known Issues & Workarounds (Depends on the project)

Do not attempt to fix or refactor these known issues unless explicitly asked:

- **Redis Connection Warnings:** On local environments, Redis throws a timeout warning on startup. Ignore it; it resolves itself after 2 seconds.
- **Legacy Payment Module:** The `src/infrastructure/legacy-payments.ts` file has `@ts-ignore` comments. Do not remove them. This file will be deprecated in v2.0.