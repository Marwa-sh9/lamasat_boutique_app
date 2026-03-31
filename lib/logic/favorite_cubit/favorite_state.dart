import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}
class FavoriteLoading extends FavoriteState {}
class FavoriteLoaded extends FavoriteState {
  final List<QueryDocumentSnapshot> favoriteProducts;
  FavoriteLoaded(this.favoriteProducts);
}
class FavoriteEmpty extends FavoriteState {}
class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}