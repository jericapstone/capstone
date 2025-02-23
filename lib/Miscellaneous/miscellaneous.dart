import 'package:capstonesproject2024/Miscellaneous/BorrowingManagement/BorrowedEquipment.dart';
import 'package:capstonesproject2024/Miscellaneous/equipment_management/type.dart';
import 'package:capstonesproject2024/Miscellaneous/room/MTManagementScreen.dart';
import 'package:capstonesproject2024/Miscellaneous/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/Miscellaneous/equipment_management/StatusManagementScreen.dart';
import 'package:capstonesproject2024/Miscellaneous/inventorydropdown.dart';
import 'package:capstonesproject2024/Miscellaneous/equipment_management/brand_management_screen.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/Sidebar.dart';

/// A more "web-like" layout with a top bar, sidebar, and spacious content area.
class MiscellaneousScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final void Function(List<Brand>) onBrandsUpdated;
  final void Function(List<EquipmentType>) onEquipmentTypeUpdated;
  final void Function(List<Type>) onTypeUpdated;

  const MiscellaneousScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onBrandsUpdated,
    required this.onEquipmentTypeUpdated,
    required this.onTypeUpdated,
    required Null Function(List<Type> p1) onTypesUpdated,
  }) : super(key: key);

  @override
  _MiscellaneousScreenState createState() => _MiscellaneousScreenState();
}

class _MiscellaneousScreenState extends State<MiscellaneousScreen> {
  @override
  Widget build(BuildContext context) {
    // Top bar height
    const double topBarHeight = 60.0;

    return Scaffold(
      // We build our own "top bar" instead of default AppBar, to show how
      // you might create a custom web-like header with branding or user info.
      body: Row(
        children: [
          // ---- SIDEBAR ON THE LEFT ----
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),

          // ---- MAIN AREA ----
          Expanded(
            child: Column(
              children: [
                // ---- TOP NAV BAR ----
                Container(
                  height: topBarHeight,
                  decoration: BoxDecoration(
                    color: Colors.teal[700], // top bar color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Page title
                      Text(
                        "Miscellaneous Management",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Right side: Profile image & admin name (if you want to show it here)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage(widget.profileImagePath),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.adminName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---- MAIN SCROLLABLE CONTENT ----
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100, // Subtle background
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1) Inventory Dropdown in a Card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: InventoryDropdown(
                                onSelect: (value) {
                                  // handle if needed
                                },
                                onItemSelected: (String selectedType) {
                                  if (selectedType == 'Borrowing') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BorrowedEquipmentManagementScreen(
                                          adminName: widget.adminName,
                                          profileImagePath:
                                              widget.profileImagePath,
                                          onEquipmentUpdated:
                                              (List<BorrowedEquipment>
                                                  updated) {},
                                        ),
                                      ),
                                    );
                                  } else if (selectedType == 'User') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ManagementScreen(
                                          adminName: widget.adminName,
                                          profileImagePath:
                                              widget.profileImagePath,
                                        ),
                                      ),
                                    );
                                  } else if (selectedType == 'Room') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MTManagementScreen(
                                          adminName: widget.adminName,
                                          profileImagePath:
                                              widget.profileImagePath,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 2) 3-Column layout for Brand, Status, and Type
                          //    We'll make them responsive:
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // If there's enough width, we'll keep them side by side
                              // If not, they might stack
                              final isWide = constraints.maxWidth > 1200;
                              if (isWide) {
                                // Show in a row
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildManagementCard(
                                        title: "Brand Management",
                                        child: BrandManagementScreen(
                                          profileImagePath:
                                              widget.profileImagePath,
                                          onBrandsUpdated:
                                              widget.onBrandsUpdated,
                                          adminName: widget.adminName,
                                        ),
                                        height: 750,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildManagementCard(
                                        title: "Status Management",
                                        child: StatusManagementScreen(
                                          profileImagePath:
                                              widget.profileImagePath,
                                          adminName: widget.adminName,
                                          onStatusesUpdated:
                                              (List<Status> statuses) {},
                                        ),
                                        height: 750,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildManagementCard(
                                        title: "Type Management",
                                        child: TypeManagementScreen(
                                          profileImagePath:
                                              widget.profileImagePath,
                                          adminName: widget.adminName,
                                          onTypesUpdated: widget.onTypeUpdated,
                                        ),
                                        height: 750,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Narrow mode: stack them vertically
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildManagementCard(
                                      title: "Brand Management",
                                      child: BrandManagementScreen(
                                        profileImagePath:
                                            widget.profileImagePath,
                                        onBrandsUpdated: widget.onBrandsUpdated,
                                        adminName: widget.adminName,
                                      ),
                                      height: 650,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildManagementCard(
                                      title: "Status Management",
                                      child: StatusManagementScreen(
                                        profileImagePath:
                                            widget.profileImagePath,
                                        adminName: widget.adminName,
                                        onStatusesUpdated:
                                            (List<Status> statuses) {},
                                      ),
                                      height: 650,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildManagementCard(
                                      title: "Type Management",
                                      child: TypeManagementScreen(
                                        profileImagePath:
                                            widget.profileImagePath,
                                        adminName: widget.adminName,
                                        onTypesUpdated: widget.onTypeUpdated,
                                      ),
                                      height: 650,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to create a styled Card for each management screen
  Widget _buildManagementCard({
    required String title,
    required Widget child,
    required double height,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
            const SizedBox(height: 16),
            // Actual child
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
