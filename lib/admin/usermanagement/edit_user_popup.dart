import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPopup extends StatefulWidget {
  final DocumentSnapshot userDoc;
  final VoidCallback onUpdated;

  const EditUserPopup({
    Key? key,
    required this.userDoc,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _EditUserPopupState createState() => _EditUserPopupState();
}

class _EditUserPopupState extends State<EditUserPopup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String firstName;
  late String lastName;
  late String email;
  late String accountType;
  late String status;

  final List<String> accountTypes = ['Administrator', 'Technician', 'Assistant'];
  final List<String> statuses = ['Active', 'Inactive'];

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final data = widget.userDoc.data() as Map<String, dynamic>;
    firstName = data['firstName'] ?? '';
    lastName = data['lastName'] ?? '';
    email = data['email'] ?? '';

    accountType = accountTypes.contains(data['accountType']) ? data['accountType'] : accountTypes[0];
    status = statuses.contains(data['status']) ? data['status'] : statuses[0];

    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    await _firestore.collection('users').doc(widget.userDoc.id).update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'accountType': accountType,
      'status': status,
    });

    widget.onUpdated();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: 500,
        height: 800,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update User',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Bold and black label
                prefixIcon: const Icon(Icons.person), // Icon for First Name
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => firstName = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Bold and black label
                prefixIcon: const Icon(Icons.person), // Icon for Last Name
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => lastName = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Bold and black label
                prefixIcon: const Icon(Icons.email), // Icon for Email
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => email = value,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
              children: [
                SizedBox(
                  width: 200, // Adjusts the width of the dropdown
                  child: DropdownButtonFormField<String>(
                    value: accountType,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: accountTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => accountType = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
              children: [
                SizedBox(
                  width: 200, // Adjusts the width of the dropdown
                  child: DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: statuses.map((stat) {
                      return DropdownMenuItem(
                        value: stat,
                        child: Text(stat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => status = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 455, // Desired width
                  height: 50, // Desired height
                  child: ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87, backgroundColor: Colors.lightBlueAccent, // Text color
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Bold text
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}