// return_dialog.dart

import 'package:capstonesproject2024/model/borrowingModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReturnDialog extends StatefulWidget {
  final Borrowing borrowing;

  ReturnDialog({required this.borrowing});

  @override
  _ReturnDialogState createState() => _ReturnDialogState();
}

class _ReturnDialogState extends State<ReturnDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _returnDate;
  bool _isDamaged = false;
  String _damageDescription = '';
  bool _isSubmitting = false;

  Future<void> _pickReturnDate() async {
    DateTime now = DateTime.now();
    DateTime initialDate = _returnDate ??
        (widget.borrowing.borrowedTime.isAfter(now)
            ? widget.borrowing.borrowedTime
            : now);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.borrowing.borrowedTime,
      lastDate: DateTime(widget.borrowing.borrowedTime.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.teal,
            colorScheme: ColorScheme.light(primary: Colors.teal),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Colors.teal,
              colorScheme: ColorScheme.light(primary: Colors.teal),
              buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _returnDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitReturn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a return date.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Update the borrowing record with return date and damage info
      await FirebaseFirestore.instance
          .collection('borrowings')
          .doc(widget.borrowing.id)
          .update({
        'returnDate': Timestamp.fromDate(_returnDate!),
        'status': _isDamaged ? 'Damage' : 'Returned',
        'damage': _isDamaged
            ? {
                'isDamaged': true,
                'damageDescription': _damageDescription,
              }
            : null,
      });

      // Update the equipment status
      QuerySnapshot equipmentSnapshot = await FirebaseFirestore.instance
          .collection('equipment')
          .where('serialNumber', isEqualTo: widget.borrowing.serialNumber)
          .limit(1)
          .get();

      if (equipmentSnapshot.docs.isNotEmpty) {
        DocumentReference equipmentRef = equipmentSnapshot.docs.first.reference;
        await equipmentRef.update({
          'status': _isDamaged ? 'Damage' : 'Usable',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Equipment returned successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      print('Error returning equipment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error returning equipment. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Return Equipment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Return Date Picker
              GestureDetector(
                onTap: _pickReturnDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Return Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _returnDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd – kk:mm')
                              .format(_returnDate!),
                    ),
                    validator: (value) {
                      if (_returnDate == null) {
                        return 'Please select a return date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Damage Checkbox
              CheckboxListTile(
                title: Text('Damaged Equipment'),
                value: _isDamaged,
                onChanged: (value) {
                  setState(() {
                    _isDamaged = value ?? false;
                    if (!_isDamaged) {
                      _damageDescription = '';
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 10),

              // Damage Description
              if (_isDamaged)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Damage Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _damageDescription = value.trim();
                  },
                  validator: (value) {
                    if (_isDamaged) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe the damage';
                      }
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReturn,
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
              : Text('Submit'),
        ),
      ],
    );
  }
}
