import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lamasatboutiquemyapp/Pages/Product/products_screen.dart';
import '../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../Basic/drawer/drawer.dart';
import '../../Basic/navbar/navbar.dart';
import 'horizontalList.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  int newOrdersCount = 0;
  @override
  void initState() {
    super.initState();
    _startListeningToOrders();
  }
  void _startListeningToOrders() {
    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'قيد الانتظار')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          newOrdersCount = snapshot.docs.length;
        });
      }
    });
  }
  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar:  MyAppBar(
        titleText: 'lamasat boutique',
        notificationCount: newOrdersCount,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              alignment: Alignment.centerRight,
              child: const Text(
                "الأقسام",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),

          HorizontalList(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              alignment: Alignment.centerRight,
              child: const Text(
                "آخر الصور",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              ),
            ),
          ),

          Flexible(
            child: MyProducts(
              titleText: '',
              showAppBar: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyNavBar(),
    );
  }
}
