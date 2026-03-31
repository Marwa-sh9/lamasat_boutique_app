import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Pages/Favorite/favorite_service.dart';
import 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteService _favoriteService = FavoriteService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavoriteCubit() : super(FavoriteInitial());

  Future<void> fetchFavorites() async {
    if (FirebaseAuth.instance.currentUser == null) {
      emit(FavoriteEmpty());
      return;
    }

    emit(FavoriteLoading());
    try {
      final ids = await _favoriteService.getFavoriteProductIds();

      if (ids.isEmpty) {
        emit(FavoriteEmpty());
        return;
      }

      final snapshot = await _firestore
          .collection('products')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      emit(FavoriteLoaded(snapshot.docs));
    } catch (e) {
      emit(FavoriteError("حدث خطأ أثناء تحميل المفضلة"));
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final isFav = await _favoriteService.isProductInFavorites(productId);
      if (isFav) {
        await _favoriteService.removeFromFavorites(productId);
      } else {
        await _favoriteService.addToFavorites(productId);
      }
      fetchFavorites();
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }
}