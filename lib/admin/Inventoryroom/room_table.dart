import 'package:capstonesproject2024/models.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomTable extends StatefulWidget {
  final Function onRoomAdded;  // Callback to update the table when a room is added, updated, or deleted

  RoomTable({required this.onRoomAdded});

  @override
  _RoomTableState createState() => _RoomTableState();
}

class _RoomTableState extends State<RoomTable> {
  String _searchText = '';
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() async {
    List<Room> rooms = await fetchRooms();
    setState(() {
      _rooms = rooms;
    });
  }

  Future<List<Room>> fetchRooms() async {
    List<Room> rooms = [];
    final querySnapshot = await FirestoreService.getRooms();
    rooms = querySnapshot.docs.map((doc) {
      return Room.fromFirestore(doc);
    }).toList();
    return rooms;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by room name | room code | type | status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.black, width: 3),
                  columnSpacing: 270,
                  dataRowHeight: 75,
                  headingRowColor: MaterialStateProperty.all(Colors.black),
                  columns: const [
                    DataColumn(label: Text('Room Name', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Room Code', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Type', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                  rows: _rooms.where((room) {
                    return room.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                        room.roomCode.toLowerCase().contains(_searchText.toLowerCase()) ||
                        room.type.toLowerCase().contains(_searchText.toLowerCase()) ||
                        room.status.toLowerCase().contains(_searchText.toLowerCase());
                  }).map((room) {
                    return DataRow(cells: [
                      DataCell(Text(room.name)),
                      DataCell(Text(room.roomCode)),
                      DataCell(Text(room.type)),
                      DataCell(Text(room.status)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () {
                                _viewRoom(room.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                _updateRoom(room);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteRoom(room.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewRoom(String id) {
    // Handle viewing room details, maybe navigate to RoomDetails screen
    print('Viewing room: $id');
  }

  void _updateRoom(Room room) {
    // Handle updating the room
    widget.onRoomAdded(); // Refresh the table after the room is updated
    print('Updating room: ${room.id}');
  }

  void _deleteRoom(String id) {
    // Delete room from Firestore and update the table
    FirestoreService.deleteRoom(id);
    setState(() {
      _rooms.removeWhere((room) => room.id == id);
    });
    widget.onRoomAdded(); // Refresh the table after deletion
    print('Deleted room: $id');
  }
}

// FirestoreService update method for deleting room
class FirestoreService {
  static Future<QuerySnapshot> getRooms() async {
    return FirebaseFirestore.instance.collection('rooms').get();
  }

  static Future<void> deleteRoom(String id) async {
    await FirebaseFirestore.instance.collection('rooms').doc(id).delete();
  }
}
