import 'package:capstonesproject2024/admin/usermanagement/admin_dashboard_screen.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  // Method to handle login
  void _loginUser() async {
    String email = _emailController.text.trim();

    try {
      bool isAuthenticated = await _firestoreService.checkUserCredentials(email);

      if (isAuthenticated) {
        // Fetch admin details from Firestore
        var adminDetails = await _firestoreService.getAdminDetails(email);

        // Navigate to AdminDashboardScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              profileImagePath: adminDetails['profileImage'] ?? 'assets/default.png', // Default fallback
              adminName: adminDetails['name'] ?? 'Admin Name',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email not found!')),
        );
      }
    } catch (e) {
      // Handle any errors such as network issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Image.asset('assets/warriors.png', width: 800),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/ccs.png', height: 300),
                  const SizedBox(height: 20),
                  const Text(
                    'CCS Computer Laboratory',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'CENTRAL PHILIPPINE UNIVERSITY',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loginUser,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white60),
                      child: const Text('SIGN IN'),
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
}
