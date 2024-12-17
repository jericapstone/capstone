import 'package:capstonesproject2024/admin/usermanagement/edit_user_popup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserTablePage extends StatefulWidget {
  @override
  _UserTablePageState createState() => _UserTablePageState();
}

class _UserTablePageState extends State<UserTablePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _userDocs = [];
  List<DocumentSnapshot> _filteredUserDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _userDocs = snapshot.docs;
      _filteredUserDocs = _userDocs;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUserDocs = _userDocs.where((user) {
        final data = user.data() as Map<String, dynamic>;
        final firstName = (data['firstName'] ?? '').toLowerCase();
        final lastName = (data['lastName'] ?? '').toLowerCase();
        final email = (data['email'] ?? '').toLowerCase();

        return firstName.contains(query) ||
            lastName.contains(query) ||
            email.contains(query);
      }).toList();
    });
  }

  Future<void> _exportToCSV() async {
    List<List<String>> csvData = [
      ['First Name', 'Last Name', 'Email', 'Account Type', 'Status'],
      ..._filteredUserDocs.map((user) {
        final data = user.data() as Map<String, dynamic>;
        return [
          (data['firstName'] ?? '').toString(),
          (data['lastName'] ?? '').toString(),
          (data['email'] ?? '').toString(),
          (data['accountType'] ?? '').toString(),
          (data['status'] ?? '').toString(),
        ];
      }).toList(),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users.csv');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV exported to ${file.path}')),
    );
  }


  void _showEditUserPopup(BuildContext context, DocumentSnapshot userDoc) {
    showDialog(
      context: context,
      builder: (context) => EditUserPopup(
        userDoc: userDoc,
        onUpdated: () {
          setState(() {
            // Refresh the table or fetch the updated data
          });
        },
      ),
    );
  }

  void _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    _fetchUsers();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search by name or email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _exportToCSV,
          icon: Icon(Icons.download),
          label: Text('Export CSV'),
        ),
      ],
    );
  }

  Widget _buildUserTable() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        height: 600,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 10),
                  _buildActionButtons(),
                ],
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 200,
                  dataRowHeight: 50,
                  headingRowHeight: 50,
                  headingRowColor: MaterialStateProperty.all(Colors.black),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  border: TableBorder.all(color: Colors.black, width: 3),
                  columns: const [
                    DataColumn(label: Text('FIRST NAME')),
                    DataColumn(label: Text('LAST NAME')),
                    DataColumn(label: Text('EMAIL ADDRESS')),
                    DataColumn(label: Text('ACCOUNT TYPE')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: _filteredUserDocs.map((user) {
                    final data = user.data() as Map<String, dynamic>;
                    return DataRow(cells: [
                      DataCell(Text(data['firstName'] ?? 'N/A')),
                      DataCell(Text(data['lastName'] ?? 'N/A')),
                      DataCell(Text(data['email'] ?? 'N/A')),
                      DataCell(Text(data['accountType'] ?? 'N/A')),
                      DataCell(Text(data['status'] ?? 'N/A')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _showEditUserPopup(context, user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(user.id),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: _buildUserTable(),
      ),
    );
  }
}
