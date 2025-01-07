import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstonesproject2024/admin/inventory_equipment/equipment_popup.dart';

class PaginatedTableEquipment extends StatefulWidget {
  @override
  _PaginatedTableEquipmentState createState() => _PaginatedTableEquipmentState();
}

class _PaginatedTableEquipmentState extends State<PaginatedTableEquipment> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _equipmentStream;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _equipmentStream = firestore.collection('equipment').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _equipmentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final equipmentDocs = snapshot.data?.docs ?? [];

        // Filtered equipment list based on the search text
        final filteredEquipmentDocs = equipmentDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['unitCode']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
              (data['brand']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
              (data['model']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
              (data['serialNumber']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
              (data['type']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false) ||
              (data['status']?.toString().toLowerCase().contains(_searchText.toLowerCase()) ?? false);
        }).toList();

        if (filteredEquipmentDocs.isEmpty) {
          return Center(child: Text('No equipment found.'));
        }

        return Padding(
          padding: const EdgeInsets.all(0.5),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                  children: [
                    // Search TextField
                    SizedBox(
                      width: 1000, // Adjust the width as needed
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by unit code | brand | model | Serial Number | type | status | room |',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(
                              color: Colors.black, // Set the color of the border
                              width: 10, // Set the width of the border
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Adjust height
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Added space after search field
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(color: Colors.black, width: 3),
                            columnSpacing: 120, // Adjusted column spacing
                            dataRowHeight: 75,
                            headingRowColor: MaterialStateProperty.all(Colors.black),
                            columns: [
                              DataColumn(label: Text('Unit Code', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Brand', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Model', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Serial Number', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Type', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Room', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredEquipmentDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DataRow(
                                cells: [
                                  DataCell(Text(data['unitCode'] ?? 'N/A')),
                                  DataCell(Text(data['brand'] ?? 'N/A')),
                                  DataCell(Text(data['model'] ?? 'N/A')),
                                  DataCell(Text(data['serialNumber'] ?? 'N/A')),
                                  DataCell(Text(data['type'] ?? 'N/A')),
                                  DataCell(Text(data['status'] ?? 'N/A')),
                                  DataCell(Text(data['room'] ?? 'N/A')),
                                  DataCell(Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                        onPressed: () {
                                          _viewEquipment(doc.id);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.green),
                                        onPressed: () {
                                          final data = doc.data() as Map<String, dynamic>;
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return EquipmentPopup(
                                                equipmentItem: data,
                                                onUpdate: (updatedEquipment) {
                                                  _updateEquipment(doc.id, updatedEquipment);
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteEquipment(doc.id),
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewEquipment(String docId) {
    print("View Equipment: $docId");
    // Implement your view logic here
  }

  void _updateEquipment(String docId, Map<String, dynamic> updatedEquipment) {
    firestore.collection('equipment').doc(docId).update(updatedEquipment).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipment updated successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update equipment: $error')),
      );
    });
  }

  void _deleteEquipment(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Equipment'),
          content: Text('Are you sure you want to delete this equipment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestore.collection('equipment').doc(docId).delete().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Equipment deleted successfully!')),
                  );
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
