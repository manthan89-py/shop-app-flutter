import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';

import '../providers/product_provider.dart';
import '../widgets/user_product_item.dart';

class UsersProductScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchandSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductProvider>(
                  builder: (ctx, productData, _) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                        itemCount: productData.items.length,
                        itemBuilder: (_, index) => Column(
                              children: [
                                UserProductItem(
                                  id: productData.items[index].id,
                                  title: productData.items[index].title,
                                  imageurl: productData.items[index].imageUrl,
                                ),
                                Divider(),
                              ],
                            )),
                  ),
                ),
              ),
      ),
    );
  }
}
