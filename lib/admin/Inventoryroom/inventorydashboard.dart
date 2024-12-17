import 'package:capstonesproject2024/admin/Inventoryroom/room_details.dart';
import 'package:capstonesproject2024/sidebar.dart';
import 'package:flutter/material.dart';
import 'inventory_type.dart';
import 'paginated_table.dart' as paginated_table;

class InventoryDashboard extends StatelessWidget {
  final String profileImagePath;
  final String adminName;

  const InventoryDashboard({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            profileImagePath: profileImagePath,
            adminName: adminName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InventoryType(onSelect: (String? type) {
                      if (type == 'Room') {
                        Navigator.of(context).pushNamed('/inventory');
                      } else if (type == 'Equipment') {
                        Navigator.of(context).pushNamed('/equipment');
                      }
                    }),
                    const SizedBox(height: 20),
                    RoomDetails(
                      // Pass the onRoomAdded callback and selectedRoomCode parameters here
                      onRoomAdded: () {
                        // Logic to refresh UI or perform actions when a room is added
                        print("Room added!");
                      },
                      selectedRoomCode: '',  // Pass initial room code here if needed
                    ),
                    const SizedBox(height: 20),
                    paginated_table.PaginatedTable(),
                    const SizedBox(height: 20),
                    // Removed StreamBuilder and ListView
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
