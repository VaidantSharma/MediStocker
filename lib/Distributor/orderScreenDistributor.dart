import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderScreenDistributer extends StatefulWidget {
  static String id = "order_screen_distributor";

  const OrderScreenDistributer({super.key});

  @override
  State<OrderScreenDistributer> createState() => _OrderScreenDistributerState();
}

class _OrderScreenDistributerState extends State<OrderScreenDistributer> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      DataSnapshot snapshot = await _databaseReference.child('orders').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> fetchedOrders = [];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            String pharmacyName = value['pharmacy']?['name'] ?? 'Unknown';
            String location = value['pharmacy']?['location'] ?? 'Unknown';

            List<Map<String, dynamic>> medicinesList = [];
            if (value['medicines'] is List<dynamic>) {
              medicinesList = List<Map<String, dynamic>>.from(
                (value['medicines'] as List<dynamic>).map((medicine) {
                  if (medicine is Map<dynamic, dynamic>) {
                    return {
                      'name': medicine['name'] ?? 'Unknown',
                      'quantity': medicine['quantity'] ?? 0,
                    };
                  }
                  return {'name': 'Unknown', 'quantity': 0};
                }),
              );
            }

            fetchedOrders.add({
              'id': key,
              'pharmacyName': pharmacyName,
              'location': location,
              'medicines': medicinesList,
              'status': value['status'] ?? 'Unknown',
            });
          }
        });

        setState(() {
          orders = fetchedOrders;
        });
      } else {
        print("No orders found.");
      }
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }

  void _markOrderAsDelivered(int index) async {
    String orderId = orders[index]['id'];
    await _databaseReference.child('orders/$orderId/status').set('delivered');
    setState(() {
      orders[index]['status'] = 'delivered';
    });
  }

  void _deleteOrder(int index) async {
    String orderId = orders[index]['id'];
    await _databaseReference.child('orders/$orderId').remove();
    setState(() {
      orders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ORDERS RECEIVED"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Orders Pending",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return Container(
                  color: orders[index]['status'] == 'delivered' ? Colors.blue[100] : Colors.transparent,
                  child: ListTile(
                    title: Text("Order"),
                    subtitle: Text("Pharmacy: ${orders[index]['pharmacyName']}"),
                    trailing: Text("Status: ${orders[index]['status']}"),
                    onTap: () {
                      _showOrderDetails(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Order Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location: ${orders[index]['location']}"),
                Text("Pharmacy Name: ${orders[index]['pharmacyName']}"),
                SizedBox(height: 10),
                Text(
                  "Medicines:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...orders[index]['medicines']
                    .map((medicine) => _buildMedicineItem(
                    medicine['name'], medicine['quantity']))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
            if (orders[index]['status'] == 'pending')
              TextButton(
                onPressed: () {
                  _markOrderAsDelivered(index);
                  Navigator.of(context).pop();
                },
                child: Text("Deliver"),
              ),
            if (orders[index]['status'] == 'delivered')
              TextButton(
                onPressed: () {
                  _deleteOrder(index);
                  Navigator.of(context).pop();
                },
                child: Text("Delete"),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMedicineItem(String name, int quantity) {
    return Text("$name x $quantity");
  }
}
