# Tailor Shop — Offline Manager (Flutter)

A simple, fully **offline** mobile app for small tailor shops: customer profiles with body
measurements, orders with status tracking, and deposit / balance payments.
**No server, no internet needed** — everything is stored in a SQLite database on the phone.
UI in **English and Amharic (አማርኛ)**.

## Features

| Area | What it does |
|---|---|
| Customers | Name, phone, notes; search by name or phone |
| Measurements | 12 fields (neck, chest, waist, hip, shoulder, sleeve, bicep, wrist, thigh, knee, trouser length, bottom width) + date + notes; keep a history per customer |
| Orders | Pick customer, choose style, fabric, total price, deposit, delivery date |
| Order status | Pending → Fitting → Sewing → Finished → Collected (one tap to advance) |
| Payments | Every payment listed per order; shows paid vs. balance; order is marked **Fully paid** automatically when balance reaches 0 |
| Dashboard | Open orders count, total balance owed, deliveries due this week, overdue warning |
| Backup | One-tap export of all data to a JSON file in the app documents folder |
| Language | English / Amharic switch in Settings, remembered on the phone |
| App lock | Optional username & password asked on every app start; enable/disable and change them in Settings. The password is stored only as a salted SHA-256 hash on the phone. |

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10 or newer — Dart 3)
- Android SDK (for Android) and/or Xcode (for iOS)

## First run (important!)

The `android/` and `ios/` platform folders are generated locally — run this **once** inside
`tailor-shop/`:

```bash
flutter create . --project-name tailor_shop --org com.example --platforms android,ios
flutter pub get
flutter run
```

`flutter create` only fills in the missing platform folders; your `lib/`, `test/`, `pubspec.yaml`
stay untouched. Change `--org` to your own reverse-domain (e.g. `--org et.myshop`) for a custom
app id.

## Tests

```bash
flutter test          # model tests + a localization smoke test
flutter analyze       # static checks
```

## Release builds

```bash
flutter build apk --release          # Android APK (install on any phone)
flutter build appbundle --release    # Android Play Store bundle
flutter build ios --release          # iOS (needs macOS + Xcode)
```

## Device compatibility

- **Android 5.0+** (API 21 — the default Flutter minimum) and **iOS 12+**.
- No special permissions requested: no internet, no contacts, no storage.
- Works on phones and tablets, portrait orientation.
- Old Android versions: if you target very old devices you can lower `minSdk` in
  `android/app/build.gradle`; the app itself uses only classic APIs (SQLite via sqflite,
  SharedPreferences, path_provider).

## Where is my data?

| What | Where |
|---|---|
| Database | App-private SQLite file `tailor_shop.db` (via sqflite) |
| Backup file | `<app documents>/tailor_backup_YYYY-MM-DD.json` |
| Lock credentials | SharedPreferences: username + salt + password hash (the password itself is never saved) |

The database is private to the app and survives reboots and app updates.
**Back up regularly** from Settings → Export backup (e.g. copy the JSON to Google Drive or a
cable transfer). A backup can be restored by any developer by loading the JSON rows back into
the same tables — the format is simply the raw table dumps.

**About the app lock:** there is no "forgot password" recovery (the app is offline by design).
If the password is forgotten, the only way back in is reinstalling the app — which also deletes
the data — so keep the password safe and export backups regularly. Toggling the lock off in
Settings is always possible from inside the app while it is still unlocked.

## Project structure

```
tailor-shop/
├── pubspec.yaml                 # dependencies + l10n generation
├── l10n.yaml                    # localization generator config
├── lib/
│   ├── main.dart                # app bootstrap (providers + db load)
│   ├── app.dart                 # MaterialApp, theme, locale
│   ├── models.dart              # Customer, Measurement, ShopOrder, Payment
│   ├── data/
│   │   └── local_db.dart        # SQLite schema + queries (offline storage)
│   ├── state/
│   │   ├── shop_provider.dart   # in-memory data + save/delete/backup logic
│   │   └── settings_provider.dart # language preference
│   ├── util/
│   │   └── format.dart          # money / date / number formatting helpers
│   ├── widgets/
│   │   ├── status_chip.dart     # colored order-status pill (+ translations)
│   │   └── measurement_labels.dart # measurement key → localized label
│   ├── l10n/
│   │   ├── app_en.arb           # English strings
│   │   └── app_am.arb           # Amharic strings
│   └── screens/
│       ├── root_shell.dart      # bottom navigation (4 tabs)
│       ├── home_screen.dart     # dashboard
│       ├── customers_screen.dart
│       ├── customer_edit.dart   # add/edit customer (bottom sheet)
│       ├── customer_detail.dart # profile + measurements + orders
│       ├── customer_picker.dart # searchable picker used by order form
│       ├── measurement_edit.dart# full measurement form (12 fields)
│       ├── orders_screen.dart   # list + status filter chips
│       ├── order_edit.dart      # new/edit order + deposit
│       ├── order_detail.dart    # status advance, payment summary, payments
│       ├── payment_edit.dart    # add/edit payment (bottom sheet)
│       └── settings_screen.dart # language, backup, offline info, developers
└── test/
    ├── models_test.dart         # model + formatting unit tests
    └── widget_test.dart         # localization smoke test
```

## Data model (SQLite tables)

- **customers** — id, name, phone, notes, created_at
- **measurements** — id, customer_id → customers, date_taken, 12 numeric columns, notes
- **orders** — id, customer_id → customers, style, fabric, total_price, delivery_date, status, notes
- **payments** — id, order_id → orders, amount, paid_at, note

A deposit is simply the first payment row of an order. "Fully paid" is derived:
`total_price − sum(payments) ≤ 0`.

## Design decisions

- **Offline-first, permanently**: there is no network code at all. The phone's SQLite is the
  single source of truth, so the app never shows sync errors or needs an account.
- **Simple state management**: one `ShopProvider` (ChangeNotifier) holds all records in memory
  and reloads after each write — instant at small-shop scale (hundreds of records) and easy to
  reason about and test.
- **UUID primary keys** generated on-device, so a future cloud-sync feature can be added later
  without id collisions.
- **Easy to extend**: adding a new measurement field = one line in the model + schema +
  `measurement_labels.dart` + the two ARB files.
