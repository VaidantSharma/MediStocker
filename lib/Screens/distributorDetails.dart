import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../util/constant.dart';
import 'order_screen.dart';
import 'package:medstoker/UserWidget/bottom_navigation_bar.dart';

class PriceComparisonScreen extends StatefulWidget {
  static String id = "Distributor_screen";

  const PriceComparisonScreen({super.key});

  @override
  _PriceComparisonScreenState createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  static int screen_num = nameNavigation.indexOf(PriceComparisonScreen.id);

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final TextEditingController _medicineController = TextEditingController();
  String? _cheapestDistributor;
  double?_lowestPrice;
  String? _location;
  bool _isLoading = false;
  Map<String, int> _suggestedMedicines = {};
  List<String> _medicineNames = []; // List to store medicinenames from database
  List<String> _filteredMedicineNames = []; // List to store filtered medicine names

  @override
  void initState() {
    super.initState();
    _fetchSuggestedMedicines();
    _fetchMedicineNames(); // Fetch medicine names when the page loads
  }

  // Fetch and filter medicines whose count is less than 80
  void _fetchSuggestedMedicines() async {
    try {
      DataSnapshot snapshot = await _databaseReference.child('medicine').get();
      if (snapshot.exists) {
        final medicines = snapshot.value as Map<dynamic, dynamic>;
        final Map<String, int> filteredMedicines = {};

        medicines.forEach((key, value) {
          if (value is int && value < 80) {
            filteredMedicines[key] = value;
          }
        });

        setState(() {
          _suggestedMedicines = filteredMedicines;
        });
      } else {
        print("Error: No data exists for medicines.");
      }
    } catch (error) {
      print("Error fetching medicines: $error");
    }
  }

  // Fetch medicine names from the database
  void _fetchMedicineNames() async {
    try {
      DataSnapshot snapshot = await _databaseReference.child('medicine').get();
      if (snapshot.exists) {
        final medicines = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _medicineNames = medicines.keys.cast<String>().toList();
          _filteredMedicineNames = _medicineNames; // Initially show all medicine names
        });
      } else {
        print("Error: No data exists for medicines.");
      }
    } catch (error) {
      print("Error fetching medicine names: $error");
    }
  }

  void comparePrices(String medicineName) async {
    setState(() {
      _isLoading = true;
      _cheapestDistributor = null;
      _lowestPrice = null;
      _location = null;
    });

    try {
      DataSnapshot snapshot = await _databaseReference.child('distributors').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        num? lowestPrice;
        String? cheapestDistributor;
        String? location;

        data.forEach((key, value) {
          final distributor = value as Map<dynamic, dynamic>;
          final medicines = distributor['medicines'] as Map<dynamic, dynamic>?;

          if (medicines != null && medicines.containsKey(medicineName)) {
            final medicineData = medicines[medicineName] as Map<dynamic, dynamic>;
            final price = medicineData['price'] as num;

            if (lowestPrice == null || price < lowestPrice!) {
              lowestPrice = price;
              cheapestDistributor = distributor['name'] as String;
              location = distributor['location'] as String;
            }
          }
        });

        setState(() {
          _lowestPrice = lowestPrice?.toDouble();
          _cheapestDistributor = cheapestDistributor;
          _location = location;
          _isLoading = false;
        });
      } else {
        print("Error: No distributors data exists.");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching distributor data: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showAllDistributors() async {
    try {
      DataSnapshot snapshot =
      await _databaseReference.child('distributors').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Allows full height control
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.8, // 80% of screen height
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final key = data.keys.elementAt(index);
                    final distributor = data[key] as Map<dynamic, dynamic>;
                    final name = distributor['name'] as String;
                    final location = distributor['location'] as String;
                    final medicines =
                    distributor['medicines'] as Map<dynamic, dynamic>;

                    return ExpansionTile(
                      title: Text(name),
                      subtitle: Text('Location: $location'),
                      children: medicines.entries.map<Widget>((medicineEntry) {
                        final medicineName = medicineEntry.key as String;
                        final price = medicineEntry.value['price'] as num;

                        return ListTile(
                          title: Text(medicineName),
                          trailing:
                          Text('Price: \$${price.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            );
          },
        );
      } else {
        print("Error: No distributors found.");
      }
    } catch (error) {
      print("Error loading distributors: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PersistentBottomNavBar(
        selectedIndex: screen_num,
        onItemTapped: (int value) {
          Navigator.popAndPushNamed(context, nameNavigation[value]);
        },
      ),
      appBar: AppBar(
        title: Text('Price Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Autocomplete TextField for medicine names
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _medicineNames.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _medicineController.text = selection;
                // You can perform actions here when a medicine is selected,
                // such as fetching details from the database.
              },
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted
                  ) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Enter Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredMedicineNames = _medicineNames
                          .where((name) => name.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_medicineController.text.isNotEmpty) {
                  comparePrices(_medicineController.text);
                }
              },
              child: Text('Compare Prices'),
            ),
            SizedBox(height: 16.0),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_cheapestDistributor != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cheapest Distributor: $_cheapestDistributor\n'
                        'Price: \$${_lowestPrice?.toStringAsFixed(2)}\n'
                        'Location: $_location',
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(
                            cheapestDistributor: _cheapestDistributor,
                          ),
                        ),
                      );},
                    child: Text('Order Now'),
                  ),
                ],
              )
            else if (_medicineController.text.isNotEmpty)
                Text(
                  'Suggested Medicines (Less Stock Available)',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
            SizedBox(
              height: 180, // Set a fixed height for the ListView
              child: _suggestedMedicines.isNotEmpty
                  ? ListView.builder( // Use ListView.builder for efficiency
                itemCount: _suggestedMedicines.length,
                itemBuilder: (context, index) {
                  final entry = _suggestedMedicines.entries.elementAt(index);
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text('Stock: ${entry.value}'),
                  );
                },
              )
                  : Text('No medicines with low stock found.'),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton(
                  onPressed: showAllDistributors,
                  style: TextButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Show All Distributors',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ),],
        ),
      ),
    );
  }
}