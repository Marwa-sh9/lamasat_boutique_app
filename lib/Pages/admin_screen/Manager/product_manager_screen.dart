import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../../Basic/components/app_components.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../sevices/cloudinary_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'add_product_screen.dart';

class ProductManagerScreen extends StatelessWidget {
  const ProductManagerScreen({Key? key}) : super(key: key);

  final List<String> _statuses = const ['جديد ', 'تخفيض ', 'نفذت الكمية '];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(
        titleText: 'إدارة المنتجات',
        showSearchIcon: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد منتجات بعد.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              return _ProductListTile(
                data: productData,
                onTap: () => _showEditDeleteDialog(context, productDoc.id, productData),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProductScreen())),
        backgroundColor: AppBarColor,
        child: Icon(Icons.add, color: TextLargColor),
      ),
    );
  }

  void _showEditDeleteDialog(BuildContext context, String documentId, Map<String, dynamic> initialData) {
    final formKey = GlobalKey<FormState>();

    String name = initialData['name'] ?? '';
    String description = initialData['description'] ?? '';
    String price = initialData['price']?.toString() ?? '';
    String newPrice = initialData['new_price']?.toString() ?? '';
    String quantity = initialData['quantity']?.toString() ?? '';
    String status = initialData['status'] ?? _statuses.first;
    String? categoryId = initialData['category_id'];
    String? currentImageUrl = initialData['image_url'];
    File? imageFile;
    Uint8List? imageBytes;

    String colorsText = (initialData['colors'] as List?)?.join(', ') ?? '';
    String sizesText = (initialData['size'] as List?)?.join(', ') ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {

          Future<void> pickImage() async {
            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (picked != null) {
              if (kIsWeb) {
                final bytes = await picked.readAsBytes();
                setState(() { imageBytes = bytes; currentImageUrl = null; });
              } else {
                setState(() { imageFile = File(picked.path); currentImageUrl = null; });
              }
            }
          }

          return AlertDialog(
            backgroundColor: BackgroundColor,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppBarColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Text(
                'تعديل: $name',
                style: const TextStyle(fontSize: 18, color:TextLargColor), // نص أبيض
                textAlign: TextAlign.center,
              ),
            ),
            titlePadding: EdgeInsets.zero,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ReusableImageWidget(file: imageFile, bytes: imageBytes, url: currentImageUrl, size: 120),
                      const SizedBox(height: 10),
                      ButtonWithText(onPressed: pickImage, label: "تغيير الصورة", color: AppBarColor.withOpacity(0.1), colortext: TextLargColor),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(label: 'اسم المنتج', initialName: name, onSave: (v) => name = v!),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: PrimaryTextFormField(label: 'السعر', initialName: price, keyboardType: TextInputType.number, onSave: (v) => price = v!)),
                          const SizedBox(width: 10),
                          Expanded(child: PrimaryTextFormField(label: 'السعر بعد الخصم', initialName: newPrice, keyboardType: TextInputType.number, onSave: (v) => newPrice = v!)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      PrimaryTextFormField(label: 'الكمية', initialName: quantity, keyboardType: TextInputType.number, onSave: (v) => quantity = v!),
                      const SizedBox(height: 10),
                      PrimaryTextFormField(label: 'الألوان (فاصلة)', initialName: colorsText, onSave: (v) => colorsText = v!),
                      const SizedBox(height: 10),
                      PrimaryTextFormField(label: 'المقاسات (فاصلة)', initialName: sizesText, onSave: (v) => sizesText = v!),
                      const SizedBox(height: 10),
                      PrimaryTextFormField(label: 'الوصف', initialName: description, maxLines: 3, onSave: (v) => description = v!),
                      const SizedBox(height: 15),
                      CategoryDropdown(selectedCategoryId: categoryId, onChanged: (v) => setState(() => categoryId = v)),
                      const SizedBox(height: 20),
                      ButtonWithText(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              _updateProduct(context, documentId, initialData, name, description, price, newPrice, quantity, status, colorsText, sizesText, categoryId, imageFile, imageBytes, currentImageUrl);
                            }
                          },
                          label: "حفظ التغييرات",
                          color: AppBarColor,
                          colortext: TextLargColor
                      ),
                      const SizedBox(height: 10),
                      ButtonWithText(
                          onPressed: () => _deleteProduct(context, documentId, initialData['image_url']),
                          label: "حذف المنتج", color: Colors.red, colortext: TextLargColor
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: const [Closebutton()],
          );
        },
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, String id, String? url) async {
    final confirm = await _showConfirmDialog(context);
    if (confirm) {
      if (url != null) await deleteImageFromCloudinary(url);
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
      Navigator.pop(context);
    }
  }

  Future<void> _updateProduct(BuildContext context, String id, Map initial, String name, String desc, String price, String newPrice, String qty, String status, String colors, String sizes, String? catId, File? file, Uint8List? bytes, String? currentUrl) async {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري التحديث...')));

    try {
      String? finalUrl = currentUrl;
      if (file != null || bytes != null) {
        finalUrl = await uploadImageToCloudinary(context: context, imageFile: file, imageBytes: bytes, resourceType: 'product');
        if (initial['image_url'] != null) await deleteImageFromCloudinary(initial['image_url']);
      }

      await FirebaseFirestore.instance.collection('products').doc(id).update({
        'name': name,
        'description': desc,
        'price': double.tryParse(price) ?? 0.0,
        'new_price': double.tryParse(newPrice),
        'quantity': int.tryParse(qty) ?? 0,
        'colors': colors.split(',').map((e) => e.trim()).toList(),
        'size': sizes.split(',').map((e) => e.trim()).toList(),
        'category_id': catId,
        'image_url': finalUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}

class _ProductListTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ProductListTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ReusableImageWidget(url: data['image_url'], size: 50),
        ),
        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: \$${data['price']} | Qty: ${data['quantity']}'),
        trailing: const Icon(Icons.edit_note, color: TextLargColor),
      ),
    );
  }
}