# SoloSpark Pro — Flutter Android MVP

A structured Flutter/Dart app for freelancers and small service businesses to organize clients, invoices/quotes, and expenses.

## Project structure

```text
lib/
  main.dart
  app/
    solo_spark_app.dart
  core/
    constants/
      app_constants.dart
    theme/
      app_theme.dart
    utils/
      formatters.dart
  data/
    models/
      client.dart
      expense.dart
      invoice.dart
    repositories/
      local_business_repository.dart
    services/
      local_storage_service.dart
  features/
    dashboard/presentation/dashboard_page.dart
    invoices/presentation/invoices_page.dart
    clients/presentation/clients_page.dart
    expenses/presentation/expenses_page.dart
    settings/presentation/settings_page.dart
  shared/
    widgets/
      empty_state.dart
      invoice_tile.dart
      page_heading.dart
      stat_card.dart
test/
  invoice_model_test.dart
```

## Included in version 1.1.0
- Feature-based folder structure instead of putting the app in one `main.dart`.
- Dashboard with paid income, pending amounts, tracked net, client/invoice counts, expenses, and overdue count.
- Invoice list with All/Paid/Pending/Draft filters and paid/pending status changes.
- Client directory with search, contact fields, notes, add and delete.
- Expense tracker with categories, notes, add and delete.
- Light and dark appearance toggle.
- Local persistence using `shared_preferences`.
- Sample records on first launch and reset-sample-data option.
- Shared widgets, theme, formatting helpers, model classes, repository, and a model serialization test.

## Requirements
- Flutter stable, Dart 3.3 or newer
- Android SDK / Android Studio
- VS Code with Flutter and Dart extensions (recommended)

## Run in VS Code on Android
1. Extract the ZIP.
2. Open the `SoloSpark_Pro_Flutter` folder in VS Code.
3. Open the integrated terminal in that folder.
4. Generate the native Android project files:
   ```bash
   flutter create --platforms=android .
   ```
   Keep the downloaded `lib/` files and `pubspec.yaml` if prompted about overwriting them.
5. Install packages:
   ```bash
   flutter pub get
   ```
6. Confirm your phone or emulator is detected:
   ```bash
   flutter devices
   ```
7. Run the app:
   ```bash
   flutter run
   ```

Build a release APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

Run tests:
```bash
flutter test
```

## Revenue model (proposed, not activated)
Possible pricing to validate with actual freelancers:
- Free: core tracking and limited active invoices.
- Solo Pro: $4.99/month or $39.99/year for unlimited invoices, PDF export, recurring invoices, reminders, and backup.
- Business: $9.99/month for multiple business profiles, reports, cloud sync, and team access.

This build does not yet contain Google Play Billing, account login, cloud synchronization, PDF generation/sharing, automated reminders, or payment processing. Those must be implemented and tested before selling subscriptions. Revenue is not guaranteed.

## Suggested next release
1. Pick one initial niche (e.g. cleaners, tutors, photographers, barbers, or handymen).
2. Generate polished PDF invoices and share them with Android's share sheet.
3. Add invoice numbering, tax/discount fields, and a business profile.
4. Add secure optional backup/sync.
5. Implement Google Play Billing, restore purchases, and subscription entitlement checks.
6. Add a privacy policy, terms, support contact, and Play Store assets.
7. Validate with potential customers before paying to publish or advertise.

## Important limitations
- Records are local to this device; deleting app data can remove them.
- Currency is USD and tax calculations are not included.
- Sample data is included on a clean first launch.
- This is an MVP, not financial or tax advice.
