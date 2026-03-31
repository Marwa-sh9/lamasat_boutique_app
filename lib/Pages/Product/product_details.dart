import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/components/app_components.dart';
import '../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';
import '../Favorite/favorite_service.dart';
import '../../logic/cart_cubit/cart_cubit.dart';

class ProductDetails extends StatefulWidget {
  final product_detail_name;
  final product_detail_new_price;
  final product_detail_old_price;
  final String? product_detail_picture;
  final String? productId;
  final String? categoryId;

  const ProductDetails({
    super.key,
    this.product_detail_name,
    this.product_detail_new_price,
    this.product_detail_old_price,
    this.product_detail_picture,
    this.productId,
    this.categoryId,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Future<DocumentSnapshot>? _productDetailsFuture;
  final FavoriteService _favoriteService = FavoriteService();

  bool _isFavorite = false;
  String? _selectedColor;
  String? _selectedSize;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _productDetailsFuture = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId!)
          .get();
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.productId != null) {
      final isFav = await _favoriteService.isProductInFavorites(widget.productId!);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (widget.productId == null) return;

    if (_isFavorite) {
      await _favoriteService.removeFromFavorites(widget.productId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإزالة من المفضلة.')),
      );
    } else {
      await _favoriteService.addToFavorites(widget.productId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإضافة إلى المفضلة.')),
      );
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _addToCart() async {
    if (widget.productId == null) return;

    if (_selectedColor == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار اللون والمقاس أولاً!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (int i = 0; i < _selectedQuantity; i++) {
      await context.read<CartCubit>().addToCart(
        widget.productId!,
        _selectedSize!,
        _selectedColor!,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت الإضافة للسلة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
        titleText: widget.product_detail_name,
        isClickableTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return _buildProductContent(context, null);
          }
          return _buildProductContent(
              context, snapshot.data!.data() as Map<String, dynamic>);
        },
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, Map<String, dynamic>? data) {
    final name = data?['name'] ?? widget.product_detail_name;
    final description = data?['description'] ?? "لا يوجد وصف حالياً لهذا المنتج.";
    final status = data?['status'] ?? "غير معروف";
    final stockQuantity = data?['quantity'] as int? ?? 0;
    final colorsList = data?['colors'] as List<dynamic>?;
    final sizesList = data?['size'] as List<dynamic>?;

    final List<String> availableQuantity =
    List<String>.generate(stockQuantity, (i) => (i + 1).toString());

    return ListView(
      children: [
        SizedBox(
          height: 350.0,
          child: GridTile(
            footer: Container(
              color: Colors.white70,
              child: ListTile(
                leading: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "\$${widget.product_detail_old_price}",
                        style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ),
                    Expanded(
                        child: Text(
                          "\$${widget.product_detail_new_price}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: TextLargColor),
                        )),
                  ],
                ),
              ),
            ),
            child: Container(
              color: BackgroundColor,
              child: (widget.product_detail_picture != null &&
                  widget.product_detail_picture!.isNotEmpty)
                  ? Image.network(
                widget.product_detail_picture!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
              )
                  : const Center(
                  child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey)),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: PrimaryDropdownButtonFormField<String>(
                  label: "اللون",
                  value: _selectedColor,
                  items: (colorsList ?? []).map((color) {
                    return DropdownMenuItem(
                      value: color.toString(),
                      child: Text(color.toString(), style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedColor = val;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: PrimaryDropdownButtonFormField<String>(
                  label: "المقاس",
                  value: _selectedSize,
                  items: (sizesList ?? []).map((size) {
                    return DropdownMenuItem(
                      value: size.toString(),
                      child: Text(size.toString(), style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSize = val;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: PrimaryDropdownButtonFormField<String>(
                  label: "الكمية",
                  value: _selectedQuantity.toString(),
                  items: availableQuantity.map((qty) {
                    return DropdownMenuItem(
                      value: qty,
                      child: Text(qty, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedQuantity = int.parse(val!);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: ButtonWithText(
                  onPressed: _addToCart,
                  color: TextLargColor,
                  label: "شراء",
                  colortext: BackgroundColor,
                ),
              ),
              IconButton(
                onPressed: _addToCart,
                icon: Icon(Icons.add_shopping_cart, color: TextLargColor),
              ),
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: TextLargColor,
                ),
              ),
            ],
          ),
        ),
        Divider(color: TextLargColor),
        ListTile(
          title: const Text("تفاصيل المنتج"),
          subtitle: Text(description),
        ),
        Divider(color: TextLargColor),
        _buildInfoRow("اسم المنتج", name),
        _buildInfoRow("حالة المنتج", status),
        _buildInfoRow("الكمية في المخزون", stockQuantity.toString()),
        Divider(color: TextLargColor),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("منتجات مشابهة"),
        ),
        SizedBox(
          height: 200.0,
          child: Similar_protucts(
              currentProductId: widget.productId, categoryId: widget.categoryId),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 5.0, 5.0, 5.0),
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(value),
        ),
      ],
    );
  }
}

class Similar_protucts extends StatelessWidget {
  final String? categoryId;
  final String? currentProductId;

  const Similar_protucts({super.key, this.categoryId, this.currentProductId});

  @override
  Widget build(BuildContext context) {
    if (categoryId == null) {
      return const Center(child: Text("لا توجد منتجات مشابهة."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('category_id', isEqualTo: categoryId)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppBarColor));
        }

        final allDocs = snapshot.data?.docs ?? [];
        final similarProducts = allDocs.where((doc) => doc.id != currentProductId).toList();

        if (similarProducts.isEmpty) {
          return const Center(child: Text('لا توجد منتجات مشابهة.'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: similarProducts.length,
          itemBuilder: (context, index) {
            final productDoc = similarProducts[index];
            final productData = productDoc.data() as Map<String, dynamic>;

            return SizedBox(
              width: 160,
              child: Similar_single_product(
                productData: productData,
                documentId: productDoc.id,
              ),
            );
          },
        );
      },
    );
  }
}

class Similar_single_product extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String documentId;

  const Similar_single_product({
    super.key,
    required this.productData,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final name = productData['name'] ?? 'منتج';
    final price = productData['price']?.toString() ?? '0';
    final newPrice = productData['new_price']?.toString();
    final imageUrl = productData['image_url'];
    final categoryId = productData['category_id'];
    final displayPrice = newPrice ?? price;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ProductDetails(
              product_detail_name: name,
              product_detail_new_price: double.tryParse(displayPrice),
              product_detail_old_price: double.tryParse(price),
              product_detail_picture: imageUrl,
              productId: documentId,
              categoryId: categoryId,
            ))),
        child: GridTile(
          footer: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "\$$displayPrice",
                  style: TextStyle(
                      color: TextLargColor, fontWeight: FontWeight.bold, fontSize: 12.0),
                )
              ],
            ),
          ),
          child: (imageUrl != null && imageUrl.isNotEmpty)
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : const Center(child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey)),
        ),
      ),
    );
  }
}