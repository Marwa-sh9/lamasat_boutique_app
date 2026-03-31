import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io';
import '../../../Basic/components/app_components.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../../logic/category_cubit/category_cubit.dart';
import '../../../logic/category_cubit/category_state.dart';
import '../../../sevices/cloudinary_constants.dart';


class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<CategoryCubit>().getCategories();

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(
        titleText: 'إدارة الأقسام',
        showSearchIcon: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        backgroundColor: AppBarColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return Center(child: CircularProgressIndicator(color: AppBarColor));
          }

          if (state is CategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () => context.read<CategoryCubit>().getCategories(),
                    child: const Text("إعادة المحاولة"),
                  )
                ],
              ),
            );
          }

          if (state is CategoryLoaded) {
            final categories = state.categories;

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final doc = categories[index];
                final data = doc.data() as Map<String, dynamic>;

                return _CategoryCard(
                  id: doc.id,
                  name: data['name'],
                  imageUrl: data['image_url'],
                  onEdit: () => _showCategoryForm(context, docId: doc.id, initialData: data),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showCategoryForm(BuildContext context, {String? docId, Map<String, dynamic>? initialData}) {
    final formKey = GlobalKey<FormState>();
    String categoryName = initialData?['name'] ?? '';
    File? imageFile;
    Uint8List? imageBytes;
    String? currentUrl = initialData?['image_url'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickImage() async {
            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              if (kIsWeb) {
                final bytes = await pickedFile.readAsBytes();
                setState(() { imageBytes = bytes; currentUrl = null; });
              } else {
                setState(() { imageFile = File(pickedFile.path); currentUrl = null; });
              }
            }
          }

          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            if (currentUrl == null && imageFile == null && imageBytes == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار صورة')));
              return;
            }
            formKey.currentState!.save();
            Navigator.pop(context);

            try {
              String? finalUrl = currentUrl;
              if (imageFile != null || imageBytes != null) {
                finalUrl = await uploadImageToCloudinary(
                  context: context,
                  imageFile: imageFile,
                  imageBytes: imageBytes,
                  resourceType: 'category',
                );
                if (initialData?['image_url'] != null) {
                  await deleteImageFromCloudinary(initialData!['image_url']);
                }
              }

              if (docId == null) {
                await FirebaseFirestore.instance.collection('categories').add({
                  'name': categoryName,
                  'image_url': finalUrl,
                  'created_at': FieldValue.serverTimestamp(),
                });
              } else {
                await FirebaseFirestore.instance.collection('categories').doc(docId).update({
                  'name': categoryName,
                  'image_url': finalUrl,
                  'updated_at': FieldValue.serverTimestamp(),
                });
              }
            } catch (e) {
              debugPrint("Error: $e");
            }
          }

          return AlertDialog(
            backgroundColor: BackgroundColor,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppBarColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Text(
                docId == null ? 'إضافة قسم' : 'تعديل قسم',
                textAlign: TextAlign.center,
                style: const TextStyle(color: TextLargColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            titlePadding: EdgeInsets.zero,

            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReusableImageWidget(file: imageFile, bytes: imageBytes, url: currentUrl, size: 100),
                      const SizedBox(height: 15),
                      ButtonWithText(onPressed: pickImage, label: "اختيار صورة", color: AppBarColor.withOpacity(0.2), colortext:  TextLargColor),
                      const SizedBox(height: 15),
                      PrimaryTextFormField(
                        label: 'اسم القسم',
                        initialName: categoryName,
                        onSave: (v) => categoryName = v!,
                        onValidate: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 20),
                      ButtonWithText(onPressed: submit, label: docId == null ? "إضافة" : "حفظ", color: AppBarColor, colortext: TextLargColor),
                      if (docId != null) ...[
                        const SizedBox(height: 10),
                        ButtonWithText(
                            onPressed: () => _confirmDelete(context, docId, currentUrl),
                            label: "حذف القسم", color: Colors.red, colortext: TextLargColor
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String? url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا القسم؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      if (url != null) await deleteImageFromCloudinary(url);
      await FirebaseFirestore.instance.collection('categories').doc(id).delete();
      Navigator.pop(context);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String id, name;
  final String? imageUrl;
  final VoidCallback onEdit;

  const _CategoryCard({required this.id, required this.name, this.imageUrl, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: ClipOval(child: ReusableImageWidget(url: imageUrl, size: 40)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: IconButton(icon:  Icon(Icons.edit_note, color: TextLargColor), onPressed: onEdit),
      ),
    );
  }
}