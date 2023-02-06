import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/provider/cart_provider.dart';
import '../Screens/product_detail_screen.dart';
import '../provider/product.dart';
import '../widgets/badge.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Product>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GridTile(
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: data.id);
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Hero(
                  tag: data.id,
                  child: FadeInImage(
                    placeholder:
                        AssetImage("assets/images/product-placeholder.png"),
                    image: NetworkImage(
                      data.imageUrl,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),

                // Image.network(
                //   data.imageUrl,
                //   fit: BoxFit.cover,
                // ),
              ),
              Positioned(
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black45
                      : Colors.black,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.black,
          leading: Consumer<Product>(
            builder: (ctx, data, child) => IconButton(
              icon: Icon(
                  data.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                try {
                  await data.toggleFaviorite();
                } catch (e) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: SizedBox(
            width: double.infinity,
          ),
          trailing: Consumer<CartProvider>(
            builder: (_, cartData, _2) => IconButton(
              icon: Consumer<CartProvider>(
                builder: (ctx, cartData, icon) {
                  return Badge(
                    child: icon!,
                    value: cartData.getItemCountById(data.id).toString(),
                  );
                },
                child: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () {
                cartData.addItem(data.id, data.title, data.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Item Added"),
                    backgroundColor:
                        Theme.of(context).snackBarTheme.backgroundColor,
                    duration: Duration(seconds: 1),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    action: SnackBarAction(
                      label: "Undo",
                      textColor: Theme.of(context).colorScheme.onError,
                      onPressed: () => cartData.removeSingleItm(data.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
