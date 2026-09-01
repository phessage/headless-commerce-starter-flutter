import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:headless_storefront/commerce.dart';
import 'package:headless_storefront/store_runtime.dart';

void main() {
  test('looks up an order using the public contract', () async {
    late http.Request request;
    final client = CommerceClient(
      client: MockClient((value) async {
        request = value;
        return http.Response(
          jsonEncode({
            'data': {
              'orderNumber': 'ORD123',
              'status': 'pending',
              'paymentStatus': 'pending',
              'items': [
                {'id': 'line-1'},
                {'id': 'line-2'},
              ],
            },
          }),
          201,
        );
      }),
    );
    client.runtime = const StoreRuntime(
      storeId: 'store',
      apiUrl: 'https://api.example.test',
      publishableKey: 'pk_test',
    );
    final result = await client.lookupOrder(
      ' ORD123 ',
      ' shopper@example.test ',
    );
    expect(request.url.path, '/v1/headless/orders/lookup');
    expect(request.headers['x-publishable-key'], 'pk_test');
    expect(jsonDecode(request.body), {
      'orderNumber': 'ORD123',
      'email': 'shopper@example.test',
    });
    expect(result.orderNumber, 'ORD123');
    expect(result.itemCount, 2);
  });
}
