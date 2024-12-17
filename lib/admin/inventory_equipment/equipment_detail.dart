import 'package:capstonesproject2024/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EquipmentDetails extends StatefulWidget {
  final String? selectedEquipmentCode;
  final Function onEquipmentAdded;

  EquipmentDetails({
    required this.onEquipmentAdded,
    this.selectedEquipmentCode,
    required List brandList,
    required List<String> equipmentTypes,
  });

  @override
  _EquipmentDetailsState createState() => _EquipmentDetailsState();
}

class _EquipmentDetailsState extends State<EquipmentDetails> {
  String? selectedRoom;
  List<Map<String, String>> maryThomaslist = [];
  String? selectedType;
  String? selectedStatus;
  String? selectedBrand;
  TextEditingController unitCodeController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> brandList = [];
  List<String> typeList = [];
  List<String> statusList = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedEquipmentCode != null) {
      unitCodeController.text = widget.selectedEquipmentCode!;
      _loadEquipmentDetails(widget.selectedEquipmentCode!);
    }
    _fetchBrandList();
    _fetchTypes();
    _fetchStatuses();
    fetchMTData();
  }

  Future<void> _fetchBrandList() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('brands').get();
      setState(() {
        brandList = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

  Future<void> _fetchTypes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('types').get();
      setState(() {
        typeList = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching types: $e');
    }
  }

  Future<void> _fetchStatuses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('statuses').get();
      setState(() {
        statusList = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching statuses: $e');
    }
  }

  // Fetch MT data (room details)
  void fetchMTData() async {
    final mts = await getMTs(_firestore.collection('mt'));
    setState(() {
      maryThomaslist = mts.map((mt) => {'id': mt.id, 'name': mt.name}).toList();
    });
  }

  Future<List<MT>> getMTs(CollectionReference mtCollection) async {
    try {
      final snapshot = await mtCollection.get();
      return snapshot.docs.map((doc) {
        return MT.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching MTs: $e');
      return [];
    }
  }

  Future<void> _loadEquipmentDetails(String unitCode) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('equipment').doc(unitCode).get();
      if (snapshot.exists) {
        setState(() {
          serialNumberController.text = snapshot['serialNumber'] ?? '';
          modelController.text = snapshot['model'] ?? '';
          selectedType = snapshot['type'];
          selectedStatus = snapshot['status'];
          selectedBrand = snapshot['brand'];
          selectedRoom = snapshot['room']; // Load the room value
        });
      }
    } catch (e) {
      print('Error loading equipment details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading equipment details: $e')));
    }
  }

  Future<void> _showSaveConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save'),
          content: const Text('Are you sure you want to save these equipment details?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveEquipmentDetails();
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEquipmentDetails() async {
    if (_validateFields()) {
      try {
        await _firestore.collection('equipment').doc(unitCodeController.text).set({
          'unitCode': unitCodeController.text,
          'brand': selectedBrand,
          'serialNumber': serialNumberController.text,
          'model': modelController.text,
          'type': selectedType,
          'status': selectedStatus,
          'room': selectedRoom, // Save selected room
        });

        widget.onEquipmentAdded();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipment details saved successfully!')));
      } catch (e) {
        print('Error saving equipment details: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save equipment details: $e')));
      }
    }
  }

  bool _validateFields() {
    if (unitCodeController.text.isEmpty ||
        selectedBrand == null ||
        serialNumberController.text.isEmpty ||
        modelController.text.isEmpty ||
        selectedType == null ||
        selectedStatus == null ||
        selectedRoom == null) { // Validate room selection as well
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all required fields')));
      return false;
    }
    return true;
  }

  void _clearFields() {
    unitCodeController.clear();
    serialNumberController.clear();
    modelController.clear();
    setState(() {
      selectedType = null;
      selectedStatus = null;
      selectedBrand = null;
      selectedRoom = null;
    });
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'TYPE',
        border: OutlineInputBorder(),
      ),
      value: selectedType,
      items: typeList.isEmpty
          ? [const DropdownMenuItem(child: Text('No Types Available'))]
          : typeList.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
      hint: const Text('Select Type'),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      value: selectedStatus,
      items: statusList.isEmpty
          ? [const DropdownMenuItem(child: Text('No Status Available'))]
          : statusList.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedStatus = value;
        });
      },
      hint: const Text('Select Status'),
    );
  }

  // Room dropdown for selecting room
  Widget _buildRoomDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Room',
        border: OutlineInputBorder(),
      ),
      value: selectedRoom, // Now selectedRoom should be a String
      items: maryThomaslist.map((mt) {
        return DropdownMenuItem<String>(
          value: mt['name'], // Set the room name as the value
          child: Text(mt['name'] ?? 'Unknown Room'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRoom = value; // Store the selected room name
        });
      },
      hint: const Text('Select Room'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Equipment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // First Row: Unit Code and Brand
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: unitCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Spacer between the fields
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedBrand,
                    items: brandList.isEmpty
                        ? [const DropdownMenuItem(child: Text('No Brands Available'))]
                        : brandList.map((brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBrand = value;
                      });
                    },
                    hint: const Text('Select Brand'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Second Row: Serial Number and Model
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: serialNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Spacer between the fields
                Expanded(
                  child: TextField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Aligns to the right
              children: [
                Container(
                  width: 200, // Adjust the width as needed
                  child: _buildTypeDropdown(),
                ),
                const SizedBox(width: 16), // Spacer between dropdowns
                Container(
                  width: 200, // Adjust the width as needed
                  child: _buildStatusDropdown(),
                ),
                const SizedBox(width: 16), // Spacer between dropdowns
                Container(
                  width: 200, // Adjust the width as needed
                  child: _buildRoomDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _clearFields,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _showSaveConfirmationDialog,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}