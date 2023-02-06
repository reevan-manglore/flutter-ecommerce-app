import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = "/product-details";

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final productDetails =
        Provider.of<ProductProvider>(context, listen: false).findById(id);
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            expandedHeight: 250,
            floating: true,
            title: Container(
              margin: EdgeInsets.all(2.0),
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.black38,
              ),
              child: Text(
                productDetails.title,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: id,
                child: FadeInImage(
                  placeholder:
                      AssetImage("assets/images/product-placeholder.png"),
                  image: NetworkImage(productDetails.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  "\$ ${productDetails.price.toString()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Text(
                    productDetails.description,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(
                  height: 800,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
