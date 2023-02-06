import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item.dart';
import '../widgets/badge.dart';
import '../Screens/cart_screen.dart';
import '../provider/products_provider.dart';
import '../provider/cart_provider.dart';
import '../widgets/app_drawer.dart';

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = "/product-overview";

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _didInitalized = false;
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    if (!_didInitalized) {
      print("did change  dependencies ran");
      _isLoading = true;
      Provider.of<ProductProvider>(context)
          .fetchAndSetProducts()
          .catchError(
            (e) {
              print(e.toString());
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      "An error occured",
                    ),
                    content: Text(
                      'an error occured while fetching product ',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Okay",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    ],
                  );
                },
              );
            },
          )
          .then((value) => null)
          .whenComplete(
            () {
              setState(() {
                _isLoading = false;
              });
            },
          );
    }
    _didInitalized = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context);
    final itms = productsData.items;
    return Scaffold(
      appBar: AppBar(
        title: Text("An shopping app"),
        actions: [
          Consumer<CartProvider>(
            builder: (_, data, cstmChild) => Badge(
              child: cstmChild!,
              value: data.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_basket),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(ProductOverviewScreen.routeName),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(15),
              itemBuilder: (ctx, idx) {
                return ChangeNotifierProvider.value(
                  value: productsData.items[idx],
                  child: ProductItem(),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 3 / 5),
              itemCount: itms.length,
            ),
    );
  }
}
