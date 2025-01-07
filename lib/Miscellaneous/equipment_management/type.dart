import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your Type model

class TypeManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final void Function(List<Type>) onTypesUpdated; // Callback to update dropdown

  const TypeManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onTypesUpdated, // Pass the callback
  }) : super(key: key);

  @override
  _TypeManagementScreenState createState() => _TypeManagementScreenState();
}

class _TypeManagementScreenState extends State<TypeManagementScreen> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isTypeTableVisible = false;
  List<Type> types = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  // Load types from Firestore
  Future<void> _loadTypes() async {
    try {
      List<Type> fetchedTypes = await _firestoreService.getTypes();
      print('Fetched types: $fetchedTypes'); // Debugging line to check fetched data
      setState(() {
        types = fetchedTypes;
      });

      widget.onTypesUpdated(types); // Update the dropdown list
    } catch (e) {
      print('Error loading types: $e');
    }
  }

  // Add a new type
  Future<void> addType() async {
    if (typeController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both type and description fields.')),
      );
      return;
    }

    final newType = Type(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: typeController.text.trim(),
      description: descriptionController.text.trim(),
    );

    try {
      await _firestoreService.addType(newType);
      print('Added new type: ${newType.name}, ${newType.description}'); // Debugging line to check the saved data

      setState(() {
        types.add(newType);
      });

      widget.onTypesUpdated(types); // Update the dropdown list

      // Clear input fields after saving
      typeController.clear();
      descriptionController.clear();
    } catch (e) {
      print('Error adding type: $e');
    }
  }

  // Edit type
  Future<void> editType(Type type) async {
    typeController.text = type.name;
    descriptionController.text = type.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Type: ${type.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'Type Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedType = Type(
                  id: type.id,
                  name: typeController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                try {
                  await _firestoreService.updateType(updatedType);
                  print('Updated type: ${updatedType.name}, ${updatedType.description}'); // Debugging line
                  await _loadTypes(); // Refresh list after update
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating type: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete type
  Future<void> deleteType(String id) async {
    try {
      await _firestoreService.deleteType(id);
      print('Deleted type with ID: $id'); // Debugging line

      setState(() {
        types.removeWhere((type) => type.id == id);
      });

      widget.onTypesUpdated(types); // Update the dropdown list
    } catch (e) {
      print('Error deleting type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Input Card for Adding Type
              Container(
                width: 400,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: typeController,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: addType,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                descriptionController.clear();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Toggle Button to Show/Hide Type Table
              Row(
                children: [
                  const Text(
                    'View Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isTypeTableVisible = !_isTypeTableVisible;
                      });
                    },
                    child: Icon(
                      _isTypeTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data Table Inside Card (Placed inside the card now)
              if (_isTypeTableVisible)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 50, // Adjusted to match the type table
                            dataRowHeight: 50, // Adjusted to match the type table
                            headingRowColor: MaterialStateProperty.all(Colors.black),
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            border: TableBorder.all(color: Colors.black, width: 2),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: types.map(
                                  (type) {
                                return DataRow(cells: [
                                  DataCell(Text(type.id)),
                                  DataCell(Text(type.name)),
                                  DataCell(Text(type.description)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.green),
                                        onPressed: () => editType(type),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteType(type.id),
                                      ),
                                    ],
                                  )),

                                ]);
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
