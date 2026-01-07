import 'package:flutter/material.dart';
import '../../data/global_data.dart'; // Pengganti data.dart
import '../checkout/checkout_view.dart'; // Pengganti checkout.dart

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  // --- LOGIC AREA ---

  // Menghitung Subtotal
  // Kita pakai 'parsePrice' karena harga di database lama bentuknya String "Rp..."
  double get subtotal => myCart.fold(
    0,
    (sum, item) => sum + (parsePrice(item.product.price) * item.quantity),
  );

  final double shippingCost = 20000;
  final double voucherDiscount = 0;

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Yakin ingin menghapus produk ini dari keranjang?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => myCart.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  // --- END LOGIC AREA ---

  // --- UI AREA (TAMPILAN SESUAI REQUEST) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Background abu sangat muda (Clean)
      appBar: AppBar(
        title: const Text(
          "Keranjang",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: myCart.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // --- LIST ITEM KERANJANG ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: myCart.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final item = myCart[index];
                      // Ambil harga angka untuk perhitungan tampilan
                      double unitPrice = parsePrice(item.product.price);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  item
                                      .product
                                      .imageUrl, // Connected: image -> imageUrl
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // Info Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item
                                              .product
                                              .name, // Connected: title -> name
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      // Tombol Hapus Kecil
                                      InkWell(
                                        onTap: () => _confirmDelete(index),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${item.size} • ${item.color}",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Harga & Quantity Control
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatRupiah(unitPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                            0xFFA50000,
                                          ), // Merah Elegan
                                          fontSize: 15,
                                        ),
                                      ),
                                      // Quantity Counter Modern
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            _buildQtyBtn(Icons.remove, () {
                                              if (item.quantity > 1) {
                                                setState(() => item.quantity--);
                                              }
                                            }),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Text(
                                                "${item.quantity}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _buildQtyBtn(Icons.add, () {
                                              setState(() => item.quantity++);
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- BOTTOM SUMMARY SECTION ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _rowSummary("Subtotal Produk", subtotal),
                      const SizedBox(height: 8),
                      _rowSummary("Pengiriman", shippingCost),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _rowSummary(
                        "Total Pembayaran",
                        subtotal + shippingCost - voucherDiscount,
                        isBold: true,
                        isTotal: true,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF1F1F1F,
                            ), // Hitam (Modern)
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutView(
                                  // Connected: CheckoutView
                                  total: subtotal + shippingCost,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Checkout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Keranjang Anda Kosong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Ayo cari barang kesukaanmu!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Widget Tombol Qty Kecil
  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  // Widget Baris Ringkasan Harga
  Widget _rowSummary(
    String label,
    double val, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          formatRupiah(val),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? const Color(0xFFA50000) : Colors.black,
          ),
        ),
      ],
    );
  }
}
