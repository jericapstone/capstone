import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart'; // Import your MT model

class MTManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const MTManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _MTManagementScreenState createState() => _MTManagementScreenState();
}

class _MTManagementScreenState extends State<MTManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  bool _isTableVisible = false;
  List<MT> mts = [];
  int nextId = 1; // Auto-incrementing ID starts from 1

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadMTs();
  }

  Future<void> _loadMTs() async {
    List<MT> fetchedMTs = await _firestoreService.getMTs();
    setState(() {
      mts = fetchedMTs;
      nextId = fetchedMTs.isNotEmpty
          ? (fetchedMTs.map((e) => int.tryParse(e.id) ?? 0).reduce((a, b) => a > b ? a : b) + 1)
          : 1;
    });
  }

  Future<void> addMT() async {
    if (nameController.text.isEmpty || departmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both name and department fields.')),
      );
      return;
    }

    final newMT = MT(
      id: nextId.toString(),
      name: nameController.text.trim(),
      department: departmentController.text.trim(),
    );

    await _firestoreService.addMT(newMT);

    setState(() {
      mts.add(newMT);
      nextId++;
    });

    nameController.clear();
    departmentController.clear();
  }

  Future<void> editMT(MT mt) async {
    nameController.text = mt.name;
    departmentController.text = mt.department;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit MT: ${mt.id}'),
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
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
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
                final updatedMT = MT(
                  id: mt.id,
                  name: nameController.text.trim(),
                  department: departmentController.text.trim(),
                );

                try {
                  await _firestoreService.updateMT(updatedMT);
                  await _loadMTs();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error updating MT: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMT(String id) async {
    await _firestoreService.deleteMT(id);
    setState(() {
      mts.removeWhere((mt) => mt.id == id);
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
                'MT Management',
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
                          controller: departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: addMT,
                          child: const Text('Add MT'),
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
                    'View MTs',
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
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: mts.map((mt) {
                        return DataRow(cells: [
                          DataCell(Text(mt.id)),
                          DataCell(Text(mt.name)),
                          DataCell(Text(mt.department)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => editMT(mt),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteMT(mt.id),
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
