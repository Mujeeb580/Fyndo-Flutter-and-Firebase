class Product {
  final String id;
  final String name;
  final String description; // Added
  final double price;
  final String imageUrl;
  final String category;
  final int stock; // Added

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
    'stock': stock,
  };

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      name: map['name'] ?? 'Unknown',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'General',
      stock: (map['stock'] ?? 1).toInt(),
    );
  }
}
