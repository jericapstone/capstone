// models/reservation.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id; // Firestore document ID
  final String name;
  final String room;
  final DateTime startDateTime;
  final DateTime endDateTime;

  Reservation({
    required this.id,
    required this.name,
    required this.room,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory Reservation.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      name: data['name'] ?? '',
      room: data['room'] ?? '',
      startDateTime: (data['startDateTime'] as Timestamp).toDate(),
      endDateTime: (data['endDateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'room': room,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };
  }
}
