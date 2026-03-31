import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Basic/constants/app_strings.dart';
import '../../sevices/auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthInitial());

  Future<String> _getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection(AppStrings.usersCollection)
        .doc(uid)
        .get();
    return doc.data()?[AppStrings.fieldRole] ?? AppStrings.roleUser;
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        String role = await _getUserRole(user.uid);
        emit(AuthAuthenticated(role: role));
      }
    } catch (e) {
      emit(AuthError("فشل تسجيل الدخول"));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        String role = await _getUserRole(user.uid);
        emit(AuthAuthenticated(role: role));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError("فشل الاتصال بجوجل"));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerWithEmail(email, password, name);
      if (user != null) {
        String role = await _getUserRole(user.uid);
        emit(AuthAuthenticated(role: role));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "حدث خطأ ما"));
    } catch (e) {
      emit(AuthError("حدث خطأ غير متوقع"));
    }
  }

  void logout() async {
    await _authService.signOut();
    emit(AuthInitial());
  }
}