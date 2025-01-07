import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your MTRoom model

class MTRoomManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final Function(List<MTRoom>) onRoomsUpdated;

  const MTRoomManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onRoomsUpdated,
  }) : super(key: key);

  @override
  _MTRoomManagementScreenState createState() => _MTRoomManagementScreenState();
}

class _MTRoomManagementScreenState extends State<MTRoomManagementScreen> {
  final TextEditingController mtRoomNameController = TextEditingController(); // Renamed controller
  final TextEditingController mtRoomDescriptionController = TextEditingController(); // Renamed controller

  bool _isMTRoomTableVisible = false;
  List<MTRoom> mtRooms = [];
  int nextRoomId = 1; // Auto-incrementing ID starts from 1

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadMTRooms(); // Fetch MTRooms
  }

  // Load MTRooms from Firestore
  Future<void> _loadMTRooms() async {
    List<MTRoom> fetchedMTRooms = await _firestoreService.getMTRooms(); // Fetch MTRooms
    setState(() {
      mtRooms = fetchedMTRooms;
      nextRoomId = mtRooms.isNotEmpty
          ? (mtRooms.map((e) => int.tryParse(e.id.toString()) ?? 0).reduce((a, b) => a > b ? a : b) + 1)
          : 1;
    });
    widget.onRoomsUpdated(mtRooms);  // Update the mtRooms list
  }

  // Add a new MTRoom
  Future<void> addMTRoom() async {
    if (mtRoomNameController.text.isEmpty || mtRoomDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both room name and description fields.')),
      );
      return;
    }

    final newMTRoom = MTRoom(
      id: nextRoomId.toString(),  // Use String for the ID
      name: mtRoomNameController.text.trim(),
      description: mtRoomDescriptionController.text.trim(),
    );

    await _firestoreService.addMTRoom(newMTRoom);

    setState(() {
      mtRooms.add(newMTRoom);
      nextRoomId++;
    });

    widget.onRoomsUpdated(mtRooms); // Notify parent about the update

    mtRoomNameController.clear();
    mtRoomDescriptionController.clear();
  }

  // Edit MTRoom
  Future<void> editMTRoom(MTRoom mtRoom) async {
    mtRoomNameController.text = mtRoom.name;
    mtRoomDescriptionController.text = mtRoom.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit MTRoom: ${mtRoom.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mtRoomNameController, // Use the renamed controller
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: mtRoomDescriptionController, // Use the renamed controller
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
                final updatedMTRoom = MTRoom(
                  id: mtRoom.id,
                  name: mtRoomNameController.text.trim(),
                  description: mtRoomDescriptionController.text.trim(),
                );

                try {
                  await _firestoreService.updateMTRoom(updatedMTRoom);
                  await _loadMTRooms(); // Refresh list after update
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating MTRoom: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete MTRoom
  Future<void> deleteMTRoom(MTRoom mtRoom) async {
    await _firestoreService.deleteMTRoom(mtRoom.id);
    setState(() {
      mtRooms.remove(mtRoom);
    });

    widget.onRoomsUpdated(mtRooms); // Notify parent about the update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MTRoom Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: mtRoomNameController, // Use the renamed controller
              decoration: InputDecoration(labelText: 'Room Name'),
            ),
            TextField(
              controller: mtRoomDescriptionController, // Use the renamed controller
              decoration: InputDecoration(labelText: 'Room Description'),
            ),
            ElevatedButton(
              onPressed: addMTRoom,
              child: Text('Add MTRoom'),
            ),
            Row(
              children: [
                const Text(
                  'View MTRooms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isMTRoomTableVisible = !_isMTRoomTableVisible;
                    });
                  },
                  child: Icon(
                    _isMTRoomTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isMTRoomTableVisible)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 50,
                          dataRowHeight: 50,
                          headingRowColor: MaterialStateProperty.all(Colors.white70),
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: mtRooms.map((mtRoom) {
                            return DataRow(
                              cells: [
                                DataCell(Text(mtRoom.id)),
                                DataCell(Text(mtRoom.name)),
                                DataCell(Text(mtRoom.description)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        editMTRoom(mtRoom);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        deleteMTRoom(mtRoom);
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
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
