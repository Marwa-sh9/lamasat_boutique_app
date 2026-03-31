import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../logic/cart_cubit/cart_cubit.dart';
import '../../logic/cart_cubit/cart_state.dart';
import 'cart_produtcts.dart';
import 'check_out_screen.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CartCubit>().fetchCart();

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: AppBarColor,
        title: InkWell(
          onTap: () => Navigator.pop(context),
          child: Text(
            "lamasat",
            style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: TextLargColor),
          )
        ],
      ),

      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }

          if (state is CartError) {
            return Center(child: Text(state.message));
          }

          if (state is CartLoaded) {
            if (state.cartProducts.isEmpty) {
              return const Center(child: Text("سلة المشتريات فارغة حالياً."));
            }
            return Cart_products(
              cartItems: state.cartProducts,
              onRefresh: () => context.read<CartCubit>().fetchCart(),
            );
          }

          return const SizedBox();
        },
      ),

      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          double total = 0.0;
          if (state is CartLoaded) {
            total = state.totalAmount;
          }

          return Container(
            color: AppBarColor,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("Total:"),
                    subtitle: Text(
                      "\$${total.toStringAsFixed(2)}",
                      style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: total > 0 ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(totalAmount: total),
                        ),
                      );                    } : null,
                    color: TextLargColor,
                    disabledColor: Colors.grey,
                    child: const Text(
                      "Check out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}