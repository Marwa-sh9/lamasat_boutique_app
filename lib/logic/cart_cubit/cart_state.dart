abstract class CartState {}

class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartProducts;
  final double totalAmount;
  CartLoaded(this.cartProducts, this.totalAmount);
}
class CartError extends CartState {
  final String message;
  CartError(this.message);
}