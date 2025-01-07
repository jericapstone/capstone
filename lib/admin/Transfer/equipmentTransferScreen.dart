// equipment_transfer_screen.dart

import 'package:capstonesproject2024/admin/Transfer/equipmenttransfertable.dart';
import 'package:capstonesproject2024/admin/Transfer/transferDialog.dart';
import 'package:capstonesproject2024/admin/Transfer/transferhistory.dart';
import 'package:capstonesproject2024/model/equipmenttransfer.dart';
import 'package:capstonesproject2024/model/transferrecord.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:capstonesproject2024/Sidebar.dart'; // Assuming Sidebar is implemented

class EquipmentTransferScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const EquipmentTransferScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _EquipmentTransferScreenState createState() =>
      _EquipmentTransferScreenState();
}

class _EquipmentTransferScreenState extends State<EquipmentTransferScreen> {
  List<EquipmentTranserModel> equipments = [];
  bool isLoading = true;
  String searchSerialNumber = '';

  @override
  void initState() {
    super.initState();
    fetchEquipments();
  }

  /// Fetches equipment data from Firestore
  Future<void> fetchEquipments() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('equipment').get();

      List<EquipmentTranserModel> fetchedEquipments = snapshot.docs
          .map((doc) => EquipmentTranserModel.fromDocument(doc))
          .toList();

      setState(() {
        equipments = fetchedEquipments;
        isLoading = false;
      });

      print('Fetched Equipments: ${equipments.length}');
    } catch (e) {
      print('Error fetching equipments: $e');
      setState(() {
        isLoading = false;
      });
      // Optionally, show a SnackBar or AlertDialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch equipments. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Filters equipments based on the search serial number
  List<EquipmentTranserModel> get filteredEquipments {
    if (searchSerialNumber.isEmpty) {
      return equipments;
    } else {
      return equipments
          .where((eq) => eq.serialNumber
              .toLowerCase()
              .contains(searchSerialNumber.toLowerCase()))
          .toList();
    }
  }

  /// Initiates the transfer process
  Future<void> initiateTransfer(EquipmentTranserModel equipment) async {
    // Show the transfer form dialog
    await showDialog(
      context: context,
      builder: (context) {
        return TransferFormDialog(equipment: equipment);
      },
    );

    // Refresh equipment data after transfer
    fetchEquipments();
  }

  /// Views the transfer history for a specific equipment
  Future<void> viewTransferHistory(EquipmentTranserModel equipment) async {
    // Fetch transfer records for the equipment
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transfers')
        .where('equipmentId', isEqualTo: equipment.id)
        .orderBy('transferDate', descending: true)
        .get();

    List<TransferRecord> fetchedTransfers =
        snapshot.docs.map((doc) => TransferRecord.fromDocument(doc)).toList();

    // Show the transfer history dialog
    showDialog(
      context: context,
      builder: (context) {
        return TransferHistoryDialog(transferRecords: fetchedTransfers);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Text(
                    'Equipment Transfer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Search and Refresh Section
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search by Serial Number',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchSerialNumber = value.trim();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: fetchEquipments,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Equipment Data Table
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredEquipments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No equipments found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : EquipmentDataTable(
                                equipments: filteredEquipments,
                                onTransfer: initiateTransfer,
                                onViewHistory: viewTransferHistory,
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
