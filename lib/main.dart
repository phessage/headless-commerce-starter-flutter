import 'package:flutter/material.dart';
import 'catalog.dart';

void main() => runApp(const StoreApp());

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Trail Flutter',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff194c37)),
      useMaterial3: true,
    ),
    home: const StorePage(),
  );
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final Future<List<Product>> products = CatalogClient().list();
  int cart = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('TRAIL/FLUTTER'),
      actions: [
        Padding(padding: const EdgeInsets.all(16), child: Text('Cart $cart')),
      ],
    ),
    body: ListView(
      children: [
        Container(
          color: const Color(0xff194c37),
          padding: const EdgeInsets.all(40),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NATIVE BY DESIGN',
                style: TextStyle(color: Color(0xffffc857), letterSpacing: 2),
              ),
              Text(
                'Find your\nnext horizon.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  height: .95,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<Product>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Catalog unavailable'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Wrap(
              children: snapshot.data!
                  .map(
                    (product) => SizedBox(
                      width: 320,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 130,
                                color: const Color(0xffdce7dc),
                              ),
                              Text(
                                product.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              Text(product.description),
                              Text(
                                '${product.amount} ${product.currency}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FilledButton(
                                onPressed: product.available
                                    ? () => setState(() => cart++)
                                    : null,
                                child: Text('Add ${product.name} to cart'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}
