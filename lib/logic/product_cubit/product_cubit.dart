import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamasatboutiquemyapp/logic/product_cubit/product_state.dart';
import '../../sevices/cloudinary_constants.dart';

class ProductCubit extends Cubit<ProductState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _productSubscription;

  List<QueryDocumentSnapshot> _categories = [];
  List<QueryDocumentSnapshot> get categories => _categories;

  ProductCubit() : super(ProductInitial());

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs;
      emit(ProductCategoriesLoaded(_categories));
    } catch (e) {
      emit(ProductError("فشل تحميل الأقسام"));
    }
  }

  void getProductsByCategory(String? categoryId) {
    emit(ProductLoading());
    _productSubscription =FirebaseFirestore.instance
        .collection('products')
        .where('category_id', isEqualTo: categoryId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        emit(ProductError("لا توجد منتجات في هذا القسم"));
      } else {
        emit(ProductLoaded(snapshot.docs));
      }
    }, onError: (e) => emit(ProductError("حدث خطأ: $e")));
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }

  Future<void> saveProduct({
    required Map<String, dynamic> productData,
    required dynamic context,
    required bool isWeb,
    dynamic imageFile,
  }) async {
    emit(ProductLoading());

    try {
      final String? imageUrl = await uploadImageToCloudinary(
        context: context,
        imageFile: isWeb ? null : imageFile,
        imageBytes: isWeb ? imageFile : null,
        resourceType: 'product',
      );

      if (imageUrl == null) {
        emit(ProductError("فشل رفع الصورة"));
        return;
      }

      productData['image_url'] = imageUrl;
      productData['created_at'] = FieldValue.serverTimestamp();

      await _firestore.collection('products').add(productData);

      emit(ProductSuccess());
    } catch (e) {
      emit(ProductError("خطأ أثناء الحفظ: $e"));
    }
  }
}