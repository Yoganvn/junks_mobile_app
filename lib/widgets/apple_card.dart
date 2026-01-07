import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/global_data.dart'; // Penting: Untuk akses fungsi 'formatRupiah'
import '../screens/detail/detail_view.dart'; // Penting: Pastikan path ini sesuai dengan file detail kamu

class AppleProductCard extends StatelessWidget {
  final Product product;

  const AppleProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke Halaman Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            // Pastikan class ini bernama 'DetailView' sesuai file detail_view.dart
            builder: (context) => DetailView(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Bagian Gambar ---
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF2F2F7), // Abu-abu Apple style
                  padding: const EdgeInsets.all(12),
                  child: Hero(
                    // Tag Hero untuk animasi transisi mulus
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. Bagian Teks Info ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),

                  // Nama Produk
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Harga (Pakai formatRupiah dari global_data.dart)
                  Text(
                    formatRupiah(parsePrice(product.price)),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
