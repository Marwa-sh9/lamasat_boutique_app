import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Basic/appbar/appbar.dart';
import '../../Basic/constants/app_strings.dart';
import '../Favorite/favorite_screen.dart';
import '../admin_screen/Manager/add_product_screen.dart';
import '../admin_screen/Manager/category_manager_screen.dart';
import '../admin_screen/Manager/product_manager_screen.dart';
import '../admin_screen/admin_orders/admin_orders_screen.dart';
import '../admin_screen/measurements_screen/customer_measurements_list.dart';
import '../admin_screen/measurements_screen/measurements_screen.dart';
import '../admin_screen/Manager/users_manager_screen.dart';
import 'edit_profile_screen.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String? role;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // سيستخدم الآن "User" بناءً على تعديلك في AppStrings
        final doc = await FirebaseFirestore.instance
            .collection(AppStrings.usersCollection)
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            // نأخذ الرتبة، وإذا لم تكن موجودة نعتبره مستخدماً عادياً
            role = doc.data()?['role'] ?? AppStrings.roleUser;
          });
        }
      } else {
        // في حال عدم وجود مستخدم مسجل دخول أصلاً
        if (mounted) setState(() => role = AppStrings.roleUser);
      }
    } catch (e) {
      debugPrint("خطأ في جلب بيانات الرتبة: $e");
      // في حال حدوث خطأ (مثل عدم وجود إنترنت)، نوقف التحميل ونعطيه رتبة مستخدم عادي
      if (mounted) {
        setState(() {
          role = AppStrings.roleUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (role == null) {
      return Scaffold(
        backgroundColor: BackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(titleText: "حسابي", showSearchIcon: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(user), // يظهر للجميع
            const SizedBox(height: 20),

            if (role != AppStrings.roleAdmin) ...[
              _accountOption(Icons.straighten, "قياساتي الشخصية", "سجلي قياساتك لتفصيل أدق", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MeasurementsScreen()));
              }),
              _accountOption(Icons.history, "سجل الخياطة والتعديل", "تاريخ القطع التي قمتِ بتعديلها", () {
              }),
            ],

            if (role == AppStrings.roleAdmin) ...[
              _accountOption(Icons.straighten, "قياسات الزبائن", "قياسات الزبائن", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerMeasurementsList()));
              }),
              _accountOption(Icons.analytics_outlined, "إدارة الطلبات", "الطلبات", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersScreen()));
              }),
              // _accountOption(Icons.analytics_outlined, "إحصائيات المبيعات والطلبات", "عرض التقارير المالية والطلبات", () {
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersScreen()));
              // }),
              _accountOption(Icons.admin_panel_settings, "لوحة التحكم السريعة", "إدارة المتجر بالكامل", () {
                _showAdminQuickPanel(context);
              }),
            ],

            const Divider(indent: 20, endIndent: 20),

            _accountOption(Icons.edit_outlined, "تعديل الملف الشخصي", "تغيير الاسم والصورة", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAdminQuickPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Text("إدارة بوتيك لمسات", style: TextStyle(color: TextLargColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickAction(context, Icons.category, "إدارة الأقسام", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagerScreen()));
                  }),
                  _buildQuickAction(context, Icons.inventory_2, "إدارة المنتجات", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagerScreen()));
                  }),
                  _buildQuickAction(context, Icons.people_alt, "إدارة الزبائن", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersManagerScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppBarColor,
            backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
            child: (user?.photoURL == null) ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? "مستخدم لمسات", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppBarColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: TextLargColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, color: TextLargColor, size: 30),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}