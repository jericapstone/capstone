import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/sidebar.dart';
import 'package:intl/intl.dart';

class MainDashboard extends StatefulWidget {
  final String profileImagePath;
  final String adminName;

  const MainDashboard({
    Key? key,
    required this.profileImagePath,
    required this.adminName,
  }) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // ======================
  // FUTURES FOR SUMMARY CARDS
  // ======================
  Future<int> _fetchBorrowersCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.size;
    } catch (e) {
      print('Error fetching borrowers: $e');
      return 0;
    }
  }

  Future<int> _fetchEquipmentCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('equipment').get();
      return snapshot.size;
    } catch (e) {
      print('Error fetching equipment: $e');
      return 0;
    }
  }

  Future<int> _fetchReservationsCount() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reservations').get();
      return snapshot.size;
    } catch (e) {
      print('Error fetching reservations: $e');
      return 0;
    }
  }

  // ======================
  // STREAMS FOR RECENT ACTIVITIES
  // ======================
  // Example: fetch recent reservations (limit 5)
  Stream<List<Map<String, dynamic>>> _fetchRecentReservations() {
    return FirebaseFirestore.instance
        .collection('reservations')
        .orderBy('startDateTime', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          'room': doc['room'] ?? '',
          'startDateTime': (doc['startDateTime'] as Timestamp).toDate(),
          'endDateTime': (doc['endDateTime'] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  // Example: fetch recent borrowings (limit 5)
  // Collection name "borrowings", sorted by "borrowedAt" desc
  Stream<List<Map<String, dynamic>>> _fetchRecentBorrowings() {
    return FirebaseFirestore.instance
        .collection('borrowings')
        .orderBy('borrowedAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // We check for expectedReturn and returnDate
        DateTime? expectedReturn;
        if (doc.data().containsKey('expectedReturn') &&
            doc['expectedReturn'] != null) {
          expectedReturn = (doc['expectedReturn'] as Timestamp).toDate();
        }

        DateTime? returnDate;
        if (doc.data().containsKey('returnDate') && doc['returnDate'] != null) {
          returnDate = (doc['returnDate'] as Timestamp).toDate();
        }

        return {
          'id': doc.id,
          'borrowerName': doc['borrowerName'] ?? '',
          'serialNumber': doc['serialNumber'] ?? '',
          'brand': doc['brand'] ?? '',
          'borrowedAt': (doc['borrowedAt'] as Timestamp).toDate(),
          'expectedReturn': expectedReturn,
          'returnDate': returnDate,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Sidebar
          SizedBox(
            width: 250,
            child: Sidebar(
              profileImagePath: widget.profileImagePath,
              adminName: widget.adminName,
            ),
          ),

          // Main Content with gradient background
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title + greeting
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Welcome back, ${widget.adminName}!",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Summary Cards Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryCard(
                          title: "Total Borrowers",
                          futureCount: _fetchBorrowersCount(),
                          icon: Icons.person,
                          color: Colors.blue,
                        ),
                        _buildSummaryCard(
                          title: "Total Equipment",
                          futureCount: _fetchEquipmentCount(),
                          icon: Icons.inventory,
                          color: Colors.orange,
                        ),
                        _buildSummaryCard(
                          title: "Total Reservations",
                          futureCount: _fetchReservationsCount(),
                          icon: Icons.calendar_month,
                          color: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Reservations Section
                    Text(
                      "Recent Reservations",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.teal, width: 1),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _fetchRecentReservations(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Error loading reservations.");
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final recentRes = snapshot.data!;
                          if (recentRes.isEmpty) {
                            return const Text("No recent reservations found.");
                          }

                          return Column(
                            children: recentRes.map((res) {
                              final start = res['startDateTime'] as DateTime;
                              final end = res['endDateTime'] as DateTime;
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.event,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    res['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${res['room']} | "
                                    "${DateFormat('MM/dd/yyyy HH:mm').format(start)} - "
                                    "${DateFormat('HH:mm').format(end)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recent Borrowings / Activities Section
                    Text(
                      "Recent Borrowing Activities",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.teal, width: 1),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _fetchRecentBorrowings(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Error loading borrowings.");
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final recentBorr = snapshot.data!;
                          if (recentBorr.isEmpty) {
                            return const Text("No recent borrowing found.");
                          }

                          return Column(
                            children: recentBorr.map((borr) {
                              final borrowedAt =
                                  borr['borrowedAt'] as DateTime?;
                              final expectedReturn =
                                  borr['expectedReturn'] as DateTime?;
                              final returnDate =
                                  borr['returnDate'] as DateTime?;

                              // Overdue logic:
                              // Overdue if returnDate == null
                              // and expectedReturn != null
                              // and now > expectedReturn
                              bool isOverdue = false;
                              if (returnDate == null &&
                                  expectedReturn != null &&
                                  DateTime.now().isAfter(expectedReturn)) {
                                isOverdue = true;
                              }

                              final itemStatus = isOverdue
                                  ? "OVERDUE"
                                  : (returnDate != null
                                      ? "Returned"
                                      : "Borrowed");

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isOverdue
                                          ? Colors.red.shade300
                                          : Colors.orange.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isOverdue
                                          ? Icons.warning
                                          : Icons.handshake,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    borr['borrowerName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Serial: ${borr['serialNumber']} | Brand: ${borr['brand']}\n"
                                    "Borrowed At: ${_formatDateTime(borrowedAt)}\n"
                                    "Status: $itemStatus",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format date/time
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat('MM/dd/yyyy HH:mm').format(dt);
  }

  // Build a summary card with improved design & chart-like style
  Widget _buildSummaryCard({
    required String title,
    required Future<int> futureCount,
    required IconData icon,
    required Color color,
  }) {
    return FutureBuilder<int>(
      future: futureCount,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!;
        } else if (snapshot.hasError) {
          print("Error in $title: ${snapshot.error}");
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 420,
            margin: const EdgeInsets.only(right: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circle icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Count + Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? "Loading..."
                          : count.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// This is the updated code that uses 'expectedReturn' and 'returnDate' fields in your 'borrowings' docs.
// If 'returnDate' is null and 'expectedReturn' is in the past => "OVERDUE".
