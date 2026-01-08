import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/chat_item.dart';

class ProductService {
  // Simpan data di memory biar barang yg BARU DIJUAL muncul di Home
  static List<Product> _localCache = [];

  // --- REQUEST 1: GET Products (Real API) ---
  Future<List<Product>> getProducts() async {
    if (_localCache.isNotEmpty) return _localCache;

    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<Product> apiProducts = body
            .map((dynamic item) => Product.fromFakeStore(item))
            .toList();
        _localCache = apiProducts;
        return _localCache;
      } else {
        throw Exception('Gagal load data API');
      }
    } catch (e) {
      return [];
    }
  }

  // --- REQUEST 2: GET Categories (Real API - Dulu Dummy) ---
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<String> categories = body.cast<String>();
        return ["All", ...categories];
      }
    } catch (e) {
      print("Error getCategories: $e");
    }
    return [
      "All",
      "electronics",
      "jewelery",
      "men's clothing",
      "women's clothing",
    ];
  }

  // --- REQUEST 3: POST Product (Real API - Jual Barang) ---
  Future<Product?> addProduct({
    required String name,
    required String price,
    required String description,
    required String category,
    required String size,
    required String condition,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fakestoreapi.com/products'),
        body: jsonEncode({
          'title': name,
          'price': double.parse(price),
          'description': description,
          'image': 'https://i.pravatar.cc',
          'category': category,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Product newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          brand: "Local Seller",
          price: "Rp ${double.parse(price) * 15000}",
          imageUrl:
              "https://images.unsplash.com/photo-1549298916-b41d501d3772?q=80&w=1000&auto=format&fit=crop",
          category: category,
          description: description,
          size: size,
          condition: condition,
          isNew: condition == "Brand New",
        );
        _localCache.insert(0, newProduct);
        return newProduct;
      }
    } catch (e) {
      print("Error upload: $e");
    }
    return null;
  }

  // --- REQUEST 4: GET Sell Categories  ---
  Future<List<String>> getSellCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.cast<String>();
      }
    } catch (e) {
      print("Error getSellCategories: $e");
    }
    return ["electronics", "jewelery", "men's clothing", "women's clothing"];
  }

  // --- REQUEST 5: GET Chat List (Real API - User Data) ---
  Future<List<ChatItem>> getChats() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/users'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);

        return body.map((user) {
          return ChatItem(
            id: user['id'].toString(),
            // Ambil nama dari API User
            name: "${user['name']['firstname']} ${user['name']['lastname']}"
                .toUpperCase(),
            message: "Halo kak, barang ini ready?",
            time: "Baru saja",
            avatarUrl: "https://i.pravatar.cc/150?u=${user['id']}",
            unreadCount: (user['id'] as int) % 2,
          );
        }).toList();
      }
    } catch (e) {
      print("Error getChats: $e");
    }
    return [];
  }

  //req http upe
  // Request 1: Ambil Alamat User (Simulasi Checkout)
  Future<Map<String, dynamic>> fetchUserAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/users/1'),
      );
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
          'products': [
            {'productId': 1, 'quantity': 1},
          ], // Dummy
        }),
      );
      // FakeStore selalu return 200
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
