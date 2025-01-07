import 'package:flutter/material.dart';

class EquipmentPopup extends StatelessWidget {
  final Map<String, dynamic> equipmentItem;
  final Function(Map<String, dynamic>) onUpdate;

  EquipmentPopup({required this.equipmentItem, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final TextEditingController unitCodeController = TextEditingController(text: equipmentItem['unitCode']);
    final TextEditingController brandController = TextEditingController(text: equipmentItem['brand']);
    final TextEditingController modelController = TextEditingController(text: equipmentItem['model']);
    final TextEditingController serialNumberController = TextEditingController(text: equipmentItem['serialNumber']);
    final TextEditingController typeController = TextEditingController(text: equipmentItem['type']);
    final TextEditingController statusController = TextEditingController(text: equipmentItem['status']);
    final TextEditingController roomController = TextEditingController(text: equipmentItem['room']);

    return AlertDialog(
      title: Text("Edit Equipment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: unitCodeController,
              decoration: InputDecoration(labelText: "Unit Code"),
            ),
            TextField(
              controller: brandController,
              decoration: InputDecoration(labelText: "Brand"),
            ),
            TextField(
              controller: modelController,
              decoration: InputDecoration(labelText: "Model"),
            ),
            TextField(
              controller: serialNumberController,
              decoration: InputDecoration(labelText: "Serial Number"),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: "Type"),
            ),
            TextField(
              controller: statusController,
              decoration: InputDecoration(labelText: "Status"),
            ),
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
            onUpdate(updatedEquipment);
            Navigator.of(context).pop(); // Dismiss the dialog
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
