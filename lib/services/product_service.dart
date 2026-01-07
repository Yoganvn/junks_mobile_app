import 'dart:convert';
import 'package:http/http.dart' as http; // Panggil package http
import '../models/product.dart';
import '../models/chat_item.dart'; // [BARU] Jangan lupa import ini!

class ProductService {
  // TRIK: Simpan data di memory biar barang yg BARU DIJUAL muncul di Home
  // (Karena FakeStore API aslinya ga nyimpen data kita)
  static List<Product> _localCache = []; 

  // --- REQUEST 1: GET Products (Real API) ---
  Future<List<Product>> getProducts() async {
    // Kalau cache sudah ada isinya (misal abis tambah barang), pakai yg di cache aja
    if (_localCache.isNotEmpty) {
      return _localCache;
    }

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        // Masukkan data API ke Cache
        List<Product> apiProducts = body.map((dynamic item) => Product.fromFakeStore(item)).toList();
        _localCache = apiProducts; 
        return _localCache;
      } else {
        throw Exception('Gagal load data API');
      }
    } catch (e) {
      // Fallback kalau internet mati, balikin list kosong biar ga crash
      return [];
    }
  }

  // --- REQUEST 2: GET Categories (Untuk Tab Home) ---
  Future<List<String>> getCategories() async {
    // Kita hardcode aja biar UI-nya bagus sesuai tema Junks
    await Future.delayed(const Duration(seconds: 1));
    return ["All", "Men's Clothing", "Jewelery", "Electronics", "Women's Clothing"];
  }

  // --- REQUEST 3: POST Product (Jual Barang) ---
  Future<Product?> addProduct({
    required String name, 
    required String price, 
    required String description,
    required String category,
    required String size,
    required String condition
  }) async {
    try {
      // Kirim ke FakeStore API
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/products'),
        body: jsonEncode({
          'title': name,
          'price': double.parse(price),
          'description': description,
          'image': 'https://i.pravatar.cc', // Placeholder image karena gausah upload
          'category': category
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // SUKSES! Bikin object Product baru secara manual
        // Gambar kita set statis sepatu keren, biar pas muncul di Home ganteng
        Product newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unik dari waktu
          name: name,
          brand: "Local Seller",
          price: "Rp ${double.parse(price) * 15000}", // Format Rupiah
          imageUrl: "https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop", // Gambar Sepatu Default
          category: category,
          description: description,
          size: size,
          condition: condition,
          isNew: condition == "Brand New",
        );

        // MASUKKAN KE CACHE PALING ATAS (Biar muncul di Home)
        _localCache.insert(0, newProduct);
        
        return newProduct;
      }
    } catch (e) {
      print("Error upload: $e");
    }
    return null;
  }

  // --- REQUEST 4: GET Sell Categories (Untuk Dropdown Halaman Jual) ---
  Future<List<String>> getSellCategories() async {
    await Future.delayed(const Duration(seconds: 1));
    return ["electronics", "jewelery", "men's clothing", "women's clothing"];
  }

  // --- REQUEST 5: GET Chat List (Simulasi API Chat) ---
  // [BARU] Ini adalah Step 2 yang kamu minta
  Future<List<ChatItem>> getChats() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading

    // Data Dummy JSON
    final List<Map<String, dynamic>> dummyChat = [
      {
        "id": "1",
        "name": "Admin Selected Junks",
        "message": "Halo, pesanan Jordan kamu sudah dikirim ya!",
        "time": "Baru saja",
        "avatarUrl": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
        "unreadCount": 2
      },
      {
        "id": "2",
        "name": "Budi Santoso",
        "message": "Mas, sepatu converse-nya masih ada?",
        "time": "10:30",
        "avatarUrl": "https://i.pravatar.cc/150?img=11",
        "unreadCount": 0
      },
      {
        "id": "3",
        "name": "Siti Aminah",
        "message": "Bisa nego tipis ga gan?",
        "time": "Kemarin",
        "avatarUrl": "https://i.pravatar.cc/150?img=5",
        "unreadCount": 1
      },
      {
        "id": "4",
        "name": "JNE Express",
        "message": "Paket anda sedang dalam pengantaran.",
        "time": "Kemarin",
        "avatarUrl": "https://yt3.googleusercontent.com/ytc/AIdro_nK5o_W5QW_9-yV92x9X2X_Z_Z_Z_Z_Z_Z_Z_Z=s900-c-k-c0x00ffffff-no-rj",
        "unreadCount": 0
      },
    ];

    return dummyChat.map((json) => ChatItem.fromJson(json)).toList();
  }
    //req http upe
  // Request 1: Ambil Alamat User (Simulasi Checkout)
  Future<Map<String, dynamic>> fetchUserAddress() async {
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/users/1'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error address: $e");
    }
    return {};
  }

  // Request 2: Kirim Order (Checkout)
  Future<bool> postOrder(double total) async {
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/carts'),
        body: jsonEncode({
          'userId': 1,
          'date': DateTime.now().toString(),
          'products': [{'productId': 1, 'quantity': 1}] // Dummy
        }),
      );
      // FakeStore selalu return 200
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

