import 'package:flutter_test/flutter_test.dart';
import 'package:headless_storefront/main.dart';
import 'package:headless_storefront/catalog.dart';

void main() {
  tearDown(() => CatalogClient.testLoader = null);
  testWidgets('renders a catalog supplied through the explicit test seam', (tester) async {
    CatalogClient.testLoader = () async => const [
      Product(
        id: 'p1',
        name: 'Traverse Pack',
        description: 'Test product',
        amount: '119.00',
        currency: 'USD',
        available: true,
      ),
    ];
    await tester.pumpWidget(const StoreApp());
    await tester.pumpAndSettle();
    expect(find.text('Traverse Pack'), findsOneWidget);
  });
}
