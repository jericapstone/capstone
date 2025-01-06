import 'package:flutter/material.dart';
import 'package:capstonesproject2024/admin/Schedule/SubjectTimeInput.dart';

class MTCL2Screen extends StatefulWidget {
  @override
  _MTCL2ScreenState createState() => _MTCL2ScreenState();
}

class _MTCL2ScreenState extends State<MTCL2Screen> {
  // Store the schedule data (Teacher and Lab Assistant)
  Map<String, Map<String, String>> teacherScheduleData = {};
  Map<String, Map<String, String>> assistantScheduleData = {};

  // Time slots for each day
  final List<String> timeSlots = [
    '07:00 - 07:30', '07:30 - 08:00', '08:00 - 08:30', '08:30 - 09:00',
    '09:00 - 09:30', '09:30 - 10:00', '10:00 - 10:30', '10:30 - 11:00',
    '11:00 - 11:30', '11:30 - 12:00', '12:00 - 12:30', '12:30 - 13:00',
    '13:00 - 13:30', '13:30 - 14:00', '14:00 - 14:30', '14:30 - 15:00',
    '15:00 - 15:30', '15:30 - 16:00', '16:00 - 16:30', '16:30 - 17:00',
    '17:00 - 17:30', '17:30 - 18:00', '18:00 - 18:30', '18:30 - 19:00',
    '19:00 - 19:30', '19:30 - 20:00', '20:00 - 20:30', '20:30 - 21:00'
  ];

  // Function to save new schedule data
  void _saveSchedule(String subject, List<String> times, List<String> days, String scheduleType) {
    setState(() {
      for (var day in days) {
        for (var time in times) {
          if (scheduleType == 'Teacher') {
            if (teacherScheduleData.containsKey(day)) {
              teacherScheduleData[day]![time] = subject;
            } else {
              teacherScheduleData[day] = {time: subject};
            }
          } else {
            if (assistantScheduleData.containsKey(day)) {
              assistantScheduleData[day]![time] = subject;
            } else {
              assistantScheduleData[day] = {time: subject};
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MTCL 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            SubjectTimeInput(
              onSave: _saveSchedule,
              days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
              timeSlots: timeSlots,
              scheduleTypes: ['Teacher', 'Lab Assistant'],
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLargeCardWithDays('Teacher Schedule'),
                _buildLargeCardWithDays('Lab Assistant Schedule'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a large card that contains the schedule data
  Widget _buildLargeCardWithDays(String title) {
    Map<String, Map<String, String>> currentSchedule = title == 'Teacher Schedule'
        ? teacherScheduleData
        : assistantScheduleData;

    return Flexible(
      child: Card(
        elevation: 6,
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(32),
          height: 500,
          width: 1000,
          child: SingleChildScrollView( // Make the card scrollable
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTableCell('Time'),
                    _buildTableCell('Mon'),
                    _buildTableCell('Tue'),
                    _buildTableCell('Wed'),
                    _buildTableCell('Thu'),
                    _buildTableCell('Fri'),
                    _buildTableCell('Sat'),
                  ],
                ),
                for (var time in timeSlots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTableCell(time),
                      _buildTableCell(currentSchedule['Monday']?[time] ?? ''),
                      _buildTableCell(currentSchedule['Tuesday']?[time] ?? ''),
                      _buildTableCell(currentSchedule['Wednesday']?[time] ?? ''),
                      _buildTableCell(currentSchedule['Thursday']?[time] ?? ''),
                      _buildTableCell(currentSchedule['Friday']?[time] ?? ''),
                      _buildTableCell(currentSchedule['Saturday']?[time] ?? ''),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to create table cells with borders
  Widget _buildTableCell(String text) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
