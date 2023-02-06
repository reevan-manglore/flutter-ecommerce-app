import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

class CartSingleItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantity;

  const CartSingleItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<CartProvider>(context);
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        data.removeItm(id);
      },
      background: Container(
        child: Container(
          margin: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete,
            size: 32,
          ),
        ),
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: FittedBox(
                child: Text(
                  "\$${price.toStringAsFixed(3)}",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text("Total ${price * quantity}"),
          trailing: Text("X $quantity"),
        ),
      ),
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Are you sure to delete?"),
            content: Text("Are You Sure to delete $title from cart"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx, true);
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
