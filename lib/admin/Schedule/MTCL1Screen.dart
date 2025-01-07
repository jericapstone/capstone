// MTCL1Screen.dart

import 'package:capstonesproject2024/admin/Schedule/subectinput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MTCL11Screen extends StatefulWidget {
  @override
  _MTCL11ScreenState createState() => _MTCL11ScreenState();
}

class _MTCL11ScreenState extends State<MTCL11Screen> {
  // Store the schedule data per semester
  Map<String, Map<String, Map<String, String>>> teacherScheduleData = {
    'Semester 1': {},
    'Semester 2': {},
  };
  Map<String, Map<String, Map<String, String>>> assistantScheduleData = {
    'Semester 1': {},
    'Semester 2': {},
  };

  // Time slots for each day
  final List<String> timeSlots = [
    '07:00 - 07:30',
    '07:30 - 08:00',
    '08:00 - 08:30',
    '08:30 - 09:00',
    '09:00 - 09:30',
    '09:30 - 10:00',
    '10:00 - 10:30',
    '10:30 - 11:00',
    '11:00 - 11:30',
    '11:30 - 12:00',
    '12:00 - 12:30',
    '12:30 - 13:00',
    '13:00 - 13:30',
    '13:30 - 14:00',
    '14:00 - 14:30',
    '14:30 - 15:00',
    '15:00 - 15:30',
    '15:30 - 16:00',
    '16:00 - 16:30',
    '16:30 - 17:00',
    '17:00 - 17:30',
    '17:30 - 18:00',
    '18:00 - 18:30',
    '18:30 - 19:00',
    '19:00 - 19:30',
    '19:30 - 20:00',
    '20:00 - 20:30',
    '20:30 - 21:00'
  ];

  String? schoolYear;
  String? semester;

  // Dropdown for selecting which semester to view
  String? selectedDisplaySemester = 'Semester 1';

  // Variable to track the last saved schedule type
  String? lastSavedScheduleType;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('schedules').doc('Mtcl1').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          schoolYear = data['schoolYear'];
          if (data.containsKey('semesters')) {
            Map<String, dynamic> semesters = data['semesters'];
            semesters.forEach((semesterKey, semesterData) {
              if (semesterData.containsKey('teacherSchedule')) {
                teacherScheduleData[semesterKey] =
                    Map<String, Map<String, String>>.from(
                  (semesterData['teacherSchedule'] as Map).map(
                    (day, times) => MapEntry(
                      day,
                      Map<String, String>.from(times),
                    ),
                  ),
                );
              }
              if (semesterData.containsKey('assistantSchedule')) {
                assistantScheduleData[semesterKey] =
                    Map<String, Map<String, String>>.from(
                  (semesterData['assistantSchedule'] as Map).map(
                    (day, times) => MapEntry(
                      day,
                      Map<String, String>.from(times),
                    ),
                  ),
                );
              }
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch schedule data.')),
      );
    }
  }

  void _saveSchedule(
    String subject,
    List<String> times,
    List<String> days,
    String scheduleType,
    String selectedSchoolYear,
    String selectedSemester,
  ) async {
    // Update local state
    setState(() {
      schoolYear = selectedSchoolYear;
      semester = selectedSemester;
      lastSavedScheduleType = scheduleType; // Update the last saved type
      for (var day in days) {
        for (var time in times) {
          if (scheduleType == 'Teacher') {
            if (teacherScheduleData[selectedSemester]!.containsKey(day)) {
              teacherScheduleData[selectedSemester]![day]![time] = subject;
            } else {
              teacherScheduleData[selectedSemester]![day] = {time: subject};
            }
          } else {
            if (assistantScheduleData[selectedSemester]!.containsKey(day)) {
              assistantScheduleData[selectedSemester]![day]![time] = subject;
            } else {
              assistantScheduleData[selectedSemester]![day] = {time: subject};
            }
          }
        }
      }
    });

    // Prepare data to store in Firestore
    Map<String, dynamic> data = {
      'schoolYear': selectedSchoolYear,
      'semesters': {
        selectedSemester: {
          'teacherSchedule': teacherScheduleData[selectedSemester],
          'assistantSchedule': assistantScheduleData[selectedSemester],
        }
      },
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('schedules')
          .doc('Mtcl1')
          .set(data, SetOptions(merge: true)); // Use merge to update fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$scheduleType schedule saved successfully!')),
      );
    } catch (e) {
      print('Error saving schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save schedule.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MTCL 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adjusted padding
        child: Column(
          children: [
            // SubjectTimeInput Form
            SubjectTimeInput(
              onSave: _saveSchedule, // Expects 6 parameters
              days: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday'
              ],
              timeSlots: timeSlots,
              scheduleTypes: ['Teacher', 'Lab Assistant'],
            ),
            SizedBox(height: 16),

            // Dropdown to select semester to view
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Semester to View'),
              value: selectedDisplaySemester,
              items: ['Semester 1', 'Semester 2']
                  .map((sem) => DropdownMenuItem(
                        value: sem,
                        child: Text(sem),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDisplaySemester = value;
                });
              },
            ),
            SizedBox(height: 16),

            // Schedule Tables
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teacher Schedule Table
                    Expanded(
                        child: _buildLargeCardWithDays(
                            'Teacher Schedule', selectedDisplaySemester!)),
                    SizedBox(width: 16),
                    // Lab Assistant Schedule Table
                    Expanded(
                        child: _buildLargeCardWithDays('Lab Assistant Schedule',
                            selectedDisplaySemester!)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a large card that contains the schedule data
  Widget _buildLargeCardWithDays(String title, String semester) {
    bool isTeacher = title == 'Teacher Schedule';
    Map<String, Map<String, String>> currentSchedule = isTeacher
        ? teacherScheduleData[semester]!
        : assistantScheduleData[semester]!;

    // Determine if this table should be highlighted
    bool shouldHighlight =
        (lastSavedScheduleType == (isTeacher ? 'Teacher' : 'Lab Assistant'));

    return Card(
      elevation: 6,
      child: Container(
        color: shouldHighlight
            ? Colors.yellow[100]
            : Colors.grey[200], // Highlight color
        padding: EdgeInsets.all(16),
        height: 600, // Adjusted height
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // Display School Year and Semester
            if (schoolYear != null && semester != null)
              Text(
                'Year: $schoolYear | Semester: $semester',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            SizedBox(height: 8),
            // Table Headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTableCell('Time', isHeader: true),
                _buildTableCell('Mon', isHeader: true),
                _buildTableCell('Tue', isHeader: true),
                _buildTableCell('Wed', isHeader: true),
                _buildTableCell('Thu', isHeader: true),
                _buildTableCell('Fri', isHeader: true),
                _buildTableCell('Sat', isHeader: true),
              ],
            ),
            Divider(),
            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  String time = timeSlots[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTableCell(time),
                      _buildScheduleCell(isTeacher, 'Monday', time, semester),
                      _buildScheduleCell(isTeacher, 'Tuesday', time, semester),
                      _buildScheduleCell(
                          isTeacher, 'Wednesday', time, semester),
                      _buildScheduleCell(isTeacher, 'Thursday', time, semester),
                      _buildScheduleCell(isTeacher, 'Friday', time, semester),
                      _buildScheduleCell(isTeacher, 'Saturday', time, semester),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build schedule cells with appropriate highlighting
  Widget _buildScheduleCell(
      bool isTeacher, String day, String time, String semester) {
    String subject = isTeacher
        ? (teacherScheduleData[semester]?[day]?[time] ?? '')
        : (assistantScheduleData[semester]?[day]?[time] ?? '');

    bool hasSubject = subject.isNotEmpty;

    String displayText = hasSubject ? subject : '';

    return _buildTableCell(
      displayText,
      isTeacher: isTeacher && hasSubject,
      isAssistant: !isTeacher && hasSubject,
    );
  }

  // Function to create table cells with borders and conditional coloring
  Widget _buildTableCell(
    String text, {
    bool isTeacher = false,
    bool isAssistant = false,
    bool isHeader = false,
  }) {
    Color cellColor = Colors.white;

    if (isHeader) {
      cellColor = Colors.blueGrey[100]!;
    } else {
      if (isTeacher && isAssistant) {
        cellColor = Colors.orangeAccent; // Both teacher and assistant
      } else if (isTeacher) {
        cellColor = Colors.lightBlueAccent; // Teacher only
      } else if (isAssistant) {
        cellColor = Colors.lightGreenAccent; // Assistant only
      }
    }

    return Flexible(
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: cellColor,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
