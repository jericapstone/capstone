import 'package:capstonesproject2024/admin/Inventoryroom/inventory_popup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedTable extends StatefulWidget {
  final String? selectedRoomCode;

  PaginatedTable({Key? key, this.selectedRoomCode}) : super(key: key);

  @override
  _PaginatedTableState createState() => _PaginatedTableState();
}

class _PaginatedTableState extends State<PaginatedTable> {
  final Stream<QuerySnapshot> _roomsStream =
  FirebaseFirestore.instance.collection('rooms').snapshots();
  final int rowsPerPage = 5;
  List<Map<String, dynamic>> localRoomData = [];

  void addRoom(Map<String, dynamic> newRoom) {
    setState(() {
      localRoomData.add(newRoom);
    });
  }

  void _editRoom(Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (context) {
        return InventoryPopup(inventoryItem: room);
      },
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _roomsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rooms available.'));
        }

        final roomDataFirestore = snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          return {
            'id': document.id,
            'description': data['room'] ?? 'N/A',
            'type': data['type'] ?? 'N/A',
            'status': data['status'] ?? 'N/A',
          };
        }).toList();

        final allRoomData = widget.selectedRoomCode != null
            ? roomDataFirestore
            .where((room) => room['description'] == widget.selectedRoomCode)
            .toList()
            : [...roomDataFirestore, ...localRoomData];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2), // Border color and width
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: PaginatedDataTable(
              header: Text(
                'Room List',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              columns: [
                DataColumn(
                  label: Container(
                    width: 220,
                    child: Center(child: Text('Room')),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 160,
                    child: Center(child: Text('Type')),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 160,
                    child: Center(child: Text('Status')),
                  ),
                ),
                DataColumn(
                  label: Container(
                    width: 140,
                    child: Center(child: Text('Actions')),
                  ),
                ),
              ],
              source: _RoomDataSource(
                context,
                allRoomData,
                onDelete: (index) {
                  setState(() {
                    localRoomData.removeAt(index);
                  });
                },
                onEdit: (room) {
                  _editRoom(room);
                },
              ),
              rowsPerPage: rowsPerPage,
              showCheckboxColumn: false,
              columnSpacing: 300,
              dataRowMaxHeight: 50,
              headingRowHeight: 50,
              headingRowColor: MaterialStateProperty.all(Colors.blueAccent),
              onRowsPerPageChanged: null,
            ),
          ),
        );
      },
    );
  }
}

class _RoomDataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  _RoomDataSource(this.context, this.data, {required this.onEdit, required this.onDelete});

  @override
  DataRow getRow(int index) {
    final room = data[index];
    return DataRow(cells: [
      DataCell(
        Container(
          width: 200,
          child: Text(room['description'], textAlign: TextAlign.center),
        ),
      ),
      DataCell(
        Container(
          width: 150,
          child: Text(room['type'], textAlign: TextAlign.center),
        ),
      ),
      DataCell(
        Container(
          width: 150,
          child: Text(room['status'], textAlign: TextAlign.center),
        ),
      ),
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                onEdit(room);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                onDelete(index);
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
