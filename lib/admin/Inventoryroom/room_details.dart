import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomDetails extends StatefulWidget {
  final String? selectedCode; // Changed from selectedRoomCode to selectedCode
  final Function onRoomAdded;

  RoomDetails({
    required this.onRoomAdded,
    this.selectedCode, // Changed from selectedRoomCode to selectedCode
    required List<String> roomTypes,
    required String adminName,
    required String profileImagePath,
  });

  @override
  _RoomDetailsState createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  String? selectedType;
  String? selectedStatus;
  TextEditingController codeController = TextEditingController(); // Changed from roomCodeController to codeController
  TextEditingController roomController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded type list
  List<String> typeList = ['Computer Laboratory', 'Office', 'Conference Room'];
  // Hardcoded status list
  List<String> statusList = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    if (widget.selectedCode != null && widget.selectedCode!.isNotEmpty) { // Changed from selectedRoomCode to selectedCode
      codeController.text = widget.selectedCode!; // Changed from roomCodeController to codeController
      _fetchRoomDetails(widget.selectedCode!); // Changed from selectedRoomCode to selectedCode
    } else {
      print('selectedCode is null or empty'); // Changed from selectedRoomCode to selectedCode
    }
  }

  void _fetchRoomDetails(String code) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('rooms').doc(code).get();

      if (snapshot.exists) {
        print('Room details fetched successfully');
        print(snapshot.data());  // Logs the room data from Firestore
        setState(() {
          codeController.text = snapshot['code'] ?? ''; // Changed from roomCodeController to codeController
          roomController.text = snapshot['name'] ?? '';
          selectedType = snapshot['type'];
          selectedStatus = snapshot['status'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No room found for this code.'))); // Changed from roomCode to code
      }
    } catch (e) {
      print('Error fetching room details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch room details: $e')));
    }
  }

  Future<void> _saveRoomDetails() async {
    if (_validateFields()) {
      try {
        await _firestore.collection('rooms').doc(codeController.text).set({ // Changed from roomCodeController to codeController
          'code': codeController.text, // Changed from roomCodeController to codeController
          'name': roomController.text,
          'type': selectedType,
          'status': selectedStatus,
        });

        widget.onRoomAdded();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room details saved successfully!')));
      } catch (e) {
        print('Error saving room details: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save room details: $e')));
      }
    }
  }

  bool _validateFields() {
    if (codeController.text.isEmpty || roomController.text.isEmpty || selectedType == null || selectedStatus == null) { // Changed from roomCodeController to codeController
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all required fields')));
      return false;
    }
    return true;
  }

  void _clearFields() {
    codeController.clear(); // Changed from roomCodeController to codeController
    roomController.clear();
    setState(() {
      selectedType = typeList.first; // Set default type
      selectedStatus = statusList.first; // Set default status
    });
  }

  Widget _buildTypeDropdown() {
    return Container(
      width: 170,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Type',
          border: OutlineInputBorder(),
        ),
        value: selectedType,
        items: typeList.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedType = value;
          });
        },
        hint: const Text('Select Type'),
      ),
    );
  }


  Widget _buildStatusDropdown() {
    return Container(
      width: 170,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
        ),
        value: selectedStatus,
        items: statusList.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedStatus = value;
          });
        },
        hint: const Text('Select Status'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Room Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController, // Changed from roomCodeController to codeController
                    decoration: const InputDecoration(labelText: 'Code', border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.password),), // Changed from Room Code to Code
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.meeting_room),),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTypeDropdown(),
                const SizedBox(width: 8),
                _buildStatusDropdown(),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _saveRoomDetails,
                  child: const Text('Save'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
