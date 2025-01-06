import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String profileImagePath;
  final String adminName;

  const Sidebar({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: Column(
          children: [
            // Drawer header with user profile picture and name
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      profileImagePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return const Icon(Icons.account_circle, size: 80);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    adminName,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
            // List of sidebar items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSidebarItem(Icons.dashboard, 'Dashboard', context, '/'),
                  _buildSidebarItem(Icons.people, 'User Management', context, '/user-management'),
                  _buildSidebarItem(Icons.inventory, 'Inventory', context, '/inventory'),
                  _buildSidebarItem(Icons.category, 'Miscellaneous', context, '/miscellaneous'),
                  _buildSidebarItem(Icons.handshake, 'Borrowing', context, '/borrowing'),
                  _buildSidebarItem(Icons.transfer_within_a_station, 'Transfer', context, '/transfer'),
                  _buildSidebarItem(Icons.calendar_month, 'Schedule', context, '/schedule'),
                  _buildSidebarItem(Icons.room, 'Room Reservation', context, '/faculty-reservation'),
                  _buildSidebarItem(Icons.logout, 'Log out', context, '/logout'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar item widget
  Widget _buildSidebarItem(IconData icon, String title, BuildContext context, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
