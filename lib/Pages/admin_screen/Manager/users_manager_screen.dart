import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';

class UsersManagerScreen extends StatefulWidget {
  const UsersManagerScreen({super.key});

  @override
  State<UsersManagerScreen> createState() => _UsersManagerScreenState();
}

class _UsersManagerScreenState extends State<UsersManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
        titleText: 'إدارة المستخدمين والصلاحيات',
        showSearchIcon: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(AppStrings.usersCollection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("لا يوجد مستخدمون مسجلون بعد", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final String currentRole = userData['role'] ?? 'user';
              final String userName = userData['name'] ?? "مستخدم بدون اسم";
              final String userEmail = userData['email'] ?? "لا يوجد بريد";
              final String userImage = userData['Image'] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppBarColor,
                    backgroundImage: (userImage.isNotEmpty && !userImage.endsWith('/0'))
                        ? NetworkImage(userImage)
                        : null,
                    child: (userImage.isEmpty || userImage.endsWith('/0'))
                        ? Icon(Icons.person, color: TextLargColor)
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text("الرتبة: ${currentRole == 'admin' ? 'أدمن' : 'مستخدم عادي'}"),
                  trailing: (userEmail.toLowerCase() == "marwa333777@hotmail.com")
                      ? const Icon(Icons.verified, color: TextLargColor)
                      : IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _deleteUser(userId, userName),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: BackgroundColor.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      child: Column(
                        children: [
                          _buildUserDetailRow("البريد الإلكتروني:", userEmail, Icons.email_outlined),
                          _buildUserDetailRow("رقم الجوال 1:", userData['phone1'] ?? "غير مسجل", Icons.phone_android),
                          _buildUserDetailRow("رقم الجوال 2:", userData['phone2'] ?? "غير مسجل", Icons.phone_iphone),
                          _buildUserDetailRow("العنوان:", userData['address'] ?? "غير مسجل", Icons.location_on_outlined),

                          const SizedBox(height: 20),
                          const Text("صلاحية الوصول", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _roleButton(context, userId, "user", "مستخدم عادي", Colors.blue, currentRole),
                              _roleButton(context, userId, "admin", "أدمن (مدير)", Colors.red, currentRole),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TextLargColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId, String userName) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BackgroundColor,
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنتِ متأكدة من حذف المستخدم '$userName'؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("حذف الآن", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection(AppStrings.usersCollection).doc(userId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حذف المستخدم بنجاح"), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _roleButton(BuildContext context, String userId, String targetRole, String label, Color color, String currentRole) {
    bool isSelected = currentRole == targetRole;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isSelected ? null : () async {
        await FirebaseFirestore.instance.collection(AppStrings.usersCollection).doc(userId).update({'role': targetRole});
      },
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}