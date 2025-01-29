import 'package:flutter/material.dart';
import 'package:capstonesproject2024/admin/usermanagement/admin_dashboard_screen.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
// Import the SharedPreferences package
import 'package:shared_preferences/shared_preferences.dart';

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
      // 1) Check if user exists
      bool isAuthenticated =
          await _firestoreService.checkUserCredentials(email);

      if (isAuthenticated) {
        // 2) Fetch user details (including accountType)
        var userDetails = await _firestoreService.getUserDetails(email);

        // 3) If no data returned, handle the error
        if (userDetails.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User details not found!')),
          );
          return;
        }

        // 4) Extract fields from Firestore
        String profileImage =
            userDetails['profileImage'] ?? 'assets/warriors.png';
        String accountType = userDetails['accountType'] ?? 'Admin';

        // 5) Store the accountType to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accountType', accountType);

        // Optionally store the profile image path, user name, etc., if needed
        // await prefs.setString('profileImage', profileImage);

        // Then navigate to your main admin dashboard screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(
              profileImagePath: profileImage,
              adminName: accountType,
            ),
          ),
        );
      } else {
        // Email not found in Firestore
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
          // Left side: an image or logo
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Image.asset('assets/warriors.png', width: 800),
              ),
            ),
          ),

          // Right side: Gradient + login card
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade200, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Container(
                    width: 450,
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 40,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CCS & CPU logos
                        Image.asset('assets/ccs.png', height: 150),
                        const SizedBox(height: 20),

                        // Title text
                        const Text(
                          'CCS Computer Laboratory',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CENTRAL PHILIPPINE UNIVERSITY',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // Email text field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('SIGN IN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
