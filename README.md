# 1Ecomm Flutter Storefront Starter

Free for authorized 1Ecomm customers and their developers to build and operate 1Ecomm-connected apps. You may distribute a compiled finished shopper app, but may not redistribute, resell, sublicense, mirror, or republish this starter or a reusable derivative. See [LICENSE.md](LICENSE.md).

This is one Flutter shop codebase for web, iOS and Android. It shows products, cart, guest checkout choices, a pending non-hosted order confirmation, and account-free return-order lookup. It never charges a card or wallet.

It fails closed when bootstrap or catalog APIs are unavailable; it never substitutes bundled products. Widget tests use an explicit test-only loader seam rather than a runtime fixture path.

## Run the web version

1. Install the current stable Flutter SDK and Node.js 20 or newer.
2. Open `assets/headless-config.json` and replace only `storeId` with your provisioned 1Ecomm store ID. The included ID is a safe test fixture.

The required CI browser gate allocates its own expiring fixture, drives the compiled Flutter UI through the real deployed catalog/cart/checkout/order/lookup APIs, and always revokes the temporary key. Local merchant setup remains store-ID-only.
3. Run:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For the exact production-web artifact and browser smoke, run `flutter build web`, `npm ci`, and `npm run test:e2e`. `npm run test:e2e:live` creates an isolated fixture cart and pending bank-transfer test order against the deployed API. It does not move money.

Changing the bundled store ID requires rebuilding, but no Dart source edit. The web build is qualified; platform-secure token storage, PKCE/deep links, offline recovery, signed builds, device installation and app-store submission remain separate native release gates.
