import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../logic/product_cubit/product_cubit.dart';
import '../../logic/product_cubit/product_state.dart';
import '../../Basic/appbar/appbar.dart';
import 'product_details.dart';

class MyProducts extends StatelessWidget {
  final String? categoryId;
  final bool showAppBar;
  final String titleText;

  const MyProducts({
    super.key,
    this.categoryId,
    this.showAppBar = true,
    required this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    context.read<ProductCubit>().getProductsByCategory(categoryId);

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: showAppBar ? MyAppBar(titleText: titleText, showSearchIcon: false) : null,
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is ProductLoaded) {
            final products = state.products;
            return GridView.builder(
              itemCount: products.length,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final productDoc = products[index];
                return SingleProductWidget(
                  productData: productDoc.data() as Map<String, dynamic>,
                  documentId: productDoc.id,
                  index: index,
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class SingleProductWidget extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String documentId;
  final int index;

  const SingleProductWidget({required this.productData, required this.documentId, required this.index});

  @override
  Widget build(BuildContext context) {
    final name = productData['name'] ?? 'منتج';
    final price = productData['price']?.toString() ?? '0';
    final newPrice = productData['new_price']?.toString();
    final imageUrl = productData['image_url'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProductDetails(
            product_detail_name: name,
            product_detail_new_price: double.tryParse(newPrice ?? price),
            product_detail_old_price: double.tryParse(price),
            product_detail_picture: imageUrl,
            productId: documentId,
            categoryId: productData['category_id'],
          ),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : const Icon(Icons.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  Text("\$$price", style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}