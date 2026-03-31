import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Basic/appbar/appbar.dart';
import '../../Basic/constants/app_strings.dart';
import '../../sevices/auth.dart';
import '../About/about_screen.dart';
import '../profile_screen/edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
          titleText: "الإعدادات",
          showSearchIcon: false,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("الحساب"),
          _settingTile(Icons.person_outline, "تعديل الملف الشخصي", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }),
          _settingTile(Icons.lock_reset, "تغيير كلمة المرور", () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && user.email != null) {
              AuthService().sendPasswordResetEmail(user.email!);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم إرسال رابط إعادة تعيين كلمة المرور إلى ${user.email}"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }),

          const Divider(),
          _buildSectionTitle("التطبيق"),
        _settingTile(Icons.notifications_none, "التنبيهات", () {
          showModalBottomSheet(
            context: context,
            backgroundColor: BackgroundColor,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text("عروض لمسات الجديدة"),
                  value: true,
                  onChanged: (val) {},
                  activeColor: TextLargColor,
                ),
              ],
            ),
          );
        }),
          _settingTile(Icons.language, "اللغة", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("التطبيق متاح حالياً باللغة العربية فقط")),
            );
          }),
          const Divider(),
          _buildSectionTitle("عن البوتيك"),
          _settingTile(Icons.info_outline, "من نحن", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const About()));

          }),
          _settingTile(Icons.policy_outlined, "سياسة الخصوصية", () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: BackgroundColor,
                title: const Text("سياسة الخصوصية"),
                content: const Text("نحن في بوتيك لمسات نحترم خصوصيتك. بياناتك تُستخدم فقط لمعالجة طلبات الفساتين وضمان أفضل خدمة خياطة وتفصيل لكِ."),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context),
                      child: const Text("حسناً"))
                ],
              ),
            );
          }),        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: TextLargColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}