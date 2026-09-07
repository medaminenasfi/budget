# 💰 Smart Budget Manager — Full Project Spec

A personal finance app to track monthly expenses, special purchases, travel, savings, and debts — built with Flutter + local SQLite storage, supporting TND / EUR / USD.

---

## 1. Overview

**Categories (5):**
1. Monthly Expenses
2. Special Purchases
3. Travel
4. Savings
5. Debt Tracker *(new)*

**Core principle:** every category follows the same pattern — a **budget/goal** + a list of **transactions**, so all logic (remaining = budget − spent) and all UI (list, add form, chart) can be reused across categories instead of rebuilt per screen.

**Currencies supported:** TND (default/base), EUR, USD — with manual or fetched conversion rates.

---

## 2. Recommended Stack

| Layer | Package | Purpose |
|---|---|---|
| State management | `flutter_riverpod` | Reactive state, less boilerplate than Bloc |
| Local database | `drift` (built on `sqflite`) or plain `sqflite` + `path_provider` | Drift gives compile-time-checked queries + reactive streams (UI auto-updates on data change) |
| Charts | `fl_chart` | Pie, bar, and line/trend charts |
| Formatting | `intl` | Currency + date formatting, localization |
| Currency conversion | manual rate table (offline) or `http` + a free exchange-rate API when online | See §5 |
| Notifications | `flutter_local_notifications` | Budget threshold alerts (80% / 100%) |
| Security | `local_auth` + `flutter_secure_storage` | PIN / biometric lock |
| Export | `csv`, `pdf` + `printing`, `share_plus` | CSV/PDF export |
| Photos | `image_picker`, `path_provider` | Receipt photo attachments |
| Backup | `path_provider` + `share_plus` (JSON read/write) | Local JSON backup/restore |
| Localization | `flutter_localizations` + `intl` + `.arb` files | Arabic / French / English |
| Prefs | `shared_preferences` | Theme, language, default currency |
| UI extras | `google_fonts`, `flutter_slidable` | Polish, swipe-to-delete |

---

## 3. Architecture

```
UI Layer (Presentation)
   ↓
Logic Layer (Riverpod providers/notifiers) — calculations, filtering, currency conversion
   ↓
Data Layer (Repositories → Drift/sqflite database)
```

### Folder structure
```
lib/
 ├── core/              → theme, constants, currency formatter, localization
 ├── data/
 │    ├── local/         → database.dart, migrations
 │    ├── models/        → Category, Budget, Transaction, Debt, RecurringRule
 │    └── repositories/  → BudgetRepository, TransactionRepository, DebtRepository, BackupRepository
 ├── logic/              → Riverpod notifiers per domain (budget_provider, currency_provider, etc.)
 ├── presentation/
 │    ├── screens/
 │    │    ├── home/
 │    │    ├── monthly/
 │    │    ├── special/
 │    │    ├── travel/
 │    │    ├── savings/
 │    │    └── debt/
 │    └── widgets/       → shared cards, progress bars, charts, currency picker
 └── main.dart
```

---

## 4. Database Design (Normalized)

Instead of 8+ near-duplicate tables, use a shared schema:

### `categories`
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| type | TEXT | monthly / special / travel / savings / debt |
| name | TEXT | |
| icon | TEXT | |
| color | TEXT | |

### `budgets`
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| category_id | FK → categories | |
| amount | REAL | budget or goal amount |
| currency | TEXT | TND / EUR / USD |
| period_start | DATE | |
| period_end | DATE | nullable (savings/debt may be open-ended) |

### `transactions`
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| category_id | FK → categories | |
| title | TEXT | |
| subcategory | TEXT | e.g. Hotel, Groceries |
| amount | REAL | in original currency |
| currency | TEXT | TND / EUR / USD |
| converted_amount | REAL | amount converted to base currency (TND) at entry time |
| exchange_rate | REAL | rate used, stored for historical accuracy |
| date | DATE | |
| is_purchased | BOOLEAN | used for Special Purchases |
| is_recurring | BOOLEAN | flags recurring expenses |
| recurring_rule_id | FK → recurring_rules | nullable |
| receipt_photo_path | TEXT | nullable, local file path |
| notes | TEXT | nullable |

### `recurring_rules` *(new — for subscriptions/rent)*
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| title | TEXT | e.g. "Netflix" |
| amount | REAL | |
| currency | TEXT | |
| frequency | TEXT | monthly / weekly / yearly |
| next_due_date | DATE | |
| category_id | FK → categories | |
| active | BOOLEAN | |

### `debts` *(new — Debt Tracker category)*
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| person_name | TEXT | who owes / is owed |
| direction | TEXT | "i_owe" / "owed_to_me" |
| amount | REAL | |
| currency | TEXT | |
| date_created | DATE | |
| due_date | DATE | nullable |
| settled | BOOLEAN | |
| notes | TEXT | nullable |

### `exchange_rates` *(new)*
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| base_currency | TEXT | always TND |
| target_currency | TEXT | EUR / USD |
| rate | REAL | e.g. 1 EUR = 3.4 TND |
| updated_at | DATETIME | |

---

## 5. Multi-Currency Logic (TND / EUR / USD)

- **Base currency = TND.** All summaries, totals, and dashboard cards are shown in TND by default.
- Every transaction stores **both** its original amount+currency **and** its converted-to-TND amount, using the exchange rate at the time of entry — this keeps historical accuracy even if rates change later.
- **Rate source options:**
  - *Offline/manual:* user sets/edits rates in a Settings screen (simplest, no internet dependency — good for MVP).
  - *Online:* fetch live rates periodically via a free API (e.g. exchangerate.host) when connected, cache locally, fall back to last cached rate offline.
- **Where currency matters most:** Travel screen (natural to log in EUR/USD abroad), Special Purchases (imported items), Debt Tracker (debts in foreign currency).
- Currency picker widget (dropdown: TND / EUR / USD) appears on every "Add transaction" form; base currency shown as a small converted preview under the input.

---

## 6. Screens & Features (Full List)

### 🏠 Home
- Summary cards for all 5 categories (budget, spent/saved, remaining), all normalized to TND.
- 6-month trend line chart comparing spend across categories (fl_chart).
- Quick-add floating button.
- Optional debt summary badge ("You owe 150 TND · Owed 300 TND").

### 💵 Monthly Expenses
- Monthly budget + expense list with category, date, currency.
- Recurring expense flag → auto-inserts on due date via `recurring_rules`.
- Pie chart by category, bar chart by week.
- Search & filter by date range / category / amount.

### 🛍️ Special Purchases
- Wishlist items with cost, purchased toggle, currency.
- Receipt photo attachment per item.
- Remaining budget updates on purchase.

### ✈️ Travel
- Per-trip budget with multi-currency expense entries (EUR/USD common here).
- Category breakdown chart (Hotel, Tickets, Food, Activities).
- Receipt photos for tickets/hotel confirmations.

### 💰 Savings
- Goal amount + progress bar.
- Saving transaction log.
- Optional recurring "auto-save monthly" rule.

### 🧾 Debt Tracker *(new)*
- Two lists: "I owe" and "Owed to me."
- Add person, amount, currency, due date.
- Mark as settled → moves to history.
- Home dashboard badge showing net debt position.

### ⚙️ Settings
- Language (Arabic / French / English) via `.arb` localization files.
- Default currency + manual exchange rate editor.
- PIN/biometric lock toggle.
- Theme (light/dark).
- Backup & Restore (local JSON export/import).
- Export reports (CSV/PDF) per category or full app.
- Notification preferences (budget alert thresholds).

---

## 7. Feature Details — New Additions

| Feature | How it works |
|---|---|
| **Recurring expenses** | `recurring_rules` table stores frequency + next due date; a background check on app open inserts a new `transactions` row if `next_due_date` has passed, then advances the date. |
| **Multi-currency** | See §5 — stored per-transaction with locked-in rate; base totals always in TND. |
| **Localization (AR/FR/EN)** | `.arb` files per language; `intl_utils` or `flutter gen-l10n` to generate code; RTL layout support for Arabic. |
| **Receipt photos** | `image_picker` captures/selects image → saved to app's local documents dir → path stored in `transactions.receipt_photo_path`. |
| **Trend chart** | Query last 6 months of `transactions` grouped by month + category_id → `fl_chart` LineChart. |
| **Search & filter** | Local query builder on `transactions` table: date range, category, amount range, currency. |
| **JSON backup/restore** | Serialize all tables to a single JSON file → save via `path_provider`/share; restore parses JSON and re-inserts (with conflict handling). |
| **Budget alerts** | On every transaction insert, recalculate % of budget used; if crossing 80%/100% threshold, trigger `flutter_local_notifications`. |
| **Debt tracker** | New category + `debts` table (see §4); simple in/out ledger, optionally linked to `transactions` if a debt payment should also count against a budget. |

---

## 8. MVP & Phased Roadmap

### ✅ Phase 1 — MVP Core (must-have to call it a working app)
- Database layer (Drift/sqflite) with `categories`, `budgets`, `transactions` tables
- Home dashboard with 4 original category summary cards (TND only)
- Monthly Expenses screen: full CRUD, remaining budget calculation
- Basic add/edit/delete transaction forms
- Single currency (TND) only — no conversion yet

### 🔁 Phase 2 — Replicate Core Pattern
- Special Purchases screen (purchased toggle logic)
- Travel screen
- Savings screen (goal + progress bar)
- Shared repository/provider pattern reused across all four

### 📊 Phase 3 — Visualization
- fl_chart integration: pie/bar charts per category
- Home dashboard 6-month trend line chart
- Search & filter on transaction lists

### 💱 Phase 4 — Multi-Currency + Debt Tracker
- `exchange_rates` table + Settings currency editor
- Currency picker on all add-transaction forms (TND/EUR/USD)
- Converted-amount display logic on Home + Travel
- Debt Tracker category (5th category) fully built

### 🔔 Phase 5 — Automation & Polish
- Recurring expenses/subscriptions (`recurring_rules`)
- Budget alert notifications (80%/100% thresholds)
- Receipt photo attachments

### 🌍 Phase 6 — Localization & Security
- Arabic / French / English localization (+ RTL support)
- PIN/biometric lock (`local_auth`)
- Dark mode

### ☁️ Phase 7 — Data Portability
- CSV/PDF export per category and full report
- Local JSON backup/restore
- *(Optional, post-MVP)* Cloud backup via Firebase/Google Drive

---

## 9. Suggested Build Order Summary

```
Phase 1: Core DB + Home + Monthly Expenses   → working single-category app
Phase 2: Special Purchases + Travel + Savings → all 4 original categories live
Phase 3: Charts + Search/Filter              → visual & usable
Phase 4: Multi-currency + Debt Tracker       → full 5-category app
Phase 5: Recurring + Alerts + Photos         → smart automation
Phase 6: Localization + Security + Dark mode → production polish
Phase 7: Export + Backup + (Cloud, optional) → data safety & portability
```

By the end of Phase 4, you already have a genuinely complete, differentiated budget app. Phases 5–7 turn it into something polished enough to publish.
