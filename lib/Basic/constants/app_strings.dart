import 'package:flutter/painting.dart';


const Color AppBarColor = Color(0xFFFDD6C1);
const Color TextLargColor = Color(0xFFDF1C55);
const Color BackgroundColor = Color(0xFFF7ECE5);
const Color BeigeFantasy = Color(0xFFF7D8C7);


class AppStrings {
  // Firestore Collections
  static const String usersCollection = 'User';
  static const String categoriesCollection = 'categories';
  static const String productsCollection = 'products';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Firestore Fields
  static const String fieldEmail = 'email';
  static const String fieldRole = 'role';
  static const String fieldLastLogin = 'lastLogin';
}