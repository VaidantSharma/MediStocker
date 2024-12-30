import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../UserWidget/bottom_navigation_bar.dart';
import 'package:medstoker/util/constant.dart';

class HomeScreen extends StatefulWidget {
  static String id = "home_screen";

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static int num = nameNavigation.indexOf(HomeScreen.id);
  List<String> medicineNames = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String? userName;
  String? pharmacyName;
  String? location;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchMedicineNames(); // Call this to fetch medicine names
  }

  void fetchUserData() async {
    DataSnapshot snapshot = await _databaseReference.child('users/12345').get(); // Replace '12345' with the actual user ID
    if (snapshot.exists) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        userName = userData['name'];
        pharmacyName = userData['pharmacyName'];
        location = userData['location'];
      });
    }
  }
  void fetchMedicineNames() async {
    DataSnapshot snapshot = await _databaseReference.child('medicineStock').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> medicines = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        medicineNames = medicines.keys.map((key) => key.toString()).toList();
      });
    }
  }


  void saveUserData(String name, String pharmacy, String loc) {
    _databaseReference.child('users/12345').set({
      'name': name,
      'pharmacyName': pharmacy,
      'location': loc,
    });
    setState(() {
      userName = name;
      pharmacyName = pharmacy;
      location = loc;
    });
  }

  // Function to update the stock in Firebase
  void updateStock(String medicine, int salesCount) async {
    final stockRef = _databaseReference.child('medicineStock/$medicine');

    DataSnapshot snapshot = await stockRef.get();

    if (snapshot.exists) {
      int currentStock = snapshot.value as int;
      int newStock = currentStock - salesCount;

      if (newStock >= 0) {
        // Update stock in the Firebase database
        await stockRef.set(newStock);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated stock for $medicine. New stock: $newStock'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Insufficient stock for $medicine'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Medicine $medicine not found in stock'),
        ),
      );
    }
  }

  // Function to show the billing input dialog
  void showBillingDialog() {
    final medicineController = TextEditingController();
    final salesCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Billing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return medicineNames.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  medicineController.text = selection;  // Auto-fill the medicine name when selected
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(labelText: 'Medicine Name'),
                  );
                },
              ),

              TextField(
                controller: salesCountController,
                decoration: InputDecoration(labelText: 'Sales Count'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String medicine = medicineController.text;
                int salesCount = int.tryParse(salesCountController.text) ?? 0;

                if (medicine.isNotEmpty && salesCount > 0) {
                  updateStock(medicine, salesCount);
                }

                Navigator.of(context).pop();
              },
              child: Text('Update Stock'),
            ),
          ],
        );
      },
    );
  }

  // Function to show user details dialog
  void showUserDetailsDialog() {
    final nameController = TextEditingController();
    final pharmacyController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Your Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: pharmacyController,
                decoration: InputDecoration(labelText: 'Pharmacy Name'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                saveUserData(nameController.text, pharmacyController.text, locationController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home Screen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assests/bgImage.jpg",  // Corrected the path
                  height: 200,
                ),
                Text('MediStock', style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)),
                SizedBox(height: 60),

                userName != null
                    ? Text('Welcome, $userName!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                    : ElevatedButton(
                  onPressed: showUserDetailsDialog,
                  child: Text('Enter your details'),
                ),
                SizedBox(height: 8),
                pharmacyName != null
                    ? Text('Pharmacy Name: $pharmacyName', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    : Container(),
                location != null
                    ? Text('Location: $location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                    : Container(),
                const SizedBox(height: 20),
                const Text(
                  'MediStock is a simple, easy-to-use web app that helps pharmacy owners and suppliers manage their supplies better. '
                      'With real-time stock tracking and automatic order updates, it ensures stock replenishment, minimizes shortages, '
                      'and reduces overstock. MediStock makes it easier for pharmacy owners to keep their shelves full, save time, and '
                      'work more smoothly with their suppliers—all in one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showBillingDialog,
        child: Icon(Icons.add_shopping_cart),
        tooltip: 'Billing',
      ),
      bottomNavigationBar: PersistentBottomNavBar(
        selectedIndex: num,
        onItemTapped: (int value) {
          Navigator.popAndPushNamed(context, nameNavigation[value]);
        },
      ),
    );
  }
}
