class Product {
  final int? id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.category = 'Umum',
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image_url': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? 'Umum',
      imageUrl: map['image_url'] ?? '',
    );
  }
}