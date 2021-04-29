import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

class CartItem {
  final String id; // this id different form product id
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title,
      @required this.imageUrl});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
          title: existingCartItem.title,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void addItem(String productid, String title, double price, String imageUrl) {
    if (_items.containsKey(productid)) {
      _items.update(
        productid,
        (value) => CartItem(
            id: value.id,
            price: value.price,
            quantity: value.quantity + 1,
            title: value.title,
            imageUrl: value.imageUrl),
      );
    } else {
      _items.putIfAbsent(
        productid,
        () => CartItem(
            id: DateTime.now().toString(),
            price: price,
            quantity: 1,
            title: title,
            imageUrl: imageUrl),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
