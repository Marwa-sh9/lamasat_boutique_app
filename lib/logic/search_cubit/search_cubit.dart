import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SearchState {}
class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchLoaded extends SearchState {
  final List<DocumentSnapshot> results;
  SearchLoaded(this.results);
}
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  void searchProducts(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final String lowerCaseQuery = query.toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: lowerCaseQuery)
          .where('name', isLessThan: lowerCaseQuery + 'z')
          .limit(20)
          .get();

      emit(SearchLoaded(snapshot.docs));
    } catch (e) {
      emit(SearchError("حدث خطأ أثناء البحث"));
    }
  }
}