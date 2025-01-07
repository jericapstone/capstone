// borrowing_transaction_screen.dart

import 'package:capstonesproject2024/admin/Borrowing_Transaction/borrowform.dart';
import 'package:capstonesproject2024/admin/Borrowing_Transaction/borrowingTable.dart';
import 'package:capstonesproject2024/admin/Borrowing_Transaction/equiptmenttable.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/Sidebar.dart';

class BorrowingTransactionScreen extends StatefulWidget {
  final String profileImagePath;
  final String adminName;
  final Function(List<BorrowingTransaction>) onTransactionsUpdated;

  const BorrowingTransactionScreen({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
    required this.onTransactionsUpdated,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BorrowingTransactionScreenState createState() =>
      _BorrowingTransactionScreenState();
}

class _BorrowingTransactionScreenState
    extends State<BorrowingTransactionScreen> {
  // Controllers for form inputs (if needed in future expansions)
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController borrowedByController = TextEditingController();
  final TextEditingController returnedByController = TextEditingController();

  String? borrowedFrom = 'Select Borrower';

  List<String> equipmentOptions = [];
  List<String> positionOptions = ['Student', 'Teacher'];
  List<String> labAssistants = []; // List to hold lab assistants
  bool isAddNew = false;
  bool isEquipment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text(
                      'Borrowing Transactions',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Action Cards Section
                    _buildActionCards(),
                    SizedBox(height: 32),
                    // Conditional Display: Add New or Equipment or Borrowings Table
                    _buildConditionalDisplay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action cards for "Equipment" and "Add New"
  Widget _buildActionCards() {
    // Determine the number of columns based on screen width for responsiveness
    int crossAxisCount = 8;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        // Equipment Card
        _buildActionCard(
          title: "Equipment",
          icon: Icons.build_outlined,
          color: Colors.teal,
          isSelected: isEquipment,
          onTap: () {
            setState(() {
              isEquipment = !isEquipment;
              isAddNew = false; // Ensure only one is active at a time
            });
          },
        ),
        // Add New Card
        _buildActionCard(
          title: "Add New",
          icon: Icons.add_box_outlined,
          color: Colors.orange,
          isSelected: isAddNew,
          onTap: () {
            setState(() {
              isAddNew = !isAddNew;
              isEquipment = false; // Ensure only one is active at a time
            });
          },
        ),
      ],
    );
  }

  /// Helper method to build individual action cards
  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      splashColor: color.withOpacity(0.2),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 60,
                color: color,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the conditional display based on selected action
  Widget _buildConditionalDisplay() {
    // Corrected logic to display the appropriate screen
    if (isEquipment && !isAddNew) {
      return EquipmentTableScreen();
    } else if (isAddNew && !isEquipment) {
      return BorrowFormScreen();
    } else {
      return BorrowingsTableScreen();
    }
  }
}
