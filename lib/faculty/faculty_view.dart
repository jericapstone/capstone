import 'package:capstonesproject2024/sidebar.dart';
import 'package:flutter/material.dart';

class FacultyView extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final String? accountType;
  const FacultyView(
      {Key? key,
      required this.profileImagePath,
      required this.adminName,
      this.accountType})
      : super(key: key);

  @override
  State<FacultyView> createState() => _FacultyViewState();
}

class _FacultyViewState extends State<FacultyView> {
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
            child: Column(),
          ),
        ],
      ),
    );
  }
}
