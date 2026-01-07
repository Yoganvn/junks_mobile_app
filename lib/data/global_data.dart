import '../models/product.dart'; // Import Model LAMA

// --- 1. MODEL CART ITEM (Baru) ---
class CartItem {
  final Product product; // Pakai Product yang LAMA
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}

// --- 2. VARIABLE GLOBAL (State Management Sederhana) ---
// Ini sesuai request kamu: myCart, myHistory, myWishlist
List<CartItem> myCart = [];
List<Product> myWishlist = [];
List<Map<String, dynamic>> myHistory = [];

// --- 3. HELPER (PENTING) ---
// Karena Product lama harganya String ("Rp 3.500.000"), 
// kita butuh alat convert biar bisa dihitung di Keranjang.

// Ubah "Rp 3.500.000" jadi angka 3500000.0
double parsePrice(String priceString) {
  try {
    String clean = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.parse(clean);
  } catch (e) {
    return 0.0;
  }
}

// Ubah angka 3500000.0 jadi "Rp. 3.500.000" (Format Code Kamu)
String formatRupiah(double price) {
  return "Rp. ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
}