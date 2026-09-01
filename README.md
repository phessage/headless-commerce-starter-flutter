# 1Ecomm Flutter Storefront Starter

Flutter iOS/Android/web reference storefront for the 1Ecomm public catalog, anonymous-cart and checkout-preparation preview. Change only `storeId` in `assets/headless-config.json`; the same source resolves the public runtime document on web, iOS and Android.

Run `flutter analyze`, `flutter test`, `flutter build web`, then `npm install && npm run test:e2e:live` for the compiled-web store journey.

The publishable key may be bundled, but the cart capability currently lives only in memory. Platform secure storage, PKCE, deep links, offline/uncertain mutation recovery, checkout return handling, native integration testing and signing remain release gates. Never clone production customer data into a demo environment.
