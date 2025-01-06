
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your AccountType model

class AccountTypeManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const AccountTypeManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _AccountTypeManagementScreenState createState() => _AccountTypeManagementScreenState();
}

class _AccountTypeManagementScreenState extends State<AccountTypeManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  bool _isTableVisible = false;
  List<AccountType> accountTypes = [];
  int nextId = 1; // Auto-incrementing ID starts from 1

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadAccountTypes();
  }


  Future<void> _loadAccountTypes() async {
    try {
      // Pass the required parameter here
      List<AccountType> fetchedAccountTypes = await FirestoreService.getAccountTypes();
      setState(() {
        accountTypes = fetchedAccountTypes; // Use empty list if null
        nextId = fetchedAccountTypes.isNotEmpty
            ? (fetchedAccountTypes.map((e) => int.tryParse(e.id) ?? 0).reduce((a, b) => a > b ? a : b) + 1)
            : 1;
      });
    } catch (e) {
      print('Error loading account types: $e');
      setState(() {
        accountTypes = [];
      });
    }
  }


  Future<void> addAccountType() async {
    if (nameController.text.isEmpty || statusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both name and status fields.')),
      );
      return;
    }

    final newAccountType = AccountType(
      id: nextId.toString(),
      name: nameController.text.trim(),
      status: statusController.text.trim(),
    );

    await _firestoreService.addAccountType(newAccountType);

    setState(() {
      accountTypes.add(newAccountType);
      nextId++;
    });

    nameController.clear();
    statusController.clear();
  }

  Future<void> editAccountType(AccountType accountType) async {
    nameController.text = accountType.name;
    statusController.text = accountType.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Account Type: ${accountType.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedAccountType = AccountType(
                  id: accountType.id,
                  name: nameController.text.trim(),
                  status: statusController.text.trim(),
                );

                try {
                  await _firestoreService.updateAccountType(updatedAccountType);
                  await _loadAccountTypes();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating account type: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccountType(String id) async {
    await _firestoreService.deleteAccountType(id);
    setState(() {
      accountTypes.removeWhere((accountType) => accountType.id == id);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Type Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                width: 400,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: statusController,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: addAccountType,
                          child: const Text('Add Account Type'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'View Account Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isTableVisible = !_isTableVisible;
                      });
                    },
                    child: Icon(
                      _isTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isTableVisible)
                Card(
                  elevation: 4,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 50,
                      dataRowHeight: 50,
                      headingRowColor: MaterialStateProperty.all(Colors.black),
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      border: TableBorder.all(color: Colors.black, width: 2),
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: accountTypes.map((accountType) {
                        return DataRow(cells: [
                          DataCell(Text(accountType.id)),
                          DataCell(Text(accountType.name)),
                          DataCell(Text(accountType.status)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => editAccountType(accountType),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteAccountType(accountType.id),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}