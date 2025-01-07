import 'package:capstonesproject2024/Sidebar.dart';
import 'package:flutter/material.dart';

class FacultyReservationScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const FacultyReservationScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _FacultyReservationScreenState createState() =>
      _FacultyReservationScreenState();
}

class _FacultyReservationScreenState extends State<FacultyReservationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _teacherNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedRoom;
  final List<String> _rooms = ['Room 101', 'Room 102', 'Room 103'];
  final List<Map<String, String>> _reservations = [];

  void _submitReservation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _reservations.add({
          'teacherName': _teacherNameController.text,
          'startTime': _startTimeController.text,
          'endTime': _endTimeController.text,
          'room': _selectedRoom!,
          'date': _dateController.text,
          'description': _descriptionController.text,
        });
      });

      // Clear form fields
      _teacherNameController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      _descriptionController.clear();
      _dateController.clear();
      setState(() {
        _selectedRoom = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Reservation Form inside a Card with expanded width
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32, // Adjusted horizontal padding
                        vertical: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Row for Teacher Name and Room dropdown
                            Row(
                              children: [
                                // Teacher Name Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: TextFormField(
                                      controller: _teacherNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Teacher Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the teacher\'s name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                // Room Dropdown
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Select Room',
                                        border: OutlineInputBorder(),
                                      ),
                                      value: _selectedRoom,
                                      items: _rooms
                                          .map((room) => DropdownMenuItem(
                                        value: room,
                                        child: Text(room),
                                      ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRoom = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a room';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row for Date and Start Time
                            Row(
                              children: [
                                // Date Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: TextFormField(
                                      controller: _dateController,
                                      decoration: const InputDecoration(
                                        labelText: 'Reservation Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _dateController.text =
                                            "${date.toLocal()}".split(' ')[0];
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a date';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                // Start Time Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: TextFormField(
                                      controller: _startTimeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Start Time',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final timeOfDay = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (timeOfDay != null) {
                                          setState(() {
                                            _startTimeController.text =
                                                timeOfDay.format(context);
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a start time';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row for End Time and Description
                            Row(
                              children: [
                                // End Time Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: TextFormField(
                                      controller: _endTimeController,
                                      decoration: const InputDecoration(
                                        labelText: 'End Time',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        final timeOfDay = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (timeOfDay != null) {
                                          setState(() {
                                            _endTimeController.text =
                                                timeOfDay.format(context);
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select an end time';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                // Description Field
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: TextFormField(
                                      controller: _descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _submitReservation,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0),
                              ),
                              child: const Text(
                                'Book Room',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reservation List
                  Expanded(
                    child: _reservations.isEmpty
                        ? const Center(
                      child: Text(
                        'No reservations yet!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = _reservations[index];
                        return Card(
                          margin:
                          const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text('Room: ${reservation['room']}'),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Teacher: ${reservation['teacherName']}'),
                                Text('Date: ${reservation['date']}'),
                                Text(
                                    'Time: ${reservation['startTime']} - ${reservation['endTime']}'),
                                Text('Description: ${reservation['description']}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _reservations.removeAt(index);
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text('Reservation deleted.'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
