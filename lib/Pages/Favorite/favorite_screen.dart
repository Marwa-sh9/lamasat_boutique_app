import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../logic/favorite_cubit/favorite_cubit.dart';
import '../../logic/favorite_cubit/favorite_state.dart';
import '../Product/products_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FavoriteCubit>().fetchFavorites();

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(titleText: 'المفضلة'),
      body: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }

          if (state is FavoriteEmpty) {
            return const Center(child: Text('قائمة المفضلة فارغة حالياً.'));
          }

          if (state is FavoriteError) {
            return Center(child: Text(state.message));
          }

          if (state is FavoriteLoaded) {
            final products = state.favoriteProducts;

            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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