import 'package:flutter/material.dart';
import '../../services/product_service.dart';

class SellView extends StatefulWidget {
  const SellView({super.key});

  @override
  State<SellView> createState() => _SellViewState();
}

class _SellViewState extends State<SellView> {
  final ProductService _productService = ProductService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  // State
  String? _selectedCategory;
  String _selectedCondition = "Brand New"; // Default Condition
  final List<String> _conditions = ["Brand New", "Like New", "Good", "Fair"];
  // Kategori hardcode biar cepet (sesuai FakeStore)
  final List<String> _categories = [
    "electronics",
    "jewelery",
    "men's clothing",
    "women's clothing",
  ];

  bool _isUploading = false;

  void _handleSubmit() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi semua data!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dialog Konfirmasi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Tayang"),
        content: Text(
          "Jual ${_nameController.text}?\nKondisi: $_selectedCondition",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
            ),
            onPressed: () {
              Navigator.pop(context);
              _uploadData();
            },
            child: const Text(
              "Ya, Jual",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadData() async {
    setState(() => _isUploading = true);

    // Panggil Service Add Product
    final newProduct = await _productService.addProduct(
      name: _nameController.text,
      price: _priceController.text,
      description: _descController.text,
      category: _selectedCategory!,
      size: _sizeController.text,
      condition: _selectedCondition,
    );

    if (mounted) {
      setState(() => _isUploading = false);

      if (newProduct != null) {
        // Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Barang berhasil tayang di Home!"),
            backgroundColor: Colors.green,
          ),
        );
        // Reset Form
        _nameController.clear();
        _priceController.clear();
        _descController.clear();
        _sizeController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal upload, cek internet."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR DIGANTI JADI CLEAN WHITE (Sesuai Chat/Profile) ---
      appBar: AppBar(
        backgroundColor: Colors.white, // Jadi Putih
        elevation: 0, // Flat
        centerTitle: true,
        title: const Text(
          "Jual Barang",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ), // Teks Hitam
        ),
        // (Opsional) Icon di pojok kanan kalau mau reset form
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _nameController.clear();
              _priceController.clear();
              _descController.clear();
              _sizeController.clear();
            },
          ),
        ],
      ),

      // -------------------------------------------------------------
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF222222)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. FOTO (Dummy - Gausah Database)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Foto akan digenerate otomatis",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. FORM INPUT
                  _buildLabel("Nama Produk"),
                  _buildInput("Contoh: Nike Jordan...", _nameController),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Harga (USD)"),
                            _buildInput(
                              "100",
                              _priceController,
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Size"),
                            _buildInput("42", _sizeController, isNumber: true),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("Kategori"),
                  _buildDropdown(
                    value: _selectedCategory,
                    hint: "Pilih Kategori",
                    items: _categories,
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("Kondisi Barang"),
                  _buildDropdown(
                    value: _selectedCondition,
                    hint: "Pilih Kondisi",
                    items: _conditions,
                    onChanged: (val) =>
                        setState(() => _selectedCondition = val!),
                  ),

                  const SizedBox(height: 16),
                  _buildLabel("Deskripsi Lengkap"),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Jelaskan minus, kelengkapan, dll...",
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF222222),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "TAYANGKAN SEKARANG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // WIDGET HELPERS
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildInput(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
