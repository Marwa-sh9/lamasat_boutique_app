import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<QueryDocumentSnapshot> products;
  ProductLoaded(this.products);
}

class ProductCategoriesLoaded extends ProductState {
  final List<QueryDocumentSnapshot> categories;
  ProductCategoriesLoaded(this.categories);
}

class ProductSuccess extends ProductState {}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}