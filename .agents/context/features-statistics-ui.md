# UX/UI Guidelines & Screen Flows

## 1. Design Language & Aesthetics
* **Theme Concept:** "Minimalist Pastel Tones". The UI must feel light, calm, and financially reassuring.
* **Color Palette:** Soft pastels for categories (mint green, blush pink, soft lavender, baby blue). Text should be highly legible (dark charcoal for light mode, soft white/grey for dark mode).
* **Dark Mode:** Fully supported. Pastel colors must dynamically adjust to darker, slightly desaturated tones to prevent eye strain while maintaining the aesthetic.
* **Typography:** Clean, modern, sans-serif (e.g., Inter, Roboto, or SF Pro). Numbers must be tabular (monospaced digits) for easy vertical scanning.

## 2. User Experience (UX) Principles
* **Anti-Blank Page Syndrome:** Always show default data or highly illustrative empty states (e.g., "Looks like you have no expenses yet! Tap '+' to log your morning coffee").
* **Discreet Mode:** Include a prominent but subtle toggle (e.g., an eye icon) on the main dashboard to mask all global balances (`**** €`).
* **Frictionless Entry:** The "Add Movement" FAB (Floating Action Button) must be accessible from almost anywhere. The input form should prioritize the numeric keypad.
* **Read-Only Padlock Indicators:** Appends visual padlock icons trailing strictly read-only/non-editable fields (excluding date fields) on the Budgets, Savings Goals, and Accounts/Wallets detail/edit sheets to indicate immutability.

## 3. Screen Flows
1. **Splash & Auth Screen:** * Logo display -> Biometric prompt or PIN pad.
2. **Dashboard (Home):**
   * Top: Global Balance (tap to hide/show).
   * Middle: Mini Income vs Expense bar chart for the current month.
   * Bottom: Recent transactions list.
3. **Add Movement (Modal/BottomSheet):**
   * Tabs: Expense | Income | Transfer.
   * Large amount input.
   * Grid of pastel-colored icons for categories.
   * Date picker (defaults to today).
4. **Statistics & Reports:**
   * Filter chips at the top (Account, Date Range, Category).
   * Interactive Pie/Donut charts for top expenses using `fl_chart`.
   * Dynamic totals that recalculate based on active filters.
5. **Budgets & Goals:**
   * Progress bars. Green if on track, turning yellow/red as the user approaches the budget limit.
6. **Settings & Security:**
   * Main settings list features: Budgets & Goals, Statistics, Profile & Security, and Recycle Bin (with 30-day soft deleted item management).
   * Profile & Security menu consolidates: Biometrics toggle, secure PIN changes, language selector, Theme Mode selector (System, Light, Dark), and legal documents (Terms & Conditions, Privacy Policy).