import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../Basic/appbar/appbar.dart';
import '../../../Basic/constants/app_strings.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  DateTime pageOpenTime = DateTime.now();
  int newOrdersCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startListeningForNewOrders();
  }

  void _startListeningForNewOrders() {
    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'قيد الانتظار')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final orderData = change.doc.data() as Map<String, dynamic>;
          final Timestamp? orderTime = orderData['created_at'] as Timestamp?;

          if (orderTime != null && orderTime.toDate().isAfter(pageOpenTime)) {
            if (mounted) {
              setState(() {
                newOrdersCount++;
              });
              _showOrderNotification(orderData['user_name'] ?? "زبون جديد");
            }
          }
        }
      }
    });
  }

  void _showOrderNotification(String userName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("طلب جديد من: $userName"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "عرض",
          textColor: Colors.white,
          onPressed: () {
            _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            setState(() { newOrdersCount = 0; });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
          titleText: 'إدارة الطلبات الجديدة',
          showSearchIcon: false,
          notificationCount: newOrdersCount
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'قيد الانتظار')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("كل الطلبات تمت معالجتها!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            controller: _scrollController,
            cacheExtent: 1000,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final Timestamp? timestamp = order['created_at'] as Timestamp?;
              final String formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate())
                  : "وقت غير معروف";

              return Card(
                key: ValueKey(orderId),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppBarColor,
                    child: Icon(Icons.new_releases, color: TextLargColor, size: 20),
                  ),
                  title: Text(order['user_name'] ?? "زبون مجهول"),
                  subtitle: Text("طلب جديد • $formattedDate"),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: BackgroundColor.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("الهاتف:", order['user_phone'], Icons.phone),
                          _buildDetailRow("العنوان:", order['user_address'], Icons.location_on),
                          const Divider(),
                          ...((order['items'] as List).map((item) => ListTile(
                            dense: true,
                            title: Text(item['name'] ?? "منتج"),
                            subtitle: Text("المقاس: ${item['size']} | اللون: ${item['color']}"),
                            trailing: Text("x${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ))),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("المجموع الكلي:", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("\$${order['total_price']}", style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _statusButton(context, orderId, "مقبول", Colors.green),
                              _statusButton(context, orderId, "تم الشحن", Colors.blue),
                              _statusButton(context, orderId, "ملغي", Colors.red),
                            ],
                          )
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

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TextLargColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? "غير متوفر")),
        ],
      ),
    );
  }

  Widget _statusButton(BuildContext context, String orderId, String newStatus, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: () async {
        await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
          'status': newStatus,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("تمت معالجة الطلب بنجاح ($newStatus)"))
        );
      },
      child: Text(newStatus, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}