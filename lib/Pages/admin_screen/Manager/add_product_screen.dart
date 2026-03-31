import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/components/app_components.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../../logic/product_cubit/product_cubit.dart';
import '../../../logic/product_cubit/product_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _productName, _description, _status, _selectedCategoryId, _sizes, _colors;
  double? _price, _newPrice;
  int? _quantity;
  File? _imageFile;
  Uint8List? _imageBytes;

  final List<String> _statuses = ['جديد ', 'تخفيض ', 'موجود ', 'نفذت الكمية'];

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchCategories();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
        });
      }
    }
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للمنتج')),
      );
      return;
    }

    _formKey.currentState!.save();

    final productData = {
      'name': _productName,
      'description': _description,
      'price': _price,
      'new_price': _newPrice ?? _price,
      'quantity': _quantity,
      'status': _status,
      'category_id': _selectedCategoryId,
      'size': _sizes?.split(',').map((e) => e.trim()).toList(),
      'colors': _colors?.split(',').map((e) => e.trim()).toList(),
    };

    context.read<ProductCubit>().saveProduct(
      productData: productData,
      context: context,
      imageFile: kIsWeb ? _imageBytes : _imageFile,
      isWeb: kIsWeb,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(
        titleText: 'إضافة منتج جديد',
        showSearchIcon: false,
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ المنتج بنجاح!')),
            );
            Navigator.pop(context);
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          List<QueryDocumentSnapshot> categories = [];
          if (state is ProductCategoriesLoaded) {
            categories = state.categories;
          }

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(10.0),
                  children: <Widget>[
                    Center(
                      child: _imageFile != null || _imageBytes != null
                          ? Image(
                        image: kIsWeb
                            ? MemoryImage(_imageBytes!)
                            : FileImage(_imageFile!) as ImageProvider,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image_search, size: 100, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    ButtonWithText(
                      onPressed: _pickImage,
                      color: AppBarColor.withOpacity(0.8),
                      label: _imageFile != null || _imageBytes != null
                          ? "تغيير صورة المنتج"
                          : "اختيار صورة المنتج",
                      colortext: TextLargColor,
                      icon: Icons.upload_file,
                    ),
                    const SizedBox(height: 20),

                    PrimaryTextFormField(
                      label: "اسم المنتج",
                      onValidate: (value) =>
                      value!.isEmpty ? 'الرجاء ادخال اسم المنتج' : null,
                      onSave: (value) => _productName = value,
                    ),
                    const SizedBox(height: 10),

                    PrimaryTextFormField(
                      label: 'السعر الأصلي (\$)',
                      keyboardType: TextInputType.number,
                      onValidate: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال السعر' : null,
                      onSave: (value) => _price = double.tryParse(value!),
                    ),
                    const SizedBox(height: 10),
                    PrimaryTextFormField(
                      label: 'السعر الجديد (اختياري)',
                      keyboardType: TextInputType.number,
                      onSave: (value) =>
                      _newPrice = double.tryParse(value!) ?? _price,
                    ),
                    const SizedBox(height: 10),
                    PrimaryTextFormField(
                      label: 'تفاصيل المنتج',
                      maxLines: 3,
                      onSave: (value) => _description = value,
                    ),
                    const SizedBox(height: 10),
                    PrimaryTextFormField(
                      label: 'الكمية المتوفرة',
                      keyboardType: TextInputType.number,
                      onValidate: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الكمية' : null,
                      onSave: (value) => _quantity = int.tryParse(value!),
                    ),
                    const SizedBox(height: 10),
                    PrimaryTextFormField(
                      label: 'الألوان المتوفرة (افصل بينها بفاصلة)',
                      onSave: (value) => _colors = value,
                    ),
                    const SizedBox(height: 10),
                    PrimaryTextFormField(
                      label: 'المقاسات المتوفرة (افصل بينها بفاصلة)',
                      onSave: (value) => _sizes = value,
                    ),
                    const SizedBox(height: 10),
                    PrimaryDropdownButtonFormField<String>(
                      label: 'حالة المنتج',
                      value: _status,
                      items: _statuses.map((status) {
                        return DropdownMenuItem<String>(
                            value: status, child: Text(status));
                      }).toList(),
                      validator: (value) =>
                      value == null ? 'الرجاء اختيار حالة المنتج' : null,
                      onChanged: (value) => setState(() => _status = value),
                      onSaved: (value) => _status = value,
                    ),
                    const SizedBox(height: 10),
                    PrimaryDropdownButtonFormField<String>(
                      label: 'القسم التابع له المنتج',
                      value: _selectedCategoryId,
                      items: categories.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(doc['name'] ?? 'قسم غير مسمى'),
                        );
                      }).toList(),
                      validator: (value) =>
                      value == null ? 'الرجاء اختيار قسم' : null,
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                      onSaved: (value) => _selectedCategoryId = value,
                    ),

                    const SizedBox(height: 20),

                    ButtonWithText(
                      onPressed: state is ProductLoading ? null : _onSavePressed,
                      color: AppBarColor,
                      label: state is ProductLoading ? "جاري الحفظ..." : "إضافة المنتج",
                      colortext: TextLargColor,
                    ),
                  ],
                ),
              ),

              if (state is ProductLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}