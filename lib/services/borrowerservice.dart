// // services/borrower_service.dart
// import 'package:capstonesproject2024/model/borrower.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class BorrowerService {
//   final CollectionReference borrowersCollection =
//       FirebaseFirestore.instance.collection('borrowers');

//   Future<void> addBorrower(Borrower borrower) async {
//     try {
//       await borrowersCollection.add(borrower.toMap());
//     } catch (e) {
//       print('Error adding borrower: $e');
//     }
//   }

//   Future<List<Borrower>> getBorrowers() async {
//     try {
//       final snapshot = await borrowersCollection.get();
//       return snapshot.docs
//           .map((doc) =>
//               Borrower.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       print('Error fetching borrowers: $e');
//       return [];
//     }
//   }

//   Future<void> deleteBorrower(String id) async {
//     try {
//       await borrowersCollection.doc(id).delete();
//     } catch (e) {
//       print('Error deleting borrower: $e');
//     }
//   }

//   Future<void> returnBorrower(
//       String id, DateTime returnedAt, String receivedBy) async {
//     try {
//       await borrowersCollection.doc(id).update({
//         'returned': true,
//         'returnedAt': Timestamp.fromDate(returnedAt),
//         'receivedBy': receivedBy,
//       });
//     } catch (e) {
//       print('Error returning borrower: $e');
//     }
//   }
// }
