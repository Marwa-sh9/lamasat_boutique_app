import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';
import '../measurements_screen/measurements_screen.dart';

class CustomerMeasurementsList extends StatefulWidget {
  const CustomerMeasurementsList({super.key});

  @override
  State<CustomerMeasurementsList> createState() => _CustomerMeasurementsListState();
}

class _CustomerMeasurementsListState extends State<CustomerMeasurementsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
        titleText: 'سجل قياسات الزبائن',
        showSearchIcon: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا يوجد زبائن مسجلون حالياً"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final String userId = users[index].id;
              final String userName = userData['name'] ?? "مستخدم بدون اسم";
              final String userEmail = userData['email'] ?? "لا يوجد بريد";
              final String userImage = userData['Image'] ?? "";

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: AppBarColor.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppBarColor,
                      backgroundImage: (userImage.isNotEmpty && !userImage.endsWith('/0'))
                          ? NetworkImage(userImage)
                          : null,
                      child: (userImage.isEmpty || userImage.endsWith('/0'))
                          ? Icon(Icons.person, color: TextLargColor)
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(userEmail, style: const TextStyle(fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TextLargColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeasurementsScreen(
                              targetUserId: userId,
                              targetUserName: userName,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "إضافة / تعديل القياسات",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewUserDialog(context),
        label: const Text("إضافة زبونة جديدة"),
        icon: const Icon(Icons.person_add),
        backgroundColor: TextLargColor,
      ),
    );
  }

  Future<void> _addNewUserDialog(BuildContext context) async {
    // كنترولرز المعلومات الشخصية
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    final Map<String, TextEditingController> measureControllers = {
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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          child: const Text("إضافة زبونة جديدة مع القياسات", textAlign: TextAlign.center,
            style: const TextStyle(color: TextLargColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionHeader("المعلومات الأساسية", Icons.person_outline),
                _buildDialogField(nameController, "الاسم الكامل", Icons.person),
                _buildDialogField(emailController, "البريد الإلكتروني", Icons.email, isEmail: true),
                _buildDialogField(phoneController, "رقم الجوال", Icons.phone, isPhone: true),
                _buildDialogField(addressController, "العنوان", Icons.location_on),

                const Divider(height: 30, thickness: 1),

                _buildSectionHeader("قياسات الخياطة (cm)", Icons.straighten),
                const SizedBox(height: 10),
                ...measureControllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: entry.key.replaceAll('_', ' '),
                      suffixText: "cm",
                      prefixIcon: const Icon(Icons.architecture, size: 18),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("يرجى ملء الاسم والإيميل على الأقل")),
                );
                return;
              }

              Map<String, String> measurementsData = {};
              measureControllers.forEach((key, controller) {
                measurementsData[key] = controller.text.isEmpty ? "0" : controller.text;
              });

              try {
                await FirebaseFirestore.instance.collection(AppStrings.usersCollection).add({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim().toLowerCase(),
                  'phone1': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                  'role': 'user',
                  'measurements': measurementsData,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تمت إضافة الزبونة وقياساتها بنجاح"), backgroundColor: Colors.green),
                );
              } catch (e) {
                debugPrint("Error adding user: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TextLargColor),
            child: const Text("إضافة وحفظ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: TextLargColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isPhone = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}