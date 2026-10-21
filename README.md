# SoloSpark Pro — Flutter Android MVP

A structured Flutter/Dart app for small service businesses to organize clients, invoices/quotes, and expenses.

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
      invoice_pdf_generator.dart
  data/
    models/
      client.dart
      expense.dart
      invoice.dart
      business_profile.dart
    repositories/
      local_business_repository.dart
    services/
      local_storage_service.dart
      csv_export_service.dart
  features/
    dashboard/presentation/dashboard_page.dart
    invoices/presentation/invoices_page.dart
    clients/presentation/clients_page.dart
    expenses/presentation/expenses_page.dart
    settings/presentation/settings_page.dart
    settings/presentation/business_profile_page.dart
  shared/
    widgets/
      empty_state.dart
      invoice_tile.dart
      page_heading.dart
      stat_card.dart
test/
  invoice_model_test.dart
  widget_test.dart
```

## Included in version 1.2.0
- Existing feature-based architecture and local persistence retained.
- Business profile with business/owner name, address, phone, email, Tax ID/EIN, payment instructions, and default payment terms.
- PDF invoice export/share through Android's native share/print options, with business branding, client, invoice number, due date, service, total, terms, payment instructions, and optional payment link.
- CSV export of invoices, clients, and expenses for Excel, Google Sheets, or an accountant.
- Optional payment URL on new invoices (Stripe, PayPal, Venmo, Cash App, or another provider's hosted link).
- Payment reminder draft shared to messaging/email apps; the user reviews and sends it.
- Invoice due dates follow simple terms such as `Due on receipt`, `Net 15`, and `Net 30`.
- Backwards-compatible invoice and business-profile JSON defaults for records created by earlier versions.
- Dashboard, clients, expenses, invoice filters/status controls, light/dark appearance, and reusable shared widgets.
- Tests for invoice serialization and the dashboard smoke test.

## Important notes
- PDF/CSV export uses the Android share sheet. The app does not send emails or messages automatically; you choose an app and send the draft yourself.
- Payment links are URLs provided by the business owner. SoloSpark does not create payment links, process payments, or automatically mark invoices paid.
- CSV export writes a temporary file and shares it through Android's share sheet.
- All records remain on this device. Cloud backup and Google Play Billing/subscriptions are not implemented.
- The app is an MVP and is not tax or accounting advice.

## Requirements
- Flutter stable, Dart 3.3 or newer
- Android SDK / Android Studio
- VS Code with Flutter and Dart extensions (recommended)

## Run in VS Code on Android
1. Extract the ZIP.
2. Open the `SoloSpark_Pro_Flutter` folder in VS Code.
3. Open the integrated terminal in that folder.
4. Install/update the Dart packages:
   ```bash
   flutter pub get
   ```
5. Confirm your phone or emulator is detected:
   ```bash
   flutter devices
   ```
6. Run the app:
   ```bash
   flutter run
   ```

The ZIP includes the Android project folder already, so you do not need to run `flutter create` unless you intentionally remove the `android/` folder.

Build a release APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

Run tests:
```bash
flutter test
```
