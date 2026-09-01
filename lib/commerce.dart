import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store_runtime.dart';

class CartState {
  const CartState({required this.items});
  final List<dynamic> items;
  factory CartState.fromJson(Map<String, dynamic> value) =>
      CartState(items: value['items'] as List<dynamic>? ?? const []);
}

class Choice {
  const Choice({
    required this.id,
    required this.name,
    this.requiresHostedCheckout,
    this.canPlaceOrder,
  });
  final String id, name;
  final bool? requiresHostedCheckout, canPlaceOrder;
  factory Choice.fromJson(Map<String, dynamic> value) {
    final capabilities =
        value['capabilities'] as Map<String, dynamic>? ?? const {};
    return Choice(
      id: value['id'] as String,
      name: value['name'] as String,
      requiresHostedCheckout: capabilities['requiresHostedCheckout'] as bool?,
      canPlaceOrder: capabilities['canPlaceOrder'] as bool?,
    );
  }
}

class OrderConfirmation {
  const OrderConfirmation(this.orderNumber, this.status, this.paymentStatus);
  final String orderNumber, status, paymentStatus;
  factory OrderConfirmation.fromJson(Map<String, dynamic> value) =>
      OrderConfirmation(
        value['orderNumber'] as String,
        value['status'] as String,
        value['paymentStatus'] as String,
      );
}

class OrderStatus {
  const OrderStatus(
    this.orderNumber,
    this.status,
    this.paymentStatus,
    this.itemCount,
  );
  final String orderNumber, status, paymentStatus;
  final int itemCount;
  factory OrderStatus.fromJson(Map<String, dynamic> value) => OrderStatus(
    value['orderNumber'] as String,
    value['status'] as String,
    value['paymentStatus'] as String,
    value['itemCount'] as int? ?? 0,
  );
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
  StoreRuntime? runtime;
  bool get live => runtime?.live ?? true;
  Future<void> configure() async {
    runtime ??= await StoreRuntime.load(client: client);
  }

  String get base => runtime!.apiUrl.replaceFirst(RegExp(r'/$'), '');
  Map<String, String> headers({bool json = false}) => {
    'accept': 'application/json',
    'x-publishable-key': runtime!.publishableKey,
    if (token.isNotEmpty) 'x-cart-token': token,
    if (json) 'content-type': 'application/json',
  };
  Future<void> createCart() async {
    await configure();
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
    await configure();
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
    await configure();
    final response = await client.put(
      Uri.parse('$base/v1/headless/carts/current/checkout/$kind'),
      headers: headers(json: true),
      body: jsonEncode({'id': id}),
    );
    _ok(response, 200);
    return _checkout(response);
  }

  Future<OrderConfirmation> placeOrder(String idempotencyKey) async {
    final key = idempotencyKey.trim();
    if (key.isEmpty || key.length > 120) {
      throw ArgumentError('An idempotency key of 1-120 characters is required');
    }
    await configure();
    final response = await client.post(
      Uri.parse('$base/v1/headless/carts/current/checkout/order'),
      headers: {...headers(), 'Idempotency-Key': key},
    );
    _ok(response, 201);
    return OrderConfirmation.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>)['data']
          as Map<String, dynamic>,
    );
  }

  Future<OrderStatus> lookupOrder(String orderNumber, String email) async {
    final number = orderNumber.trim();
    final address = email.trim();
    if (number.isEmpty || address.isEmpty) {
      throw ArgumentError('Order number and email are required');
    }
    await configure();
    final response = await client.post(
      Uri.parse('$base/v1/headless/orders/lookup'),
      headers: headers(json: true),
      body: jsonEncode({'orderNumber': number, 'email': address}),
    );
    _ok(response, 201);
    return OrderStatus.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>)['data']
          as Map<String, dynamic>,
    );
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
