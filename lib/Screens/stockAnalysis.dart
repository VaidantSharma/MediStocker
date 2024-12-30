import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StockAnalysis extends StatefulWidget {
  static String id = "Stock_Screen";

  const StockAnalysis({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StockAnalysis();
  }
}

class _StockAnalysis extends State<StockAnalysis> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _stockController = TextEditingController();
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('medicine');
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _selectedMedicine;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(() {
      _filterItems();
    });
  }

  void _loadItems() {
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> loadedItems = [];
        map.forEach((key, value) {
          loadedItems.add({
            'id': key,
            'name': key, // Use the key as the name
            'stock': value, // Use the value as the stock
          });
        });
        setState(() {
          _items = loadedItems;
          _filteredItems = loadedItems;
        });
      } else {
        setState(() {
          _items = [];
          _filteredItems = [];
        });
      }
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items
          .where((item) =>
          item['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  void _addItem(String name, int stock) {
    final newItem = {
      'name': name,
      'stock': stock,
    };
    databaseRef.child(name).set(stock).then((_) {
      setState(() {
        _items.add({
          'id': name,
          'name': name,
          'stock': stock,
        });
        _filteredItems.add({
          'id': name,
          'name': name,
          'stock': stock,
        });
      });
    });
  }

  // Update stock of the item
  void _updateItem(String id, int stock) {
    databaseRef.child(id).set(stock).then((_) {
      setState(() {
        _items = _items.map((item) {
          if (item['id'] == id) {
            return {'id': id, 'name': id, 'stock': stock};
          }
          return item;
        }).toList();
        _filteredItems = _filteredItems.map((item) {
          if (item['id'] == id) {
            return {'id': id, 'name': id, 'stock': stock};
          }
          return item;
        }).toList();
        _selectedMedicine = null; // Clear the selected medicine after update
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Row(
            children: [
              Expanded(
                  child: Text(
                    "  Medicine",
                    style: TextStyle(fontSize: 18),
                  )),
              Text(
                "Stock  ",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: _filteredItems[index]['stock'] < 80
                            ? Text(
                          _filteredItems[index]['name'],
                          style: const TextStyle(color: Colors.red),
                        )
                            : Text(_filteredItems[index]['name']),
                      ),
                      _filteredItems[index]['stock'] < 80
                          ? Text(
                        _filteredItems[index]['stock'].toString(),
                        style: const TextStyle(color: Colors.red),
                      )
                          : Text(_filteredItems[index]['stock'].toString()),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedMedicine = _filteredItems[index];
                    });
                  },
                  selected: _selectedMedicine != null &&
                      _selectedMedicine!['id'] == _filteredItems[index]['id'],
                  selectedTileColor: Colors.grey[300],
                );
              },
            ),
          ),
          _selectedMedicine != null
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Selected Medicine: ${_selectedMedicine!['name']}'),
                Text('Current Stock: ${_selectedMedicine!['stock']}'),
                ElevatedButton(
                  onPressed: () {
                    _showUpdateDialog(
                        _selectedMedicine!['id'], _selectedMedicine!['stock']);
                  },
                  child: Text('Edit Stock'),
                ),
              ],
            ),
          )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Show dialog to update stock
  void _showUpdateDialog(String id, int stock) {
    _nameController.text = id;
    _stockController.text = stock.toString();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Medicine Name'),
                    controller: _nameController,
                    readOnly: true,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Stock'),
                    controller: _stockController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a stock quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateItem(
                            _nameController.text, int.parse(_stockController.text));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Update Stock'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show dialog to add a new item
  void _showAddDialog() {
    _nameController.clear();
    _stockController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Stock'),
                    controller: _stockController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a stock quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addItem(
                            _nameController.text, int.parse(_stockController.text));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add Item'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
