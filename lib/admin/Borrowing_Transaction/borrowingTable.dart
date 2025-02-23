// borrowings_table_screen.dart

import 'package:capstonesproject2024/admin/Borrowing_Transaction/transactionPopup.dart';
import 'package:capstonesproject2024/model/borrowingModel.dart';
import 'package:capstonesproject2024/model/overdueDialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:capstonesproject2024/services/notifemailsevice.dart';

class BorrowingsTableScreen extends StatefulWidget {
  const BorrowingsTableScreen({Key? key}) : super(key: key);

  @override
  _BorrowingsTableScreenState createState() => _BorrowingsTableScreenState();
}

class _BorrowingsTableScreenState extends State<BorrowingsTableScreen> {
  List<Borrowing> _borrowings = [];
  List<Borrowing> _filteredBorrowings = [];
  bool _isLoading = true;

  // Renamed from _searchID to _searchQuery
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBorrowings();
  }

  Future<void> _fetchBorrowings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('borrowings')
          .orderBy('borrowedAt', descending: true)
          .get();

      List<Borrowing> borrowings =
          snapshot.docs.map((doc) => Borrowing.fromDocument(doc)).toList();

      setState(() {
        _borrowings = borrowings;
        _filteredBorrowings = borrowings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching borrowings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching borrowings.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Allows searching by ID, Brand, Serial Number, Model, Borrower Name, etc.
  void _filterBorrowings() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredBorrowings = _borrowings;
      });
    } else {
      final query = _searchQuery.toLowerCase();
      setState(() {
        _filteredBorrowings = _borrowings.where((b) {
          final matchesID = b.borrowerID.toLowerCase().contains(query);
          final matchesBrand = b.brand.toLowerCase().contains(query);
          final matchesSerial = b.serialNumber.toLowerCase().contains(query);
          final matchesModel = b.model.toLowerCase().contains(query);
          final matchesBorrowerName =
              b.borrowerName.toLowerCase().contains(query);

          // Add or remove fields as needed
          return matchesID ||
              matchesBrand ||
              matchesSerial ||
              matchesModel ||
              matchesBorrowerName;
        }).toList();
      });
    }
  }

  Future<void> _openReturnDialog(Borrowing borrowing) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ReturnDialog(borrowing: borrowing);
      },
    );

    // Refresh the borrowings after returning
    _fetchBorrowings();
  }

  Future<void> _exportToCSV() async {
    // Prepare CSV data
    List<List<String>> csvData = [
      [
        'Borrower Name',
        'ID',
        'Position',
        'Department',
        'Serial No.',
        'Brand',
        'Model',
        'Room',
        'Status',
        'Unit Code',
        'Lab Assistant',
        'Borrowed Time',
        'Purpose'
      ],
      // Add data rows
      ..._filteredBorrowings.map((b) => [
            b.borrowerName,
            b.borrowerID,
            b.borrowerPosition,
            b.borrowerDepartment,
            b.serialNumber,
            b.brand,
            b.model,
            b.room,
            b.status,
            b.unitCode,
            b.labAssistant,
            DateFormat('yyyy-MM-dd – kk:mm').format(b.borrowedTime),
            b.purpose,
          ])
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    try {
      // Encode the CSV string to bytes
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'borrowings_${DateTime.now().millisecondsSinceEpoch}.csv';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV exported successfully.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error exporting CSV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error exporting CSV.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              // Updated label to reflect multiple searchable fields
              labelText: 'Search by ID, Brand, Serial, Model, Name, etc.',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onChanged: (value) {
              _searchQuery = value.trim();
              _filterBorrowings();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            onPressed: _exportToCSV,
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _filteredBorrowings.isEmpty
                  ? const Center(
                      child: Text(
                        'No borrowings found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: PaginatedDataTable(
                          header: Text(
                            'Borrowing Records',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                            ),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Borrower Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Department',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Serial No.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Brand',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Model',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Quantity',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Lab Assistant',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Borrowed Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Purpose',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: false,
                            ),
                          ],
                          source: BorrowingsDataSource(
                            borrowings: _filteredBorrowings,
                            context: context,
                            onReturn: _openReturnDialog,
                          ),
                          rowsPerPage: 10,
                          columnSpacing: 20.0,
                          horizontalMargin: 12.0,
                          showCheckboxColumn: false,
                          showFirstLastButtons: true,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class BorrowingsDataSource extends DataTableSource {
  final List<Borrowing> borrowings;
  final BuildContext context;
  final Function(Borrowing) onReturn;

  // For sending email
  final EmailServiceVer _messageverify = EmailServiceVer();

  BorrowingsDataSource({
    required this.borrowings,
    required this.context,
    required this.onReturn,
  });

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= borrowings.length) return null!;
    final borrowing = borrowings[index];
    final isEven = index % 2 == 0;
    final rowColor = isEven ? Colors.grey.withOpacity(0.05) : Colors.white;

    // Overdue logic: if not returned & expectedReturn is in the past
    final now = DateTime.now();
    final bool isOverdue = (borrowing.returnDate == null &&
        borrowing.expectedReturn != null &&
        now.isAfter(borrowing.expectedReturn!));

    return DataRow.byIndex(
      index: index,
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.teal.withOpacity(0.2);
          }
          return rowColor;
        },
      ),
      cells: [
        DataCell(
          Text(
            borrowing.borrowerName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            borrowing.borrowerDepartment,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            borrowing.serialNumber,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            borrowing.brand,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            borrowing.model,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          _buildStatusChip(borrowing.status),
        ),
        DataCell(
          Text(
            "${borrowing.quantity}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            borrowing.labAssistant,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            DateFormat('yyyy-MM-dd – kk:mm').format(borrowing.borrowedTime),
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        DataCell(
          Text(
            borrowing.purpose,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        // ACTION Column
        DataCell(
          _buildActionCell(borrowing, isOverdue),
        ),
      ],
      onSelectChanged: (selected) {
        // Optional: Implement row selection if needed
      },
    );
  }

  // Build a status chip
  Widget _buildStatusChip(String status) {
    final lowered = status.toLowerCase();
    if (lowered == 'damage' || lowered == 'damaged') {
      return Chip(
        avatar: const Icon(
          Icons.error,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          status,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      );
    } else if (lowered == 'borrowed') {
      return Chip(
        avatar: const Icon(
          Icons.assignment_turned_in,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          status,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      );
    } else {
      // Usable, or anything else
      return Chip(
        avatar: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          status,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      );
    }
  }

  // Decide which button or label to show
  Widget _buildActionCell(Borrowing borrowing, bool isOverdue) {
    if (borrowing.returnDate != null) {
      // Already returned
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          'Returned',
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isOverdue) {
      // Overdue => show a "Send Email" button or "Overdue" button
      return Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Example: open a custom Overdue dialog that can extend time or send an email
              _openOverdueDialog(borrowing);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Overdue'),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            onPressed: () => onReturn(borrowing),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Return'),
          ),
        ],
      );
    } else {
      // Not returned, not overdue => Show Return button
      return ElevatedButton(
        onPressed: () => onReturn(borrowing),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text('Return'),
      );
    }
  }

  void _openOverdueDialog(Borrowing borrowing) {
    showDialog(
      context: context,
      builder: (_) => OverdueDialog(
        borrowing: borrowing,
        messageService: _messageverify,
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => borrowings.length;

  @override
  int get selectedRowCount => 0;
}
