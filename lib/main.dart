import 'package:flutter/material.dart';
import 'catalog.dart';
import 'commerce.dart';

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
  final commerce = CommerceClient();
  late final Future<List<Product>> products = CatalogClient().list();
  final fields = {
    for (final name in [
      'firstName',
      'lastName',
      'email',
      'address1',
      'city',
      'state',
      'postalCode',
      'country',
    ])
      name: TextEditingController(text: name == 'country' ? 'CA' : ''),
  };
  int cart = 0;
  CheckoutState? checkout;
  String error = '', status = '';
  bool busy = false;
  Future<void> add(Product product) async {
    if (!commerce.live) {
      setState(() {
        cart++;
        status = 'Synthetic demo only; configure a live sandbox for checkout';
      });
      return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final value = await commerce.add(product.id);
      setState(() {
        cart = value.items.length;
        status = '${product.name} added';
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> prepare() async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      final values = {
        for (final entry in fields.entries) entry.key: entry.value.text,
      };
      final value = await commerce.prepare(values);
      setState(() {
        checkout = value;
        status = 'Checkout prepared';
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> select(String kind, String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      final value = await commerce.select(kind, id);
      setState(() {
        checkout = value;
        status = '$kind selected';
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

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
        hero(),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error, semanticsLabel: 'Error'),
          ),
        if (status.isNotEmpty)
          Padding(padding: const EdgeInsets.all(16), child: Text(status)),
        if (cart > 0) checkoutForm(),
        catalog(),
      ],
    ),
  );
  Widget hero() => Container(
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
        Text(
          'Preparation only—no order placement or payment capture.',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
  Widget catalog() => FutureBuilder<List<Product>>(
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
      return Wrap(children: snapshot.data!.map(productCard).toList());
    },
  );
  Widget productCard(Product product) => SizedBox(
    width: 320,
    child: Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 130, color: const Color(0xffdce7dc)),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(product.description),
            Text(
              '${product.amount} ${product.currency}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            FilledButton(
              key: ValueKey('add-${product.id}'),
              onPressed: product.available && !busy ? () => add(product) : null,
              child: Text('Add ${product.name} to cart'),
            ),
          ],
        ),
      ),
    ),
  );
  Widget checkoutForm() {
    final state = checkout;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Prepare checkout',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (state != null) ...[
              Text(
                state.missing.isEmpty
                    ? 'No preparation gaps'
                    : state.missing.join(', '),
              ),
              DropdownButtonFormField<String>(
                initialValue: state.shippingId,
                decoration: const InputDecoration(labelText: 'Shipping method'),
                items: state.shipping
                    .map(
                      (choice) => DropdownMenuItem(
                        value: choice.id,
                        child: Text(choice.name),
                      ),
                    )
                    .toList(),
                onChanged: (id) => select('shipping-method', id),
              ),
              DropdownButtonFormField<String>(
                initialValue: state.paymentId,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: state.payment
                    .map(
                      (choice) => DropdownMenuItem(
                        value: choice.id,
                        child: Text(choice.name),
                      ),
                    )
                    .toList(),
                onChanged: (id) => select('payment-method', id),
              ),
            ],
            ...fields.entries.map(
              (entry) => TextField(
                controller: entry.value,
                keyboardType: entry.key == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(labelText: labels[entry.key]),
              ),
            ),
            FilledButton(
              onPressed: busy ? null : prepare,
              child: const Text('Load checkout choices'),
            ),
          ],
        ),
      ),
    );
  }

  static const labels = {
    'firstName': 'First name',
    'lastName': 'Last name',
    'email': 'Email',
    'address1': 'Address',
    'city': 'City',
    'state': 'State / province',
    'postalCode': 'Postal code',
    'country': 'Country code',
  };
}
