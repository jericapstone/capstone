import 'package:capstonesproject2024/admin/Inventoryroom/room_table.dart';
import 'package:capstonesproject2024/admin/Inventoryroom/room_details.dart';
import 'package:capstonesproject2024/admin/inventory_equipment/inventory_type.dart';
import 'package:capstonesproject2024/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomDashboard extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final List<String> roomTypes; // Adjusted to room types
  final List roomList; // Added roomList as parameter
  final List brandList; // Added brandList as parameter
  final List equipmentTypes; // Added equipmentTypes as parameter
  final String selectedRoomCode; // Added selectedRoomCode as parameter
  final Function onRoomAdded; // Correctly typed onRoomAdded

  const RoomDashboard({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.roomList,
    required this.roomTypes,
    required this.onRoomAdded,
    required this.brandList,
    required this.equipmentTypes,
    required this.selectedRoomCode,
    required Null Function() onEquipmentAdded,
  }) : super(key: key);

  @override
  _RoomDashboardState createState() => _RoomDashboardState();
}

class _RoomDashboardState extends State<RoomDashboard> {
  String? selectedInventoryType;
  String? selectedRoomCode; // Adjusted for room code

  List<QueryDocumentSnapshot> roomList = [];

  @override
  void initState() {
    super.initState();
    _fetchRoomData();
  }

  void _fetchRoomData() async {
    final snapshot = await FirebaseFirestore.instance.collection('rooms').get();
    setState(() {
      roomList = snapshot.docs;
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
                    RoomDetails(
                      selectedCode: selectedRoomCode, // Adjusted for room code
                      onRoomAdded: widget.onRoomAdded, // Correctly passing the function
                      roomTypes: widget.roomTypes, // Correct reference
                      adminName: widget.adminName, // Correct reference
                      profileImagePath: widget.profileImagePath, // Correct reference
                    ),
                    const SizedBox(height: 20),
                    RoomTable(
                      onRoomAdded: widget.onRoomAdded, // Pass the function here
                    ),
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
