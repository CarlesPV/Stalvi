# Active Task: Phase 9 - Advanced Settings Management

## Objective
Implement advanced settings management features, specifically manual/system dark/light mode theme selection, and movement soft-delete 30-day recycle bin management.

## Current Context
The project has successfully implemented Phase 8 (Onboarding Improvements, Localization Polish & Bug Fixes) with all tests passing. The onboarding experience, multi-language seeding, separate legal viewers, and secure storage resiliency are in place. The next milestone is to enable users to control their theme mode preferences and manage their soft-deleted transactions in a trash/recycle bin.

## Atomic Steps
1. **Theme Mode Selection (Manual/System)**:
   - Expand the settings panel to allow the user to select between System, Light, and Dark theme mode preferences.
   - Persist user theme preference in the profile / local settings database structure.
   - Implement dynamic state provider in Riverpod to rebuild the application layout when the theme mode updates.
2. **30-Day Recycle Bin (Soft-delete Trash)**:
   - Develop a "Recycle Bin" visual viewer in Settings displaying transactions marked as `isDeleted` with their remaining days before permanent erasure (based on `modifiedAt` / deletion timestamp).
   - Add action items to either "Restore" transactions (resetting `isDeleted` to false) or "Delete Permanently" (removing the database row entirely).
   - Implement an automatic purging routine at startup or database instantiation to permanently delete items where the deletion age exceeds 30 days.

## Rules
- Follow Clean Architecture pattern structures strictly.
- Utilize Riverpod for state notifications in the settings presentation controllers.
- Ensure proper ARB localization coverage for all new UI text, labels, and buttons.
- Update/add unit and widget tests to cover theme persistence and recycling validations.