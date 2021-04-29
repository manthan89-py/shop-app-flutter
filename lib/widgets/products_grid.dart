import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;

  ProductGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context);
    final products = showFavs ? productsData.favitems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (context, i) => ChangeNotifierProvider.value(
          value: products[i],
          child: ProductItem(
              // id: products[i].id,
              // title: products[i].title,
              // imageUrl: products[i].imageUrl,
              )),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
    );
  }
}
