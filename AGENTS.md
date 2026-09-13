# AI engineering guide

Read `README.md`, `analysis_options.yaml`, `lib/*`, `test/*`, platform configuration and both Playwright suites before editing.

## Boundary and contract

This is one Flutter codebase for web, Android and iOS. `assets/headless-config.json` contains one `storeId`; changing it requires rebuild but no Dart source edit. Canonical HTTP truth is `https://www.1ecomm.com/headless-commerce/openapi.yaml`.

The server owns pricing, inventory, checkout options and orders. Cart tokens and order proof are sensitive. Do not retry mutations/lookup; reuse the same idempotency key only for uncertain order placement. Parse exact contract shapes: guest orders contain `items[]`; line count is `items.length`.

## Dart/Flutter practices

- Keep JSON decoding typed and defensive; distinguish missing, null and invalid values instead of silently inventing business values.
- Prefer immutable models, `const` widgets and small composable widgets. Keep HTTP/runtime code outside rendering widgets.
- Check `mounted` after asynchronous gaps before changing widget state.
- Represent loading, empty, offline, error, success and uncertain placement explicitly.
- Use Material semantics, scalable text, safe areas, keyboard/focus support and minimum touch targets.
- Store production bearer tokens in platform Keychain/Keystore through a reviewed abstraction. Never log them.
- Direct dependencies must follow the stable Flutter/Dart constraint. Do not force transitive packages beyond the SDK-pinned graph.

## License boundary

`LICENSE.md` allows authorized 1Ecomm customer projects and deployed or compiled shopper applications, but prohibits redistribution of this reusable starter or its derivatives. Preserve the notice in clones, packages, generated projects and documentation. Do not describe this repository as open source or grant broader rights in examples.

## Verification

Run `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`, `flutter build web`, `npm ci`, and `npm run test:e2e`. Live proof uses only the maintained sandbox. Native claims require Android and iOS build plus installed-device evidence; compiled web does not qualify native behavior.
