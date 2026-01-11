import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // REQUIRED for debugPrint
import '../models/product_model.dart';

class DatabaseService {
  // Reference to the 'products' collection in Firestore
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  // --- CREATE ---
  Future<void> addProduct(Product product) async {
    try {
      // Firestore generates the ID automatically
      await _products.add(product.toMap());
    } catch (e) {
      debugPrint(
        "Error adding product: $e",
      ); // Changed from print to debugPrint
      rethrow;
    }
  }

  // --- READ (Real-time Stream) ---
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Product.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id, // Extracts the unique Firestore string
            ),
          )
          .toList(),
    );
  }

  // --- UPDATE ---
  Future<void> updateProduct(Product product) async {
    try {
      // Targets the specific document by its stored ID
      await _products.doc(product.id).update(product.toMap());
    } catch (e) {
      debugPrint("Update Error: $e"); // Fixed debugPrint error
      rethrow;
    }
  }

  // --- DELETE ---
  Future<void> deleteProduct(String productId) async {
    try {
      if (productId.isEmpty) throw "Product ID is empty";
      await _products.doc(productId).delete();
    } catch (e) {
      debugPrint(
        "Error deleting product: $e",
      ); // Changed from print to debugPrint
      rethrow;
    }
  }
}
