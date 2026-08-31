import 'dart:convert';
import 'package:http/http.dart' as http;

class CartState {
  const CartState({required this.items});
  final List<dynamic> items;
  factory CartState.fromJson(Map<String, dynamic> value) =>
      CartState(items: value['items'] as List<dynamic>? ?? const []);
}

class Choice {
  const Choice({required this.id, required this.name});
  final String id, name;
  factory Choice.fromJson(Map<String, dynamic> value) =>
      Choice(id: value['id'] as String, name: value['name'] as String);
}

class CheckoutState {
  const CheckoutState({
    required this.shipping,
    required this.payment,
    required this.missing,
    this.shippingId,
    this.paymentId,
  });
  final List<Choice> shipping, payment;
  final List<String> missing;
  final String? shippingId, paymentId;
  factory CheckoutState.fromJson(Map<String, dynamic> value) => CheckoutState(
    shipping: (value['shippingOptions'] as List)
        .map((v) => Choice.fromJson(v as Map<String, dynamic>))
        .toList(),
    payment: (value['paymentMethods'] as List)
        .map((v) => Choice.fromJson(v as Map<String, dynamic>))
        .toList(),
    missing: (value['missing'] as List).cast<String>(),
    shippingId: value['selectedShippingMethodId'] as String?,
    paymentId: value['selectedPaymentMethodId'] as String?,
  );
}

class CommerceClient {
  CommerceClient({http.Client? client}) : client = client ?? http.Client();
  final http.Client client;
  String token = '';
  static const apiUrl = String.fromEnvironment('HEADLESS_API_URL');
  static const key = String.fromEnvironment('HEADLESS_PUBLISHABLE_KEY');
  bool get live => apiUrl.isNotEmpty && key.isNotEmpty;
  String get base => apiUrl.replaceFirst(RegExp(r'/$'), '');
  Map<String, String> headers({bool json = false}) => {
    'accept': 'application/json',
    'x-publishable-key': key,
    if (token.isNotEmpty) 'x-cart-token': token,
    if (json) 'content-type': 'application/json',
  };
  Future<void> createCart() async {
    if (token.isNotEmpty) return;
    final response = await client.post(
      Uri.parse('$base/v1/headless/carts'),
      headers: headers(),
    );
    _ok(response, 201);
    token =
        (jsonDecode(response.body) as Map<String, dynamic>)['cartToken']
            as String;
  }

  Future<CartState> add(String productId) async {
    await createCart();
    final response = await client.post(
      Uri.parse('$base/v1/headless/carts/current/items'),
      headers: headers(json: true),
      body: jsonEncode({'productId': productId, 'quantity': 1}),
    );
    _ok(response, 201);
    return CartState.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>)['data']
          as Map<String, dynamic>,
    );
  }

  Future<CheckoutState> prepare(Map<String, String> address) async {
    final response = await client.patch(
      Uri.parse('$base/v1/headless/carts/current/checkout'),
      headers: headers(json: true),
      body: jsonEncode({
        'customerInfo': {
          'firstName': address['firstName'],
          'lastName': address['lastName'],
          'email': address['email'],
        },
        'billingAddress': address,
        'shippingAddress': {'sameAsBilling': true},
      }),
    );
    _ok(response, 200);
    return _checkout(response);
  }

  Future<CheckoutState> select(String kind, String id) async {
    final response = await client.put(
      Uri.parse('$base/v1/headless/carts/current/checkout/$kind'),
      headers: headers(json: true),
      body: jsonEncode({'id': id}),
    );
    _ok(response, 200);
    return _checkout(response);
  }

  CheckoutState _checkout(http.Response response) => CheckoutState.fromJson(
    (jsonDecode(response.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>,
  );
  void _ok(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw Exception('Headless request failed (${response.statusCode})');
    }
  }
}
