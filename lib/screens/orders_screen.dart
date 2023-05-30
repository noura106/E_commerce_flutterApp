import 'package:flutter/material.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routName = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders'),),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false)
              .fetchAndSetOrders(),
          builder: (ctx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapShot.error != null) {
                return Center(child: Text(''),);
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) =>
                      ListView.builder(
                        itemBuilder: (BuildContext context, int index) =>
                          OrderItem(orderData.orders[index]),
                        itemCount: orderData.orders.length,
                      ),
                );
              }
            }
          },
        ),
      ),

    );
  }


}