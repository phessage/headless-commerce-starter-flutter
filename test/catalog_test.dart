import 'package:flutter_test/flutter_test.dart';
import 'package:headless_storefront/catalog.dart';

void main() {
  test('parses the public product shape', () {
    final product = Product.fromJson({
      'id': 'p',
      'name': 'Pack',
      'description': 'D',
      'price': {'amount': '9.00', 'currency': 'USD'},
      'available': true,
    });
    expect(product.name, 'Pack');
    expect(product.available, true);
  });
}
