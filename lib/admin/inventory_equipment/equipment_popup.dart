import 'package:flutter/material.dart';

class EquipmentPopup extends StatefulWidget {
  final Map<String, dynamic> equipmentItem;
  final Function(Map<String, dynamic>) onUpdate;

  EquipmentPopup({required this.equipmentItem, required this.onUpdate});

  @override
  State<EquipmentPopup> createState() => _EquipmentPopupState();
}

class _EquipmentPopupState extends State<EquipmentPopup> {
  late TextEditingController unitCodeController;
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController serialNumberController;
  late TextEditingController typeController;
  late TextEditingController statusController;
  late TextEditingController roomController;

  // Tracks if the user has chosen to override the auto-generated Unit Code
  bool _isUnitCodeOverridden = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on the passed equipmentItem
    unitCodeController =
        TextEditingController(text: widget.equipmentItem['unitCode']);
    brandController =
        TextEditingController(text: widget.equipmentItem['brand']);
    modelController =
        TextEditingController(text: widget.equipmentItem['model']);
    serialNumberController =
        TextEditingController(text: widget.equipmentItem['serialNumber']);
    typeController = TextEditingController(text: widget.equipmentItem['type']);
    statusController =
        TextEditingController(text: widget.equipmentItem['status']);
    roomController = TextEditingController(text: widget.equipmentItem['room']);

    // Whenever the user changes 'type' or 'room' and we haven't overridden,
    // auto-generate unit code => "type - room"
    typeController.addListener(_autoGenerateUnitCode);
    roomController.addListener(_autoGenerateUnitCode);
  }

  @override
  void dispose() {
    // Remove listeners
    typeController.removeListener(_autoGenerateUnitCode);
    roomController.removeListener(_autoGenerateUnitCode);

    // Dispose controllers
    unitCodeController.dispose();
    brandController.dispose();
    modelController.dispose();
    serialNumberController.dispose();
    typeController.dispose();
    statusController.dispose();
    roomController.dispose();

    super.dispose();
  }

  /// Automatically generate "Unit Code" as "type - room"
  /// only if user hasn't overridden the field manually
  void _autoGenerateUnitCode() {
    if (!_isUnitCodeOverridden) {
      final newUnitCode = '${typeController.text} - ${roomController.text}';
      unitCodeController.text = newUnitCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Equipment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ------------------
            // Unit Code
            // ------------------
            TextField(
              controller: unitCodeController,
              readOnly: !_isUnitCodeOverridden, // read-only unless overridden
              decoration: InputDecoration(
                labelText: "Unit Code (auto: type - room)",
                suffixIcon: IconButton(
                  icon: Icon(_isUnitCodeOverridden
                      ? Icons.lock_open
                      : Icons.lock_outline),
                  onPressed: () {
                    // Toggle manual override
                    setState(() {
                      _isUnitCodeOverridden = !_isUnitCodeOverridden;
                    });
                  },
                ),
              ),
            ),
            // Brand
            TextField(
              controller: brandController,
              decoration: InputDecoration(labelText: "Brand"),
            ),
            // Model
            TextField(
              controller: modelController,
              decoration: InputDecoration(labelText: "Model"),
            ),
            // Serial Number
            TextField(
              controller: serialNumberController,
              decoration: InputDecoration(labelText: "Serial Number"),
            ),
            // Type
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: "Type"),
            ),
            // Status
            TextField(
              controller: statusController,
              decoration: InputDecoration(labelText: "Status"),
            ),
            // Room
            TextField(
              controller: roomController,
              decoration: InputDecoration(labelText: "Room"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Collect the updated data
            Map<String, dynamic> updatedEquipment = {
              'unitCode': unitCodeController.text,
              'brand': brandController.text,
              'model': modelController.text,
              'serialNumber': serialNumberController.text,
              'type': typeController.text,
              'status': statusController.text,
              'room': roomController.text,
            };

            // Call the onUpdate function to pass the updated data back
            widget.onUpdate(updatedEquipment);
            Navigator.of(context).pop(); // Dismiss the dialog
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
