import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Pastikan sudah add package: http di pubspec.yaml
import 'dart:convert';

// --- IMPORT DATA LOKAL ANDA ---
import '../../data/global_data.dart';
// import '../../models/product.dart'; // Aktifkan jika diperlukan

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  // --- VARIABLE STATE ---
  List<dynamic> combinedHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- 1. LOGIC LOAD DATA (GABUNG API + LOKAL) ---
  Future<void> _loadData() async {
    // Reset data
    combinedHistory.clear();

    // 1. Masukkan Data Lokal (Di-reverse biar yang baru paling atas)
    combinedHistory.addAll(myHistory.reversed);

    // 2. Ambil Data API
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/carts/user/1'),
      );

      if (response.statusCode == 200) {
        List apiData = json.decode(response.body);

        // Tandai data dari API agar UI bisa bedakan
        for (var item in apiData) {
          item['isLocal'] = false;
          // Hitung total dummy untuk API (karena API cart tidak ada harga total)
          item['total'] = 0;
        }

        combinedHistory.addAll(apiData);
      }
    } catch (e) {
      debugPrint("Gagal load API history: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- HELPER FORMAT RUPIAH ---
  String formatRupiah(dynamic price) {
    try {
      double value = 0;
      if (price is int) value = price.toDouble();
      if (price is double) value = price;
      if (price is String) value = double.tryParse(price) ?? 0;

      return "Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp 0";
    }
  }

  // --- 2. LOGIC HAPUS RIWAYAT ---
  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Riwayat"),
        content: const Text("Hapus semua catatan transaksi lokal?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                myHistory.clear(); // Hapus data global
                _loadData(); // Reload ulang (API tetap ada, lokal hilang)
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Riwayat lokal berhasil dihapus")),
              );
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

  // --- 3. LOGIC DETAIL POPUP ---
  void _showDetail(dynamic order) {
    bool isLocal =
        order['isLocal'] ?? true; // Default true jika tidak ada key isLocal
    List items = isLocal ? order['items'] : order['products'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Agar bisa full height jika item banyak
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Detail Barang",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),

                  // LIST ITEM
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: items.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                      itemBuilder: (ctx, i) {
                        var item = items[i];

                        if (isLocal) {
                          // --- TAMPILAN DATA LOKAL (Ada Gambar & Nama) ---
                          // item adalah object CartItem dari global_data.dart
                          return Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.network(
                                  item
                                      .product
                                      .image, // Sesuaikan field model Anda
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${item.quantity} x ${formatRupiah(item.product.price)}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.size,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        } else {
                          // --- TAMPILAN DATA API (Hanya ID & Qty) ---
                          return Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.api,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product ID: ${item['productId']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Qty: ${item['quantity']}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- UI UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmClearHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : combinedHistory.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: combinedHistory.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final order = combinedHistory[index];
                bool isLocal =
                    order['isLocal'] ??
                    true; // Default true jika dari myHistory

                return Container(
                  padding: const EdgeInsets.all(16),
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
                    border: isLocal
                        ? Border.all(color: Colors.green.withOpacity(0.3))
                        : null,
                  ),
                  child: InkWell(
                    onTap: () => _showDetail(order),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Order ID & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: isLocal ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isLocal
                                      ? "Order #${order['orderId'].toString().substring(0, 6)}"
                                      : "Order API #${order['id']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isLocal
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isLocal ? "Selesai" : "Proses",
                                style: TextStyle(
                                  color: isLocal ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),

                        // Content: Date & Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tanggal",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order['date'].toString().substring(0, 10),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Total Belanja",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isLocal)
                                  Text(
                                    formatRupiah(order['total']),
                                    style: const TextStyle(
                                      color: Color(0xFFA50000),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )
                                else
                                  const Text(
                                    "Lihat Detail",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Belum ada riwayat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
