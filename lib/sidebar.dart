import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatelessWidget {
  final String profileImagePath;
  final String adminName;

  const Sidebar({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  // A method to get accountType from SharedPreferences
  Future<String?> _getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accountType'); // returns null if not set
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getAccountType(),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        String? accountType = snapshot.data ?? '';

        return Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: Drawer(
            backgroundColor: Colors.transparent,
            child: Column(
              children: [
                // Drawer Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          profileImagePath,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(Icons.account_circle,
                                size: 90, color: Colors.white);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        adminName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          accountType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sidebar Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 10),
                      _buildMenuItems(context, accountType),
                      const Divider(color: Colors.white54, thickness: 0.5),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------
  // 🏆 Build Sidebar Menu Items
  // ------------------------------------------
  Widget _buildMenuItems(BuildContext context, String? accountType) {
    List<Widget> menuItems = [];

    // Admin can access everything
    if (accountType == 'Admin') {
      menuItems.addAll([
        _buildSidebarItem(Icons.dashboard, 'Dashboard', context, '/'),
        _buildSidebarItem(
            Icons.people, 'User Management', context, '/user-management'),
        _buildSidebarItem(Icons.inventory, 'Inventory', context, '/inventory'),
        _buildSidebarItem(Icons.handshake, 'Borrowing', context, '/borrowing'),
        _buildSidebarItem(
            Icons.category, 'Miscellaneous', context, '/miscellaneous'),
        _buildSidebarItem(
            Icons.transfer_within_a_station, 'Transfer', context, '/transfer'),
        const Divider(color: Colors.white24),
      ]);
    }

    // LabAssistant can access Borrowing, Transfer (Admin can see these too)
    if (accountType == 'LabAssistant') {
      menuItems.addAll([
        _buildSidebarItem(Icons.dashboard, 'Dashboard', context, '/'),
        _buildSidebarItem(Icons.handshake, 'Borrowing', context, '/borrowing'),
        _buildSidebarItem(
            Icons.category, 'Miscellaneous', context, '/miscellaneous'),
        _buildSidebarItem(
            Icons.transfer_within_a_station, 'Transfer', context, '/transfer'),
        const Divider(color: Colors.white24),
      ]);
    }

    // LabAssistant & Faculty can access Schedule, Room Reservation (Admin too)
    if (accountType == 'LabAssistant' ||
        accountType == 'Faculty' ||
        accountType == 'Admin') {
      menuItems.addAll([
        _buildSidebarItem(
            Icons.calendar_month, 'Schedule', context, '/schedule'),
        _buildSidebarItem(
            Icons.room, 'Room Reservation', context, '/faculty-reservation'),
      ]);
    }

    return Column(children: menuItems);
  }

  // ------------------------------------------
  // 🏆 Sidebar Item Widget
  // ------------------------------------------
  Widget _buildSidebarItem(
      IconData icon, String title, BuildContext context, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        hoverColor: Colors.white24,
        onTap: () {
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  // ------------------------------------------
  // 🏆 Logout Button with Confirmation Dialog
  // ------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(147, 207, 189, 29),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Log Out', style: TextStyle(fontSize: 16)),
        onPressed: () async {
          bool confirmLogout = await _showLogoutConfirmation(context);
          if (confirmLogout) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('accountType');
            await prefs.remove('labassistantname');
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }

  // ------------------------------------------
  // 🏆 Show Logout Confirmation Dialog
  // ------------------------------------------
  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text('Log Out'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
