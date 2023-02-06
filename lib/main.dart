import 'package:flutter/material.dart';
import 'package:shop_app/Screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import './Screens/product_overview_screen.dart';
import './Screens/cart_screen.dart';
import 'Screens/order_screen.dart';
import 'Screens/manage_products_screen.dart';
import 'Screens/product_edit_screen.dart';
import 'Screens/auth_screen.dart';
import './Screens/splash_screen.dart';

import './provider/auth.dart';
import './provider/products_provider.dart';
import './provider/cart_provider.dart';
import './provider/order_provider.dart';

import './helpers/CutomRoute.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (context) => ProductProvider(),
          update: (context, authProvider, productProvider) =>
              productProvider == null ? ProductProvider() : productProvider
                ..setAuthToken(authProvider == null ? "" : authProvider.token)
                ..setUserId(authProvider.userId),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, OrderProvider>(
          create: (context) => OrderProvider(),
          update: (context, authProvider, orderProvider) =>
              orderProvider == null ? OrderProvider() : orderProvider
                ..setAuthToken(orderProvider == null ? "" : authProvider.token),
        ),
      ],
      child: Consumer<Auth>(
        builder: ((context, value, _) {
          return MaterialApp(
            title: 'Flutter Demo',
            // theme: ThemeData(
            //   colorSchemeSeed: Color.fromARGB(255, 93, 182, 108),
            //   fontFamily: 'Lato',
            //   useMaterial3: true,
            //   brightness:
            //       WidgetsBinding.instance!.platformDispatcher.platformBrightness,
            // ),

            // theme: ThemeData(
            //   fontFamily: "Lato",
            //   pageTransitionsTheme: PageTransitionsTheme(
            //     builders: {
            //       TargetPlatform.android: CustomPageTransitonBuilder(),
            //       TargetPlatform.iOS: CustomPageTransitonBuilder(),
            //     },
            //   ),
            // ),
            theme: FlexThemeData.light(scheme: FlexScheme.mango).copyWith(
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CustomPageTransitonBuilder(),
                  TargetPlatform.iOS: CustomPageTransitonBuilder(),
                },
              ),
            ),

            darkTheme: FlexThemeData.dark(
              scheme: FlexScheme.sakura,
              fontFamily: "Lato",
            ),
            home: value.isAuthorized
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: value.tryAutoLogin(),
                    builder: (context, dataSnapShot) {
                      if (dataSnapShot.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      } else {
                        return AuthScreen();
                      }
                    },
                  ),
            routes: {
              AuthScreen.routeName: (ctx) => AuthScreen(),
              ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              ManageProductsScreen.routeName: (ctx) => ManageProductsScreen(),
              ProductEditScreen.routeName: (ctx) => ProductEditScreen(),
            },
            // initialRoute: ProductOverviewScreen.routeName,
          );
        }),
      ),
    );
  }
}
