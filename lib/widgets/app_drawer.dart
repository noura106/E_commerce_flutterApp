import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  return Drawer(

    child: Column(
      children: [
        AppBar(title: Text('Hello friend!'),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.shop),
          title:Text('Shop') ,
          onTap: ()=> Navigator.of(context).pushReplacementNamed('/'),
        ),
        ListTile(
          leading: Icon(Icons.payment),
          title:Text('Orders') ,
          onTap: ()=> Navigator.of(context).pushReplacementNamed(OrderScreen.routName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title:Text('Manage Product') ,
          onTap: ()=> Navigator.of(context).pushReplacementNamed(UserProductScreen.routName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title:Text('Log Out') ,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context,listen: false).logout();

          },
        ),
      ],
    ),
  );
  }

}