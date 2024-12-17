import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/Sidebar.dart';
import 'package:capstonesproject2024/models.dart';

class SchedulingDetails extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  SchedulingDetails({
    required this.profileImagePath,
    required this.adminName, required Null Function(dynamic schedules) onScheduleUpdated,
  });

  @override
  _SchedulingDetailsState createState() => _SchedulingDetailsState();
}

class _SchedulingDetailsState extends State<SchedulingDetails> {
  TextEditingController subjectController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController instructorController = TextEditingController();

  String? selectedLabAssistant;
  String? selectedRoom;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> labAssistantList = [];
  List<Map<String, String>> maryThomaslist = [];
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchLabAssistants();
    fetchMTData();
    _fetchSchedules();
  }

  // Fetch lab assistants
  Future<void> _fetchLabAssistants() async {
    try {
      _firestore.collection('lab_assistants').snapshots().listen((snapshot) {
        setState(() {
          labAssistantList = snapshot.docs.map((doc) => doc['name'] as String).toList();
        });
      });
    } catch (e) {
      print('Error fetching lab assistants: $e');
    }
  }

  // Fetch MT data (for room list)
  Future<List<MT>> getMTs(CollectionReference mtCollection) async {
    try {
      final snapshot = await mtCollection.get();
      return snapshot.docs.map((doc) {
        return MT.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching MTs: $e');
      return [];
    }
  }

  void fetchMTData() async {
    final mts = await getMTs(_firestore.collection('mt'));
    setState(() {
      maryThomaslist = mts.map((mt) => {'id': mt.id, 'name': mt.name}).toList();
    });
  }

  Future<void> _fetchSchedules() async {
    final schedulesSnapshot = await FirebaseFirestore.instance.collection('Schedules').get();
    setState(() {
      _schedules = schedulesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _addSchedule() async {
    if (subjectController.text.isEmpty ||
        timeController.text.isEmpty ||
        dayController.text.isEmpty ||
        instructorController.text.isEmpty ||
        selectedLabAssistant == null ||
        selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    final newSchedule = {
      'subject': subjectController.text,
      'time': timeController.text,
      'day': dayController.text,
      'instructor': instructorController.text,
      'labAssistant': selectedLabAssistant,
      'room': selectedRoom,
    };

    await FirebaseFirestore.instance.collection('Schedules').add(newSchedule);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule added successfully!')),
    );

    _clearFields();
    _fetchSchedules();
  }

  Future<void> _deleteSchedule(String docId) async {
    await FirebaseFirestore.instance.collection('Schedules').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule deleted successfully!')),
    );
    _fetchSchedules();
  }

  void _clearFields() {
    subjectController.clear();
    timeController.clear();
    dayController.clear();
    instructorController.clear();
    setState(() {
      selectedLabAssistant = null;
      selectedRoom = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildScheduleForm(),
                  SizedBox(height: 16),
                  _buildScheduleTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Schedule Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            Row(
              children: [
                Container(
                  width: 790,
                  child: _buildTextField(subjectController, 'Subject'),
                ),
                SizedBox(width: 16),
                Container(
                  width: 790,
                  child: _buildTextField(instructorController, 'Instructor'),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 300,
                      child: _buildDropdownField(
                          'Lab Assistant', labAssistantList, selectedLabAssistant, (value) {
                        setState(() {
                          selectedLabAssistant = value;
                        });
                      }),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: 300,
                      child: _buildRoomDropdown(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 300,
                      child: _buildTextField(timeController, 'Time', width: 250),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: 300,
                      child: _buildTextField(dayController, 'Day', width: 180),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _addSchedule,
                  child: Text(
                    'Add Schedule',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: Text(
                    'Clear Fields',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {double width = double.infinity}) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: value?.isEmpty ?? true ? null : value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text('Select $label'),
    );
  }

  Widget _buildRoomDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Room',
        border: OutlineInputBorder(),
      ),
      value: selectedRoom,
      items: maryThomaslist.map((mt) {
        return DropdownMenuItem<String>(
          value: mt['name'],
          child: Text(mt['name'] ?? 'Unknown Room'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRoom = value;
        });
      },
      hint: Text('Select Room'),
    );
  }

  Widget _buildScheduleTable() {
    return Card(
      elevation: 4,
      child: Container(
        width: 2000,
        height: 450,
        padding: const EdgeInsets.all(10),
        child: DataTable(
          columnSpacing: 20, // Adjust spacing between columns
          dataRowHeight: 50,
          headingRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(Colors.black),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          border: TableBorder.all(color: Colors.black, width: 3),
          columns: const [
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Instructor')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Day')),
            DataColumn(label: Text('Lab Assistant')),
            DataColumn(label: Text('Room')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _schedules.map((schedule) {
            return DataRow(cells: [
              DataCell(Text(schedule['subject'] ?? '')),
              DataCell(Text(schedule['instructor'] ?? '')),
              DataCell(Text(schedule['time'] ?? '')),
              DataCell(Text(schedule['day'] ?? '')),
              DataCell(Text(schedule['labAssistant'] ?? '')),
              DataCell(Text(schedule['room'] ?? '')),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteSchedule(schedule['id']),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
