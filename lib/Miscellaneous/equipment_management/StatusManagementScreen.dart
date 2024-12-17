import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your Status model

class StatusManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final Function(List<Status>) onStatusesUpdated; // Callback to update dropdown

  const StatusManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onStatusesUpdated, // Pass the callback
  }) : super(key: key);

  @override
  _StatusManagementScreenState createState() => _StatusManagementScreenState();
}

class _StatusManagementScreenState extends State<StatusManagementScreen> {
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isStatusTableVisible = false;
  List<Status> statuses = [];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  // Load statuses from Firestore
  Future<void> _loadStatuses() async {
    List<Status> fetchedStatuses = await _firestoreService.getStatuses();
    setState(() {
      statuses = fetchedStatuses;
    });

    widget.onStatusesUpdated(statuses); // Update the dropdown list
  }

  // Add a new status
  Future<void> addStatuses() async {
    if (statusController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both status and description fields.')),
      );
      return;
    }

    final newStatus = Status(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: statusController.text.trim(),
      description: descriptionController.text.trim(),
    );

    await _firestoreService.addStatus(newStatus);

    setState(() {
      statuses.add(newStatus);
    });

    widget.onStatusesUpdated(statuses); // Update the dropdown list

    // Clear input fields after saving
    statusController.clear();
    descriptionController.clear();
  }

  // Edit status
  Future<void> editStatus(Status status) async {
    statusController.text = status.name;
    descriptionController.text = status.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Status: ${status.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: statusController, // Correct usage of named argument
                decoration: const InputDecoration(
                  labelText: 'Status Name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController, // Correct usage of named argument
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                  ),
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
                final updatedStatus = Status(
                  id: status.id,
                  name: statusController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                try {
                  await _firestoreService.updateStatus(updatedStatus);
                  await _loadStatuses(); // Refresh list after update
                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating status: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete status
  Future<void> deleteStatus(String id) async {
    await _firestoreService.deleteStatus(id);
    setState(() {
      statuses.removeWhere((status) => status.id == id);
    });

    widget.onStatusesUpdated(statuses); // Update the dropdown list
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
                'Status Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Input Card for Adding Status
              Container(
                width: 400,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: statusController, // Correct usage of named argument
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: addStatuses,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: descriptionController, // Correct usage of named argument
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                descriptionController.clear();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Toggle Button to Show/Hide Status Table
              Row(
                children: [
                  const Text(
                    'View Statuses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isStatusTableVisible = !_isStatusTableVisible;
                      });
                    },
                    child: Icon(
                      _isStatusTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data Table Inside Card (Placed inside the card now)
              if (_isStatusTableVisible)
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
                            columnSpacing: 50, // Adjusted to match the brand table
                            dataRowHeight: 50, // Adjusted to match the brand table
                            headingRowColor: MaterialStateProperty.all(Colors.black),
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            border: TableBorder.all(color: Colors.black, width: 2),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: statuses.map(
                                  (status) {
                                return DataRow(cells: [
                                  DataCell(Text(status.id)),
                                  DataCell(Text(status.name)),
                                  DataCell(Text(status.description)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.green),
                                        onPressed: () => editStatus(status),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => deleteStatus(status.id),
                                      ),
                                    ],
                                  )),
                                ]);
                              },
                            ).toList(),
                          ),
                        ),
                      ],
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
