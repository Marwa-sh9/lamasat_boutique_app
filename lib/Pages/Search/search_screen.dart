import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../sevices/cloudinary_constants.dart';
import '../Product/product_details.dart';
import '../../logic/search_cubit/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: AppBar(
        backgroundColor: AppBarColor,
        elevation: 0,
        title: SizedBox(
          height: 40,
          child: TextField(
            autofocus: true,
            style: TextStyle(color: TextLargColor),
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج...',
              hintStyle: TextStyle(color: TextLargColor.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search, color: TextLargColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            onChanged: (value) {
              context.read<SearchCubit>().searchProducts(value);
            },
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return Center(
              child: Text('ابدأ البحث عن منتجاتنا المميزة...',
                  style: TextStyle(color: TextLargColor, fontSize: 16)),
            );
          }

          if (state is SearchLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }

          if (state is SearchError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          if (state is SearchLoaded) {
            if (state.results.isEmpty) {
              return Center(child: Text('لا توجد نتائج مطابقة.',
                  style: TextStyle(color: TextLargColor)));
            }

            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                return _buildResultItem(context, state.results[index]);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'منتج غير مسمى';
    final oldPrice = data['price'];
    final newPrice = data['new_price'];
    final imageUrl = data['image_url'];
    final categoryId = data['category_id'];

    final displayPrice = newPrice ?? oldPrice;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: ListTile(
        leading: ClipOval(
          child: ReusableImageWidget(
            url: imageUrl,
            size: 50,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('السعر: \$${displayPrice.toString()}'),
        trailing: Icon(Icons.arrow_forward_ios, color: AppBarColor, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetails(
                productId: doc.id,
                product_detail_name: name,
                product_detail_new_price: newPrice,
                product_detail_old_price: oldPrice,
                product_detail_picture: imageUrl,
                categoryId: categoryId,
              ),
            ),
          );
        },
      ),
    );
  }
}