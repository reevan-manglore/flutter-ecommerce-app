import 'package:flutter/cupertino.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _itms = {};

  Map<String, CartItem> get itms {
    return Map.from(_itms);
  }

  int get itemCount {
    return _itms.length;
  }

  int getItemCountById(String id) {
    if (_itms.containsKey(id)) {
      return _itms[id]!.quantity;
    } else {
      return 0;
    }
  }

  void addItem(String prodcutId, String title, double price) {
    if (_itms.containsKey(prodcutId)) {
      _itms.update(
          prodcutId,
          (prevValue) => CartItem(
              id: prevValue.id,
              title: prevValue.title,
              price: prevValue.price,
              quantity: prevValue.quantity + 1));
    } else {
      _itms.putIfAbsent(
        prodcutId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            price: price,
            quantity: 1),
      );
    }

    notifyListeners();
  }

  void removeItm(String id) {
    _itms.removeWhere((_, value) => value.id == id);
    notifyListeners();
  }

  void removeSingleItm(String id) {
    if (_itms.containsKey(id)) {
      if (_itms[id]!.quantity <= 1) {
        _itms.remove(id);
      } else {
        _itms.update(
          id,
          (prev) => CartItem(
              id: prev.id,
              title: prev.title,
              price: prev.price,
              quantity: prev.quantity - 1),
        );
      }
    }
    notifyListeners();
  }

  double get totalAmount {
    double totalAmt = 0.0;
    _itms.forEach((_, value) {
      totalAmt += value.price * value.quantity;
    });
    return totalAmt.truncateToDouble();
  }

  void clearCart() {
    _itms.clear();
    notifyListeners();
  }
}
