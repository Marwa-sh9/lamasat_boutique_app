import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  CategoryCubit() : super(CategoryLoading());

  Stream<QuerySnapshot> get categoriesStream =>
      FirebaseFirestore.instance.collection('categories').snapshots();

  void getCategories() {
    emit(CategoryLoading());
    _subscription?.cancel();
    _subscription = _firestore
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        emit(CategoryError("لا توجد أقسام حالياً"));
      } else {
        emit(CategoryLoaded(snapshot.docs));
      }
    }, onError: (error) {
      emit(CategoryError("حدث خطأ في جلب البيانات"));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}