import 'package:flutter/material.dart';

class SubjectTimeInput extends StatefulWidget {
  final Function(String, List<String>, List<String>, String) onSave;
  final List<String> days;
  final List<String> timeSlots;
  final List<String> scheduleTypes;

  SubjectTimeInput({
    required this.onSave,
    required this.days,
    required this.timeSlots,
    required this.scheduleTypes,
  });

  @override
  _SubjectTimeInputState createState() => _SubjectTimeInputState();
}

class _SubjectTimeInputState extends State<SubjectTimeInput> {
  final _subjectController = TextEditingController();
  List<String> _selectedTimes = [];
  List<String> _selectedDays = [];
  String? _selectedScheduleType;

  void _handleSave() {
    final subject = _subjectController.text;
    final times = _selectedTimes;
    final days = _selectedDays;
    final scheduleType = _selectedScheduleType ?? '';

    if (subject.isNotEmpty && days.isNotEmpty && times.isNotEmpty && scheduleType.isNotEmpty) {
      widget.onSave(subject, times, days, scheduleType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: TextField and Time Dropdown
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Enter Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select Time'),
                        value: _selectedTimes.isEmpty ? null : _selectedTimes.first,
                        onChanged: (newValue) {
                          setState(() {
                            if (_selectedTimes.contains(newValue)) {
                              _selectedTimes.remove(newValue);
                            } else {
                              _selectedTimes.add(newValue!);
                            }
                          });
                        },
                        isExpanded: true,
                        items: widget.timeSlots.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(value),
                                Checkbox(
                                  value: _selectedTimes.contains(value),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedTimes.add(value);
                                      } else {
                                        _selectedTimes.remove(value);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Second Row: Day Dropdown and Schedule Type Dropdown
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select Day'),
                        value: _selectedDays.isEmpty ? null : _selectedDays.first,
                        onChanged: (newValue) {
                          setState(() {
                            if (_selectedDays.contains(newValue)) {
                              _selectedDays.remove(newValue);
                            } else {
                              _selectedDays.add(newValue!);
                            }
                          });
                        },
                        isExpanded: true,
                        items: widget.days.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(value),
                                Checkbox(
                                  value: _selectedDays.contains(value),
                                  onChanged: (bool? selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedDays.add(value);
                                      } else {
                                        _selectedDays.remove(value);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedScheduleType,
                    hint: Text('Select Schedule Type'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedScheduleType = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: widget.scheduleTypes.map<DropdownMenuItem<String>>(
                          (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Save Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: Text('Save Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
