import 'package:capstonesproject2024/admin/Schedule/MTCL1Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL2Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL3Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL4Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL5Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL6Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL7Screen.dart';
import 'package:capstonesproject2024/admin/Schedule/MTCL8Screen.dart';
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMTCLCards(), // Add MTCL cards here
                  ],
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
      'MTCL 1', 'MTCL 2', 'MTCL 3', 'MTCL 4',
      'MTCL 5', 'MTCL 6', 'MTCL 7', 'MTCL 8'
    ];

    // A mapping of MTCL titles to their respective screens
    Map<String, Widget> mtclScreens = {
      'MTCL 1': MTCL1Screen(),
      'MTCL 2': MTCL2Screen(),
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
        crossAxisCount: 4, // Number of columns in grid
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: mtclTitles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigate to the corresponding MTCL screen based on the title
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => mtclScreens[mtclTitles[index]]!),
            );
          },
          child: _buildCard(mtclTitles[index], '0', Icons.meeting_room, Colors.purple),
        );
      },
    );
  }

  // Function to build each individual MTCL card
  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
