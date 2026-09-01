import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_storefront/main.dart';
import 'package:headless_storefront/store_runtime.dart';

void main() {
  testWidgets('renders catalog and updates cart', (tester) async {
    StoreRuntime.testLoader = () async =>
        const StoreRuntime(storeId: 'test', apiUrl: '', publishableKey: '');
    await tester.pumpWidget(const StoreApp());
    await tester.pumpAndSettle();
    expect(find.text('Traverse Pack'), findsOneWidget);
    final add = find.text('Add Traverse Pack to cart');
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pump();
    expect(find.text('Cart 1'), findsOneWidget);
  });
}
