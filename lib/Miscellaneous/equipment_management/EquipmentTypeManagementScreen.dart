import 'package:flutter/material.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';

class EquipmentTypeManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final Function(List<EquipmentType>) onEquipmentTypesUpdated;

  const EquipmentTypeManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onEquipmentTypesUpdated,
  }) : super(key: key);

  @override
  _EquipmentTypeManagementScreenState createState() =>
      _EquipmentTypeManagementScreenState();
}

class _EquipmentTypeManagementScreenState
    extends State<EquipmentTypeManagementScreen> {
  final TextEditingController equipmentTypeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool _isEquipmentTypeTableVisible = false;
  List<EquipmentType> equipmentTypes = [];
  List<EquipmentType> allEquipmentTypes = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadEquipmentTypes();
  }

  // Load equipment types from Firestore
  Future<void> _loadEquipmentTypes() async {
    try {
      List<String> fetchedEquipmentTypes =
      await _firestoreService.getEquipmentTypes();
      setState(() {
        equipmentTypes = fetchedEquipmentTypes.cast<EquipmentType>();
        allEquipmentTypes = List.from(fetchedEquipmentTypes); // For search functionality
      });

      widget.onEquipmentTypesUpdated(equipmentTypes); // Update the dropdown list
    } catch (e) {
      print("Error loading equipment types: $e");
    }
  }

  // Add a new equipment type
  Future<void> addEquipmentType() async {
    if (equipmentTypeController.text.isEmpty || descriptionController.text.isEmpty) {
      print('Equipment Type and Description fields cannot be empty');
      return;
    }

    final newEquipmentType = EquipmentType(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: equipmentTypeController.text.trim(),
      description: descriptionController.text.trim(),
    );

    try {
      await _firestoreService.addEquipmentType(
        newEquipmentType.name,
        newEquipmentType.description,
        newEquipmentType.id,
      );

      setState(() {
        equipmentTypes.add(newEquipmentType);
        allEquipmentTypes.add(newEquipmentType);
      });

      widget.onEquipmentTypesUpdated(equipmentTypes); // Update the dropdown list

      // Clear input fields after saving
      equipmentTypeController.clear();
      descriptionController.clear();
    } catch (e) {
      print('Error adding equipment type: $e');
    }
  }

  // Edit equipment type
  Future<void> editEquipmentType(EquipmentType equipmentType) async {
    equipmentTypeController.text = equipmentType.name;
    descriptionController.text = equipmentType.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Equipment Type: ${equipmentType.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: equipmentTypeController,
                decoration: const InputDecoration(
                  labelText: 'Equipment Type Name',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
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
                final updatedEquipmentType = EquipmentType(
                  id: equipmentType.id,
                  name: equipmentTypeController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                try {
                  await _firestoreService.updateEquipmentType(
                    updatedEquipmentType.id,
                    updatedEquipmentType.name,
                    updatedEquipmentType.description,
                  );
                  await _loadEquipmentTypes(); // Refresh list after update
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating equipment type: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete equipment type
  Future<void> deleteEquipmentType(String id) async {
    try {
      await _firestoreService.deleteEquipmentType(id);
      setState(() {
        equipmentTypes.removeWhere((equipmentType) => equipmentType.id == id);
        allEquipmentTypes.removeWhere((equipmentType) => equipmentType.id == id);
      });

      widget.onEquipmentTypesUpdated(equipmentTypes); // Update the dropdown list
    } catch (e) {
      print('Error deleting equipment type: $e');
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
                'Equipment Type Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Equipment Type Form inside a Container
              Container(
                width: 500, // Set the width of the container
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
                                controller: equipmentTypeController,
                                decoration: const InputDecoration(
                                  labelText: 'Equipment Type',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: addEquipmentType,
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
              // Toggle Button to Show/Hide Equipment Type Table
              Row(
                children: [
                  const Text(
                    'View Equipment Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isEquipmentTypeTableVisible = !_isEquipmentTypeTableVisible;
                      });
                    },
                    child: Icon(
                      _isEquipmentTypeTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Equipment Type Table with Search, inside a Card
              if (_isEquipmentTypeTableVisible)
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
                            columnSpacing: 50, // Adjusted to match the brand table
                            dataRowHeight: 50, // Adjusted to match the brand table
                            headingRowColor: MaterialStateProperty.all(Colors.black),
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            border: TableBorder.all(color: Colors.black, width: 2),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Equipment Type')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: equipmentTypes.map(
                                  (equipmentType) {
                                return DataRow(cells: [
                                  DataCell(Text(equipmentType.id)),
                                  DataCell(Text(equipmentType.name)),
                                  DataCell(Text(equipmentType.description)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.green),
                                        onPressed: () => editEquipmentType(equipmentType),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteEquipmentType(equipmentType.id),
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