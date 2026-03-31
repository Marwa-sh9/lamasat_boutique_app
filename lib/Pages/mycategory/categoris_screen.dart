import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../Basic/appbar/appbar.dart';
import '../../logic/category_cubit/category_cubit.dart';
import '../../logic/category_cubit/category_state.dart';
import '../Product/products_screen.dart';

class CategoriesViewScreen extends StatelessWidget {
  const CategoriesViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<CategoryCubit>().getCategories();

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(titleText: 'الأقسام'),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }

          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryData = categories[index].data() as Map<String, dynamic>;
                final categoryName = categoryData['name'] ?? 'قسم غير مسمى';
                final imageUrl = categoryData['image_url'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(
                      categoryName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppBarColor),
                    ),
                    leading: _buildCategoryImage(imageUrl),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => MyProducts(
                          titleText: ' $categoryName',
                          categoryId: categories[index].id,
                          showAppBar: true,
                        ),
                      ));
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCategoryImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: AppBarColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.category, color: AppBarColor),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}