import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItemModel {
  final String productId;
  final int quantity;
  final String size;
  final String color;

  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'],
      quantity: map['quantity'],
      size: map['size'],
      color: map['color'],
    );
  }
}

class CartService {
  static const String _cartKey = 'cartItems';

  Future<List<CartItemModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cartJson = prefs.getStringList(_cartKey);
    if (cartJson == null) return [];

    return cartJson
        .map((item) => CartItemModel.fromMap(json.decode(item)))
        .toList();
  }

  Future<void> addToCart(String productId, String size, String color) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CartItemModel> items = await getCartItems();

    int index = items.indexWhere((item) =>
    item.productId == productId && item.size == size && item.color == color);

    if (index != -1) {
      items[index] = CartItemModel(
        productId: productId,
        quantity: items[index].quantity + 1,
        size: size,
        color: color,
      );
    } else {
      items.add(CartItemModel(
        productId: productId,
        quantity: 1,
        size: size,
        color: color,
      ));
    }

    final List<String> cartJson = items.map((item) => json.encode(item.toMap())).toList();
    await prefs.setStringList(_cartKey, cartJson);
  }

  Future<void> removeFromCart(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getCartItems();
    if (index < items.length) {
      items.removeAt(index);
      final List<String> cartJson = items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_cartKey, cartJson);
    }
  }
  Future<void> incrementQuantity(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getCartItems();

    if (index < items.length) {
      items[index] = CartItemModel(
        productId: items[index].productId,
        quantity: items[index].quantity + 1,
        size: items[index].size,
        color: items[index].color,
      );
      final List<String> cartJson = items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_cartKey, cartJson);
    }
  }

  Future<void> decrementQuantity(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getCartItems();

    if (index < items.length && items[index].quantity > 1) {
      items[index] = CartItemModel(
        productId: items[index].productId,
        quantity: items[index].quantity - 1,
        size: items[index].size,
        color: items[index].color,
      );
      final List<String> cartJson = items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList(_cartKey, cartJson);
    }
  }

  Future<void> clearAllCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
  }
}