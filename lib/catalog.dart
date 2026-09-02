import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store_runtime.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.currency,
    required this.available,
  });
  final String id, name, description, amount, currency;
  final bool available;
  factory Product.fromJson(Map<String, dynamic> value) => Product(
    id: value['id'],
    name: value['name'],
    description: value['description'],
    amount: value['price']['amount'],
    currency: value['price']['currency'],
    available: value['available'],
  );
}

class CatalogClient {
  CatalogClient({http.Client? client}) : client = client ?? http.Client();
  static Future<List<Product>> Function()? testLoader;
  final http.Client client;
  Future<List<Product>> list() async {
    if (testLoader != null) return testLoader!();
    final runtime = await StoreRuntime.load(client: client);
    final response = await client.get(
      Uri.parse(
        '${runtime.apiUrl.replaceFirst(RegExp(r'/$'), '')}/v1/headless/products',
      ),
      headers: {
        'accept': 'application/json',
        'x-publishable-key': runtime.publishableKey,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Catalog unavailable (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['data'] as List)
        .map((item) => Product.fromJson(item))
        .toList();
  }
}
