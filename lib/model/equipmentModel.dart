// equipment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentModel {
  final String id;
  final String serialNumber;
  final String brand;
  final String model;
  final String room;
  final String status;
  final String unitCode;
  final DateTime createdAt;

  EquipmentModel({
    required this.id,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.room,
    required this.status,
    required this.unitCode,
    required this.createdAt,
  });

  factory EquipmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentModel(
      id: doc.id,
      serialNumber: data['serialNumber'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      room: data['room'] ?? '',
      status: data['status'] ?? '',
      unitCode: data['unitCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
