import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class DatabaseService {
  // Reference to the 'products' collection in Firestore
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  // --- CREATE ---
  Future<void> addProduct(Product product) async {
    try {
      // We use toMap() which doesn't include the ID field 
      // because Firestore generates the ID automatically.
      await _products.add(product.toMap());
    } catch (e) {
      print("Error adding product: $e");
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
              doc.id // doc.id is the unique Firestore string
            ),
          )
          .toList(),
    );
  }

  // --- UPDATE ---
  Future<void> updateProduct(Product product) async {
    try {
      // Use the product's own ID to find the document
      await _products.doc(product.id).update(product.toMap());
    } catch (e) {
      print("Error updating product: $e");
      rethrow;
    }
  }

  // --- DELETE ---
  Future<void> deleteProduct(String productId) async {
    try {
      if (productId.isEmpty) throw "Product ID is empty";
      await _products.doc(productId).delete();
    } catch (e) {
      print("Error deleting product: $e");
      rethrow;
    }
  }
}