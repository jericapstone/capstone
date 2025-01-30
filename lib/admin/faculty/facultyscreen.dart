import 'package:capstonesproject2024/services/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Example import for your custom classes
import 'package:capstonesproject2024/sidebar.dart';
import 'package:capstonesproject2024/model/reservation.dart';
import 'package:capstonesproject2024/services/notifemailsevice.dart';

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

  // Teacher & Assistant schedule data from Firestore (like your MTCL code)
  // For example, we assume "Semester 1" is the active semester. Adjust as needed.
  Map<String, Map<String, String>> _teacherSchedule =
      {}; // e.g. _teacherSchedule["Monday"]["07:30 - 08:00"] = "SomeSubject"
  Map<String, Map<String, String>> _assistantSchedule = {};

  // For date/time picking
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Controllers for the "New Reservation" dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

  // For email notifications
  final _emailService = EmailServiceVer();

  @override
  void initState() {
    super.initState();
    _fetchReservations();
    _fetchScheduleData(); // Load teacher/assistant schedules from Firestore
    _fetchRecentReservations();
  }

  Stream<List<Map<String, dynamic>>> _fetchRecentReservations() {
    return FirebaseFirestore.instance
        .collection('reservations')
        .orderBy('startDateTime', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          'room': doc['room'] ?? '',
          'startDateTime': (doc['startDateTime'] as Timestamp).toDate(),
          'endDateTime': (doc['endDateTime'] as Timestamp).toDate(),
        };
      }).toList();
    });
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

  // ----------------------------------------------------
  // 1) FETCH TEACHER / ASSISTANT SCHEDULE
  // ----------------------------------------------------
  Future<void> _fetchScheduleData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('schedules')
          .doc('Mtcl1') // or whichever doc you want
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Example: We only handle "Semester 1" for now. Adjust to your logic
        if (data.containsKey('semesters')) {
          Map<String, dynamic> semesters = data['semesters'];
          if (semesters.containsKey('Semester 1')) {
            Map<String, dynamic> s1Data = semesters['Semester 1'];
            if (s1Data.containsKey('teacherSchedule')) {
              // e.g. teacherScheduleData["Semester 1"]["Monday"]["07:00 - 07:30"]
              Map<String, dynamic> teacherMap = s1Data['teacherSchedule'];
              // Convert to Map<String, Map<String, String>>
              _teacherSchedule = teacherMap.map((day, timesMap) {
                return MapEntry(
                  day,
                  Map<String, String>.from(timesMap),
                );
              });
            }
            if (s1Data.containsKey('assistantSchedule')) {
              Map<String, dynamic> assistantMap = s1Data['assistantSchedule'];
              _assistantSchedule = assistantMap.map((day, timesMap) {
                return MapEntry(
                  day,
                  Map<String, String>.from(timesMap),
                );
              });
            }
          }
        }

        setState(() {}); // Refresh UI
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch schedule data.')),
      );
    }
  }

  // ----------------------------------------------------
  // 2) FETCH RESERVATIONS
  // ----------------------------------------------------
  Future<void> _fetchReservations() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('reservations').get();

    Map<DateTime, List<Reservation>> reservations = {};

    for (var doc in snapshot.docs) {
      Reservation reservation = Reservation.fromDocument(doc);
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

  List<Reservation> _getReservationsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _reservationsMap[key] ?? [];
  }

  // ----------------------------------------------------
  // 3) BUILD UI
  // ----------------------------------------------------
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

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Title + New Reservation
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

                  // TableCalendar
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
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
                            child: _buildCalendar(),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text(
                            "Recent Reservations",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.teal, width: 1),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _fetchRecentReservations(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text(
                                      "Error loading reservations.");
                                }
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final recentRes = snapshot.data!;
                                if (recentRes.isEmpty) {
                                  return const Text(
                                      "No recent reservations found.");
                                }

                                return Column(
                                  children: recentRes.map((res) {
                                    final start =
                                        res['startDateTime'] as DateTime;
                                    final end = res['endDateTime'] as DateTime;
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade300,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.event,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          res['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${res['room']} | "
                                          "${DateFormat('MM/dd/yyyy HH:mm').format(start)} - "
                                          "${DateFormat('HH:mm').format(end)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
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
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // 4) BUILD CALENDAR
  // ----------------------------------------------------
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        final reservations = _getReservationsForDay(selectedDay);
        if (reservations.isNotEmpty) {
          _showReservationsModal(selectedDay);
        } else {
          // If the day is a class day (teacher/assistant), show info maybe
          if (_isClassDay(selectedDay)) {
            _showClassDayPopup(selectedDay);
          }
        }
      },
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        todayDecoration: BoxDecoration(
          color: Colors.tealAccent.withOpacity(0.6),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
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
      // We do a custom day builder to check if day is "class day" => color red
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dayReservations = _getReservationsForDay(day);
          final hasRes = dayReservations.isNotEmpty;
          final isSameMonth = (day.month == focusedDay.month);

          // If there's a class on that day, color background red
          bool isClassDay = _isClassDay(day);

          return ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(2.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: !isSameMonth
                      ? Colors.grey.withOpacity(0.15)
                      : (isClassDay
                          ? Colors.red.withOpacity(0.2) // highlight red
                          : (hasRes
                              ? Colors.yellow.withOpacity(0.2)
                              : Colors.transparent)),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: !isSameMonth ? Colors.grey : Colors.black,
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
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper: Check if a given day has ANY class in teacher/assistant schedule
  bool _isClassDay(DateTime day) {
    // Convert day -> dayOfWeek string
    // E.g. Monday, Tuesday, ... from day
    final dayOfWeek = DateFormat('EEEE').format(day); // e.g. "Monday"

    // We'll assume "Semester 1" in this example, or whichever
    // If dayOfWeek is in teacherSchedule or assistantSchedule, it's a class day
    // Because you have half-hour slots, we only check if there's ANY slot for that day
    if (_teacherSchedule.containsKey(dayOfWeek)) {
      // if there's any time slot => class day
      if (_teacherSchedule[dayOfWeek]!.isNotEmpty) {
        return true;
      }
    }
    if (_assistantSchedule.containsKey(dayOfWeek)) {
      if (_assistantSchedule[dayOfWeek]!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // If user clicks a day that is a class day, show a popup explaining
  void _showClassDayPopup(DateTime day) {
    final dayOfWeek = DateFormat('EEEE').format(day);

    // Gather teacher schedule for that day
    final teacherSlots = _teacherSchedule[dayOfWeek] ?? {};
    final assistantSlots = _assistantSchedule[dayOfWeek] ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Class Day"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "There's a class on this day ($dayOfWeek). "
                  "Reservation might conflict with the class schedule.",
                ),
                const SizedBox(height: 8),
                // Show teacher times
                if (teacherSlots.isNotEmpty) ...[
                  const Text(
                    "Teacher Schedule:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: teacherSlots.entries.map((entry) {
                      final timeSlot = entry.key; // "07:30 - 08:00"
                      final subject = entry.value;
                      return Text("$timeSlot => $subject");
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                // Show assistant times
                if (assistantSlots.isNotEmpty) ...[
                  const Text(
                    "Assistant Schedule:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: assistantSlots.entries.map((entry) {
                      final timeSlot = entry.key;
                      final subject = entry.value;
                      return Text("$timeSlot => $subject");
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // 5) NEW RESERVATION DIALOG & SUBMIT
  // ----------------------------------------------------
  void _showNewReservationDialog() {
    _dateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _selectedDate = null;
    _startTime = null;
    _endTime = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Reservation'),
        content: SingleChildScrollView(
          child: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your name.'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name/Number',
                    prefixIcon: Icon(Icons.meeting_room),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter the room.'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Reservation Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please select a date.'
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickStartTime,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please select a start time.'
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickEndTime,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please select an end time.'
                              : null,
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
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {
              await _submitReservation();
            },
          ),
        ],
      ),
    );
  }

  // pick date
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
        _endTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_dialogFormKey.currentState!.validate()) {
      return; // invalid form
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
        const SnackBar(
          content: Text('End time must be after start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 1) Check for class schedule conflict
    final dayOfWeek =
        DateFormat('EEEE').format(_selectedDate!); // e.g. "Monday"
    if (_hasClassConflict(dayOfWeek, startDateTime, endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot reserve. There is a class scheduled during that time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2) Overlap check with other reservations
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('reservations').get();
    final allReservations =
        snapshot.docs.map((doc) => Reservation.fromDocument(doc)).toList();

    bool hasOverlap = allReservations.any((res) {
      bool sameRoom =
          res.room.toLowerCase() == _roomController.text.trim().toLowerCase();
      bool sameDay = (res.startDateTime.year == _selectedDate!.year &&
          res.startDateTime.month == _selectedDate!.month &&
          res.startDateTime.day == _selectedDate!.day);
      if (!sameRoom || !sameDay) return false;

      // Overlap if start < res.end and end > res.start
      return startDateTime.isBefore(res.endDateTime) &&
          endDateTime.isAfter(res.startDateTime);
    });

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This room is already reserved for that time.'),
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

    // Save new Reservation
    final newReservation = Reservation(
      id: '',
      name: _nameController.text.trim(),
      room: _roomController.text.trim(),
      description: _descriptionController.text.trim(),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );

    await firestore.collection('reservations').add(newReservation.toMap());

    // Refresh calendar & close
    await _fetchReservations();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room reserved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    _clearFormFields();
  }

  // Helper: check if day/time range conflicts with teacher/assistant schedule
  bool _hasClassConflict(String dayOfWeek, DateTime start, DateTime end) {
    // Convert start..end into half-hour blocks matching your schedule format
    final timeBlocks = _generateTimeBlocks(start, end);

    // If ANY time block is in teacherSchedule or assistantSchedule => conflict
    for (final block in timeBlocks) {
      // e.g. "07:30 - 08:00"
      if (_teacherSchedule[dayOfWeek] != null &&
          _teacherSchedule[dayOfWeek]!.containsKey(block)) {
        return true;
      }
      if (_assistantSchedule[dayOfWeek] != null &&
          _assistantSchedule[dayOfWeek]!.containsKey(block)) {
        return true;
      }
    }
    return false;
  }

  // Convert a start..end into half-hour blocks matching "HH:mm - HH:mm"
  List<String> _generateTimeBlocks(DateTime start, DateTime end) {
    List<String> blocks = [];
    DateTime current = start;
    while (current.isBefore(end)) {
      // Next half hour
      final next = current.add(const Duration(minutes: 30));

      // Build a timeslot string e.g. "07:30 - 08:00"
      final startStr = DateFormat('HH:mm').format(current);
      final endStr = DateFormat('HH:mm').format(next);

      blocks.add("$startStr - $endStr");

      current = next;
    }
    return blocks;
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

  // ----------------------------------------------------
  // 6) Show Reservations / Class-day Popups
  // ----------------------------------------------------
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
}
