import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../Basic/appbar/appbar.dart';
import '../../../Basic/components/app_components.dart';
import '../../logic/cart_cubit/cart_cubit.dart';
import '../../logic/cart_cubit/cart_state.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitOrder(List<Map<String, dynamic>> cartItems) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final orderData = {
        'user_name': _nameController.text.trim(),
        'user_phone': _phoneController.text.trim(),
        'user_address': _addressController.text.trim(),
        'items': cartItems,
        'total_price': widget.totalAmount,
        'status': 'قيد الانتظار',
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);
      await context.read<CartCubit>().clearCart();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم الطلب بنجاح', textAlign: TextAlign.center),
        content: const Text('سيقوم فريقنا بالتواصل معك لتأكيد الطلب.', textAlign: TextAlign.center),
        actions: [
          Center(
            child: ButtonWithText(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              label: "العودة للرئيسية",
              color: AppBarColor,
              colortext: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: const MyAppBar(titleText: 'إتمام الطلب'),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          List<Map<String, dynamic>> items = [];
          double total = widget.totalAmount;

          if (state is CartLoaded) {
            items = state.cartProducts;
            total = state.totalAmount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("معلومات الشحن", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  PrimaryTextFormField(
                    label: "الاسم الكامل",
                    controller: _nameController,
                    prefixIcon: Icons.person,
                    onSave: (String? value) {  },
                  ),
                  const SizedBox(height: 15),
                  PrimaryTextFormField(
                    label: "رقم الهاتف",
                    controller: _phoneController,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    onSave: (val) {},
                    onValidate: (val) => (val == null || val.isEmpty) ? "هذا الحقل مطلوب" : null,
                  ),
                  const SizedBox(height: 15),
                  PrimaryTextFormField(
                    label: "العنوان بالتفصيل",
                    controller: _addressController,
                    prefixIcon: Icons.location_on,
                    maxLines: 2,
                    onSave: (val) {},
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  _buildSummaryRow("إجمالي المنتجات:", "${items.length}"),
                  _buildSummaryRow("المبلغ الإجمالي:", "\$${total.toStringAsFixed(2)}"),
                  const Divider(),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ButtonWithText(
                    onPressed: () => _submitOrder(items),
                    label: "تأكيد الطلب الآن",
                    color: TextLargColor,
                    colortext: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextLargColor)),
        ],
      ),
    );
  }
}