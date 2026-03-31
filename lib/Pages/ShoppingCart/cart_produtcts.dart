import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../logic/cart_cubit/cart_cubit.dart';

class Cart_products extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onRefresh;

  const Cart_products({
    super.key,
    required this.cartItems,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return const Center(child: Text("سلة المشتريات فارغة"));
    }

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];

        return Dismissible(
          key: Key(item["id"] + item["size"] + item["color"]),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            context.read<CartCubit>().removeItem(item["index"]);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تم حذف المنتج من السلة")),
            );
          },
          child: Single_cart_product(
            cart_product_name: item["name"],
            cart_product_picture: item["picture"],
            cart_product_price: item["price"],
            cart_product_size: item["size"],
            cart_product_color: item["color"],
            cart_product_qty: item["quantity"],
            itemIndex: item["index"],
          ),
        );
      },
    );
  }
}

class Single_cart_product extends StatelessWidget {
  final String? cart_product_name;
  final String? cart_product_picture;
  final dynamic cart_product_price;
  final String? cart_product_color;
  final String? cart_product_size;
  final int cart_product_qty;
  final int itemIndex;

  const Single_cart_product({
    super.key,
    this.cart_product_name,
    this.cart_product_picture,
    this.cart_product_price,
    this.cart_product_color,
    this.cart_product_size,
    required this.cart_product_qty,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 70,
            height: 70,
            child: (cart_product_picture != null && cart_product_picture!.startsWith('http'))
                ? Image.network(cart_product_picture!, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported, size: 40),
          ),
        ),

        title: Text(
          cart_product_name ?? "منتج",
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Size: "),
                Text(cart_product_size ?? "N/A", style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                const Text("Color: "),
                Text(cart_product_color ?? "N/A", style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "\$${cart_product_price}",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: TextLargColor,
              ),
            ),
          ],
        ),

        trailing: SizedBox(
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    context.read<CartCubit>().plusQuantity(itemIndex);
                  },
                  icon: const Icon(Icons.arrow_drop_up, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Text("$cart_product_qty", style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    context.read<CartCubit>().minusQuantity(itemIndex);
                  },
                  icon: const Icon(Icons.arrow_drop_down, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}