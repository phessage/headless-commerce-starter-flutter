import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class StoreRuntime {
  const StoreRuntime({
    required this.storeId,
    required this.apiUrl,
    required this.publishableKey,
  });
  final String storeId, apiUrl, publishableKey;
  bool get live => apiUrl.isNotEmpty && publishableKey.startsWith('pk_');
  static Future<StoreRuntime> Function()? testLoader;
  static Future<StoreRuntime>? _cached;
  static Future<StoreRuntime> load({http.Client? client}) =>
      testLoader?.call() ?? (_cached ??= _load(client ?? http.Client()));
  static Future<StoreRuntime> _load(http.Client client) async {
    final config =
        jsonDecode(await rootBundle.loadString('assets/headless-config.json'))
            as Map<String, dynamic>;
    final storeId = config['storeId'] as String;
    final bootstrap =
        (config['bootstrapUrl'] as String? ?? 'https://api.1ecomm.com')
            .replaceFirst(RegExp(r'/$'), '');
    final response = await client.get(
      Uri.parse(
        '$bootstrap/v1/headless/stores/${Uri.encodeComponent(storeId)}/config',
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Store is not configured for headless commerce');
    }
    final value =
        (jsonDecode(response.body) as Map<String, dynamic>)['data']
            as Map<String, dynamic>;
    if (value['storeId'] != storeId ||
        !(value['publishableKey'] as String? ?? '').startsWith('pk_')) {
      throw Exception('Invalid store bootstrap response');
    }
    return StoreRuntime(
      storeId: storeId,
      apiUrl: value['apiUrl'] as String,
      publishableKey: value['publishableKey'] as String,
    );
  }
}
