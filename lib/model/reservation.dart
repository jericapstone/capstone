import 'package:capstonesproject2024/Sidebar.dart';
import 'package:capstonesproject2024/services/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
  /// Holds all reservations, keyed by date
  Map<DateTime, List<Reservation>> _reservationsMap = {};

  /// Calendar states
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// For picking date/time in the dialog
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  /// Controllers for the dialog fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  /// A form key for the reservation dialog
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fetch all reservations from Firestore and build the _reservationsMap
  Future<void> _fetchReservations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('reservations').get();

    Map<DateTime, List<Reservation>> reservations = {};

    for (var doc in snapshot.docs) {
      Reservation reservation = Reservation.fromDocument(doc);

      // Use only the date portion as the key
      DateTime dateKey = DateTime(
        reservation.startDateTime.year,
        reservation.startDateTime.month,
        reservation.startDateTime.day,
      );

      reservations[dateKey] ??= [];
      reservations[dateKey]!.add(reservation);
    }

    setState(() {
      _reservationsMap = reservations;
    });
  }

  /// Returns the reservations for a particular [day]
  List<Reservation> _getReservationsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _reservationsMap[key] ?? [];
  }

  /// Return 'Upcoming', 'Ongoing', or 'Done'
  String _getReservationStatus(Reservation reservation) {
    final now = DateTime.now();
    if (now.isBefore(reservation.startDateTime)) {
      return 'Upcoming';
    } else if (now.isAfter(reservation.endDateTime)) {
      return 'Done';
    } else {
      return 'Ongoing';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.orange;
      case 'Done':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  // -------------------------------------------------------------------
  // DIALOG FOR NEW RESERVATIONS
  // -------------------------------------------------------------------
  void _showNewReservationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New Reservation'),
          content: SingleChildScrollView(
            child: Form(
              key: _dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // Room
                  TextFormField(
                    controller: _roomController,
                    decoration: InputDecoration(
                      labelText: 'Room Name/Number',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the room name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),

                  // Date
                  GestureDetector(
                    onTap: () => _pickDate(),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Reservation Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select a date.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Start Time
                  GestureDetector(
                    onTap: () => _pickStartTime(),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(
                          text: _startTime == null
                              ? ''
                              : _startTime!.format(context),
                        ),
                        validator: (value) {
                          if (_startTime == null) {
                            return 'Please select a start time.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // End Time
                  GestureDetector(
                    onTap: () => _pickEndTime(),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(
                          text:
                              _endTime == null ? '' : _endTime!.format(context),
                        ),
                        validator: (value) {
                          if (_endTime == null) {
                            return 'Please select an end time.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _clearFormFields();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () => _submitReservation(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  /// Validate & create the reservation in Firestore
  Future<void> _submitReservation() async {
    if (!_dialogFormKey.currentState!.validate()) {
      return; // form invalid
    }

    // Combine date/time
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Check overlap
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('reservations').get();
    final allReservations =
        snapshot.docs.map((doc) => Reservation.fromDocument(doc)).toList();

    // Filter for same date & room
    final sameDateReservations = allReservations.where((res) {
      bool sameDay = res.startDateTime.year == _selectedDate!.year &&
          res.startDateTime.month == _selectedDate!.month &&
          res.startDateTime.day == _selectedDate!.day;
      bool sameRoom =
          res.room.toLowerCase() == _roomController.text.trim().toLowerCase();
      return sameDay && sameRoom;
    }).toList();

    bool hasOverlap = sameDateReservations.any((res) {
      return startDateTime.isBefore(res.endDateTime) &&
          endDateTime.isAfter(res.startDateTime);
    });

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This room is already reserved for the selected time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Create new reservation
    final newReservation = Reservation(
      id: '',
      name: _nameController.text.trim(),
      room: _roomController.text.trim(),
      description: _descriptionController.text.trim(),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );

    // Save to Firestore
    await firestore.collection('reservations').add(newReservation.toMap());

    // Refresh the calendar data
    await _fetchReservations();

    // Close dialog
    Navigator.of(context).pop();

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room reserved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear fields
    _clearFormFields();
  }

  /// Clears all form fields and resets date/time
  void _clearFormFields() {
    _dialogFormKey.currentState?.reset();
    _nameController.clear();
    _roomController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  // -------------------------------------------------------------------
  // BUILD: UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDEBAR
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),

          // MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top row: Title + button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faculty Room Reservations',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('New Reservation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _showNewReservationDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // The Calendar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: TableCalendar(
                        // Restrict to current to next year
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        // Custom day builders to show reservations + highlight
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            // If day out of current month, show in grey
                            if (day.month != focusedDay.month) {
                              return Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            final dayReservations = _getReservationsForDay(day);
                            final hasReservations = dayReservations.isNotEmpty;

                            return Container(
                              margin: EdgeInsets.all(2.0),
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                // HIGHLIGHT the day if it has reservations
                                color: hasReservations
                                    ? Colors.yellow.withOpacity(0.3)
                                    : Colors.transparent,
                                border:
                                    Border.all(color: Colors.teal, width: 1),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Day number
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Show up to 2 reservations (with times)
                                  for (var r in dayReservations.take(2))
                                    Text(
                                      '${r.name}\n${DateFormat('HH:mm').format(r.startDateTime)}-${DateFormat('HH:mm').format(r.endDateTime)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (dayReservations.length > 2)
                                    Text(
                                      '+${dayReservations.length - 2} more',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          // Selected day builder
                          selectedBuilder: (context, day, focusedDay) {
                            final dayReservations = _getReservationsForDay(day);

                            return Container(
                              margin: EdgeInsets.all(2.0),
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade300,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  for (var r in dayReservations.take(2))
                                    Text(
                                      '${r.name}\n${DateFormat('HH:mm').format(r.startDateTime)}-${DateFormat('HH:mm').format(r.endDateTime)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (dayReservations.length > 2)
                                    Text(
                                      '+${dayReservations.length - 2} more',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.yellowAccent,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          markersMaxCount: 0, // not using markerBuilder
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                          ),
                          titleTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
