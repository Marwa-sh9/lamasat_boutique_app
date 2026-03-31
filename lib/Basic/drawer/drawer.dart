import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Pages/ShoppingCart/shopping_cart_screen.dart';
import '../../Pages/admin_screen/Manager/add_product_screen.dart';
import '../../Pages/admin_screen/Manager/category_manager_screen.dart';
import '../../Pages/admin_screen/Manager/product_manager_screen.dart';
import '../../Pages/admin_screen/admin_orders/admin_orders_screen.dart';
import '../../Pages/admin_screen/Manager/users_manager_screen.dart';
import '../../Pages/login/login_screen.dart';
import '../../Pages/my_home/home_screen.dart';
import '../../Pages/profile_screen/my_account_screen.dart';
import '../../Pages/settings_screen/settings_screen.dart';
import '../../sevices/auth.dart';
import '../constants/app_strings.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? role;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  void _checkRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var doc = await FirebaseFirestore.instance.collection('User').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            role = doc.data()?['role'];
            _isLoading = false;
          });
          print("Current User Role: $role");
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: BackgroundColor,
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "مستخدم لمسات", style: TextStyle(color: TextLargColor)),
            accountEmail: Text(user?.email ?? "لا يوجد بريد إلكتروني", style: TextStyle(color: TextLargColor)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: (user?.photoURL != null && !user!.photoURL!.endsWith('/0'))
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: (user?.photoURL == null || user!.photoURL!.endsWith('/0'))
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            decoration: BoxDecoration(color: AppBarColor),
          ),

          _buildMenuItem(Icons.account_circle, "My Account", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen()));
          }),

          _buildMenuItem(Icons.shopping_cart_outlined, "Shopping cart", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingCartScreen()));
          }),
          _buildMenuItem(Icons.settings, "Settings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          const Divider(),
          _buildMenuItem(Icons.logout, "Sign Out", () async {
            await AuthService().signOut();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            }
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? TextLargColor),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }
}