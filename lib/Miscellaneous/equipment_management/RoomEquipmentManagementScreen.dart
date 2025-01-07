import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your RoomEquipment model

class RoomEquipmentManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final Function(List<RoomEquipment>) onEquipmentsUpdated;

  const RoomEquipmentManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onEquipmentsUpdated,
  }) : super(key: key);

  @override
  _RoomEquipmentManagementScreenState createState() =>
      _RoomEquipmentManagementScreenState();
}

class _RoomEquipmentManagementScreenState
    extends State<RoomEquipmentManagementScreen> {
  final TextEditingController roomEquipmentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isEquipmentTableVisible = false;
  List<RoomEquipment> equipments = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  // Load equipment from Firestore
  Future<void> _loadEquipments() async {
    List<RoomEquipment> fetchedEquipments =
    await _firestoreService.getRoomEquipments();
    setState(() {
      equipments = fetchedEquipments;
    });

    widget.onEquipmentsUpdated(equipments); // Update the dropdown list
  }

  // Add a new equipment
  Future<void> addEquipment() async {
    if (roomEquipmentController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in both room equipment and description.')),
      );
      return;
    }

    final newEquipment = RoomEquipment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: roomEquipmentController.text.trim(),
      description: descriptionController.text.trim(),
      status: '', type: '',
    );

    await _firestoreService.addRoomEquipment(newEquipment);

    setState(() {
      equipments.add(newEquipment);
    });

    widget.onEquipmentsUpdated(equipments); // Update the dropdown list

    // Clear input fields after saving
    roomEquipmentController.clear();
    descriptionController.clear();
  }

  // Edit equipment
  Future<void> editEquipment(RoomEquipment equipment) async {
    roomEquipmentController.text = equipment.name;
    descriptionController.text = equipment.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Equipment: ${equipment.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomEquipmentController,
                decoration: const InputDecoration(
                  labelText: 'Room Equipment',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
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
                final updatedEquipment = RoomEquipment(
                  id: equipment.id,
                  name: roomEquipmentController.text.trim(),
                  description: descriptionController.text.trim(),
                  status: '', type: '',
                );

                try {
                  await _firestoreService.updateRoomEquipment(updatedEquipment);
                  await _loadEquipments(); // Refresh list after update
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating equipment: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete equipment
  Future<void> deleteEquipment(String id) async {
    await _firestoreService.deleteRoomEquipment(id);
    setState(() {
      equipments.removeWhere((equipment) => equipment.id == id);
    });

    widget.onEquipmentsUpdated(equipments); // Update the dropdown list
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
                'Room Equipment Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Input Card for Adding Equipment
              Container(
                width: 400,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: roomEquipmentController,
                                decoration: const InputDecoration(
                                  labelText: 'Room Equipment',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: addEquipment,
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
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon:
                              const Icon(Icons.cancel, color: Colors.red),
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
              // Toggle Button to Show/Hide Equipment Table
              Row(
                children: [
                  const Text(
                    'View Equipments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isEquipmentTableVisible = !_isEquipmentTableVisible;
                      });
                    },
                    child: Icon(
                      _isEquipmentTableVisible
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data Table for Equipment
              if (_isEquipmentTableVisible)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 50,
                            dataRowHeight: 50,
                            headingRowColor:
                            MaterialStateProperty.all(Colors.black),
                            headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            border: TableBorder.all(color: Colors.black),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Room Equipment')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: equipments.map((equipment) {
                              return DataRow(cells: [
                                DataCell(Text(equipment.id)),
                                DataCell(Text(equipment.name)),
                                DataCell(Text(equipment.description)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.green),
                                      onPressed: () =>
                                          editEquipment(equipment),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          deleteEquipment(equipment.id),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
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
