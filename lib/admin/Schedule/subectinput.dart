// lib/admin/Schedule/SubjectTimeInput.dart

import 'package:capstonesproject2024/admin/Schedule/typefiledef.dart';
import 'package:flutter/material.dart';

class SubjectTimeInput extends StatefulWidget {
  final OnSaveCallback onSave;
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
  final _formKey = GlobalKey<FormState>();
  String? _selectedScheduleType;
  String? _selectedSchoolYear;
  String? _selectedSemester;
  String? _subject;
  List<String> _selectedDays = [];
  List<String> _selectedTimes = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // School Year Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'School Year'),
            items: ['2023-2024', '2024-2025', '2025-2026']
                .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSchoolYear = value;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a school year' : null,
          ),
          SizedBox(height: 16),

          // Semester Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Semester'),
            items: ['Semester 1', 'Semester 2']
                .map((sem) => DropdownMenuItem(
                      value: sem,
                      child: Text(sem),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSemester = value;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a semester' : null,
          ),
          SizedBox(height: 16),

          // Schedule Type Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Schedule Type'),
            items: widget.scheduleTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedScheduleType = value;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a schedule type' : null,
          ),
          SizedBox(height: 16),

          // Subject TextField
          TextFormField(
            decoration: InputDecoration(labelText: 'Subject'),
            onChanged: (value) {
              setState(() {
                _subject = value;
              });
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a subject'
                : null,
          ),
          SizedBox(height: 16),

          // Days Multi-Select
          MultiSelectChip(
            widget.days,
            onSelectionChanged: (selectedList) {
              setState(() {
                _selectedDays = selectedList.cast<String>();
              });
            },
          ),
          SizedBox(height: 16),

          // Times Multi-Select
          MultiSelectChip(
            widget.timeSlots,
            onSelectionChanged: (selectedList) {
              setState(() {
                _selectedTimes = selectedList.cast<String>();
              });
            },
          ),
          SizedBox(height: 16),

          // Save Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedSchoolYear == null ||
                    _selectedSemester == null ||
                    _selectedScheduleType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please complete all fields')),
                  );
                  return;
                }

                widget.onSave(
                  _subject!,
                  _selectedTimes,
                  _selectedDays,
                  _selectedScheduleType!,
                  _selectedSchoolYear!,
                  _selectedSemester!,
                );
              }
            },
            child: Text('Save Schedule'),
          ),
        ],
      ),
    );
  }
}

// Helper widget for multi-select chips
class MultiSelectChip extends StatefulWidget {
  final List<String> items;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.items, {required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.items.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: FilterChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
