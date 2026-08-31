# 1Ecomm Flutter Storefront Starter

Flutter iOS/Android/web reference storefront for the 1Ecomm public catalog, anonymous-cart and checkout-preparation preview. Synthetic fixtures are the default; configure an approved sandbox with `--dart-define=HEADLESS_API_URL=...` and `--dart-define=HEADLESS_PUBLISHABLE_KEY=...`.

Run `flutter analyze`, `flutter test`, `flutter build web`, then `npm install && npm run test:e2e` for the compiled-web synthetic journey. For the live gate, rebuild web with both Dart defines and run `npm run test:e2e:live` with the matching environment variables.

The publishable key may be bundled, but the cart capability currently lives only in memory. Platform secure storage, PKCE, deep links, offline/uncertain mutation recovery, checkout return handling, native integration testing and signing remain release gates. Never clone production customer data into a demo environment.
