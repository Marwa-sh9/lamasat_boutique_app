import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Pages/ShoppingCart/cart_service.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartService _cartService = CartService();

  CartCubit() : super(CartInitial());

  Future<void> fetchCart() async {
    emit(CartLoading());
    try {
      final localItems = await _cartService.getCartItems();
      if (localItems.isEmpty) {
        emit(CartLoaded([], 0.0));
        return;
      }

      double tempTotal = 0.0;
      List<Map<String, dynamic>> tempProducts = [];

      for (var item in localItems) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('products')
            .doc(item.productId)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          double price = double.parse(data['price'].toString());
          tempTotal += price * item.quantity;

          tempProducts.add({
            "id": item.productId,
            "name": data['name'],
            "picture": data['image_url'] ?? '',
            "price": price,
            "size": item.size,
            "color": item.color,
            "quantity": item.quantity,
            "index": localItems.indexOf(item),
          });
        }
      }
      emit(CartLoaded(tempProducts, tempTotal));
    } catch (e) {
      emit(CartError("فشل تحميل السلة"));
    }
  }
  Future<void> plusQuantity(int index) async {
    await _cartService.incrementQuantity(index);
    await fetchCart();
  }
  Future<void> addToCart(String productId, String size, String color) async {
    try {
      await _cartService.addToCart(productId, size, color);
      await fetchCart();
    } catch (e) {
      emit(CartError("فشل في إضافة المنتج للسلة"));
    }
  }
  Future<void> clearCart() async {
    try {
      await _cartService.clearAllCart();
      emit(CartLoaded([], 0.0));
    } catch (e) {
      emit(CartError("لم نتمكن من تفريغ السلة"));
    }
  }
  Future<void> minusQuantity(int index) async {
    await _cartService.decrementQuantity(index);
    await fetchCart();
  }
  Future<void> removeItem(int index) async {
    await _cartService.removeFromCart(index);
    fetchCart();
  }
}