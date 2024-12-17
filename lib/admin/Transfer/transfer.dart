import 'package:capstonesproject2024/models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstonesproject2024/sidebar.dart'; // Import the Sidebar

class TransferEquipmentScreen extends StatefulWidget {
  final String adminName;
  final String profileImagePath;
  final Function(List<Brand>) onBrandsUpdated;
  final Function(String) onScheduleAdded;
  final String? selectedScheduleCode;

  TransferEquipmentScreen({
    required this.adminName,
    required this.profileImagePath,
    required this.onBrandsUpdated,
    required this.onScheduleAdded,
    this.selectedScheduleCode,
  });

  @override
  _TransferEquipmentScreenState createState() =>
      _TransferEquipmentScreenState();
}

class _TransferEquipmentScreenState extends State<TransferEquipmentScreen> {
  List<String> brandList = [];
  List<String> equipmentList = [];
  List<String> roomList = [];
  String? selectedBrand;
  String? selectedEquipment;
  String? selectedTransferFrom;
  String? selectedTransferTo;

  TextEditingController serialNumberController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  // Initialize an empty list of transfers
  List<Map<String, dynamic>> transferData = [];

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchEquipments();
    _fetchRooms();
    _fetchTransfers();  // Fetch initial transfers when the screen loads
  }

  Future<void> _fetchBrands() async {
    setState(() {
      brandList = ['Brand A', 'Brand B', 'Brand C'];
    });
  }

  Future<void> _fetchEquipments() async {
    setState(() {
      equipmentList = ['Laptop', 'Monitor', 'Keyboard'];
    });
  }

  Future<void> _fetchRooms() async {
    setState(() {
      roomList = ['Room 1', 'Room 2', 'Room 3'];
    });
  }

  Future<void> _fetchTransfers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('transfers').get();
      setState(() {
        transferData = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Store the document ID in the transfer data
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error fetching transfers: $e');
    }
  }

  Future<void> _addTransfer() async {
    if (serialNumberController.text.isEmpty ||
        selectedTransferFrom == null ||
        selectedTransferTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    try {
      String currentDate = DateTime.now().toString(); // Get the current date and time

      await FirebaseFirestore.instance.collection('transfers').add({
        'serialNumber': serialNumberController.text,
        'brand': selectedBrand,
        'equipment': selectedEquipment,
        'transferFrom': selectedTransferFrom,
        'transferTo': selectedTransferTo,
        'date': currentDate, // Add the current date here
      });

      // After adding the transfer, fetch the updated data
      await _fetchTransfers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer added successfully')),
      );

      // Clear form fields
      setState(() {
        serialNumberController.clear();
        selectedBrand = null;
        selectedEquipment = null;
        selectedTransferFrom = null;
        selectedTransferTo = null;
      });
    } catch (e) {
      print('Error adding transfer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transfer')),
      );
    }
  }

  Widget _buildBrandTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 2000, // Set a fixed width for the container
        height: 450, // Set a fixed height for the container
        padding: const EdgeInsets.all(10),
        child: DataTable(
          columnSpacing: 150,
          dataRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.black),
          headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
          border: TableBorder.all(color: Colors.black, width: 2),
          columns: const [
            DataColumn(label: Text('Date', textAlign: TextAlign.center)),
            DataColumn(label: Text('Transfer from', textAlign: TextAlign.center)),
            DataColumn(label: Text('Transfer to', textAlign: TextAlign.center)),
            DataColumn(label: Text('Brand Name', textAlign: TextAlign.center)),
            DataColumn(label: Text('Serial Number', textAlign: TextAlign.center)),
            DataColumn(label: Text('Equipment', textAlign: TextAlign.center)),
            DataColumn(label: Text('Actions', textAlign: TextAlign.center)),
          ],
          rows: transferData.map((transfer) {
            return DataRow(cells: [
              DataCell(Text(transfer['date'] ?? '', textAlign: TextAlign.center)),
              DataCell(Text(transfer['transferFrom'] ?? '', textAlign: TextAlign.center)),
              DataCell(Text(transfer['transferTo'] ?? '', textAlign: TextAlign.center)),
              DataCell(Text(transfer['brand'] ?? '', textAlign: TextAlign.center)),
              DataCell(Text(transfer['serialNumber'] ?? '', textAlign: TextAlign.center)),
              DataCell(Text(transfer['equipment'] ?? '', textAlign: TextAlign.center)),
              DataCell(Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the action buttons
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      // Show edit dialog with the selected row's data
                      _showEditDialog(transfer);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Handle delete action here
                      _deleteTransfer(transfer['id']);
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }


  void _deleteTransfer(String id) async {
    try {
      await FirebaseFirestore.instance.collection('transfers').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer deleted successfully')),
      );
      // Refresh the data after deletion
      await _fetchTransfers();
    } catch (e) {
      print('Error deleting transfer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transfer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (permanently shown)
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main content area (taking up the remaining space)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // First row (Serial Number and Brand)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: serialNumberController,
                                    decoration: InputDecoration(
                                      labelText: 'Serial Number',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Brand',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedBrand,
                                    items: brandList.map((brand) {
                                      return DropdownMenuItem(
                                        value: brand,
                                        child: Text(brand),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedBrand = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Second row (Equipment, Transfer From, Transfer To)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 250, // Adjust size as needed
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Equipment',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedEquipment,
                                    items: equipmentList.map((equipment) {
                                      return DropdownMenuItem(
                                        value: equipment,
                                        child: Text(equipment),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedEquipment = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),

                                SizedBox(
                                  width: 250, // Adjust size as needed
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Transfer From',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedTransferFrom,
                                    items: roomList.map((room) {
                                      return DropdownMenuItem(
                                        value: room,
                                        child: Text(room),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTransferFrom = value;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),

                                SizedBox(
                                  width: 250, // Adjust size as needed
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Transfer To',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: selectedTransferTo,
                                    items: roomList.map((room) {
                                      return DropdownMenuItem(
                                        value: room,
                                        child: Text(room),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTransferTo = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Transfer Button aligned to the right
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _addTransfer,
                                child: Text('Transfer'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildBrandTable(), // Display the transfer data table
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showEditDialog(Map<String, dynamic> transfer) {
    // You can create an edit dialog to update transfer details.
  }
}
