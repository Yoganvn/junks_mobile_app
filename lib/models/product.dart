class Product {
  final String id;
  final String name; // Di API: title
  final String brand; // Custom (FakeStore ga punya brand)
  final String price;
  final String imageUrl; // Di API: image
  final String category;
  final String description; // Baru
  final String size; // Baru
  final String condition; // Baru (New/Used)
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.description = "",
    this.size = "All Size",
    this.condition = "Good",
    this.isNew = false,
  });

  // Mapping dari FakeStore API ke Model Kita
  factory Product.fromFakeStore(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['title'] ?? 'No Name',
      brand: "Generic", // FakeStore ga ada brand, kita default aja
      price: "Rp ${(json['price'] * 15000).toStringAsFixed(0)}", // Convert Dollar ke Rupiah
      imageUrl: json['image'] ?? 'https://via.placeholder.com/150',
      category: json['category'] ?? 'General',
      description: json['description'] ?? 'No Description',
      size: "40-44", // Default size buat data dummy API
      condition: "New", // Default kondisi
      isNew: true,
    );
  }
}