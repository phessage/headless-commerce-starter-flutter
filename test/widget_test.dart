import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_storefront/main.dart';

void main() {
  testWidgets('renders catalog and updates cart', (tester) async {
    await tester.pumpWidget(const StoreApp());
    await tester.pumpAndSettle();
    expect(find.text('Traverse Pack'), findsOneWidget);
    await tester.tap(find.text('Add Traverse Pack to cart'));
    await tester.pump();
    expect(find.text('Cart 1'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Add Winter Quilt to cart'),
          )
          .onPressed,
      isNull,
    );
  });
}
