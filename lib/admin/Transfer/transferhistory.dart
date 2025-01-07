// transfer_history_dialog.dart

import 'package:capstonesproject2024/model/transferrecord.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransferHistoryDialog extends StatelessWidget {
  final List<TransferRecord> transferRecords;

  const TransferHistoryDialog({
    Key? key,
    required this.transferRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Transfer History'),
      content: transferRecords.isEmpty
          ? Text('No transfer records found.')
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(
                      'From Room',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'To Room',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Transfer Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: transferRecords.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text(record.fromRoom)),
                      DataCell(Text(record.toRoom)),
                      DataCell(Text(DateFormat('yyyy-MM-dd – kk:mm')
                          .format(record.transferDate))),
                    ],
                  );
                }).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
