import 'package:flutter/material.dart';
import 'package:products_dashboard/src/models/product_model.dart';
import 'package:products_dashboard/src/providers/products_provider.dart';

class HomePage extends StatelessWidget {
  final productsProvider = ProductsProvider();
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: _buildList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, 'product');
          },
          child: const Icon(Icons.add),
        ));
  }

  Widget _buildList() {
    return FutureBuilder(
      future: productsProvider.loadProducts(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildItem(context, snapshot.data![index]);
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildItem(BuildContext context, ProductModel product) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
      ),
      onDismissed: (direction) {
        productsProvider.deleteProduct(product.id!);
      },
      child: Card(
        child: Column(
          children: [
            (product.photoUrl.isEmpty)
                ? const Image(
                    image: AssetImage('assets/no-image.png'),
                  )
                : FadeInImage(
                    placeholder: const AssetImage('assets/jar-loading.gif'),
                    image: NetworkImage(product.photoUrl),
                    height: 300.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            ListTile(
              title: Text('${product.title} - ${product.value}'),
              subtitle: Text(product.id ?? ''),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pushNamed(context, 'product', arguments: product);
              },
            ),
          ],
        ),
      ),
    );
  }
}
