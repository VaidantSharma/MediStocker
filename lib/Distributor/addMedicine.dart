import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:medstoker/Distributor/HomeScreenDistributer.dart';

class DistributorPage extends StatefulWidget {
  static String id = "addMedicine_screen";
  @override
  _DistributorPageState createState() => _DistributorPageState();
}

class _DistributorPageState extends State<DistributorPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  String? _medicineName;
  double? _price;

  void _addMedicine() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String distributorId = "distributor_1"; // Replace with actual distributor ID

      try {
        // Push medicine data to Firebase
        await _databaseReference.child('distributors/$distributorId/medicines/$_medicineName').set({
          'price': _price,
        });
        // Clear inputs after successful submission
        setState(() {
          _medicineName = null;
          _price = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Medicine added successfully!")));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add medicine: $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Distributor Page"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Medicine Name"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the medicine name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _medicineName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.tryParse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addMedicine,
                child: Text("Add Medicine"),
              ),
              SizedBox(height: 20), // Add spacing between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DistributerHomeScreen()),
                  );
                },
                child: Text("Go to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
