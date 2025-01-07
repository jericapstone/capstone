import 'package:capstonesproject2024/admin/inventory_equipment/inventory_type.dart';
import 'package:capstonesproject2024/admin/inventory_equipment/equipment_detail.dart';
import 'package:capstonesproject2024/admin/inventory_equipment/equipment_table.dart';
import 'package:capstonesproject2024/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentDashboard extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final List<String> equipmentTypes;

  const EquipmentDashboard({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required List brandList,
    required this.equipmentTypes,
    required Null Function() onEquipmentAdded, required List roomList, required Null Function() onRoomAdded, required List roomTypes,
  }) : super(key: key);

  @override
  _EquipmentDashboardState createState() => _EquipmentDashboardState();
}

class _EquipmentDashboardState extends State<EquipmentDashboard> {
  String? selectedInventoryType;
  String? selectedEquipmentCode;

  List<QueryDocumentSnapshot> equipmentList = [];

  @override
  void initState() {
    super.initState();
    _fetchEquipmentData();
  }

  void _fetchEquipmentData() async {
    final snapshot = await FirebaseFirestore.instance.collection('equipment').get();
    setState(() {
      equipmentList = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InventoryType(
                      onSelect: (type) {
                        setState(() {
                          selectedInventoryType = type;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    EquipmentDetails(
                      selectedEquipmentCode: selectedEquipmentCode,
                      onEquipmentAdded: () {
                        _fetchEquipmentData();
                      },
                      brandList: [],
                      equipmentTypes: widget.equipmentTypes, // Correct reference
                    ),
                    const SizedBox(height: 20),
                    PaginatedTableEquipment(), // Add the paginated table here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
