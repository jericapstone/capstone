import 'package:capstonesproject2024/admin/Inventoryroom/RoomSelectionDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RoomDetails extends StatefulWidget {
  final String? selectedRoomCode;
  final Function onRoomAdded;

  RoomDetails({required this.selectedRoomCode, required this.onRoomAdded});

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  String? selectedRoom;
  String? selectedType;
  String? selectedStatus;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> mtRoomList = []; // List of rooms fetched from Firestore

  @override
  void initState() {
    super.initState();
    _fetchMTRooms(); // Load the MTRoom list when the widget is initialized
  }

  // Fetch MTRooms from Firestore
  Future<void> _fetchMTRooms() async {
    try {
      print("Fetching MTRooms...");
      QuerySnapshot snapshot = await _firestore.collection('MTRoom').get();

      setState(() {
        mtRoomList = snapshot.docs
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['room'] as String; // Assuming the field name is 'room'
        })
            .where((room) => room.isNotEmpty)
            .toList();

        // Automatically select the first room if none is selected
        if (selectedRoom == null && mtRoomList.isNotEmpty) {
          selectedRoom = mtRoomList.first;
        }
      });

      print("MTRoom List: $mtRoomList");
    } catch (e) {
      print('Error fetching MTRoom list: $e');
    }
  }

  // Show the room selection dialog
  void _showRoomSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return RoomSelectDialog(
          onRoomSelected: (selectedRoom) {
            setState(() {
              this.selectedRoom = selectedRoom;
            });
            Navigator.pop(context); // Close the dialog
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2000,
      height: 300,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Room',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedRoom,
                      items: mtRoomList.map((room) {
                        return DropdownMenuItem<String>(value: room, child: Text(room));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoom = value;
                        });
                        print("Selected Room: $selectedRoom");
                      },
                      hint: Text('Select a room'),
                      isExpanded: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _showRoomSelectDialog, // Open dialog when pressed
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedType,
                      items: [
                        'Computer Laboratory',
                        'Office',
                        'Conference Room'
                      ].map((item) {
                        return DropdownMenuItem<String>(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                      hint: Text('Select a type'),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStatus,
                      items: ['Active', 'Inactive'].map((item) {
                        return DropdownMenuItem<String>(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      hint: Text('Select a status'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRoom = null;
                        selectedType = null;
                        selectedStatus = null;
                      });
                    },
                    child: Text('Clear', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // Handle the save logic here
                      print("Saved Room: $selectedRoom");
                      print("Type: $selectedType");
                      print("Status: $selectedStatus");
                    },
                    child: Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
