import 'package:flutter/material.dart';
import 'package:capstonesproject2024/admin/Schedule/SubjectTimeInput.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MTCL1Screen extends StatefulWidget {
  @override
  _MTCL1ScreenState createState() => _MTCL1ScreenState();
}

class _MTCL1ScreenState extends State<MTCL1Screen> {
  Map<String, Map<String, String>> teacherScheduleData = {};
  Map<String, Map<String, String>> assistantScheduleData = {};
  Map<String, Color> cellColors = {};
  Map<String, Color> fontColors = {};

  final List<String> timeSlots = [
    '07:00 - 07:30', '07:30 - 08:00', '08:00 - 08:30', '08:30 - 09:00',
    '09:00 - 09:30', '09:30 - 10:00', '10:00 - 10:30', '10:30 - 11:00',
    '11:00 - 11:30', '11:30 - 12:00', '12:00 - 12:30', '12:30 - 13:00',
    '13:00 - 13:30', '13:30 - 14:00', '14:00 - 14:30', '14:30 - 15:00',
    '15:00 - 15:30', '15:30 - 16:00', '16:00 - 16:30', '16:30 - 17:00',
    '17:00 - 17:30', '17:30 - 18:00', '18:00 - 18:30', '18:30 - 19:00',
    '19:00 - 19:30', '19:30 - 20:00', '20:00 - 20:30', '20:30 - 21:00'
  ];

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

    // Resetting the form fields
    resetForm();
  }

  void resetForm() {
    // Reset any controllers or input fields here.
    // For example, if you have a controller for subject input in the SubjectTimeInput widget
    // You could call the reset method of SubjectTimeInput to clear text fields or dropdowns.
  }

  void _highlightCell(String day, String time) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose a color or Edit Content"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Choose Background Color'),
                BlockPicker(
                  pickerColor: cellColors['$day-$time'] ?? Colors.white,
                  onColorChanged: (color) {
                    setState(() {
                      cellColors['$day-$time'] = color;
                    });
                  },
                ),
                TextField(
                  controller: TextEditingController(text: teacherScheduleData[day]?[time] ?? ''),
                  decoration: InputDecoration(
                    labelText: 'Edit Subject',
                  ),
                  onChanged: (newText) {
                    setState(() {
                      if (teacherScheduleData[day] == null) {
                        teacherScheduleData[day] = {};
                      }
                      teacherScheduleData[day]![time] = newText;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text('Choose Font Color'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          fontColors['$day-$time'] = Colors.black;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('Black', style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          fontColors['$day-$time'] = Colors.white;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('White', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  teacherScheduleData[day]?[time] = ''; // Delete the text content
                  cellColors.remove('$day-$time'); // Remove the highlight color
                  fontColors.remove('$day-$time'); // Optional: Remove the font color
                });
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MTCL 1'),
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

  Widget _buildLargeCardWithDays(String title) {
    Map<String, Map<String, String>> currentSchedule = title == 'Teacher Schedule'
        ? teacherScheduleData
        : assistantScheduleData;

    return Flexible(
      child: Card(
        elevation: 6,
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.all(16),
          height: 500,
          width: 1000,
          child: SingleChildScrollView(
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
                Table(
                  border: TableBorder.all(color: Colors.black),
                  columnWidths: const {
                    0: FixedColumnWidth(100),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(100),
                    3: FixedColumnWidth(100),
                    4: FixedColumnWidth(100),
                    5: FixedColumnWidth(100),
                    6: FixedColumnWidth(100),
                  },
                  children: [
                    TableRow(
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
                    ...timeSlots.map((time) {
                      return TableRow(
                        children: [
                          _buildTableCell(time),
                          _buildInteractiveCell('Monday', time),
                          _buildInteractiveCell('Tuesday', time),
                          _buildInteractiveCell('Wednesday', time),
                          _buildInteractiveCell('Thursday', time),
                          _buildInteractiveCell('Friday', time),
                          _buildInteractiveCell('Saturday', time),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInteractiveCell(String day, String time) {
    return GestureDetector(
      onTap: () => _highlightCell(day, time),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: cellColors['$day-$time'] ?? Colors.white,
        child: Text(
          teacherScheduleData[day]?[time] ?? '',
          style: TextStyle(
            fontSize: 16,
            color: fontColors['$day-$time'] ?? Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
