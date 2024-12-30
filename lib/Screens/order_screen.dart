import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderScreen extends StatefulWidget {
  static String id = "order_screen";

  // Accept the cheapest distributor as a parameter
  final String? cheapestDistributor;

  const OrderScreen({super.key, this.cheapestDistributor});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String? selectedDistributor;
  List<Map<String, dynamic>> selectedMedicines = []; // Initialize an empty list

  List<String> distributors = [];
  Map<String, Map<String, dynamic>> distributorData = {};
  List<String> medicines = [];
  Map<String, int> lowStockMedicines = {};

  @override
  void initState() {
    super.initState();
    fetchDistributorsData();
    fetchLowStockMedicines();
  }

  void fetchDistributorsData() async {
    DataSnapshot snapshot =
        await _databaseReference.child('distributors').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      Map<String, Map<String, dynamic>> distributorsMap = {};
      data.forEach((key, value) {
        distributorsMap[key as String] =
            Map<String, dynamic>.from(value as Map);
      });

      setState(() {
        distributors = distributorsMap.values
            .map<String>((distributor) => distributor['name'] as String)
            .toList();
        distributorData = distributorsMap;
        selectedDistributor = widget.cheapestDistributor ?? distributors.first;
        updateMedicinesList(selectedDistributor);

        // Add low stock medicines that are present with the distributor
        if (selectedDistributor != null) {
          addLowStockMedicinesToOrder(selectedDistributor);
        }

        // If no medicines were added, initialize with an empty entry
        if (selectedMedicines.isEmpty) {
          selectedMedicines.add({'medicine': null, 'count': 1});
        }
      });
    }
  }

  void fetchLowStockMedicines() async {
    DataSnapshot snapshot = await _databaseReference.child('medicine').get();
    if (snapshot.exists) {
      final medicines = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, int> filteredMedicines = {};

      medicines.forEach((key, value) {
        if (value is int && value < 80) {
          filteredMedicines[key as String] = value;
        }
      });

      setState(() {
        lowStockMedicines = filteredMedicines;
      });
    }
  }

  void updateMedicinesList(String? distributorName) {
    if (distributorName != null) {
      final distributor = distributorData.values
          .firstWhere((d) => d['name'] == distributorName);
      setState(() {
        medicines = (distributor['medicines'] as Map)
            .keys
            .map<String>((medicine) => medicine as String)
            .toList();
      });
    }
  }

  void addLowStockMedicinesToOrder(String? distributorName) {
    if (distributorName != null) {
      final distributor = distributorData.values
          .firstWhere((d) => d['name'] == distributorName);
      final distributorMedicines =
          distributor['medicines'] as Map<dynamic, dynamic>;
      lowStockMedicines.forEach((medicine, count) {
        if (distributorMedicines.containsKey(medicine)) {
          selectedMedicines.add({'medicine': medicine, 'count': 1});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ORDER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Distributor Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Distributor'),
              value: selectedDistributor,
              onChanged: (newValue) {
                setState(() {
                  selectedDistributor = newValue;
                  updateMedicinesList(selectedDistributor);
                  selectedMedicines = []; // Reset selected medicines
                  addLowStockMedicinesToOrder(selectedDistributor);
                  if (selectedMedicines.isEmpty) {
                    selectedMedicines.add({'medicine': null, 'count': 1});
                  }
                });
              },
              items: distributors.map((distributor) {
                return DropdownMenuItem(
                  value: distributor,
                  child: Text(distributor),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

// Medicine Dropdowns with Add/Remove Buttons and Count
            Expanded(
              child: ListView.builder(
                itemCount: selectedMedicines.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Medicine ${index + 1}'),
                          value: selectedMedicines[index]['medicine'],
                          onChanged: (newValue) {
                            setState(() {
                              selectedMedicines[index]['medicine'] = newValue;
                            });
                          },
                          items: medicines.map((medicine) {
                            return DropdownMenuItem(
                              value: medicine,
                              child: Text(medicine),
                            );
                          }).toList(),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (selectedMedicines[index]['count'] > 1) {
                                setState(() {
                                  selectedMedicines[index]['count']--;
                                });
                              }
                            },
                          ),
                          Text('${selectedMedicines[index]['count']}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                selectedMedicines[index]['count']++;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              if (selectedMedicines.length > 1) {
                                setState(() {
                                  selectedMedicines.removeAt(index);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedMedicines.add({'medicine': null, 'count': 1});
                    });
                  },
                  child: Text('Add'),
                ),
              ],
            ),

// Order Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle order submission
                  print('Order submitted:');
                  print('Distributor: $selectedDistributor');
                  print('Medicines: $selectedMedicines');
                  // You can add your order submission logic here, such as sending the order data to a server or Firebase
                },
                child: Text('Order Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
