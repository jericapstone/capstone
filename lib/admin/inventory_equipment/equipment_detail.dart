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
      _fetchEquipmentDetails(widget.selectedEquipmentCode!);
    }
    _fetchBrandList();
    _fetchTypes();
    _fetchStatuses();
    fetchMTData();
    serialNumberController.addListener(_fetchEquipmentDetailsBySerial);
  }

  @override
  void dispose() {
    serialNumberController.removeListener(_fetchEquipmentDetailsBySerial);
    super.dispose();
  }

  void _fetchEquipmentDetailsBySerial() async {
    final serialNumber = serialNumberController.text;

    if (serialNumber.isNotEmpty) {
      QuerySnapshot snapshot = await _firestore
          .collection('equipment')
          .where('serialNumber', isEqualTo: serialNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        setState(() {
          unitCodeController.text = doc['unitCode'] ?? '';
          modelController.text = doc['model'] ?? '';
          selectedType = doc['type'];
          selectedStatus = doc['status'];
          selectedBrand = doc['brand'];
          selectedRoom = doc['room'];
        });
      } else {
        setState(() {
          unitCodeController.clear();
          modelController.clear();
          selectedType = null;
          selectedStatus = null;
          selectedBrand = null;
          selectedRoom = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No equipment found for this serial number.')));
      }
    }
  }

  void _fetchEquipmentDetails(String equipmentCode) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('equipment').doc(equipmentCode).get();

      if (snapshot.exists) {
        setState(() {
          unitCodeController.text = snapshot['unitCode'] ?? '';
          modelController.text = snapshot['model'] ?? '';
          selectedType = snapshot['type'];
          selectedStatus = snapshot['status'];
          selectedBrand = snapshot['brand'];
          selectedRoom = snapshot['room'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No equipment found for this unit code.')));
      }
    } catch (e) {
      print('Error fetching equipment details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch equipment details: $e')));
    }
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
          'room': selectedRoom,
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
        selectedRoom == null) {
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
    return Container(
      width: 170,
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      width: 170,
      child: DropdownButtonFormField<String>(
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
      ),
    );
  }

  Widget _buildRoomDropdown() {
    return Container(
      width: 170,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Room',
          border: OutlineInputBorder(),
        ),
        value: selectedRoom,
        items: maryThomaslist.map((mt) {
          return DropdownMenuItem<String>(
            value: mt['name'],
            child: Text(mt['name'] ?? 'Unknown Room'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedRoom = value;
          });
        },
        hint: const Text('Select Room'),
      ),
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

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: unitCodeController,
                    decoration: const InputDecoration(labelText: 'Unit Code', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                    decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder()),
                    hint: const Text('Select Brand'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: serialNumberController,
                    decoration: const InputDecoration(labelText: 'Serial Number', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTypeDropdown(),
                const SizedBox(width: 8),
                _buildStatusDropdown(),
                const SizedBox(width: 8),
                _buildRoomDropdown(),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveEquipmentDetails,
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
