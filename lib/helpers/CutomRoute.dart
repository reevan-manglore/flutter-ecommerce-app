import 'package:flutter/material.dart';
import '../Screens/product_detail_screen.dart';

class CustomRoute extends MaterialPageRoute {
  CustomRoute({required WidgetBuilder builder, RouteSettings? setting})
      : super(
          builder: builder,
          settings: setting,
        );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> opacityAnimation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == "/") {
      return child;
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(opacityAnimation),
      child: child,
    );
  }
}

class CustomPageTransitonBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute route,
    BuildContext context,
    Animation<double> opacityAnimation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == "/" ||
        route.settings.name == ProductDetailScreen.routeName) {
      return child;
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1, 0),
        end: Offset.zero,
      ).animate(opacityAnimation),
      child: child,
    );
  }
}
