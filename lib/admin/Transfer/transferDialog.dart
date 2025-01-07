// transfer_form_dialog.dart

import 'package:capstonesproject2024/model/equipmenttransfer.dart';
import 'package:capstonesproject2024/model/transferrecord.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransferFormDialog extends StatefulWidget {
  final EquipmentTranserModel equipment;

  const TransferFormDialog({Key? key, required this.equipment})
      : super(key: key);

  @override
  _TransferFormDialogState createState() => _TransferFormDialogState();
}

class _TransferFormDialogState extends State<TransferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fromRoomController;
  late TextEditingController toRoomController;
  DateTime? transferDate;

  @override
  void initState() {
    super.initState();
    fromRoomController = TextEditingController(text: widget.equipment.room);
    toRoomController = TextEditingController();
    transferDate = DateTime.now();
  }

  @override
  void dispose() {
    fromRoomController.dispose();
    toRoomController.dispose();
    super.dispose();
  }

  /// Handles the transfer submission
  Future<void> handleTransfer() async {
    if (_formKey.currentState!.validate()) {
      // Update equipment's room and status
      await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.equipment.id)
          .update({
        'room': toRoomController.text.trim(),
        'status': 'Transferred',
      });

      // Create a transfer record
      TransferRecord transfer = TransferRecord(
        id: '', // Firestore will assign the ID
        equipmentId: widget.equipment.id,
        serialNumber: widget.equipment.serialNumber,
        brand: widget.equipment.brand,
        model: widget.equipment.model,
        unitCode: widget.equipment.unitCode,
        fromRoom: fromRoomController.text.trim(),
        toRoom: toRoomController.text.trim(),
        transferDate: transferDate!,
      );

      await FirebaseFirestore.instance.collection('transfers').add(
            transfer.toMap(),
          );

      // Close the dialog
      Navigator.of(context).pop();

      // Optionally, show a success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment transferred successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Opens the date picker
  Future<void> pickTransferDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: transferDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != transferDate) {
      setState(() {
        transferDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transfer Equipment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Serial Number (Read-only)
              TextFormField(
                initialValue: widget.equipment.serialNumber,
                decoration: const InputDecoration(
                  labelText: 'Serial Number',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              // Brand (Read-only)
              TextFormField(
                initialValue: widget.equipment.brand,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              // Model (Read-only)
              TextFormField(
                initialValue: widget.equipment.model,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16),
              // Unit Code (Read-only)
              TextFormField(
                initialValue: widget.equipment.unitCode,
                decoration: const InputDecoration(
                  labelText: 'Unit Code',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              // From Room (Read-only)
              TextFormField(
                controller: fromRoomController,
                decoration: const InputDecoration(
                  labelText: 'From Room',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16),
              // To Room (Editable)
              TextFormField(
                controller: toRoomController,
                decoration: const InputDecoration(
                  labelText: 'Transfer To Room',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the destination room.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Transfer Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transfer Date: ${transferDate != null ? DateFormat('yyyy-MM-dd').format(transferDate!) : ''}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: pickTransferDate,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal, // Text color
                    ),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: handleTransfer,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal, // Text color
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
