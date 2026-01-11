class Product {
  final String
  id; // Changed from String? to String to ensure delete always has a target
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id, // Now required
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  // Convert Product to a Map for Firestore (usually we don't save the ID inside the document)
  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
  };

  // Convert Firestore Document back to Product object
  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId, // Pass the Document ID from Firestore here
      name: map['name'] ?? 'Unknown Product',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      category: map['category'] ?? 'General',
    );
  }
}
