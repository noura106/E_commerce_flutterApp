import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProuductsGrid extends StatelessWidget {
  final bool showFavs;

  ProuductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavs ? productData.favouritesItems : productData.items;
    return products.isEmpty
        ? Center(
            child: Text('there is no produts!'),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(),
            ),
          );
  }
}
