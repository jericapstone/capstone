import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstonesproject2024/models.dart' as models;

class BrandDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference brandsCollection = FirebaseFirestore.instance.collection('brands');

  // Fetch brands from Firestore
  Future<List<models.Brand>> getBrands() async {
    QuerySnapshot querySnapshot = await brandsCollection.get();
    return querySnapshot.docs.map((doc) {
      return models.Brand(
        id: doc.id,
        name: doc['name'],
        description: doc['description'],
      );
    }).toList();
  }

  // Add a new brand to Firestore
  Future<void> addBrand(models.Brand brand) async {
    await brandsCollection.doc(brand.id).set({
      'name': brand.name,
      'description': brand.description,
    });
  }

  // Delete a brand from Firestore
  Future<void> deleteBrand(String id) async {
    await brandsCollection.doc(id).delete();
  }
}
