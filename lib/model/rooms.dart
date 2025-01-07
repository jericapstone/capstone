// models/room.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id; // Firestore document ID
  final String name;

  Room({
    required this.id,
    required this.name,
  });

  factory Room.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}
