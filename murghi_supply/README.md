# Murghi Supply App

A Flutter app to manage a poultry (murghi) supply business, with local SQLite storage (no internet/backend required).

## Features

### Daily Rate Table
- Date
- Rate
- Description
- Add / edit / delete entries, sorted newest first

### Accounts Table
- Account Name
- Address
- Supply Vehicle
- Previous Balance
- Supply Discount
- Search by account name, expandable cards, add / edit / delete

## Getting an APK to install on your phone (no computer setup needed)

This project includes a GitHub Actions workflow (`.github/workflows/build-apk.yml`) that builds the APK for you in the cloud.

1. Create a free GitHub account if you don't have one: https://github.com/signup
2. Create a new **repository** (e.g. `murghi-supply`) — public or private, doesn't matter.
3. Upload this entire unzipped project folder into that repository:
   - Easiest way: on the repo page, click **"Add file" > "Upload files"**, then drag in everything from the unzipped `murghi_supply` folder (including the hidden `.github` folder — if your file manager hides it, use `git` on desktop, or a tool like GitHub Desktop, to push the folder instead).
4. Once uploaded to the `main` branch, go to the **Actions** tab in your repository. A workflow run called "Build APK" will start automatically (takes about 3-5 minutes).
5. When it finishes (green checkmark), click into that run, scroll to **Artifacts**, and download `murghi-supply-apk` — it's a zip containing `app-release.apk`.
6. Transfer `app-release.apk` to your phone (via USB, WhatsApp/Telegram to yourself, Google Drive, email — any method).
7. On your phone, tap the APK file to install. Android will likely warn "install from unknown sources" — allow it for this file/app. Then it installs like any app.

You can re-run this any time you push changes — every push to `main` builds a fresh APK automatically.

## Building locally instead (if you have Flutter installed)

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. From the project folder run:

```bash
flutter pub get
flutter build apk --release
```

3. The APK will be at `build/app/outputs/flutter-apk/app-release.apk` — copy it to your phone and install as above.

Or run `flutter run` with a device/emulator connected to launch it directly during development.

## Project Structure

```
lib/
  main.dart                     # App entry + bottom navigation
  models/
    daily_rate.dart             # DailyRate model
    account.dart                # Account model
  db/
    database_helper.dart        # SQLite (sqflite) setup + CRUD for both tables
  screens/
    daily_rate_screen.dart      # Daily Rate list + add/edit dialog
    account_screen.dart         # Accounts list + add/edit dialog
```

## Data storage

Data is stored locally on-device using `sqflite`, in two tables:

- `daily_rates(id, date, rate, description)`
- `accounts(id, accountName, address, supplyVehicle, previousBalance, supplyDiscount)`

No backend/server is required — everything works fully offline.

## Ideas for next steps

- Link accounts to daily supply transactions (quantity supplied × rate − discount)
- Ledger/statement view per account with running balance
- Export accounts / rates to PDF or Excel
- Cloud sync (Firebase) if you need multi-device access
