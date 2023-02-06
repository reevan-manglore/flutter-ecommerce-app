import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'product.dart';

import '../exceptions/http_exception.dart';

class ProductProvider with ChangeNotifier {
  String? _authToken;
  String _userId = "";
  void setAuthToken(String token) {
    _authToken = token;
    _items.forEach(
      //whenever token of ProductProvider updates update coresponding token of  product items
      (element) {
        element.setAuthToken(token);
      },
    );
  }

  void setUserId(String id) {
    _userId = id;
    items.forEach(
      //whenever userId of ProductProvider updates update coresponding usedId of  product items
      (element) {
        element.setUserId(_userId);
      },
    );
  }

  String get _productListUri {
    return "https://shop-app-9b89c-default-rtdb.firebaseio.com/products.json?auth=$_authToken";
  }

  String get _faviouriteStatusUri {
    return "https://shop-app-9b89c-default-rtdb.firebaseio.com/userFaviourites/$_userId.json?auth=$_authToken";
  }

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  Future<void> fetchAndSetProducts() async {
    if (_items.length > 0) {
      return;
    }
    final prodcutsListUrl = Uri.parse(_productListUri);
    final faviouriteStatusUrl = Uri.parse(_faviouriteStatusUri);

    final response = await Future.wait([
      http.get(prodcutsListUrl),
      http.get(faviouriteStatusUrl),
    ]);
    Map<String, dynamic>? _resposeProductItems = json.decode(response[0].body);
    Map<String, dynamic> _responseFaviouriteStatus =
        json.decode(response[1].body) ?? {};
    List<Product> tempList = [];
    if (_resposeProductItems != null) {
      _resposeProductItems.forEach(
        (key, value) {
          tempList.add(
            Product(
              id: key,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavorite: _responseFaviouriteStatus[key] ?? false,
            ),
          );
        },
      );
      _items = tempList;
      _items.forEach(
        //once new set of items are fetched and set set their coresponding product auth token and userId
        (element) {
          element.setAuthToken(_authToken ?? "");
          element.setUserId(_userId);
        },
      );

      notifyListeners();
    }
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product val) async {
    final url = Uri.parse(_productListUri);
    final response = await http.post(
      url,
      body: json.encode({
        'title': val.title,
        'description': val.description,
        'price': val.price,
        'imageUrl': val.imageUrl,
        'isFavorite': val.isFavorite,
      }),
    );

    final productToBeSaved = Product(
      id: json.decode(response.body)['name'],
      title: val.title,
      description: val.description,
      price: val.price,
      imageUrl: val.imageUrl,
    );
    _items.add(productToBeSaved);
    notifyListeners();
  }

  Future<void> modifyProduct(String id, Product product) async {
    final url = Uri.parse(
      "https://shop-app-9b89c-default-rtdb.firebaseio.com/products/${id}.json",
    );
    await http.patch(
      url,
      body: json.encode(
        {
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite,
        },
      ),
    );
    final productId = _items.indexWhere((element) => element.id == id);
    _items[productId] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((element) => element.id == id);
    Product? _deletedProduct = _items[index];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final url = Uri.parse(
      "https://shop-app-9b89c-default-rtdb.firebaseio.com/products/${id}.json",
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException("Product insertion failed");
      }
    } catch (e) {
      _items.insert(index, _deletedProduct);
      notifyListeners();
      throw HttpException(e.toString());
    }
    _deletedProduct = null;
  }
}
