import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routName = '/user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Products'),
          actions: [
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(EditProductScreen.routName),
                icon: Icon(Icons.add))
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, snapShot) =>
              snapShot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      child: Consumer<Products>(
                        builder: (ctx, prouductData, _) => Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemBuilder: (_, int index) => Column(
                              children: [
                                UserProductItem(
                                  prouductData.items[index].id,
                                  prouductData.items[index].title,
                                  prouductData.items[index].imageUrl
                                ),
                                Divider(),
                              ],
                            ),
                            itemCount: prouductData.items.length,
                          ),
                        ),
                      ),
                      onRefresh: () => _refreshProducts(context)),
        ));
  }
}
