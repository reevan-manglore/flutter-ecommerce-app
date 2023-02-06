import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/product_edit_screen.dart';
import '../provider/products_provider.dart';

class ManageProductScreenItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  ManageProductScreenItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 40,
        ),
        title: Text(title),
        trailing: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(ProductEditScreen.routeName, arguments: id);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
                  final response = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("Are you sure to delete?"),
                      content: Text(
                          "Are you sure to delete item \" ${title} \" \nitem once deleted cant be retrieved back"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            "No",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            "Yes",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (response == true) {
                    try {
                      await Provider.of<ProductProvider>(context, listen: false)
                          .deleteProduct(id);
                    } catch (_) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text("Product deletion failed"),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
