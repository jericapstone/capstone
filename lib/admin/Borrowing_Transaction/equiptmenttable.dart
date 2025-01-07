import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For debounce

// Ensure you have initialized Firebase correctly as per previous instructions

class EquipmentTableScreen extends StatefulWidget {
  @override
  _EquipmentTableScreenState createState() => _EquipmentTableScreenState();
}

class _EquipmentTableScreenState extends State<EquipmentTableScreen> {
  // Pagination variables
  final int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  late EquipmentDataSource _dataSource;
  bool _isLoading = true;
  List<Equipment> _allEquipments = [];
  List<Equipment> _filteredEquipments = [];
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch data from Firestore
  Future<void> _fetchData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('equipment')
          .orderBy('createdAt', descending: true)
          .get();

      List<Equipment> equipments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Equipment(
          brand: data['brand'] ?? '',
          model: data['model'] ?? '',
          room: data['room'] ?? '',
          serialNumber: data['serialNumber'] ?? '',
          status: data['status'] ?? '',
          type: data['type'] ?? '',
          unitCode: data['unitCode'] ?? '',
        );
      }).toList();

      setState(() {
        _allEquipments = equipments;
        _filteredEquipments = equipments;
        _dataSource = EquipmentDataSource(_filteredEquipments);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error accordingly
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle search input with debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.trim().toLowerCase();
        _filteredEquipments = _allEquipments.where((equipment) {
          return equipment.serialNumber.toLowerCase().contains(_searchQuery);
        }).toList();
        _dataSource.updateData(_filteredEquipments);
      });
    });
  }

  // Clear search input
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filteredEquipments = _allEquipments;
      _dataSource.updateData(_filteredEquipments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search by Serial Number',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 20),
                // Expanded PaginatedDataTable
                _filteredEquipments.isEmpty
                    ? const Center(
                        child: Text(
                          'No equipment found.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: PaginatedDataTable(
                            header: const Text(
                              'Equipment List',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            columns: const [
                              DataColumn(
                                  label: Text('Brand',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Model',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Room',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Serial Number',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Type',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              DataColumn(
                                  label: Text('Unit Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                            ],
                            source: _dataSource,
                            rowsPerPage: _rowsPerPage,
                            columnSpacing: 20.0,
                            horizontalMargin: 10.0,
                            showCheckboxColumn: false,
                            // Optional: Add actions like sorting
                          ),
                        ),
                      ),
              ],
            ),
          );
  }
}

class Equipment {
  final String brand;
  final String model;
  final String room;
  final String serialNumber;
  final String status;
  final String type;
  final String unitCode;
  final Timestamp? createdAt;

  Equipment({
    required this.brand,
    required this.model,
    required this.room,
    required this.serialNumber,
    required this.status,
    required this.type,
    required this.unitCode,
    this.createdAt,
  });
}

class EquipmentDataSource extends DataTableSource {
  List<Equipment> equipments;
  EquipmentDataSource(this.equipments);

  void updateData(List<Equipment> newEquipments) {
    equipments = newEquipments;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= equipments.length) return null;
    final equipment = equipments[index];
    return DataRow.byIndex(
      index: index,
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        // Alternate row color
        if (index % 2 == 0) return Colors.grey.withOpacity(0.1);
        return null; // Use default value for odd rows
      }),
      cells: [
        DataCell(Text(equipment.brand)),
        DataCell(Text(equipment.model)),
        DataCell(Text(equipment.room)),
        DataCell(Text(equipment.serialNumber)),
        DataCell(StatusBadge(status: equipment.status)),
        DataCell(Text(equipment.type)),
        DataCell(Text(equipment.unitCode)),
      ],
      // Optional: Add onSelectChanged for row tap
      // onSelectChanged: (selected) {
      //   if (selected != null && selected) {
      //     // Handle row tap
      //   }
      // },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => equipments.length;

  @override
  int get selectedRowCount => 0;
}

// Enhanced StatusBadge with Icons
class StatusBadge extends StatelessWidget {
  final String status;

  StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'repair':
        color = Colors.orange;
        icon = Icons.build;
        break;
      case 'damage':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'usable':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(
        icon,
        color: color,
        size: 20,
      ),
      label: Text(
        status,
        style: TextStyle(
          color: color.darken(),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Helper function to format Timestamp
String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return '';
  DateTime date = timestamp.toDate();
  return '${date.day} ${monthName(date.month)} ${date.year} at ${formatTime(date)}';
}

String monthName(int monthNumber) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[monthNumber - 1];
}

String formatTime(DateTime date) {
  int hour = date.hour;
  String meridiem = 'AM';
  if (hour >= 12) {
    meridiem = 'PM';
    if (hour > 12) hour -= 12;
  }
  String minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute $meridiem';
}

// Extension to darken a color
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
