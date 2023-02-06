import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth.dart';
import "./drawer_list_tile.dart";
import '../Screens/product_overview_screen.dart';
import '../Screens/order_screen.dart';
import '../Screens/manage_products_screen.dart';

import '../helpers/CutomRoute.dart';

class AppDrawer extends StatelessWidget {
  final String _currentRouteName;
  AppDrawer(this._currentRouteName);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text(
              "Hello Friend!",
            ),
            automaticallyImplyLeading: false,
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Column(
              children: [
                DrawerListTile(
                  icon: Icons.shop,
                  listText: "Shop",
                  isSelected:
                      _currentRouteName == ProductOverviewScreen.routeName,
                  whenTapped: () {
                    Navigator.of(context)
                        .pushNamed(ProductOverviewScreen.routeName);
                  },
                ),
                DrawerListTile(
                  icon: Icons.bookmark,
                  listText: "Orders",
                  isSelected: _currentRouteName == OrderScreen.routeName,
                  whenTapped: () {
                    Navigator.of(context).pushNamed(OrderScreen.routeName);
                    // Navigator.of(context).push(
                    //   CustomRoute(builder: (ctx) => OrderScreen()),
                    // );
                  },
                ),
                DrawerListTile(
                  icon: Icons.manage_accounts,
                  listText: "Manage Products",
                  isSelected:
                      _currentRouteName == ManageProductsScreen.routeName,
                  whenTapped: () {
                    Navigator.of(context)
                        .pushNamed(ManageProductsScreen.routeName);
                  },
                ),
                Divider(
                  thickness: 4.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<Auth>(context, listen: false).logout();
                  },
                  child: Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 30.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
