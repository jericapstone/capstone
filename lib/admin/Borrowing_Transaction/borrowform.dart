// borrow_form_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Entry point for the Borrow Form Screen
class BorrowFormScreen extends StatefulWidget {
  @override
  _BorrowFormScreenState createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for TextFields
  final TextEditingController _borrowerNameController = TextEditingController();
  final TextEditingController _idController =
      TextEditingController(); // Renamed
  String _borrowerPosition = 'Staff'; // Default value
  final TextEditingController _borrowerDepartmentController =
      TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  // New Controller for Lab Assistant
  String? _selectedLabAssistant;

  // Auto-populated fields
  String _brand = '';
  String _model = '';
  String _room = '';
  String _status = '';
  String _unitCode = '';

  // Borrowed Time
  DateTime? _borrowedDateTime;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Flag to indicate loading state when fetching equipment
  bool _isFetching = false;

  // List to store lab assistants
  List<String> _labAssistants = [];

  @override
  void initState() {
    super.initState();
    _fetchLabAssistants(); // Fetch lab assistants on init
  }

  // Fetch Lab Assistants from Firestore
  Future<void> _fetchLabAssistants() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('lab_assistants').get();

      List<String> assistants = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toList();

      setState(() {
        _labAssistants = assistants;
      });
    } catch (e) {
      print('Error fetching lab assistants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching lab assistants.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to fetch equipment details based on serial number
  Future<void> _fetchEquipmentDetails(String serialNumber) async {
    setState(() {
      _isFetching = true;
      _brand = '';
      _model = '';
      _room = '';
      _status = '';
      _unitCode = '';
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('equipment')
          .where('serialNumber', isEqualTo: serialNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _brand = data['brand'] ?? '';
          _model = data['model'] ?? '';
          _room = data['room'] ?? '';
          _status = data['status'] ?? '';
          _unitCode = data['unitCode'] ?? '';
        });
      } else {
        // Serial number not found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Serial Number not found.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error fetching equipment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching equipment details.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  // Method to pick date and time
  Future<void> _pickBorrowedDateTime() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 0)),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.teal,
            hintColor: Colors.tealAccent,
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
              hintColor: Colors.tealAccent,
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
          _borrowedDateTime = DateTime(
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

  // Method to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_brand.isEmpty ||
          _model.isEmpty ||
          _room.isEmpty ||
          _status.isEmpty ||
          _unitCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid Serial Number.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_borrowedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select Borrowed Time.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedLabAssistant == null || _selectedLabAssistant!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a Lab Assistant.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      try {
        // Add borrowing record to 'borrowings' collection with 'returnDate' as null
        await _firestore.collection('borrowings').add({
          'borrowerName': _borrowerNameController.text.trim(),
          'ID': _idController.text.trim(), // Renamed
          'borrowerPosition': _borrowerPosition,
          'borrowerDepartment': _borrowerDepartmentController.text.trim(),
          'serialNumber': _serialNumberController.text.trim(),
          'brand': _brand,
          'model': _model,
          'room': _room,
          'status': _status,
          'unitCode': _unitCode,
          'borrowedTime': Timestamp.fromDate(_borrowedDateTime!),
          'purpose': _purposeController.text.trim(),
          'borrowedAt': Timestamp.now(),
          'returnDate': null, // Initialize returnDate as null
          'labAssistant': _selectedLabAssistant, // New field
        });

        // Update equipment status to 'Borrowed' (optional)
        await _firestore
            .collection('equipment')
            .where('serialNumber',
                isEqualTo: _serialNumberController.text.trim())
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'status': 'Borrowed'});
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Borrowing record created successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear the form
        _formKey.currentState!.reset();
        setState(() {
          _borrowerPosition = 'Staff';
          _selectedLabAssistant = null; // Reset selected assistant
          _brand = '';
          _model = '';
          _room = '';
          _status = '';
          _unitCode = '';
          _borrowedDateTime = null;
        });
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting form. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _idController.dispose(); // Updated
    _borrowerDepartmentController.dispose();
    _serialNumberController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Borrower Information Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 12.0),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Borrower Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Borrower Name
                  TextFormField(
                    controller: _borrowerNameController,
                    decoration: InputDecoration(
                      labelText: 'Borrower Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter borrower name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // ID (Renamed from Border ID)
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'ID', // Updated label
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Borrower Position Dropdown
                  DropdownButtonFormField<String>(
                    value: _borrowerPosition,
                    decoration: InputDecoration(
                      labelText: 'Borrower Position',
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: ['Staff', 'Student']
                        .map((position) => DropdownMenuItem(
                              value: position,
                              child: Text(position),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _borrowerPosition = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select borrower position';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Borrower Department
                  TextFormField(
                    controller: _borrowerDepartmentController,
                    decoration: InputDecoration(
                      labelText: 'Borrower Department',
                      prefixIcon: Icon(Icons.apartment),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter borrower department';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Lab Assistant Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLabAssistant,
                    decoration: InputDecoration(
                      labelText: 'Lab Assistant',
                      prefixIcon: Icon(Icons.assignment_ind),
                    ),
                    items: _labAssistants
                        .map((assistant) => DropdownMenuItem(
                              value: assistant,
                              child: Text(assistant),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLabAssistant = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a Lab Assistant';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Equipment Information Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 12.0),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipment Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Serial Number
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: InputDecoration(
                      labelText: 'Serial Number of the Item',
                      prefixIcon: const Icon(Icons.vpn_key),
                      suffixIcon: _isFetching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                String serial =
                                    _serialNumberController.text.trim();
                                if (serial.isNotEmpty) {
                                  _fetchEquipmentDetails(serial);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter a serial number',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    onFieldSubmitted: (value) {
                      String serial = value.trim();
                      if (serial.isNotEmpty) {
                        _fetchEquipmentDetails(serial);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter serial number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Auto-populated Fields
                  if (_brand.isNotEmpty ||
                      _model.isNotEmpty ||
                      _room.isNotEmpty ||
                      _status.isNotEmpty ||
                      _unitCode.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Equipment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        // Brand, Model, Room, Status, Unit Code
                        EquipmentDetailRow(
                          label: 'Brand',
                          value: _brand,
                          icon: Icons.branding_watermark,
                        ),
                        SizedBox(height: 10),
                        EquipmentDetailRow(
                          label: 'Model',
                          value: _model,
                          icon: Icons.laptop_mac,
                        ),
                        SizedBox(height: 10),
                        EquipmentDetailRow(
                          label: 'Room',
                          value: _room,
                          icon: Icons.room,
                        ),
                        SizedBox(height: 10),
                        EquipmentDetailRow(
                          label: 'Status',
                          value: _status,
                          icon: Icons.info,
                          isStatus: true,
                        ),
                        SizedBox(height: 10),
                        EquipmentDetailRow(
                          label: 'Unit Code',
                          value: _unitCode,
                          icon: Icons.code,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Borrowing Details Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 12.0),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Borrowing Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Borrowed Time Picker
                  GestureDetector(
                    onTap: _pickBorrowedDateTime,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Borrowed Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: TextEditingController(
                          text: _borrowedDateTime == null
                              ? ''
                              : DateFormat('yyyy-MM-dd – kk:mm')
                                  .format(_borrowedDateTime!),
                        ),
                        validator: (value) {
                          if (_borrowedDateTime == null) {
                            return 'Please select borrowed time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Purpose of Borrow
                  TextFormField(
                    controller: _purposeController,
                    decoration: InputDecoration(
                      labelText: 'Purpose of Borrow',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter purpose of borrowing';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Widget to display equipment details in a row
class EquipmentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isStatus;

  EquipmentDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.teal[700],
        ),
        SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.teal[600],
          ),
        ),
        SizedBox(width: 10),
        isStatus
            ? StatusBadge(status: value)
            : Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
      ],
    );
  }
}

// Widget for status badge with enhanced design
class StatusBadge extends StatelessWidget {
  final String status;

  StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'repair':
        color = Colors.orange;
        icon = Icons.build;
        break;
      case 'damage':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'usable':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'borrowed':
        color = Colors.blue;
        icon = Icons.assignment_return;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Extension to darken a color
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
