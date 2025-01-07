import 'package:capstonesproject2024/Sidebar.dart';
import 'package:capstonesproject2024/model/reservation.dart';
import 'package:capstonesproject2024/model/rooms.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRoomId; // Changed from Room? to String?
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // For Calendar
  Map<DateTime, List<Reservation>> _reservationsMap = {};

  // Added variables for calendar selection
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Fetch reservations from Firestore and map them to dates
  Future<void> _fetchReservations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('reservations').get();

    Map<DateTime, List<Reservation>> reservations = {};

    for (var doc in snapshot.docs) {
      Reservation reservation = Reservation.fromDocument(doc);

      // Only map the start date
      DateTime date = DateTime(reservation.startDateTime.year,
          reservation.startDateTime.month, reservation.startDateTime.day);

      if (reservations[date] == null) {
        reservations[date] = [];
      }
      reservations[date]!.add(reservation);
    }

    setState(() {
      _reservationsMap = reservations;
    });
  }

  /// Fetch available rooms from Firestore
  Stream<List<Room>> _fetchRooms() {
    return FirebaseFirestore.instance.collection('MTROOMS').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Room.fromDocument(doc)).toList());
  }

  /// Select reservation date via DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _selectedDay = picked; // Synchronize with calendar
        _focusedDay = picked; // Update focused day
      });
  }

  /// Select start time
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: now);
    if (picked != null && picked != _startTime)
      setState(() {
        _startTime = picked;
      });
  }

  /// Select end time
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: now);
    if (picked != null && picked != _endTime)
      setState(() {
        _endTime = picked;
      });
  }

  /// Submit reservation to Firestore
  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoomId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a room.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a reservation date.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select start and end times.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Combine date and time into DateTime objects
      DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      DateTime endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Validate that end time is after start time
      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('End time must be after start time.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Fetch the selected room's name using its id
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('MTROOMS')
          .doc(_selectedRoomId)
          .get();

      if (!roomDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected room does not exist.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      String roomName = roomDoc['name'] ?? '';

      // Fetch all reservations
      QuerySnapshot allReservationsSnapshot =
          await FirebaseFirestore.instance.collection('reservations').get();

      // Filter reservations for the selected room and date
      List<Reservation> reservationsForRoomAndDate = allReservationsSnapshot
          .docs
          .map((doc) => Reservation.fromDocument(doc))
          .where((reservation) =>
              reservation.room == roomName &&
              reservation.startDateTime.year == _selectedDate!.year &&
              reservation.startDateTime.month == _selectedDate!.month &&
              reservation.startDateTime.day == _selectedDate!.day)
          .toList();

      // Check for overlapping reservations
      bool hasOverlap = reservationsForRoomAndDate.any((reservation) {
        return startDateTime.isBefore(reservation.endDateTime) &&
            endDateTime.isAfter(reservation.startDateTime);
      });

      if (hasOverlap) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('This room is already reserved for the selected time.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Create reservation object
      Reservation reservation = Reservation(
        id: '',
        name: _nameController.text.trim(),
        room: roomName, // Use the room's name
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservation.toMap());

      // Refresh reservations map
      _fetchReservations();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room reserved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _formKey.currentState!.reset();
      setState(() {
        _selectedRoomId = null;
        _selectedDate = null;
        _selectedDay = null;
        _startTime = null;
        _endTime = null;
        _focusedDay = DateTime.now(); // Reset focused day
      });
    }
  }

  /// Determine reservation status
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

  /// Color based on reservation status
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

  /// Build reservation list for selected day
  List<Reservation> _getReservationsForDay(DateTime day) {
    DateTime key = DateTime(day.year, day.month, day.day);
    return _reservationsMap[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(children: [
      Sidebar(
        profileImagePath: widget.profileImagePath,
        adminName: widget.adminName,
      ),
      Expanded(
          child: Padding(
        padding:
            const EdgeInsets.all(18.0), // Increased padding for better spacing
        child: SingleChildScrollView(
          // Added SingleChildScrollView to prevent overflow
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to start
            children: [
              // Reservation Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        filled: true,
                        fillColor: Colors.teal.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none, // Remove border
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.teal),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Room Selection
                    StreamBuilder<List<Room>>(
                      stream: _fetchRooms(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error fetching rooms.',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(
                              color: Colors.teal,
                            ),
                          );
                        }
                        List<Room> rooms = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Select Room',
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none, // Remove border
                            ),
                            prefixIcon:
                                Icon(Icons.meeting_room, color: Colors.teal),
                          ),
                          value: _selectedRoomId,
                          items: rooms
                              .map(
                                (room) => DropdownMenuItem<String>(
                                  value: room.id, // Use room.id as the value
                                  child: Text(room.name),
                                ),
                              )
                              .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRoomId = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a room.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),

                    // Reservation Date
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Reservation Date',
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none, // Remove border
                            ),
                            suffixIcon:
                                Icon(Icons.calendar_today, color: Colors.teal),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Please select a reservation date.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Start Time
                    GestureDetector(
                      onTap: () => _selectStartTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none, // Remove border
                            ),
                            prefixIcon:
                                Icon(Icons.access_time, color: Colors.teal),
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
                    SizedBox(height: 16),

                    // End Time
                    GestureDetector(
                      onTap: () => _selectEndTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none, // Remove border
                            ),
                            prefixIcon:
                                Icon(Icons.access_time, color: Colors.teal),
                          ),
                          controller: TextEditingController(
                            text: _endTime == null
                                ? ''
                                : _endTime!.format(context),
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
                    SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitReservation,
                        child: Text('Reserve Room'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Calendar Widget
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay; // update `_focusedDay`
                        _selectedDate =
                            selectedDay; // synchronize with reservation date
                      });
                    }
                  },
                  eventLoader: _getReservationsForDay,
                  calendarStyle: CalendarStyle(
                    // Square decoration for today
                    todayDecoration: BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    // Square decoration for selected day
                    selectedDecoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    // Square markers
                    markerDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    markersMaxCount: 3,
                    markerSize: 8.0,
                    todayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    weekendTextStyle: TextStyle(color: Colors.teal),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: _buildMarkers(events),
                        );
                      }
                      return SizedBox();
                    },
                    dowBuilder: (context, day) {
                      // Adding grid lines by showing days of week with styling
                      final text = DateFormat.E().format(day);
                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      );
                    },
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
              SizedBox(height: 16),

              // Display Reservations for Selected Day
              _selectedDate == null
                  ? Container()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservations on ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        _getReservationsForDay(_selectedDate!).isEmpty
                            ? Text(
                                'No reservations for this day.',
                                style: TextStyle(color: Colors.grey[700]),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    _getReservationsForDay(_selectedDate!)
                                        .length,
                                itemBuilder: (context, index) {
                                  Reservation reservation =
                                      _getReservationsForDay(
                                          _selectedDate!)[index];
                                  String status =
                                      _getReservationStatus(reservation);
                                  return Card(
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.event_note,
                                          color: Colors.teal),
                                      title: Text(
                                        reservation.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                          '${DateFormat('HH:mm').format(reservation.startDateTime)} - ${DateFormat('HH:mm').format(reservation.endDateTime)}'),
                                      trailing: Text(
                                        status,
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
            ],
          ),
        ),
      ))
    ]));
  }

  /// Build markers for reservations
  Widget _buildMarkers(List<dynamic> events) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: events.map((event) {
        Reservation reservation = event as Reservation;
        String status = _getReservationStatus(reservation);
        Color markerColor = _getStatusColor(status);

        return Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: markerColor,
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      }).toList(),
    );
  }
}
