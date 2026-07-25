# Security Policy

This document outlines the security standards for both human contributors and AI Agents operating within this repository.

## AI Agent Security Protocols
- **No Hardcoded Secrets:** The agent MUST NOT output raw secrets, API keys, JWT tokens, or database credentials in code generation, terminal outputs, or memory scratchpads (`.agents/memory/`).
- **Dependency Management:** The agent must ask for explicit human confirmation before installing any new third-party Flutter/Dart package (`flutter pub add`).

## Application Specific Security Rules
- **Data Encryption:** All local database storage must be encrypted at rest using **SQLCipher**.
- **Secure Storage:** Use `flutter_secure_storage` for biometric keys, PINs, or any sensitive preferences.
- **Privacy Mode:** Implement UI blurring when the app goes into the background or multitasking view.
- **Protected Exports:** All JSON backups and PDF exports must be password protected.

## Reporting a Vulnerability
If an automated scanner or agent detects a vulnerability, it should log it in `.agents/memory/active-task.md` and immediately halt execution pending human review.