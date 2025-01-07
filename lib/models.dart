

// User class to represent user details
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String password;
  final String name;

  User({required this.email, required this.password, required this.name});

  // Convert User to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }

  // Convert Firestore document to User
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
    );
  }
}

// Brand class to represent equipment brand details
class Brand {
  final String id;
  final String name;
  final String description;

  Brand({required this.id, required this.name, required this.description});

  // Convert Brand to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Convert Firestore document to Brand
  factory Brand.fromMap(Map<String, dynamic> map, String documentId) {
    return Brand(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

// EquipmentType class to represent equipment type details
class EquipmentType {
  final String id;
  final String name;
  final String description;

  EquipmentType({required this.id, required this.name, required this.description});

  // Convert EquipmentType to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Convert Firestore document to EquipmentType
  factory EquipmentType.fromMap(Map<String, dynamic> map, String documentId) {
    return EquipmentType(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
// Status class to represent different status of equipment or rooms
class Status {
  final String id;
  final String name;
  final String description;

  Status({required this.id, required this.name, required this.description});

  // Convert Status to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Convert Firestore document to Status
  factory Status.fromMap(Map<String, dynamic> map, String documentId) {
    return Status(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

// Room class to represent room details
// Room Model
class Room {
  final String id;
  final String name;
  final String roomCode;
  final String type;
  final String status;

  Room({
    required this.id,
    required this.name,
    required this.roomCode,
    required this.type,
    required this.status,
  });

  // Ensure this method is correct
  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Get document data as a map
    return Room(
      id: doc.id, // Firestore document ID
      name: data['name'] ?? '',
      roomCode: data['Code'] ?? '',  // Corrected field name to 'Code'
      type: data['type'] ?? '',
      status: data['status'] ?? '',
    );
  }
}


class BorrowingTransaction {
  String id;
  String equipment;
  int quantity;
  String borrowedBy;
  String borrowedFrom;
  String returnedBy;
  String position;
  DateTime date;
  String itemId;
  String userId;

  // Updated constructor without the borrowDate parameter
  BorrowingTransaction({
    required this.id,
    required this.equipment,
    required this.quantity,
    required this.borrowedBy,
    required this.borrowedFrom,
    required this.returnedBy,
    required this.position,
    required this.date,
    required this.itemId,
    required this.userId,
  });

  // Add the fromFirestore method to map Firestore document to BorrowingTransaction
  factory BorrowingTransaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return BorrowingTransaction(
      id: doc.id,
      equipment: data['equipment'] ?? '',
      quantity: data['quantity'] ?? 0,
      borrowedBy: data['borrowedBy'] ?? '',
      borrowedFrom: data['borrowedFrom'] ?? '',
      returnedBy: data['returnedBy'] ?? '',
      position: data['position'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      itemId: data['itemId'] ?? '',
      userId: data['userId'] ?? '', // If userId is required, make sure it's handled properly
    );
  }
}


// RoomEquipment class to represent equipment in a room
class RoomEquipment {
  final String id;
  final String name;
  final String description;
  final String status;
  final String type;

  RoomEquipment({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.type,
  });

  // Convert RoomEquipment to map for Firestore saving
  factory RoomEquipment.fromMap(Map<String, dynamic> map, String id) {
    return RoomEquipment(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      type: map['type'] as String,
    );
  }

  // Convert RoomEquipment to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'type': type,
    };
  }
}

// RoomManagement class for managing room details
class RoomManagement {
  final String id;
  final String roomName;
  final String description;

  RoomManagement({
    required this.id,
    required this.roomName,
    required this.description,
  });

  // Convert Firestore document to RoomManagement instance
  factory RoomManagement.fromFirestore(Map<String, dynamic> doc, String id) {
    return RoomManagement(
      id: id,
      roomName: doc['roomName'] ?? '',
      description: doc['description'] ?? '',
    );
  }

  // Convert RoomManagement instance to map for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'description': description,
    };
  }
}
class BorrowedEquipment {
  String? id;
  String equipmentName;
  String borrowerName;
  DateTime borrowedDate;

  BorrowedEquipment({
    this.id,
    required this.equipmentName,
    required this.borrowerName,
    required this.borrowedDate,
  });

  factory BorrowedEquipment.fromMap(Map<String, dynamic> map, String documentId) {
    return BorrowedEquipment(
      id: documentId,
      equipmentName: map['equipmentName'] ?? '',
      borrowerName: map['borrowerName'] ?? '',
      borrowedDate: (map['borrowedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentName': equipmentName,
      'borrowerName': borrowerName,
      'borrowedDate': borrowedDate,
    };
  }
}

class EquipmentTransfer {
  String? id;
  String equipmentId;
  String fromRoomId;
  String toRoomId;
  DateTime transferDate;

  EquipmentTransfer({
    this.id,
    required this.equipmentId,
    required this.fromRoomId,
    required this.toRoomId,
    required this.transferDate,
  });

  factory EquipmentTransfer.fromMap(Map<String, dynamic> map, String id) {
    return EquipmentTransfer(
      id: id,
      equipmentId: map['equipmentId'],
      fromRoomId: map['fromRoomId'],
      toRoomId: map['toRoomId'],
      transferDate: (map['transferDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'fromRoomId': fromRoomId,
      'toRoomId': toRoomId,
      'transferDate': transferDate,
    };
  }
}


// Lab Assistant
class LabAssistant {
  final String id;
  final String name;
  final String course;

  LabAssistant({
    required this.id,
    required this.name,
    required this.course,
  });

  // Convert Firestore document to LabAssistant object
  factory LabAssistant.fromMap(Map<String, dynamic> map, String documentId) {
    return LabAssistant(
      id: documentId,
      name: map['name'] ?? '',
      course: map['course'] ?? '',
    );
  }

  // Convert LabAssistant object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
    };
  }
}

// Room For MT Lab
class MTRoom {
  final String id;  // Change this to int
  final String name;
  final String description;

  MTRoom({
    required this.id,
    required this.name,
    required this.description,
  });

  // Convert MTRoom to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  // Create an MTRoom instance from a Firestore document
  factory MTRoom.fromMap(Map<String, dynamic> map, String id) {
    return MTRoom(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class MT {
  final String id;
  final String name;
  final String department;

  MT({
    required this.id,
    required this.name,
    this.department = '', // Default to an empty string if not provided
  });

  // Convert Firestore document to MT object
  factory MT.fromMap(Map<String, dynamic> map, String documentId) {
    return MT(
      id: documentId,
      name: map['name'] ?? 'Unknown Room', // Default to 'Unknown Room' if name is null
      department: map['department'] ?? '', // Default to an empty string if department is null
    );
  }

  // Convert MT object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
    };
  }
}

class Schedule {
  final String subject;
  final String instructor;
  final String? labAssistant;
  final String? room;
  final String time;
  final String day;

  Schedule({
    required this.subject,
    required this.instructor,
    this.labAssistant,
    this.room,
    required this.time,
    required this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'instructor': instructor,
      'labAssistant': labAssistant,
      'room': room,
      'time': time,
      'day': day,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      subject: map['subject'],
      instructor: map['instructor'],
      labAssistant: map['labAssistant'],
      room: map['room'],
      time: map['time'],
      day: map['day'],
    );
  }
}

class AccountType {
  final String id;
  final String name;
  final String status;

  AccountType({
    required this.id,
    required this.name,
    required this.status,
  });

  factory AccountType.fromFirestore(Map<String, dynamic> data) {
    return AccountType(
      id: data['id'] ?? '', // Default value for missing fields
      name: data['name'] ?? '',
      status: data['status'] ?? '',
    );
  }

  // toMap method for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }
}

class Equipment {
  String unitCode;
  String serialNumber;
  String? brand;
  String? Type;
  String? status;
  String? room;

  Equipment({
    required this.unitCode,
    required this.serialNumber,
    this.brand,
    this.Type,
    this.status,
    this.room,
  });

  // Method to convert an Equipment object into a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'unitCode': unitCode,
      'serialNumber': serialNumber,
      'brand': brand,
      'Type': Type,
      'status': status,
      'room': room,
    };
  }

  // Factory method to create an Equipment object from Firestore data
  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      unitCode: map['unitCode'],
      serialNumber: map['serialNumber'],
      brand: map['brand'],
      Type: map['Type'],
      status: map['status'],
      room: map['room'],
    );
  }
}

class Type {
  final String id;
  final String name;
  final String description;

  Type({required this.id, required this.name, required this.description});

  factory Type.fromMap(Map<String, dynamic> map) {
    return Type(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

// schedule_model.dart

class ScheduleModel {
  String time;
  String monday;
  String tuesday;
  String wednesday;
  String thursday;
  String friday;
  String saturday;

  ScheduleModel({
    required this.time,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  // Example of a method that encodes the schedule as a list of strings
  List<String> toList() {
    return [
      time,
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
    ];
  }

  // Method to get time slots based on a particular schedule day (e.g., for a teacher or student)
  static List<String> getTimeSlots(List<ScheduleModel> schedules, String day) {
    return schedules
        .map((schedule) => schedule.toList()[ScheduleModel._getDayIndex(day)])
        .toSet() // Ensure unique times
        .toList();
  }

  // Helper method to find the correct index for each day (mapping to list)
  static int _getDayIndex(String day) {
    switch (day) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      default:
        return 0;
    }
  }
}





