import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentDataSource extends DataTableSource {
  final List<QueryDocumentSnapshot> equipmentDocs;
  final Function(String) onEdit;
  final Function(String) onDelete;
  final Function(String) onView; // Add this line

  EquipmentDataSource(this.equipmentDocs, {
    required this.onEdit,
    required this.onDelete,
    required this.onView, // Add this line
  });

  @override
  DataRow getRow(int index) {
    final equipmentDoc = equipmentDocs[index];
    final data = equipmentDoc.data() as Map<String, dynamic>;

    return DataRow(cells: [
      DataCell(Text(data['unitCode'] ?? 'N/A')),
      DataCell(Text(data['brand'] ?? 'N/A')),
      DataCell(Text(data['model'] ?? 'N/A')),
      DataCell(Text(data['serialNumber'] ?? 'N/A')),
      DataCell(Text(data['equipmentTypes'] ?? 'N/A')),
      DataCell(Text(data['status'] ?? 'N/A')),
      DataCell(Text(data['room'] ?? 'N/A')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the icons
        children: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
            onPressed: () {
              // Use the onView callback
              onView(equipmentDoc.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () => onEdit(equipmentDoc.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.deepOrange),
            onPressed: () => onDelete(equipmentDoc.id),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => equipmentDocs.length;

  @override
  int get selectedRowCount => 0; // Implement if needed
}
