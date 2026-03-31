import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/components/app_components.dart';
import '../../../Basic/constants/app_strings.dart';

class MeasurementsScreen extends StatefulWidget {
  final String? targetUserId;
  final String? targetUserName;

  const MeasurementsScreen({super.key, this.targetUserId, this.targetUserName});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _currentUserRole;
  late String currentUid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final Map<String, TextEditingController> _measureControllers = {
    'الصدر': TextEditingController(),
    'الخصر': TextEditingController(),
    'الورك': TextEditingController(),
    'طول_الكتف_للخصر': TextEditingController(),
    'الطول_كامل': TextEditingController(),
    'عرض_الكتف': TextEditingController(),
    'طول_الكم': TextEditingController(),
    'الزند': TextEditingController(),
    'المعصم': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    currentUid = widget.targetUserId ?? FirebaseAuth.instance.currentUser!.uid;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final myId = user.uid;
      var myDoc = await FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .doc(myId)
          .get();

      if (mounted) {
        setState(() {
          _currentUserRole = myDoc.data()?['role'] ?? 'user';
        });
      }

      var doc = await FirebaseFirestore.instance
          .collection(AppStrings.usersCollection)
          .doc(currentUid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? "";
        _phone1Controller.text = data['phone1'] ?? "";
        _phone2Controller.text = data['phone2'] ?? "";
        _addressController.text = data['address'] ?? "";

        if (data['measurements'] != null) {
          Map<String, dynamic> measurements = data['measurements'];
          measurements.forEach((key, value) {
            if (_measureControllers.containsKey(key)) {
              _measureControllers[key]!.text = value.toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("CRITICAL ERROR in MeasurementsScreen: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAllData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // تجهيز خريطة القياسات
      Map<String, String> measurementsToSave = {};
      _measureControllers.forEach((key, controller) {
        measurementsToSave[key] = controller.text;
      });

      try {
        await FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .doc(currentUid)
            .update({
          'name': _nameController.text.trim(),
          'phone1': _phone1Controller.text.trim(),
          'phone2': _phone2Controller.text.trim(),
          'address': _addressController.text.trim(),
          'measurements': measurementsToSave,
        });

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تحديث كافة بيانات الزبونة بنجاح"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فشل التحديث: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _currentUserRole == 'admin';
    String title = isAdmin ? "ملف الزبونة الشامل" : "بياناتي وقياساتي";

    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(titleText: title, showSearchIcon: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(Icons.person_pin_rounded, "المعلومات الشخصية"),
            const SizedBox(height: 10),
            PrimaryTextFormField(
              label: "الاسم الكامل",
              controller: _nameController,
              prefixIcon: Icons.person,
              readOnly: !isAdmin,
              onSave: (String? value) {  },
            ),
            const SizedBox(height: 10),
            PrimaryTextFormField(
              label: "رقم الجوال 1",
              controller: _phone1Controller,
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              readOnly: !isAdmin,
              onSave: (String? value) {  },
            ),
            const SizedBox(height: 10),
            PrimaryTextFormField(
              label: "رقم الجوال 2",
              controller: _phone2Controller,
              prefixIcon: Icons.phone_iphone,
              readOnly: !isAdmin,
              onSave: (String? value) {  },
            ),
            const SizedBox(height: 10),
            PrimaryTextFormField(
              label: "العنوان بالتفصيل",
              controller: _addressController,
              prefixIcon: Icons.location_on,
              readOnly: !isAdmin,
              maxLines: 2,
              onSave: (String? value) {  },
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            _buildSectionTitle(Icons.straighten, "بيانات القياس (cm)"),
            const SizedBox(height: 10),

            ..._measureControllers.entries.map((entry) {
              return _buildMeasureField(
                  entry.key.replaceAll('_', ' '),
                  entry.value,
                  !isAdmin
              );
            }).toList(),

            const SizedBox(height: 30),

            if (isAdmin)
              ElevatedButton.icon(
                onPressed: _saveAllData,
                icon: const Icon(Icons.save_as, color: Colors.white),
                label: const Text("حفظ كافة البيانات", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TextLargColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: TextLargColor, size: 22),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildMeasureField(String label, TextEditingController controller, bool readOnly) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: "cm",
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.check_circle_outline, size: 18, color: readOnly ? Colors.grey : Colors.blueGrey),
        ),
      ),
    );
  }
}