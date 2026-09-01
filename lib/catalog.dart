import 'dart:convert';
import 'package:flutter/services.dart';
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
  final http.Client client;
  Future<List<Product>> list() async {
    final runtime = await StoreRuntime.load(client: client);
    String body;
    if (!runtime.live) {
      body = await rootBundle.loadString('assets/products.json');
    } else {
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
      body = response.body;
    }
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return (decoded['data'] as List)
        .map((item) => Product.fromJson(item))
        .toList();
  }
}
