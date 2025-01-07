import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_user_popup.dart';

class UserDataSource extends DataTableSource {
  final List<DocumentSnapshot> _userDocs;
  final BuildContext _context;

  UserDataSource(this._userDocs, this._context);

  @override
  DataRow? getRow(int index) {
    if (index >= _userDocs.length) return null;
    final data = _userDocs[index].data() as Map<String, dynamic>;

    return DataRow(cells: [
      DataCell(Center(child: Text(data['firstName'] ?? '', style: TextStyle(color: Colors.black)))),
      DataCell(Center(child: Text(data['lastName'] ?? '', style: TextStyle(color: Colors.black)))),
      DataCell(Center(child: Text(data['email'] ?? '', style: TextStyle(color: Colors.black)))),
      DataCell(Center(child: Text(data['accountType'] ?? '', style: TextStyle(color: Colors.black)))),
      DataCell(Center(child: Text(data['status'] ?? '', style: TextStyle(color: Colors.black)))),
      DataCell(
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                onPressed: () {
                  // Implement your view logic here
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: () {
                  showDialog(
                    context: _context,
                    builder: (BuildContext context) {
                      return EditUserPopup(
                        userDoc: _userDocs[index],
                        onUpdated: () {
                          (context as Element).markNeedsBuild();
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteUser(_userDocs[index].id);
                },
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _userDocs.length;

  @override
  int get selectedRowCount => 0;

  Future<void> _deleteUser(String userId) async {
    final confirmDelete = await showDialog<bool>(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      } catch (e) {
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
}
