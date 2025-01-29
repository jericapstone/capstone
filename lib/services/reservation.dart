import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String name;
  final String room;
  final String description; // New field
  final DateTime startDateTime;
  final DateTime endDateTime;

  Reservation({
    required this.id,
    required this.name,
    required this.room,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
  });

  /// Create from Firestore document
  factory Reservation.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      name: data['name'] ?? '',
      room: data['room'] ?? '',
      description: data['description'] ?? '',
      startDateTime: (data['startDateTime'] as Timestamp).toDate(),
      endDateTime: (data['endDateTime'] as Timestamp).toDate(),
    );
  }

  /// Convert to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'room': room,
      'description': description,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
    };
  }
}
