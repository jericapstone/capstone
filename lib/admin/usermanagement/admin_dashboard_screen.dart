import 'package:capstonesproject2024/admin/usermanagement/user_table.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../sidebar.dart';


class AdminDashboardScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const AdminDashboardScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field data
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String accountType = 'User';
  String status = 'Active';
  List<String> accountTypes = [];

  @override
  void initState() {
    super.initState();
    _loadAccountTypes(); // Load account types when the screen is initialized
  }

  // Fetch account types from Firestore
  Future<void> _loadAccountTypes() async {
    try {
      // Call the static method directly
      List<AccountType> fetchedAccountTypes = await FirestoreService.getAccountTypes();
      List<String> accountTypeNames = fetchedAccountTypes.map((accountType) => accountType.name).toList();

      setState(() {
        accountTypes = accountTypeNames;
        if (accountTypes.isNotEmpty) {
          accountType = accountTypes[0];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading account types: $e')),
      );
    }
  }

  // Get account types from Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            child: Sidebar(
              profileImagePath: widget.profileImagePath,
              adminName: widget.adminName,
            ),
          ),
          Expanded(
            child: _buildUserFormAndTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFormAndTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserForm(),
          const SizedBox(height: 20),
          Expanded(child: UserTablePage()),
          // Replace with actual UserTablePage widget
        ],
      ),
    );
  }

  Widget _buildUserForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align form fields to the left
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Align rows evenly spaced
                children: [
                  SizedBox(
                    width: 780,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          firstName = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 780, // Set a fixed width for the last name field
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          lastName = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start, // Align rows evenly spaced
                children: [
                  SizedBox(
                    width: 780, // Set a fixed width for the email field
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 780, // Set a fixed width for the password field
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.password),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Evenly space the items
                crossAxisAlignment: CrossAxisAlignment.start, // Align fields to the top
                children: [
                  SizedBox(
                    width: 300, // Set a fixed width for the Account Type dropdown
                    child: DropdownButtonFormField<String>(
                      value: accountType,
                      items: accountTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          accountType = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 300, // Set a fixed width for the Status dropdown
                    child: DropdownButtonFormField<String>(
                      value: status,
                      items: ['Active', 'Inactive'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          status = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the end of the row
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Adjust padding for button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Add rounded corners
                    side: BorderSide(color: Colors.orange.shade900), // Add border with a darker orange shade
                  ),
                ),
                onPressed: _clearForm,
                child: const Text(
                  'CLEAR',
                  style: TextStyle(color: Colors.white), // White font color
                ),
              ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical:20), // Adjust padding for button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Add rounded corners
                        side: BorderSide(color: Colors.green.shade900), // Add border with a darker green shade
                      ),
                    ),
                    onPressed: _saveUser,
                    child: const Text(
                      'SAVE',
                      style: TextStyle(color: Colors.white), // White font color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      firstName = '';
      lastName = '';
      email = '';
      password = '';
      accountType = 'User';
      status = 'Active';
    });
    _formKey.currentState?.reset();
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      int nextUserId = await _getNextUserId();

      Map<String, dynamic> userData = {
        'userId': nextUserId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'accountType': accountType,
        'status': status,
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .set(userData);

        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user: $e')),
        );
      }
    }
  }

  Future<int> _getNextUserId() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('userId', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['userId'] + 1;
      } else {
        return 1;
      }
    } catch (e) {
      return 1;
    }
  }
}