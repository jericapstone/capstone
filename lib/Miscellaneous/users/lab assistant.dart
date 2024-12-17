import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your LabAssistant model

class LabAssistantManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const LabAssistantManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _LabAssistantManagementScreenState createState() => _LabAssistantManagementScreenState();
}

class _LabAssistantManagementScreenState extends State<LabAssistantManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController courseYearController = TextEditingController();

  bool _isTableVisible = false;
  List<LabAssistant> labAssistants = [];
  int nextId = 1; // Auto-incrementing ID starts from 1

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadLabAssistants();
  }

  Future<void> _loadLabAssistants() async {
    List<LabAssistant> fetchedLabAssistants = await _firestoreService.getLabAssistants();
    setState(() {
      labAssistants = fetchedLabAssistants;
      nextId = fetchedLabAssistants.isNotEmpty
          ? (fetchedLabAssistants.map((e) => int.tryParse(e.id) ?? 0).reduce((a, b) => a > b ? a : b) + 1)
          : 1;
    });
  }

  Future<void> addLabAssistant() async {
    if (nameController.text.isEmpty || courseYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both name and course & year fields.')),
      );
      return;
    }

    final newLabAssistant = LabAssistant(
      id: nextId.toString(),
      name: nameController.text.trim(),
      course: courseYearController.text.trim(),
    );

    await _firestoreService.addLabAssistant(newLabAssistant);

    setState(() {
      labAssistants.add(newLabAssistant);
      nextId++;
    });

    nameController.clear();
    courseYearController.clear();
  }

  Future<void> editLabAssistant(LabAssistant labAssistant) async {
    nameController.text = labAssistant.name;
    courseYearController.text = labAssistant.course;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Lab Assistant: ${labAssistant.id}'),
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
                controller: courseYearController,
                decoration: const InputDecoration(
                  labelText: 'Course & Year',
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
                final updatedLabAssistant = LabAssistant(
                  id: labAssistant.id,
                  name: nameController.text.trim(),
                  course: courseYearController.text.trim(),
                );

                try {
                  await _firestoreService.updateLabAssistant(updatedLabAssistant);
                  await _loadLabAssistants();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating lab assistant: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteLabAssistant(String id) async {
    await _firestoreService.deleteLabAssistant(id);
    setState(() {
      labAssistants.removeWhere((labAssistant) => labAssistant.id == id);
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
                'Lab Assistant Management',
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
                          controller: courseYearController,
                          decoration: const InputDecoration(
                            labelText: 'Course & Year',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: addLabAssistant,
                          child: const Text('Add Lab Assistant'),
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
                    'View Lab Assistants',
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
                        DataColumn(label: Text('Course & Year')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: labAssistants.map((labAssistant) {
                        return DataRow(cells: [
                          DataCell(Text(labAssistant.id)),
                          DataCell(Text(labAssistant.name)),
                          DataCell(Text(labAssistant.course)), // Combined Course & Year
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => editLabAssistant(labAssistant),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteLabAssistant(labAssistant.id),
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
