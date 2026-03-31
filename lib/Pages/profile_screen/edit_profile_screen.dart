import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Basic/appbar/appbar.dart';
import '../../Basic/components/app_components.dart';
import '../../Basic/constants/app_strings.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phone1Controller;
  late TextEditingController _phone2Controller;
  late TextEditingController _addressController;

  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.displayName ?? "");
    _phone1Controller = TextEditingController();
    _phone2Controller = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .doc(user?.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _phone1Controller.text = data?['phone1'] ?? "";
          _phone2Controller.text = data?['phone2'] ?? "";
          _addressController.text = data?['address'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      await user?.updateDisplayName(_nameController.text);
      await FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .doc(user?.uid)
          .update({
        'name': _nameController.text,
        'phone1': _phone1Controller.text,
        'phone2': _phone2Controller.text,
        'address': _addressController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث بيانات ملفك الشخصي بنجاح"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في التحديث: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(titleText: "تعديل الملف الشخصي", showSearchIcon: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildAvatarSection(),

              const SizedBox(height: 30),

              PrimaryTextFormField(
                label: "الاسم الكامل",
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                onSave: (val) {},
                onValidate: (val) => (val == null || val.isEmpty) ? "هذا الحقل مطلوب" : null,
              ),

              const SizedBox(height: 15),

              PrimaryTextFormField(
                label: "رقم الجوال الأساسي",
                controller: _phone1Controller,
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                onSave: (val) {},
                onValidate: (val) => (val == null || val.isEmpty) ? "هذا الحقل مطلوب" : null,
              ),

              const SizedBox(height: 15),

              PrimaryTextFormField(
                label: "رقم جوال إضافي (اختياري)",
                controller: _phone2Controller,
                prefixIcon: Icons.phone_iphone,
                keyboardType: TextInputType.phone,
                onSave: (val) {},
              ),

              const SizedBox(height: 15),
              PrimaryTextFormField(
                label: "العنوان بالتفصيل",
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                onSave: (val) {},
              ),

              const SizedBox(height: 15),
              PrimaryTextFormField(
                label: "البريد الإلكتروني",
                controller: TextEditingController(text: user?.email),
                prefixIcon: Icons.email_outlined,
                readOnly: true,
                onSave: (val) {},
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isUpdating ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TextLargColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isUpdating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("حفظ التغييرات", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppBarColor,
            backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
            child: (user?.photoURL == null) ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: TextLargColor,
              radius: 18,
              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}