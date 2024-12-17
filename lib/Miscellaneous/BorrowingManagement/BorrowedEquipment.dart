import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart';

class BorrowedEquipmentManagementScreen extends StatefulWidget {
  const BorrowedEquipmentManagementScreen({
    Key? key,
    required Null Function(List<BorrowedEquipment> updatedEquipment) onEquipmentUpdated,
    required String adminName,
    required String profileImagePath
  }) : super(key: key);

  @override
  _BorrowedEquipmentManagementScreenState createState() =>
      _BorrowedEquipmentManagementScreenState();
}

class _BorrowedEquipmentManagementScreenState
    extends State<BorrowedEquipmentManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController equipmentController = TextEditingController();
  final TextEditingController borrowerController = TextEditingController();

  bool _isTableVisible = false;
  List<BorrowedEquipment> borrowedEquipments = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowedEquipments();
  }

  // Load borrowed equipments from Firestore
  Future<void> _loadBorrowedEquipments() async {
    List<BorrowedEquipment> fetchedEquipments =
    await _firestoreService.getBorrowedEquipments();
    setState(() {
      borrowedEquipments = fetchedEquipments;
    });
  }

  // Add a new borrowed equipment
  Future<void> addBorrowedEquipment() async {
    if (equipmentController.text.isEmpty || borrowerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final newEquipment = BorrowedEquipment(
      equipmentName: equipmentController.text.trim(),
      borrowerName: borrowerController.text.trim(),
      borrowedDate: DateTime.now(),
    );

    await _firestoreService.addBorrowedEquipment(newEquipment);

    setState(() {
      borrowedEquipments.add(newEquipment);
    });

    equipmentController.clear();
    borrowerController.clear();
  }

  // Edit borrowed equipment
  Future<void> editBorrowedEquipment(BorrowedEquipment equipment) async {
    equipmentController.text = equipment.equipmentName;
    borrowerController.text = equipment.borrowerName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Borrowed Equipment: ${equipment.equipmentName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: equipmentController,
                decoration: const InputDecoration(
                  labelText: 'Equipment Name',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: borrowerController,
                decoration: const InputDecoration(
                  labelText: 'Borrower Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedEquipment = BorrowedEquipment(
                  id: equipment.id,
                  equipmentName: equipmentController.text.trim(),
                  borrowerName: borrowerController.text.trim(),
                  borrowedDate: equipment.borrowedDate,
                );

                await _firestoreService.updateBorrowedEquipment(updatedEquipment);
                await _loadBorrowedEquipments(); // Refresh list after update
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete borrowed equipment
  Future<void> deleteBorrowedEquipment(String id) async {
    await _firestoreService.deleteBorrowedEquipment(id);
    setState(() {
      borrowedEquipments.removeWhere((equipment) => equipment.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrowed Equipment Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Borrowed Equipment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Input Fields for Equipment and Borrower Details
            TextField(
              controller: equipmentController,
              decoration: const InputDecoration(
                labelText: 'Equipment Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: borrowerController,
              decoration: const InputDecoration(
                labelText: 'Borrower Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: addBorrowedEquipment,
              child: const Text('Add Borrowed Equipment'),
            ),
            const SizedBox(height: 16),
            // Toggle Button to Show/Hide Equipment Table
            Row(
              children: [
                const Text(
                  'View Borrowed Equipments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isTableVisible = !_isTableVisible;
                    });
                  },
                  child: Icon(
                    _isTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display Borrowed Equipment Data Table
            if (_isTableVisible)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: borrowedEquipments.map((equipment) {
                            return DataRow(cells: [
                              DataCell(Text(equipment.id ?? '')),
                              DataCell(Text(equipment.equipmentName)),
                              DataCell(Text(equipment.borrowerName)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () => editBorrowedEquipment(equipment),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteBorrowedEquipment(equipment.id!),
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
    );
  }
}
