import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../exceptions/http_exception.dart';

class Product with ChangeNotifier {
  String? _authToken = "";
  String? _userId = "";
  void setAuthToken(String token) {
    _authToken = token;
  }

  void setUserId(String id) {
    _userId = id;
  }

  String get _uri {
    return "https://shop-app-9b89c-default-rtdb.firebaseio.com/userFaviourites/$_userId/${id}.json?auth=$_authToken";
  }

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
  Future<void> toggleFaviorite() async {
    final url = Uri.parse(
      _uri,
    );
    final tempVal = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        throw HttpException("Updation faviourite status failed");
      }
    } catch (_) {
      isFavorite = tempVal;
      notifyListeners();
      throw HttpException("Updating faviourite  status failed");
    }
  }
}
