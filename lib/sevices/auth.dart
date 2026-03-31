import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Basic/constants/app_strings.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateUserData(User user, {String? name}) async {
    try {
      const String adminEmail = "marwa333777@hotmail.com";
      final String userEmail = user.email?.toLowerCase() ?? "";

      // 1. تحديد الرتبة
      String role = (userEmail == adminEmail.toLowerCase())
          ? AppStrings.roleAdmin
          : AppStrings.roleUser;

      // --- بداية منطق الدمج الذكي ---
      Map<String, dynamic> additionalData = {};

      // البحث عن أي مستند مسبق (أضافه الأدمن) يمتلك نفس الإيميل
      final existingDocs = await _firestore
          .collection(AppStrings.usersCollection)
          .where('email', isEqualTo: userEmail)
          .get();

      for (var doc in existingDocs.docs) {
        // إذا وجدنا مستنداً بـ ID مختلف عن UID الحالي، نأخذ بياناته (مثل القياسات)
        if (doc.id != user.uid) {
          additionalData = doc.data();
          // حذف المستند القديم (العشوائي) بعد أخذ بياناته لتنظيف Firestore
          await _firestore.collection(AppStrings.usersCollection).doc(doc.id).delete();
          debugPrint("تم العثور على بيانات مسبقة للزبونة وتم دمجها.");
        }
      }
      // --- نهاية منطق الدمج ---

      // 2. تحديث المستند الأساسي (باستخدام UID كـ ID للمستند)
      await _firestore.collection(AppStrings.usersCollection).doc(user.uid).set({
        'Id': user.uid,
        'email': user.email,
        'name': name ?? user.displayName ?? "مستخدم لمسات",
        'role': role,
        'Image': user.photoURL ?? "",
        'username': user.email != null ? user.email!.split('@')[0] : "",
        'lastLogin': FieldValue.serverTimestamp(),
        ...additionalData, // هنا نقوم بدمج القياسات وأي بيانات قديمة وُجدت
      }, SetOptions(merge: true));

      debugPrint("User data updated successfully in Firestore.");
    } catch (e) {
      debugPrint("Error updating user data: $e");
    }
  }

  Future<User?> registerWithEmail(String email, String password, String name) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);

    User? user = result.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      user = _auth.currentUser;
      await _updateUserData(user!, name: name);
    }
    return user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    if (result.user != null) {
      await _updateUserData(result.user!);
    }
    return result.user;
  }


  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? "461298342809-e2rcvpk1q4f088ut5naj2u1e3uli0n0a.apps.googleusercontent.com" : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await _updateUserData(result.user!);
      }
      return result.user;
    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}