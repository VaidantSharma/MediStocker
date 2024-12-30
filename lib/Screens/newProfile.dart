import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:medstoker/Screens/order_screen.dart';

class NewProfileScreen extends StatefulWidget {
  static String id = "new_profile_screen";
  @override
  State<NewProfileScreen> createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<Map<dynamic, dynamic>> _users = []; // To store retrieved users

  @override
  void initState() {
    super.initState();
    _retrieveUsers();
  }



  void _retrieveUsers() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _users = data.entries.map((entry) {
            return {
              'id': entry.key,
              'name': entry.value['name'],
              'location': entry.value['location'],
            };
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Set"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(hintText: 'Location'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                Map<String,dynamic> data = {
                  "name":_nameController.text.toString(),
                  "location":_locationController.text.toString(),
                };
                _dbRef.child("users").push().set(data).then((value){
                  Navigator.pushNamed(context, OrderScreen.id);
                });
              },
              child: Text('Save Profile'),
            ),
            SizedBox(height: 20),
            Text(
              'Saved Profiles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _users.isEmpty
              ? Center(child: CircularProgressIndicator())
              :ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_users[index]['name']),
                    subtitle: Text(_users[index]['location']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}