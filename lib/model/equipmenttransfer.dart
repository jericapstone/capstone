// equipment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentTranserModel {
  final String id; // Firestore document ID
  final String brand;
  final String model;
  final String room;
  final String serialNumber;
  final String status;
  final String type;
  final String unitCode;

  EquipmentTranserModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.room,
    required this.serialNumber,
    required this.status,
    required this.type,
    required this.unitCode,
  });

  factory EquipmentTranserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentTranserModel(
      id: doc.id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      room: data['room'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      status: data['status'] ?? '',
      type: data['type'] ?? '',
      unitCode: data['unitCode'] ?? '',
    );
  }
}
