import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryPopup extends StatefulWidget {
  final Map<String, dynamic> inventoryItem; // Item data passed to the popup

  InventoryPopup({required this.inventoryItem}); // Constructor to receive item data

  @override
  _InventoryPopupState createState() => _InventoryPopupState();
}

class _InventoryPopupState extends State<InventoryPopup> {
  TextEditingController roomCodeController = TextEditingController();
  String? selectedType; // Selected equipment type
  String? selectedStatus; // Selected status
  String? selectedRoom; // Selected room
  List<String> roomOptions = []; // List to hold room options from Firestore

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  void initState() {
    super.initState();

    // Initialize fields with data from inventory item
    roomCodeController.text = widget.inventoryItem['roomCode'] ?? '';
    selectedType = widget.inventoryItem['type'];
    selectedStatus = widget.inventoryItem['status'];
    selectedRoom = widget.inventoryItem['room'];

    _fetchRoomOptions(); // Fetch room options from Firestore
  }

  Future<void> _fetchRoomOptions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('rooms').get(); // Fetching room data
      setState(() {
        roomOptions = snapshot.docs.map((doc) => doc['room'] as String).toList(); // Map docs to room names
        print('Fetched rooms: $roomOptions'); // Debugging
      });
    } catch (e) {
      print('Error fetching rooms: $e'); // Error handling
    }
  }

  Future<void> _updateInventoryItem() async {
    // Check if all fields are filled
    if (roomCodeController.text.isNotEmpty &&
        selectedType != null &&
        selectedStatus != null &&
        selectedRoom != null) {
      try {
        // Update inventory item in Firestore
        await _firestore.collection('inventory').doc(widget.inventoryItem['id']).update({
          'roomCode': roomCodeController.text,
          'type': selectedType,
          'status': selectedStatus,
          'room': selectedRoom,
        });

        Navigator.of(context).pop(); // Close the popup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inventory updated successfully!')), // Success message
        );
      } catch (e) {
        print('Error updating inventory: $e'); // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update inventory')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')), // Prompt to fill all fields
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Equipment Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Code TextField
            TextField(
              controller: roomCodeController,
              decoration: InputDecoration(
                labelText: 'Room Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Equipment Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Equipment Type',
                border: OutlineInputBorder(),
              ),
              value: selectedType,
              items: ['Computer Laboratory', 'Office', 'Conference Room'].map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value; // Update selected type
                });
              },
            ),
            SizedBox(height: 16),
            // Status Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: selectedStatus,
              items: ['Active', 'Inactive'].map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value; // Update selected status
                });
              },
            ),
            SizedBox(height: 16),
            // Room Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Room',
                border: OutlineInputBorder(),
              ),
              value: selectedRoom,
              items: roomOptions.map((room) {
                return DropdownMenuItem(value: room, child: Text(room)); // Populate room options
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoom = value; // Update selected room
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel action
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _updateInventoryItem, // Update action
          child: Text('UPDATE'),
        ),
      ],
    );
  }
}
