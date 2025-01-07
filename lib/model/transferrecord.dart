// transfer_record.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TransferRecord {
  final String id; // Firestore document ID
  final String equipmentId;
  final String serialNumber;
  final String brand;
  final String model;
  final String unitCode;
  final String fromRoom;
  final String toRoom;
  final DateTime transferDate;

  TransferRecord({
    required this.id,
    required this.equipmentId,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.unitCode,
    required this.fromRoom,
    required this.toRoom,
    required this.transferDate,
  });

  factory TransferRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransferRecord(
      id: doc.id,
      equipmentId: data['equipmentId'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      unitCode: data['unitCode'] ?? '',
      fromRoom: data['fromRoom'] ?? '',
      toRoom: data['toRoom'] ?? '',
      transferDate: (data['transferDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'serialNumber': serialNumber,
      'brand': brand,
      'model': model,
      'unitCode': unitCode,
      'fromRoom': fromRoom,
      'toRoom': toRoom,
      'transferDate': transferDate,
    };
  }
}
