// borrowing.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Borrowing {
  final String id;
  final String borrowerName;
  final String borrowerID;
  final String borrowerPosition;
  final String borrowerDepartment;
  final String serialNumber;
  final String brand;
  final String model;
  final String room;
  final String status;
  final String unitCode;
  final String labAssistant;
  final DateTime borrowedTime;
  final String purpose;
  final DateTime borrowedAt;
  final DateTime? returnDate;
  final bool isDamaged;
  final String? damageDescription;

  Borrowing({
    required this.id,
    required this.borrowerName,
    required this.borrowerID,
    required this.borrowerPosition,
    required this.borrowerDepartment,
    required this.serialNumber,
    required this.brand,
    required this.model,
    required this.room,
    required this.status,
    required this.unitCode,
    required this.labAssistant,
    required this.borrowedTime,
    required this.purpose,
    required this.borrowedAt,
    this.returnDate,
    this.isDamaged = false,
    this.damageDescription,
  });

  factory Borrowing.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final damageData = data['damage'] as Map<String, dynamic>?;

    return Borrowing(
      id: doc.id,
      borrowerName: data['borrowerName'] ?? '',
      borrowerID: data['ID'] ?? '',
      borrowerPosition: data['borrowerPosition'] ?? '',
      borrowerDepartment: data['borrowerDepartment'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      room: data['room'] ?? '',
      status: data['status'] ?? '',
      unitCode: data['unitCode'] ?? '',
      labAssistant: data['labAssistant'] ?? '',
      borrowedTime: (data['borrowedTime'] as Timestamp).toDate(),
      purpose: data['purpose'] ?? '',
      borrowedAt: (data['borrowedAt'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      isDamaged: damageData != null ? damageData['isDamaged'] ?? false : false,
      damageDescription:
          damageData != null ? damageData['damageDescription'] ?? '' : null,
    );
  }
}
