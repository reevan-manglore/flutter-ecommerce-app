import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../provider/order_provider.dart';
import '../widgets/order_view_card.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = "/order_screen";

  Widget orderViewBuilder(BuildContext context, OrderProvider ordersProvider) {
    if (ordersProvider.orders.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (ctx, idx) => OrderViewCard(ordersProvider.orders[idx]),
        itemCount: ordersProvider.orderCount,
      );
    } else {
      return Center(
        child: Text(
          "No Orders Found",
          style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 48),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final orders = Provider.of<OrderProvider>(context);//will lead infinite loop
    //so insted of this  technique use consumer technique
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your orders",
        ),
      ),
      drawer: AppDrawer(routeName),
      body: FutureBuilder(
        future: Provider.of<OrderProvider>(context, listen: false)
            .fetchAndSetProducts(),
        builder: (context, AsyncSnapshot dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapShot.hasError) {
            return Center(
              child: Text(
                "An error occured while loading data",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 32,
                    ),
              ),
            );
          } else {
            return Consumer<OrderProvider>(builder: (context, value, child) {
              return orderViewBuilder(context, value);
            });
          }
        },
      ),
    );
  }
}
