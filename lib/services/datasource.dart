import 'package:cloud_firestore/cloud_firestore.dart';

class DataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUsers() {
    return firestore.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteUser(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updatedData) async {
    await firestore.collection('users').doc(userId).update(updatedData);
  }
}
