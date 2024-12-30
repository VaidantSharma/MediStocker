import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../UserWidget/bottom_navigation_bar.dart';
import '../util/constant.dart';

class NotificationScreen extends StatefulWidget {
  static String id = "notification_screen";

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final databaseRef = FirebaseDatabase.instance.ref().child('medicine');
  List<Map<String, dynamic>> lowStockMedicines = [];
  static int num = nameNavigation.indexOf(NotificationScreen.id);

  @override
  void initState() {
    super.initState();
    _fetchLowStockMedicines();
  }

  void _fetchLowStockMedicines() async {
    DataSnapshot snapshot = await databaseRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> medicines = snapshot.value as Map<dynamic, dynamic>;
      lowStockMedicines = medicines.entries
          .where((entry) => entry.value < 80)
          .map((entry) => {'name': entry.key, 'stock': entry.value})
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PersistentBottomNavBar(
        selectedIndex: num,
        onItemTapped: (int value) {
          Navigator.popAndPushNamed(context, nameNavigation[value]);
        },
      ),
      appBar: AppBar(
        title: Text('Low Stock Notifications'),
      ),
      body: lowStockMedicines.isEmpty
          ? Center(
        child: Text(
          'No low stock medicines.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: lowStockMedicines.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(lowStockMedicines[index]['name']),
            subtitle: Text('Low stock: ${lowStockMedicines[index]['stock']} remaining'),
            trailing: Icon(Icons.warning, color: Colors.red),
          );
        },
      ),
    );
  }
}