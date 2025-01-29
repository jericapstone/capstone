import 'package:capstonesproject2024/admin/Schedule/MTCL1Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL2Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL3Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL4Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL5Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL6Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL7Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL8Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/Schedule.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/sidebar.dart'; // Make sure the Sidebar widget is imported correctly

class ScheduleScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const ScheduleScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main content area
          Expanded(
            child: Container(
              color: Colors.grey[100], // Light background
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Schedules",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Subtitle
                      Text(
                        "Select a classroom below to view or manage its schedule:",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 32),

                      // The grid of cards
                      _buildMTCLCards(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build MTCL cards dynamically
  Widget _buildMTCLCards() {
    List<String> mtclTitles = [
      'MTCL 1',
      'MTCL 2',
      'MTCL 3',
      'MTCL 4',
      'MTCL 5',
      'MTCL 6',
      'MTCL 7',
      'MTCL 8'
    ];

    // A mapping of MTCL titles to their respective screens
    Map<String, Widget> mtclScreens = {
      'MTCL 1': MTCL11Screen(),
      'MTCL 2': MTCL22Screen(),
      'MTCL 3': MTCL3Screen(),
      'MTCL 4': MTCL4Screen(),
      'MTCL 5': MTCL5Screen(),
      'MTCL 6': MTCL6Screen(),
      'MTCL 7': MTCL7Screen(),
      'MTCL 8': MTCL8Screen(),
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: mtclTitles.length,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to the corresponding MTCL screen based on the title
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => mtclScreens[mtclTitles[index]]!,
              ),
            );
          },
          child: _buildCard(
            title: mtclTitles[index],
            icon: Icons.class_,
          ),
        );
      },
    );
  }

  // Function to build each individual MTCL card with fancy design
  Widget _buildCard({
    required String title,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with a circle background
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                ),
                SizedBox(height: 6),
                // A small text or subtitle if you want
                Text(
                  "Tap to view schedule",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
