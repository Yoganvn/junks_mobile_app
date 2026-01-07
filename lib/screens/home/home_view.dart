import 'package:flutter/material.dart';
// Import Service & Model
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/apple_card.dart';

// --- IMPORT CART SAJA (Wishlist & History dihapus dari sini) ---
import '../cart/cart_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final data = await _productService.getProducts();
    if (mounted) {
      setState(() {
        _products = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: const Color(0xFF222222),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),

        // --- HEADER KEMBALI SEPERTI AWAL ---
        appBar: AppBar(
          backgroundColor: const Color(0xFF222222),
          elevation: 0,
          toolbarHeight: 70,
          titleSpacing: 16,
          title: Row(
            children: [
              // 1. Logo Teks
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "SELECTED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "JUNKS.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // 2. Search Bar
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Cari...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 3. ICON KERANJANG (Berfungsi ke CartView)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartView()),
                  );
                },
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              // 4. ICON NOTIFIKASI (Lonceng Saja)
              const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),

        // --- BODY TETAP SAMA ---
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF222222)),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildPromoCarousel()),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "Fresh Drops",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return AppleProductCard(product: _products[index]);
                      }, childCount: _products.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // --- CAROUSEL TIDAK BERUBAH ---
  Widget _buildPromoCarousel() {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: PageView(
        controller: PageController(viewportFraction: 0.85),
        padEnds: false,
        children: [
          _buildBannerItem(
            color: const Color(0xFF8B0000),
            title: "NEW YEAR\nSALE",
            subtitle: "Up to 50% Off",
            imageUrl:
                "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1000&auto=format&fit=crop",
          ),
          _buildBannerItem(
            color: const Color(0xFF222222),
            title: "FREE\nSHIPPING",
            subtitle: "On all orders > IDR 1M",
            imageUrl:
                "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?q=80&w=1000&auto=format&fit=crop",
          ),
          _buildBannerItem(
            color: Colors.blueAccent.shade700,
            title: "NEW\nARRIVALS",
            subtitle: "Check 'em out",
            imageUrl:
                "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?q=80&w=1000&auto=format&fit=crop",
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem({
    required Color color,
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12, left: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: color),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "SHOP NOW",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
}
