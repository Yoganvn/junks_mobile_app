import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../data/global_data.dart';

class CheckoutView extends StatefulWidget {
  final double total;
  const CheckoutView({super.key, required this.total});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final ProductService _service = ProductService();
  Map<String, dynamic>? userAddress;
  bool isLoadingAddress = true;
  bool isPaying = false;
  String selectedPaymentMethod = "Bank Transfer (Virtual Account)";

  // Data Pilihan Pembayaran
  final List<Map<String, dynamic>> paymentOptions = [
    {'name': "Bank Transfer (Virtual Account)", 'icon': Icons.account_balance},
    {'name': "Credit Card", 'icon': Icons.credit_card},
    {'name': "E-Wallet (GoPay/OVO/Dana)", 'icon': Icons.account_balance_wallet},
    {'name': "Cash on Delivery (COD)", 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    try {
      final data = await _service.fetchUserAddress();
      if (mounted) {
        setState(() {
          userAddress = data;
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _processPayment() async {
    setState(() => isPaying = true);
    bool success = await _service.postOrder(widget.total);

    if (mounted) {
      setState(() => isPaying = false);
      if (success) {
        myHistory.add({
          'orderId': "LOKAL-${DateTime.now().millisecondsSinceEpoch}",
          'date': DateTime.now().toString(),
          'total': widget.total,
          'items': List<CartItem>.from(myCart),
          'isLocal': true,
          'paymentMethod': selectedPaymentMethod,
        });
        myCart.clear();
        _showSuccessBottomSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal Checkout"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pembayaran Berhasil!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Metode: $selectedPaymentMethod\nPesanan akan segera diproses.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F1F1F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(
                    "Kembali ke Home",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. ALAMAT PENGIRIMAN ---
                  const Text(
                    "Alamat Pengiriman",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFA50000),
                          size: 30,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isLoadingAddress
                                  ? const Text(
                                      "Loading...",
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : Text(
                                      "${userAddress?['name']['firstname']} ${userAddress?['name']['lastname']}"
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                              const SizedBox(height: 5),
                              isLoadingAddress
                                  ? Container(
                                      height: 10,
                                      width: 100,
                                      color: Colors.grey[200],
                                    )
                                  : Text(
                                      "Jalan ${userAddress?['address']['street']}, Kota ${userAddress?['address']['city']}\nKode Pos: ${userAddress?['address']['zipcode']}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        height: 1.5,
                                        fontSize: 13,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- 2. DAFTAR BARANG (YANG KAMU MINTA) ---
                  const Text(
                    "Daftar Barang",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myCart.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final item = myCart[i];
                      double unitPrice = parsePrice(item.product.price);

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            // Gambar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Info Nama & Qty
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${item.quantity} x ${formatRupiah(unitPrice)}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Total per item
                            Text(
                              formatRupiah(unitPrice * item.quantity),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // --- 3. METODE PEMBAYARAN ---
                  const Text(
                    "Metode Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPaymentMethod,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: paymentOptions.map((Map<String, dynamic> item) {
                          return DropdownMenuItem<String>(
                            value: item['name'],
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'],
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space bawah
                ],
              ),
            ),
          ),

          // --- FIXED BOTTOM BAR ---
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
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Tagihan",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        formatRupiah(widget.total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA50000),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F1F1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isPaying ? null : _processPayment,
                      child: isPaying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Bayar Sekarang",
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
          ),
        ],
      ),
    );
  }
}
