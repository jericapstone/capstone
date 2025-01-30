import 'package:capstonesproject2024/Sidebar.dart';
import 'package:capstonesproject2024/model/reservation.dart';
import 'package:capstonesproject2024/services/notifemailsevice.dart';
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

  // **Date/Time Controllers** so we can set the text after picking
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // A form key for the dialog
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

  // For sending email notifications (example usage)
  final _emailService = EmailServiceVer();

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
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  //  FETCH RESERVATIONS
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
  //  NEW RESERVATION DIALOG
  // -------------------------------------------------------------------
  void _showNewReservationDialog() {
    // Clear all date/time in text fields
    _dateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _selectedDate = null;
    _startTime = null;
    _endTime = null;

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
                  const SizedBox(height: 10),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),

                  // Date
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Reservation Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a date.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Start Time
                  GestureDetector(
                    onTap: _pickStartTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a start time.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // End Time
                  GestureDetector(
                    onTap: _pickEndTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
              child: const Text('Cancel'),
              onPressed: () {
                _clearFormFields();
                Navigator.of(context).pop(); // close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                await _submitReservation();
              },
            ),
          ],
        );
      },
    );
  }

  // Show a modal with the reservations of a given day
  void _showReservationsModal(DateTime day) {
    final dayReservations = _getReservationsForDay(day);
    if (dayReservations.isEmpty) return;

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
                String start = DateFormat('HH:mm').format(res.startDateTime);
                String end = DateFormat('HH:mm').format(res.endDateTime);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      res.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        '$start - $end\nRoom: ${res.room}\n${res.description}'),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------
  // PICKERS for date/time
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
        // Update the text field
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
        // Update the text field
        _startTimeController.text = picked.format(context);
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
        // Update the text field
        _endTimeController.text = picked.format(context);
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

    final DateTime startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final DateTime endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Example email
    _emailService.sendMailVerified(
      recipientEmail: "jericsabellano12@gmail.com",
      subject: "New Reservation",
      message: "New Room Reservation:\n"
          "- Name: ${_nameController.text}\n"
          "- Room: ${_roomController.text}\n"
          "- Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}\n"
          "- Start: ${_startTime!.format(context)}\n"
          "- End: ${_endTime!.format(context)}\n"
          "- Description: ${_descriptionController.text}\n",
    );

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
    _dateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    setState(() {
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  // -------------------------------------------------------------------
  // UI BUILD
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
                        icon: const Icon(Icons.add),
                        label: const Text('New Reservation'),
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
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        // Limit range to one year from now
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
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
                          defaultTextStyle: const TextStyle(fontSize: 16),
                          weekendTextStyle: const TextStyle(
                            color: Colors.redAccent,
                          ),
                          markersMaxCount: 0,
                          selectedDecoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          selectedTextStyle: const TextStyle(
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
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                          ),
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ),
                        // We do a custom day builder to display reservations
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final dayReservations = _getReservationsForDay(day);
                            final hasRes = dayReservations.isNotEmpty;
                            final isSameMonth = (day.month == focusedDay.month);

                            return Container(
                              margin: const EdgeInsets.all(2.0),
                              padding: const EdgeInsets.all(3.0),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: !isSameMonth
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  // Show up to 2 reservations by name
                                  for (var r in dayReservations.take(2))
                                    Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  if (dayReservations.length > 2)
                                    Text(
                                      '+${dayReservations.length - 2} more',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
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
