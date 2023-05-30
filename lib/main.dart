import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Auth>(create: (_) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, authValue, previousProducts) => previousProducts!
              ..getData(authValue.token!, authValue.userId,
                 previousProducts.items),
          ),
          ChangeNotifierProvider<Cart>(create: (_) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(),
            update: (ctx, authValue, previousOrders) => previousOrders!
              ..getData(authValue.token!, authValue.userId,
                previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: auth.isAuh
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, AsyncSnapshot authsnapShot) =>
                        authsnapShot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routName: (_) => ProductDetailScreen(),
              CartScreen.routName: (_) => CartScreen(),
              EditProductScreen.routName: (_) => EditProductScreen(),
              //AuthScreen.routName: (_) => AuthScreen(),
              UserProductScreen.routName: (_) => UserProductScreen(),
              OrderScreen.routName: (_) => OrderScreen(),
            },
          ),
        ));
  }
}
