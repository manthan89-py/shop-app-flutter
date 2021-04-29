import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //       id: 'p2',
    //       title: 'Trousers',
    //       description: 'A nice pair of trousers.',
    //       price: 59.99,
    //       imageUrl:
    //           'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcRMozogWGzEk5WCDK_xfO6-vQRwo100iu60ZtRHjB9YJhwHY7NCodfVbn5W2fC5rfQ1nCqj4lj4_sI&usqp=CAc'),
    //   Product(
    //       id: 'p3',
    //       title: 'Shirt',
    //       description: 'A nice cotton shirt.',
    //       price: 78.99,
    //       imageUrl:
    //           'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcTiQVEesNLIM3yp4JwWf7DKnmGbRlDxHt0GIXVxr8WU-PyBnlQCJWB87U55dCMhHEApePdYcNijpaL_wTBTO-NxiULrfMHC6ijHgpz0-hgThYVouZyKbLlb964&usqp=CAc'),
    //   Product(
    //     id: 'p4',
    //     title: 'Shorts',
    //     description: 'shorts for men',
    //     price: 20.99,
    //     imageUrl:
    //         'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcS2HGCHxNjuSpeF1rMQl2_iiHf9fvG9deFTAA247T-iKMrQ1Q300WiKLTa-A3eYXSawusOq5hvfLnRq-eG8b0rqkJhquYMo11N4XgzBygx0XFRdhkC6Hc7uYCs&usqp=CAc',
    //   ),
  ];
  final String authToken;
  final String userId;
  ProductProvider(this.authToken, this.userId, this._items);
  Product findByID(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-app-ed53e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.price,
            'imageUrl': product.imageUrl,
          }));
      _items[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> fetchandSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ?  'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shop-app-ed53e-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-shop-app-ed53e-default-rtdb.firebaseio.com/usersFavourites/$userId.json?auth=$authToken';
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedproducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedproducts.add(
          Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              isFavourite:favouriteData == null ? false : favouriteData[prodId] ?? false,
              imageUrl: prodData['imageUrl']),
        );
      });
      _items = loadedproducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shop-app-ed53e-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId
        }),
      );
      final newProduct = Product(
        price: product.price,
        description: product.description,
        title: product.title,
        id: json.decode(response.body)['name'], // server generate id
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-app-ed53e-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);

    var existingProduct = _items[existingProductIndex];

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Colud not delete a product');
    }
    existingProduct = null;
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  List<Product> get items {
    notifyListeners();
    return [..._items];
  }

  List<Product> get favitems {
    return _items.where((element) => element.isFavourite).toList();
  }
}
