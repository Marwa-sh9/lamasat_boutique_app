import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Basic/constants/app_strings.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _userFavorites {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");
    return _firestore
        .collection(AppStrings.usersCollection)
        .doc(user.uid)
        .collection('favorites');
  }

  Future<List<String>> getFavoriteProductIds() async {
    try {
      final snapshot = await _userFavorites.get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint("Error fetching favorite IDs: $e");
      return [];
    }
  }

  Future<bool> isProductInFavorites(String productId) async {
    final doc = await _userFavorites.doc(productId).get();
    return doc.exists;
  }

  Future<void> addToFavorites(String productId) async {
    await _userFavorites.doc(productId).set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromFavorites(String productId) async {
    await _userFavorites.doc(productId).delete();
  }
}