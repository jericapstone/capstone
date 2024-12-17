import 'package:capstonesproject2024/Miscellaneous/users/AccountType.dart';
import 'package:capstonesproject2024/Miscellaneous/users/lab%20assistant.dart';
import 'package:capstonesproject2024/Sidebar.dart';
import 'package:flutter/material.dart';

class ManagementScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const ManagementScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Section
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main Content Section
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Row: Lab Assistant and Account Type Management Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lab Assistant Management Screen
                      Expanded(
                        child: SizedBox(
                          height: 600, // Adjust height for the first section
                          child: LabAssistantManagementScreen(
                            profileImagePath: widget.profileImagePath,
                            adminName: widget.adminName,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Space between sections

                      // Account Type Management Screen
                      Expanded(
                        child: SizedBox(
                          height: 600, // Adjust height for the second section
                          child: AccountTypeManagementScreen(
                            profileImagePath: widget.profileImagePath,
                            adminName: widget.adminName,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // Space before the next row (if any)
                  // You can add another row or sections here if needed
                ],
              ),
            ),
        ],
      ),
    );
  }
}
