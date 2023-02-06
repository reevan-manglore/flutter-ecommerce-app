import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../widgets/cart_single_item.dart';
import '../provider/cart_provider.dart';
import '../provider/order_provider.dart';

class CartScreen extends StatefulWidget {
  static const routName = "/cart";

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(
      context,
    );
    final orders = Provider.of<OrderProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart Screen"),
      ),
      body: Column(
        children: [
          Card(
            elevation: 3,
            margin: EdgeInsets.all(7),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Total",
                    style: const TextStyle(fontSize: 28),
                  ),
                  Spacer(),
                  Chip(
                    label: Text("\$${cartData.totalAmount}"),
                    backgroundColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .headline1!
                            .color),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : TextButton(
                          onPressed: cartData.totalAmount <= 0
                              ? null
                              : () async {
                                  if (cartData.totalAmount <= 0) {
                                    return;
                                  }
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await orders.addOrder(
                                        cartData.itms.values.toList(),
                                        cartData.totalAmount);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    cartData.clearCart();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                          child: Text("purcahase items"),
                        )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.itemCount,
              itemBuilder: (_, idx) {
                return CartSingleItem(
                  id: cartData.itms.values.toList()[idx].id,
                  title: cartData.itms.values.toList()[idx].title,
                  price: cartData.itms.values.toList()[idx].price,
                  quantity: cartData.itms.values.toList()[idx].quantity,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
