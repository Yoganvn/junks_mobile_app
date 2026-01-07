import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Request HTTP
import 'dart:convert'; // Untuk decode JSON

import '../../models/product.dart';
import '../../data/global_data.dart'; // PENTING: Import ini agar bisa pakai formatRupiah & parsePrice
import '../cart/cart_view.dart';
import '../profile/wishlist_view.dart';
import '../profile/history_view.dart';

class DetailView extends StatefulWidget {
  final Product product;
  const DetailView({super.key, required this.product});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  String? selectedSize;
  String? selectedColor;
  bool isFavorite = false;

  // Variable untuk data API
  String? apiDescription;
  bool isLoadingApi = true;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Navy', 'Brown', 'Black', 'White'];

  @override
  void initState() {
    super.initState();
    // Cek status wishlist lokal
    isFavorite = myWishlist.any((item) => item.id == widget.product.id);

    // Panggil HTTP Request saat halaman dibuka
    _fetchProductDetail();
  }

  // --- HTTP REQUEST (GET DETAIL PRODUCT) ---
  Future<void> _fetchProductDetail() async {
    try {
      final url = Uri.parse(
        'https://fakestoreapi.com/products/${widget.product.id}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            apiDescription = data['description'];
            isLoadingApi = false;
          });
        }
      } else {
        throw Exception("Gagal load detail");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingApi = false;
        });
      }
    }
  }

  void _toggleWishlist() {
    setState(() {
      if (isFavorite) {
        myWishlist.removeWhere((item) => item.id == widget.product.id);
        isFavorite = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dihapus dari Wishlist"),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        myWishlist.add(widget.product);
        isFavorite = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ditambahkan ke Wishlist"),
            backgroundColor: Colors.pink,
          ),
        );
      }
    });
  }

  void _addToCart() {
    if (selectedSize == null || selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih Size dan Warna dulu!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      myCart.add(
        CartItem(
          product: widget.product,
          size: selectedSize!,
          color: selectedColor!,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Berhasil masuk keranjang!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR BERSIH ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR + TOMBOL WISHLIST ---
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: double.infinity,
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Hero(
                    tag: widget.product.id,
                    child: Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FloatingActionButton.small(
                    heroTag: "btn_wishlist",
                    backgroundColor: Colors.white,
                    elevation: 3,
                    onPressed: _toggleWishlist,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pink : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Info Produk
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            // --- PERBAIKAN HARGA (PAKAI FORMATTER GLOBAL) ---
            Text(
              formatRupiah(parsePrice(widget.product.price.toString())),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA50000),
              ),
            ),

            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isLoadingApi)
                  const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              apiDescription ?? widget.product.description,
              style: TextStyle(height: 1.6, color: Colors.grey[600]),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // Dropdown
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Size",
                    sizes,
                    selectedSize,
                    (val) => setState(() => selectedSize = val),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDropdown(
                    "Color",
                    colors,
                    selectedColor,
                    (val) => setState(() => selectedColor = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // Tombol Beli
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text(
              "Masukkan Keranjang",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          hint: const Text("Pilih"),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
