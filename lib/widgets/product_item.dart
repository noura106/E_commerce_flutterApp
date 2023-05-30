import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);


    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) =>
                IconButton(
                  icon: Icon(product.isFavourite ? Icons.favorite : Icons
                      .favorite_border),
                  color: Theme
                      .of(context)
                      .accentColor,
                  onPressed: () {
                    product.toggleFavouriteStatus(
                        authData.token!, authData.userId);
                  },
                ),
          ),
          trailing: IconButton(
            color: Theme
                .of(context)
                .accentColor,
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Added to cart!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(label: 'UNDO', onPressed: () {
                      cart.removeSingleItem(product.id);
                    },),
                  ),
              );
            },
          ),
          title: Text(product.title, textAlign: TextAlign.center,),
        ),
        child: GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(ProductDetailScreen.routName,arguments: product.id),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),


      ),
    );
  }
}
