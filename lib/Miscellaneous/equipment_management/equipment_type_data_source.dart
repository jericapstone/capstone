import 'package:capstonesproject2024/services/firestore_service.dart';
import 'package:capstonesproject2024/models.dart';

class EquipmentTypeDataSource {
  final FirestoreService firestoreService;

  EquipmentTypeDataSource({required this.firestoreService});

  // Fetch all equipment types from Firestore
  Future<List<String>> fetchEquipmentTypes() async {
    try {
      return await firestoreService.getEquipmentTypes();
    } catch (e) {
      throw Exception("Failed to load equipment types: $e");
    }
  }

  // Add a new equipment type to Firestore
  Future<void> addEquipmentType(String id, String name, String description) async {
    try {
      await firestoreService.addEquipmentType(id as String, name, description);
    } catch (e) {
      throw Exception("Failed to add equipment type: $e");
    }
  }

  // Edit an existing equipment type in Firestore
  Future<void> editEquipmentType(String id, String name, String description) async {
    try {
      await firestoreService.updateEquipmentType(id as String, name, description);
    } catch (e) {
      throw Exception("Failed to edit equipment type: $e");
    }
  }

  // Delete an equipment type from Firestore
  Future<void> deleteEquipmentType(String id) async {
    try {
      await firestoreService.deleteEquipmentType(id);
    } catch (e) {
      throw Exception("Failed to delete equipment type: $e");
    }
  }
}
