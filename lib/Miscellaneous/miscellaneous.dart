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
    required this.onTypeUpdated, required Null Function(List<Type> p1) onTypesUpdated,
  }) : super(key: key);

  @override
  _MiscellaneousScreenState createState() => _MiscellaneousScreenState();
}

class _MiscellaneousScreenState extends State<MiscellaneousScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar - fixed on the left side
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main content area
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Inventory Dropdown
                    InventoryDropdown(
                      onSelect: (value) {
                        // Handle the selection from the dropdown
                      },
                      onItemSelected: (String selectedType) {
                        if (selectedType == 'Borrowing') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BorrowedEquipmentManagementScreen(
                                adminName: widget.adminName,
                                profileImagePath: widget.profileImagePath,
                                onEquipmentUpdated: (List<BorrowedEquipment> updatedEquipment) {
                                  // Handle the updated equipment list here if necessary
                                },
                              ),
                            ),
                          );
                        } else if (selectedType == 'User') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ManagementScreen(
                                adminName: widget.adminName,
                                profileImagePath: widget.profileImagePath,
                              ),
                            ),
                          );
                        } else if (selectedType == 'Room') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MTManagementScreen(
                                adminName: widget.adminName,
                                profileImagePath: widget.profileImagePath,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Row for Brand, Status, and Type Management Screens
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Management Screen
                        Expanded(
                          child: SizedBox(
                            height: 750, // Consistent height for alignment
                            child: BrandManagementScreen(
                              profileImagePath: widget.profileImagePath,
                              onBrandsUpdated: widget.onBrandsUpdated,
                              adminName: widget.adminName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Space between widgets

                        // Status Management Screen
                        Expanded(
                          child: SizedBox(
                            height: 700, // Consistent height for alignment
                            child: StatusManagementScreen(
                              profileImagePath: widget.profileImagePath,
                              adminName: widget.adminName,
                              onStatusesUpdated: (List<Status> statuses) {
                                // Handle the updated statuses here
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Space between widgets

                        // Type Management Screen (Updated)
                        Expanded(
                          child: SizedBox(
                            height: 750, // Consistent height for alignment
                            child: TypeManagementScreen(
                              profileImagePath: widget.profileImagePath,
                              adminName: widget.adminName,
                              onTypesUpdated: widget.onTypeUpdated, // Corrected this line
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32), // Space below content
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
