//in maxmillian course this file is named as  user_product_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/manage_product_screen_item.dart';
import '../widgets/app_drawer.dart';

import '../Screens/product_edit_screen.dart';
import '../provider/products_provider.dart';

class ManageProductsScreen extends StatelessWidget {
  static const routeName = "/manage-products";

  Future<void> _onPageRefresh(BuildContext context) async {
    try {
      await Provider.of<ProductProvider>(context, listen: false)
          .fetchAndSetProducts();
    } catch (e) {
      await showDialog(
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Products"),
      ),
      drawer: AppDrawer(routeName),
      body: RefreshIndicator(
        onRefresh: () => _onPageRefresh(context),
        child: ListView.builder(
          itemBuilder: (_, idx) => ManageProductScreenItem(
            id: data.items[idx].id,
            title: data.items[idx].title,
            imageUrl: data.items[idx].imageUrl,
          ),
          itemCount: data.items.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(ProductEditScreen.routeName);
        },
      ),
    );
  }
}
