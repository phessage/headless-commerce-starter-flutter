# 1Ecomm Flutter Storefront Starter

This is one Flutter shop codebase for web, iOS and Android. It shows products, cart, guest checkout choices, a pending non-hosted order confirmation, and account-free return-order lookup. It never charges a card or wallet.

## Run the web version

1. Install the current stable Flutter SDK and Node.js 20 or newer.
2. Open `assets/headless-config.json` and replace only `storeId` with your provisioned 1Ecomm store ID. The included ID is a safe test fixture.
3. Run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For the exact production-web artifact and browser smoke, run `flutter build web`, `npm ci`, and `npm run test:e2e`. `npm run test:e2e:live` creates an isolated fixture cart and pending bank-transfer test order against the deployed API. It does not move money.

Changing the bundled store ID requires rebuilding, but no Dart source edit. The web build is qualified; platform-secure token storage, PKCE/deep links, offline recovery, signed builds, device installation and app-store submission remain separate native release gates.
