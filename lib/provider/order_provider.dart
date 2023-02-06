import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  String? _authToken;
  void setAuthToken(String token) {
    _authToken = token;
  }

  String get _uri {
    return "https://shop-app-9b89c-default-rtdb.firebaseio.com/orders.json?auth=$_authToken";
  }

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return List.from(_orders);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(_uri);
    final response = await http.get(url);
    final Map<String, dynamic> data = json.decode(response.body);
    List<OrderItem> _tmp = [];
    data.forEach(
      (key, dynamic value) {
        _tmp.add(OrderItem(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map(
                  (cartVal) => CartItem(
                    id: cartVal['id'],
                    title: cartVal['title'],
                    price: cartVal['price'],
                    quantity: cartVal['quantity'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(value['dateTime'])));
      },
    );
    _orders = _tmp;
    notifyListeners();
  }

  int get orderCount {
    return _orders.length;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(_uri);
    final time = DateTime.now().toIso8601String();
    final response = await http.post(
      url,
      body: json.encode(
        {
          "amount": total,
          "dateTime": time,
          "products": cartProducts
              .map((val) => {
                    "id": val.id,
                    "title": val.title,
                    "price": val.price,
                    "quantity": val.quantity
                  })
              .toList()
        },
      ),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
