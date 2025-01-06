import 'package:flutter/material.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/Sidebar.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

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
  _BorrowingTransactionScreenState createState() =>
      _BorrowingTransactionScreenState();
}

class _BorrowingTransactionScreenState
    extends State<BorrowingTransactionScreen> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController borrowedByController = TextEditingController();
  final TextEditingController returnedByController = TextEditingController();

  String? borrowedFrom = 'Select Borrower';
  List<String> selectedEquipment = [];
  List<String> selectedPositions = [];
  List<BorrowingTransaction> transactions = [];
  List<BorrowingTransaction> allTransactions = [];

  final FirestoreService _firestoreService = FirestoreService();

  List<String> equipmentOptions = [];
  List<String> positionOptions = ['Student', 'Teacher'];
  List<String> labAssistants = []; // List to hold lab assistants

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadEquipmentOptions();
    _loadLabAssistants(); // Fetch lab assistants
  }

  // Load lab assistants from Firestore (modify based on actual collection)
  Future<void> _loadLabAssistants() async {
    List<LabAssistant> fetchedAssistants = await _firestoreService.getLabAssistants();
    setState(() {
      labAssistants = fetchedAssistants.map((assistant) => assistant.name).toList();
    });
  }

  Future<void> _loadTransactions() async {
    List<BorrowingTransaction> fetchedTransactions =
    await _firestoreService.getBorrowingTransactions();
    setState(() {
      transactions = fetchedTransactions;
      allTransactions = List.from(fetchedTransactions);
    });
    widget.onTransactionsUpdated(transactions);
  }

  Future<void> _loadEquipmentOptions() async {
    List<BorrowedEquipment> borrowedEquipments =
    await _firestoreService.getBorrowedEquipments();
    setState(() {
      equipmentOptions =
          borrowedEquipments.map((equipment) => equipment.equipmentName).toList();
    });
  }

  Future<void> addTransaction() async {
    if (selectedEquipment.isEmpty ||
        quantityController.text.isEmpty ||
        borrowedByController.text.isEmpty ||
        borrowedFrom == null ||
        borrowedFrom == 'Select Borrower' ||
        selectedPositions.isEmpty || // Ensure at least one position is selected
        returnedByController.text.isEmpty) {
      print('All fields must be filled');
      return;
    }

    final newTransaction = BorrowingTransaction(
      id: '', // Firestore will assign the ID
      itemId: '', // Assuming this is auto-generated
      userId: borrowedByController.text.trim(),
      date: DateTime.now(),
      equipment: selectedEquipment.join(', '),
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      borrowedBy: borrowedByController.text.trim(),
      borrowedFrom: borrowedFrom ?? 'Unknown Source',
      returnedBy: returnedByController.text.trim(),
      position: selectedPositions.join(', '), // Join selected positions
    );

    // Add the transaction to Firestore
    await _firestoreService.addBorrowingTransaction(newTransaction);

    setState(() {
      transactions.add(newTransaction);
      allTransactions.add(newTransaction);
    });

    widget.onTransactionsUpdated(transactions);

    // Clear the form after submission
    quantityController.clear();
    borrowedByController.clear();
    returnedByController.clear();
    borrowedFrom = 'Select Borrower';
    selectedEquipment.clear();
    selectedPositions.clear(); // Clear selected positions
  }
  Future<void> deleteTransaction(String transactionId) async {
    // Call the Firestore service to delete the transaction by its ID
    bool success = await _firestoreService.deleteBorrowingTransaction(transactionId);

    if (success) {
      setState(() {
        transactions.removeWhere((transaction) => transaction.id == transactionId);
        allTransactions.removeWhere((transaction) => transaction.id == transactionId);
      });
      widget.onTransactionsUpdated(transactions);
    } else {
      print('Failed to delete transaction');
    }
  }
  void _exportDataToCsv() {
    List<List<String>> rows = [
      [
        'Date',
        'Equipment',
        'Quantity',
        'Borrowed By',
        'Borrowed From',
        'Position',
        'Returned By',
      ],
      ...transactions.map((transaction) => [
        transaction.date.toString(),
        transaction.equipment,
        transaction.quantity.toString(),
        transaction.borrowedBy,
        transaction.borrowedFrom,
        transaction.position,
        transaction.returnedBy,
      ]),
    ];

    String csvData = const ListToCsvConverter().convert(rows);

    final blob = html.Blob([csvData]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.Url.revokeObjectUrl(url);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: addTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'Add Transaction',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _exportDataToCsv,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text(
            'Download as CSV',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Equipment:'),
        Column(
          children: equipmentOptions.map((equipment) {
            return CheckboxListTile(
              title: Text(equipment),
              value: selectedEquipment.contains(equipment),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    selectedEquipment.add(equipment);
                  } else {
                    selectedEquipment.remove(equipment);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build checkboxes for positions (Student, Teacher)
  Widget _buildPositionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Position:'),
        Column(
          children: positionOptions.map((position) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Adjust the width of the label to align with the checkbox
                SizedBox(
                  width: 100,  // Adjust the width as needed
                  child: Text(position),
                ),
                Checkbox(
                  value: selectedPositions.contains(position),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        selectedPositions.add(position);
                      } else {
                        selectedPositions.remove(position);
                      }
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionDataTable() {
    return Card(
      elevation: 4,
      child: Container(
        width: 2000, // Keep the width fixed
        height: 450, // Keep the height fixed
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20, // Adjust spacing between columns
            dataRowHeight: 50,
            headingRowHeight: 50,
            headingRowColor: MaterialStateProperty.all(Colors.black),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            border: TableBorder.all(color: Colors.black, width: 3),
            columns: const [
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Borrowed By', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Borrowed From', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Position', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Returned By', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: transactions.map((transaction) {
              return DataRow(cells: [
                DataCell(Text(transaction.date.toString())),
                DataCell(Text(transaction.equipment)),
                DataCell(Text(transaction.quantity.toString())),
                DataCell(Text(transaction.borrowedBy)),
                DataCell(Text(transaction.borrowedFrom)),
                DataCell(Text(transaction.position)),
                DataCell(Text(transaction.returnedBy)),
                DataCell(
                  // This is where you can add buttons or actions for each row.
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTransaction(transaction.id), // Use the correct property name here
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            profileImagePath: widget.profileImagePath,
            adminName: widget.adminName,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Container(
                              height: 350,
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [_buildEquipmentSelection()],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Container(
                              height: 350,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: borrowedByController,
                                          decoration: const InputDecoration(
                                            labelText: 'Borrowed By',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: borrowedFrom,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              borrowedFrom = newValue;
                                            });
                                          },
                                          items: <String>[
                                            'Select Borrower',
                                            ...labAssistants, // Fetch lab assistants dynamically
                                          ]
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                          decoration: const InputDecoration(
                                            labelText: 'Borrowed From',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildPositionSelection(),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: returnedByController,
                                          decoration: const InputDecoration(
                                            labelText: 'Returned By',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: quantityController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Quantity',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildTransactionDataTable(),
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
