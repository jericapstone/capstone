import 'package:capstonesproject2024/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  final CollectionReference borrowingTransactionsCollection =
  FirebaseFirestore.instance.collection('borrowing_transactions');
  final CollectionReference roomsCollection =
  FirebaseFirestore.instance.collection('rooms');
  final CollectionReference brandsCollection =
  FirebaseFirestore.instance.collection('brands');
  final CollectionReference equipmentTypesCollection =
  FirebaseFirestore.instance.collection('equipment_types');
  final CollectionReference statusesCollection =
  FirebaseFirestore.instance.collection('statuses');
  final CollectionReference roomEquipmentsCollection =
  FirebaseFirestore.instance.collection('room_equipments');
  final CollectionReference roomManagementCollection =
  FirebaseFirestore.instance.collection('room_management');
  final CollectionReference borrowedEquipmentsCollection =
  FirebaseFirestore.instance.collection('borrowedEquipments');
  final CollectionReference equipmentTransfersCollection =
  FirebaseFirestore.instance.collection('equipment_transfers');
  final CollectionReference labAssistantsCollection =
  FirebaseFirestore.instance.collection('lab_assistants');
  final CollectionReference mtrRoomsCollection =
  FirebaseFirestore.instance.collection('MTRooms');
  final CollectionReference mtCollection =
  FirebaseFirestore.instance.collection('mt');
  final CollectionReference schedulesCollection =
  FirebaseFirestore.instance.collection('schedule');
  final CollectionReference account_typesCollection =
  FirebaseFirestore.instance.collection('account_types');
  final CollectionReference typesCollection =
  FirebaseFirestore.instance.collection('types');
  final CollectionReference transfersCollection =
  FirebaseFirestore.instance.collection('transfer');

  // ================================
  // Type
  // ================================

  // Get all types from Firestore
  Future<List<Type>> getTypes() async {
    try {
      QuerySnapshot snapshot = await _db.collection('types').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Type(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching types: $e');
      return [];
    }
  }

  // Add a new type to Firestore
  Future<void> addType(Type type) async {
    try {
      await _db.collection('types').doc(type.id).set({
        'name': type.name,
        'description': type.description,
      });
    } catch (e) {
      print('Error adding type: $e');
    }
  }

  // Update an existing type in Firestore
  Future<void> updateType(Type type) async {
    try {
      await _db.collection('types').doc(type.id).update({
        'name': type.name,
        'description': type.description,
      });
    } catch (e) {
      print('Error updating type: $e');
    }
  }

  // Delete a type from Firestore
  Future<void> deleteType(String id) async {
    try {
      await _db.collection('types').doc(id).delete();
    } catch (e) {
      print('Error deleting type: $e');
    }
  }


    // ================================
    // Account Type
    // ================================


  // Fetch account types from Firestore
  static Future<List<AccountType>> getAccountTypes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('accountTypes').get();
      return snapshot.docs.map((doc) {
        return AccountType(
          id: doc.id,
          name: doc['name'],
          status: doc['status'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching account types: $e');
      return [];
    }
  }

  // Add a new account type
  Future<void> addAccountType(AccountType accountType) async {
    await _db.collection('accountTypes').add({
      'name': accountType.name,
      'status': accountType.status,
    });
  }

  Future<void> updateAccountType(AccountType accountType) async {
    await _db.collection('accountTypes').doc(accountType.id).update({
      'name': accountType.name,
      'status': accountType.status,
    });
  }
  Future<void> deleteAccountType(String id) async {
    try {
      await account_typesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting account type: $e');
    }
  }

  // ================================
  // Schedule
  // ================================

  // Fetch all schedules
  Future<List<Schedule>> getSchedules() async {
    try {
      final snapshot = await _db.collection('schedules').get();
      return snapshot.docs.map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }

  // Add a schedule
  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _db.collection('schedules').add(schedule.toMap());
    } catch (e) {
      print("Error adding schedule: $e");
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String subject) async {
    try {
      var scheduleDoc = await _db.collection('schedules').where('subject', isEqualTo: subject).get();
      for (var doc in scheduleDoc.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error deleting schedule: $e");
    }
  }

  // Update a schedule
  Future<void> updateSchedule(String subject, Schedule updatedSchedule) async {
    try {
      var scheduleDoc = await _db.collection('schedules').where('subject', isEqualTo: subject).get();
      for (var doc in scheduleDoc.docs) {
        await doc.reference.update(updatedSchedule.toMap());
      }
    } catch (e) {
      print("Error updating schedule: $e");
    }
  }


// ================================
  // MT Management Methods
  // ================================
  Future<List<MT>> getMTs() async {
    try {
      final snapshot = await mtCollection.get();
      return snapshot.docs.map((doc) {
        return MT.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching MTs: $e');
      return [];
    }
  }

  void fetchMTs() async {
    final mts = await getMTs();
    print('Fetched MTs: $mts');
  }

  Future<void> addMT(MT mt) async {
    try {
      await mtCollection.doc(mt.id).set(mt.toMap());
    } catch (e) {
      print('Error adding MT: $e');
    }
  }

  Future<void> updateMT(MT mt) async {
    try {
      await mtCollection.doc(mt.id).update(mt.toMap());
    } catch (e) {
      print('Error updating MT: $e');
    }
  }

  Future<void> deleteMT(String id) async {
    try {
      await mtCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting MT: $e');
    }
  }
// ================================
// MTRoom Methods (Refactored)
// ================================

// Get all rooms from the 'MTROOMS' collection
  Future<List<MTRoom>> getMTRooms() async {
    try {
      final snapshot = await _db.collection('MTROOMS').get();
      return snapshot.docs.map((doc) {
        return MTRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

// Add a room to the 'MTROOMS' collection
  Future<void> addMTRoom(MTRoom room) async {
    try {
      await _db.collection('MTROOMS').doc(room.id.toString()).set(room.toMap());
    } catch (e) {
      print('Error adding room: $e');
    }
  }

// Update a room in the 'MTROOMS' collection
  Future<void> updateMTRoom(MTRoom room) async {
    try {
      await _db.collection('MTROOMS').doc(room.id.toString()).update(room.toMap());
    } catch (e) {
      print('Error updating room: $e');
    }
  }

// Delete a room from the 'MTROOMS' collection
  Future<void> deleteMTRoom(String roomId) async {
    try {
      await _db.collection('MTROOMS').doc(roomId).delete();
    } catch (e) {
      print('Error deleting room: $e');
    }
  }


  // ================================
  // Lab Assistant Methods (New)
  // ================================
  Future<List<LabAssistant>> getLabAssistants() async {
    try {
      final snapshot = await labAssistantsCollection.get();
      return snapshot.docs.map((doc) {
        return LabAssistant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching lab assistants: $e');
      return [];
    }
  }

  Future<void> addLabAssistant(LabAssistant assistant) async {
    try {
      await labAssistantsCollection.doc(assistant.id).set(assistant.toMap());
    } catch (e) {
      print('Error adding lab assistant: $e');
    }
  }

  Future<void> updateLabAssistant(LabAssistant assistant) async {
    try {
      await labAssistantsCollection.doc(assistant.id).update(assistant.toMap());
    } catch (e) {
      print('Error updating lab assistant: $e');
    }
  }

  Future<void> deleteLabAssistant(String id) async {
    try {
      await labAssistantsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting lab assistant: $e');
    }
  }
  // ================================
  // Equipment Transfer Methods
  // ================================

  // Fetch equipment transfer records
  Future<List<EquipmentTransfer>> getEquipmentTransfers() async {
    try {
      final snapshot = await equipmentTransfersCollection.get();
      return snapshot.docs.map((doc) {
        return EquipmentTransfer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching equipment transfers: $e');
      return [];
    }
  }

  // Add new equipment transfer
  Future<void> addEquipmentTransfer(EquipmentTransfer transfer) async {
    try {
      await equipmentTransfersCollection.add(transfer.toMap());
    } catch (e) {
      print('Error adding equipment transfer: $e');
    }
  }

  // Update existing equipment transfer
  Future<void> updateEquipmentTransfer(EquipmentTransfer transfer) async {
    try {
      if (transfer.id != null) {
        await equipmentTransfersCollection
            .doc(transfer.id)
            .update(transfer.toMap());
      }
    } catch (e) {
      print('Error updating equipment transfer: $e');
    }
  }

  // Delete equipment transfer record
  Future<void> deleteEquipmentTransfer(String id) async {
    try {
      await equipmentTransfersCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting equipment transfer: $e');
    }
  }



  // ================================
  // Borrowed Equipment Methods
  // ================================
  Future<List<BorrowedEquipment>> getBorrowedEquipments() async {
    try {
      final snapshot = await borrowedEquipmentsCollection.get();
      return snapshot.docs
          .map((doc) => BorrowedEquipment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching borrowed equipments: $e');
      return [];
    }
  }

  Future<void> addBorrowedEquipment(BorrowedEquipment equipment) async {
    try {
      await borrowedEquipmentsCollection.add(equipment.toMap());
    } catch (e) {
      print('Error adding borrowed equipment: $e');
    }
  }

  Future<void> updateBorrowedEquipment(BorrowedEquipment equipment) async {
    if (equipment.id != null) {
      try {
        await borrowedEquipmentsCollection
            .doc(equipment.id)
            .update(equipment.toMap());
      } catch (e) {
        print('Error updating borrowed equipment: $e');
      }
    }
  }

  Future<void> deleteBorrowedEquipment(String id) async {
    try {
      await borrowedEquipmentsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting borrowed equipment: $e');
    }
  }


  // ================================
  // User and Admin Credentials Methods
  // ================================
  Future<bool> checkUserCredentials(String email) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user credentials: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getAdminDetails(String email) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception('Admin details not found for email: $email');
      }
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching admin details: $e');
      rethrow;
    }
  }

  // ================================
  // Equipment Types Methods
  // ================================
  // Fetch equipment types from Firestore
  Future<List<String>> getEquipmentTypes() async {
    try {
      final snapshot = await equipmentTypesCollection.get();
      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Return only the 'name' fields from the documents
      List<String> types = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
      return types;
    } catch (e) {
      print('Error getting equipment types: $e');
      return [];
    }
  }

  Future<void> updateEquipmentType(String equipmentTypeId, String newTypeName, String description) async {
    try {
      // Update the equipment type document in Firestore
      await _firestore.collection('equipmentTypes').doc(equipmentTypeId).update({
        'name': newTypeName, // Update the 'name' field
      });
      print('Equipment type updated successfully');
    } catch (e) {
      print('Error updating equipment type: $e');
      throw e;
    }
  }

  Future<void> addEquipmentType(String name, String description, String id) async {
    try {
      await equipmentTypesCollection.doc(id).set({
        'name': name,
        'description': description,
      });
    } catch (e) {
      print('Error adding equipment type: $e');
    }
  }

  Future<void> deleteEquipmentType(String id) async {
    try {
      await equipmentTypesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting equipment type: $e');
    }
  }
  // ================================
  // Room Methods
  // ================================
  Future<List<Room>> fetchRooms() async {
    try {
      final snapshot = await roomsCollection.get();
      return snapshot.docs.map((doc) {
        return Room.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  Future<void> addRoom(Room room) async {
    try {
      await roomsCollection.doc(room.id).set(room.toMap());
    } catch (e) {
      print('Error adding room: $e');
    }
  }

  Future<void> updateRoom(MTRoom room) async { // Ensure the correct model is used
    try {
      await roomsCollection.doc(room.id.toString()).update(room.toMap()); // Use the correct field names here
    } catch (e) {
      print('Error updating room: $e');
    }
  }


  Future<void> deleteRoom(String id) async { // Ensure the parameter type matches the ID type
    try {
      await roomsCollection.doc(id).delete(); // Use the correct ID for Firestore
    } catch (e) {
      print('Error deleting room: $e');
    }
  }


  // ================================
  // Status Methods
  // ================================
  Future<List<Status>> getStatuses() async {
    try {
      final snapshot = await statusesCollection.get();
      return snapshot.docs.map((doc) {
        return Status.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching statuses: $e');
      return [];
    }
  }

  Future<void> addStatus(Status status) async {
    try {
      await statusesCollection.doc(status.id).set(status.toMap());
    } catch (e) {
      print('Error adding status: $e');
    }
  }

  Future<void> updateStatus(Status status) async {
    try {
      await statusesCollection.doc(status.id).update(status.toMap());
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> deleteStatus(String id) async {
    try {
      await statusesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting status: $e');
    }
  }
// ================================
  // Borrowing Transaction Methods
  // ================================

  // Add Borrowing Transaction
  Future<void> addBorrowingTransaction(BorrowingTransaction transaction) async {
    try {
      await _db.collection('transactions').add({
        'date': transaction.date,
        'equipment': transaction.equipment,
        'quantity': transaction.quantity,
        'borrowedBy': transaction.borrowedBy,
        'borrowedFrom': transaction.borrowedFrom,
        'returnedBy': transaction.returnedBy,
        'position': transaction.position,
      });
      print('Transaction Added Successfully');
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  // Fetch Borrowing Transactions
  Future<List<BorrowingTransaction>> getBorrowingTransactions() async {
    try {
      final querySnapshot = await _db.collection('transactions').get();
      return querySnapshot.docs.map((doc) {
        return BorrowingTransaction(
          id: doc.id,
          equipment: doc['equipment'],
          quantity: doc['quantity'],
          borrowedBy: doc['borrowedBy'],
          borrowedFrom: doc['borrowedFrom'],
          returnedBy: doc['returnedBy'],
          position: doc['position'],
          date: (doc['date'] as Timestamp).toDate(), itemId: '', userId: '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  // Delete Borrowing Transaction
  Future<bool> deleteBorrowingTransaction(String transactionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('borrowing_transactions')
          .doc(transactionId)
          .delete();
      return true;
    } catch (e) {
      print("Error deleting transaction: $e");
      return false;
    }
  }

// ================================
  // Room Equipment Methods
  // ================================
  Future<List<RoomEquipment>> getRoomEquipments() async {
    try {
      final snapshot = await roomEquipmentsCollection.get();
      return snapshot.docs.map((doc) {
        return RoomEquipment.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching room equipments: $e');
      return [];
    }
  }

  Future<void> addRoomEquipment(RoomEquipment equipment) async {
    try {
      await roomEquipmentsCollection.add(equipment.toMap());
    } catch (e) {
      print('Error adding room equipment: $e');
    }
  }

  Future<void> updateRoomEquipment(RoomEquipment equipment) async {
    try {
      await roomEquipmentsCollection.doc(equipment.id).update(equipment.toMap());
    } catch (e) {
      print('Error updating room equipment: $e');
    }
  }

  Future<void> deleteRoomEquipment(String equipmentId) async {
    try {
      // Assuming you have a collection named "equipment" in Firestore
      await _db.collection('equipment').doc(equipmentId).delete();
    } catch (e) {
      throw Exception('Error deleting equipment: $e');
    }
  }

  // ================================
  // Brand Methods
  // ================================
  Future<List<Brand>> getBrands() async {
    try {
      final snapshot = await brandsCollection.get();
      return snapshot.docs.map((doc) {
        return Brand.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching brands: $e');
      return [];
    }
  }

  Future<void> addBrand(Brand brand) async {
    try {
      await brandsCollection.doc(brand.id).set(brand.toMap());
    } catch (e) {
      print('Error adding brand: $e');
    }
  }

  Future<void> updateBrand(Brand brand) async {
    try {
      await brandsCollection.doc(brand.id).update(brand.toMap());
    } catch (e) {
      print('Error updating brand: $e');
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      await brandsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting brand: $e');
    }
  }

  // ================================
  // Room Management Methods
  // ================================
  Future<List<RoomManagement>> fetchRoomManagement() async {
    try {
      final snapshot = await roomManagementCollection.get();
      return snapshot.docs.map((doc) {
        return RoomManagement.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching room management data: $e');
      return [];
    }
  }

  Future<void> addRoomManagement(RoomManagement roomManagement) async {
    try {
      await roomManagementCollection.doc(roomManagement.id).set(roomManagement.toMap());
    } catch (e) {
      print('Error adding room management: $e');
    }
  }

  Future<void> updateRoomManagement(RoomManagement roomManagement) async {
    try {
      await roomManagementCollection
          .doc(roomManagement.id)
          .update(roomManagement.toMap());
    } catch (e) {
      print('Error updating room management: $e');
    }
  }

  Future<void> deleteRoomManagement(String roomId) async {
    try {
      // Assuming you have a collection named "rooms" in Firestore
      await _db.collection('rooms').doc(roomId).delete();
    } catch (e) {
      throw Exception('Error deleting room: $e');
    }
  }
}

// ================================
// Transfer Methods
// ================================

Future<List<Map<String, dynamic>>> fetchTransfers(dynamic _db) async {
  try {
    QuerySnapshot snapshot = await _db.collection('transfers').get();
    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  } catch (e) {
    print('Error fetching transfers: $e');
    return [];
  }
}

// Add a transfer to Firestore
Future<void> addTransfer(Map<String, dynamic> transferData, dynamic _db) async {
  try {
    await _db.collection('transfers').add(transferData);
    print('Transfer added successfully');
  } catch (e) {
    print('Error adding transfer: $e');
  }
}

// Update a transfer in Firestore
Future<void> updateTransfer(String transferId, Map<String, dynamic> updatedData, dynamic _db) async {
  try {
    await _db.collection('transfers').doc(transferId).update(updatedData);
    print('Transfer updated successfully');
  } catch (e) {
    print('Error updating transfer: $e');
  }
}

// Delete a transfer from Firestore
Future<void> deleteTransfer(String transferId, dynamic _db) async {
  try {
    await _db.collection('transfers').doc(transferId).delete();
    print('Transfer deleted successfully');
  } catch (e) {
    print('Error deleting transfer: $e');
  }
}
