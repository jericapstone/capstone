import 'package:capstonesproject2024/Sidebar.dart';
import 'package:capstonesproject2024/model/reservation.dart';
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
  // Store all reservations in a map keyed by Date
  Map<DateTime, List<Reservation>> _reservationsMap = {};

  // Calendar states
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // For picking date/time in the dialog
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Controllers for the dialog fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // A form key for the dialog
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

  // -------------------------------------------------------------------
  // 🔎 FETCH RESERVATIONS
  // -------------------------------------------------------------------
  /// Fetch reservations from Firestore and map them to dates
  Future<void> _fetchReservations() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('reservations').get();

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

  /// Returns all reservations for a given day
  List<Reservation> _getReservationsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _reservationsMap[key] ?? [];
  }

  // -------------------------------------------------------------------
  // 📅 RESERVATION FORM & DIALOG
  // -------------------------------------------------------------------
  void _showNewReservationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Reservation'),
          content: SingleChildScrollView(
            child: Form(
              key: _dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 10),

                  // Room field
                  TextFormField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Room Name/Number',
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the room.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // Description field
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
                Navigator.of(context).pop(); // close the dialog
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                await _submitReservation();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show a modal with the reservations of a given day
  void _showReservationsModal(DateTime day) {
    final dayReservations = _getReservationsForDay(day);
    if (dayReservations.isEmpty)
      return; // If no reservations, do nothing or show an empty message

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Reservations on ${DateFormat('yyyy-MM-dd').format(day)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: dayReservations.map((res) {
                // You can choose what details to show here
                String start = DateFormat('HH:mm').format(res.startDateTime);
                String end = DateFormat('HH:mm').format(res.endDateTime);

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(res.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '$start - $end\nRoom: ${res.room}\n${res.description}'),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------
  // PICKERS
  // -------------------------------------------------------------------
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

  // -------------------------------------------------------------------
  // SUBMIT RESERVATION
  // -------------------------------------------------------------------
  Future<void> _submitReservation() async {
    if (!_dialogFormKey.currentState!.validate()) {
      return; // form invalid
    }

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

    // Overlap check
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('reservations').get();
    final allReservations =
        snapshot.docs.map((doc) => Reservation.fromDocument(doc)).toList();

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
        const SnackBar(
          content: Text('This room is already reserved for the selected time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Create new Reservation
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

    // Refresh the calendar
    await _fetchReservations();

    // Close dialog
    Navigator.of(context).pop();

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room reserved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear fields
    _clearFormFields();
  }

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
                  // Top row: Title + New Reservation button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faculty Room Reservations',
                        style: TextStyle(
                          fontSize: 24,
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
                  const SizedBox(height: 16),

                  // The Calendar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                          // Limit range to one year from now
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
                            // If day has reservations, show them in a modal
                            final reservations =
                                _getReservationsForDay(selectedDay);
                            if (reservations.isNotEmpty) {
                              _showReservationsModal(selectedDay);
                            }
                          },
                          // Extra styling for the entire calendar
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: true,
                            todayDecoration: BoxDecoration(
                              color: Colors.tealAccent.withOpacity(0.6),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            outsideDaysVisible: true,
                            defaultTextStyle: TextStyle(fontSize: 16),
                            weekendTextStyle: TextStyle(
                              color: Colors.redAccent,
                            ),
                            markersMaxCount: 0,
                            selectedDecoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            selectedTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          // Fancy gradient header
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal, Colors.tealAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.0),
                              ),
                            ),
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                          ),
                          // We do a custom day builder to display reservations
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final dayReservations =
                                  _getReservationsForDay(day);
                              final hasRes = dayReservations.isNotEmpty;
                              final isSameMonth =
                                  (day.month == focusedDay.month);

                              return Container(
                                // 1) Decrease margin/padding so more space is available
                                margin: const EdgeInsets.all(2.0), // was 5.0
                                padding: const EdgeInsets.all(3.0), // was 6.0
                                decoration: BoxDecoration(
                                  color: !isSameMonth
                                      ? Colors.grey.withOpacity(0.15)
                                      : hasRes
                                          ? Colors.yellow.withOpacity(0.2)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      // 2) Reduce the font size a bit
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14, // was 18
                                        color: !isSameMonth
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    // Show up to 2 reservations by name
                                    for (var r in dayReservations.take(2))
                                      // Option A: reduce font size
                                      Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontSize: 8, // was 10
                                          color: Colors.black87,
                                        ),
                                        // Option B: limit lines & show ellipsis
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    if (dayReservations.length > 2)
                                      Text(
                                        '+${dayReservations.length - 2} more',
                                        style: TextStyle(
                                          fontSize: 8, // was 10
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            // ... (selectedBuilder, etc.)
                          )),
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
