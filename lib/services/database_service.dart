import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class DatabaseService {
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  // CREATE
  Future<void> addProduct(Product product) async {
    try {
      await _products.add(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // READ (Real-time Stream)
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                Product.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  // UPDATE - Target specific document ID
  Future<void> updateProduct(Product product) async {
    try {
      await _products.doc(product.id).update(product.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteProduct(String productId) async {
    try {
      if (productId.isEmpty) throw "Product ID is empty";
      await _products.doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
