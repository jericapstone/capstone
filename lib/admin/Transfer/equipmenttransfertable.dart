// equipment_data_table.dart

import 'package:capstonesproject2024/model/equipmenttransfer.dart';
import 'package:flutter/material.dart';

class EquipmentDataTable extends StatelessWidget {
  final List<EquipmentTranserModel> equipments;
  final Future<void> Function(EquipmentTranserModel) onTransfer;
  final Future<void> Function(EquipmentTranserModel) onViewHistory;

  const EquipmentDataTable({
    Key? key,
    required this.equipments,
    required this.onTransfer,
    required this.onViewHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          headingRowColor:
              WidgetStateColor.resolveWith((states) => Colors.teal.shade200),
          columns: const [
            DataColumn(
              label: Text(
                'Serial Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Brand',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Model',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Unit Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Room',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: equipments.map((equipment) {
            return DataRow(
              cells: [
                DataCell(Text(equipment.serialNumber)),
                DataCell(Text(equipment.brand)),
                DataCell(Text(equipment.model)),
                DataCell(Text(equipment.unitCode)),
                DataCell(Text(equipment.room)),
                DataCell(
                  Text(
                    equipment.status,
                    style: TextStyle(
                      color: equipment.status.toLowerCase() == 'available'
                          ? Colors.green
                          : equipment.status.toLowerCase() == 'borrowed'
                              ? Colors.blue
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.transfer_within_a_station,
                            color: Colors.orange),
                        tooltip: 'Transfer',
                        onPressed: () => onTransfer(equipment),
                      ),
                      IconButton(
                        icon: Icon(Icons.history, color: Colors.teal),
                        tooltip: 'View History',
                        onPressed: () => onViewHistory(equipment),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
